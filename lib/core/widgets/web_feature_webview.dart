// Reusable in-app webview component for hybrid "web feature" flows.
//
// Hosts a Flutter-web build (served from Firebase Hosting) inside an
// InAppWebView and bridges its requests to native capabilities. Adapted from
// the srisawad universal-webview component, but made **web-safe**: it uses
// `defaultTargetPlatform`/`kIsWeb` instead of `dart:io`, so the same codebase
// still compiles for `flutter build web`.
//
// ## Bridge protocol
//
// The embedded web build talks to the host via `flutter_inappwebview` handlers:
//
//   WEB -> NATIVE (camera/OCR), awaits a base64 data URL back:
//     const dataUrl =
//       await window.flutter_inappwebview.callHandler('openCamera', action);
//     // action = mask type, e.g. 'idcard' | 'selfie' | 'document'
//     // returns 'data:<mime>;base64,<...>' or null (cancelled)
//
//   WEB -> NATIVE (close this host page):
//     window.flutter_inappwebview.callHandler('closeWebview');
//
//   NATIVE -> WEB (recovered capture after an Android process kill):
//     window.dispatchEvent(new CustomEvent('onRecoveredCapture',
//       { detail: { dataBase64: '<dataUrl>' } }));

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:url_launcher/url_launcher.dart';

class WebFeatureWebview extends StatefulWidget {
  const WebFeatureWebview({
    super.key,
    required this.webUrl,
    required this.onFinishedLoading,
    required this.closeWebviewAction,
  });

  /// URL of the Flutter-web build to embed (built via [WebFeatures]).
  final String webUrl;

  /// Called with `true` when the webview is created/loading and `false` once
  /// the embedded web build has finished loading (so the host can drop its
  /// loading overlay).
  final Future<void> Function(bool isLoading) onFinishedLoading;

  /// Called when the embedded web build asks to close this host page.
  final Future<void> Function() closeWebviewAction;

  @override
  State<WebFeatureWebview> createState() => _WebFeatureWebviewState();
}

class _WebFeatureWebviewState extends State<WebFeatureWebview>
    with WidgetsBindingObserver {
  InAppWebViewController? _controller;

  /// Whether the web build has finished its initial load (so it is safe to
  /// push a recovered capture into it).
  bool _webLoaded = false;

  /// A capture recovered via `retrieveLostData()` waiting for the web to be
  /// ready before we push it in.
  String? _pendingRecoveredDataUrl;

  /// JS handler the web build calls to capture a photo (document/OCR/selfie).
  static const String _kOpenCameraHandler = 'openCamera';

  /// JS handler the web build calls to close this host page.
  static const String _kCloseWebviewHandler = 'closeWebview';

  /// True only on a real Android device build (never on web).
  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Cold start: the app may have been killed mid-capture last time.
    WidgetsBinding.instance.addPostFrameCallback((_) => _recoverLostImage());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Returning after the system camera (and a possible process kill) — try to
    // recover a capture that never made it back.
    if (state == AppLifecycleState.resumed) {
      _recoverLostImage();
    }
  }

  /// Android-only: recovers a photo captured while our activity was destroyed
  /// (`image_picker.retrieveLostData()`). The original `openCamera` request is
  /// gone after a kill, so the recovered image is **pushed** into the web.
  Future<void> _recoverLostImage() async {
    if (!_isAndroid) return; // retrieveLostData is Android-only
    try {
      final LostDataResponse response = await ImagePicker().retrieveLostData();
      if (response.isEmpty || response.file == null) return;
      final dataUrl = await _convertImageToString(response.file);
      if (dataUrl.isEmpty) return;
      _pendingRecoveredDataUrl = dataUrl;
      await _flushRecoveredImage();
    } catch (_) {
      // Nothing recoverable / plugin not ready -> ignore.
    }
  }

  /// Pushes a recovered capture into the web via an `onRecoveredCapture` window
  /// event once the web build has loaded.
  Future<void> _flushRecoveredImage() async {
    final dataUrl = _pendingRecoveredDataUrl;
    final controller = _controller;
    if (dataUrl == null || controller == null || !_webLoaded) return;
    _pendingRecoveredDataUrl = null;
    // base64 data URLs contain no quotes/backslashes, so direct interpolation
    // is safe.
    await controller.evaluateJavascript(source: """
      window.dispatchEvent(new CustomEvent('onRecoveredCapture', {
        detail: { dataBase64: '$dataUrl' }
      }));
    """);
  }

  /// Encodes [file] as a `data:<mime>;base64,<...>` URL (what the web decodes).
  Future<String> _convertImageToString(XFile? file) async {
    try {
      if (file == null) return '';
      final imageBytes = await file.readAsBytes();
      final lookupType = lookupMimeType(file.path) ?? 'image/jpeg';
      final base64Image = base64Encode(imageBytes);
      return 'data:$lookupType;base64,$base64Image';
    } catch (_) {
      return '';
    }
  }

  /// Opens the **system camera** (`image_picker`) for [action] and returns the
  /// captured file. `selfie` prefers the front lens; everything else the rear.
  Future<XFile?> _openCameraForAction(String action) async {
    final lower = action.toLowerCase();
    return ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 2000,
      maxHeight: 2000,
      imageQuality: 85,
      preferredCameraDevice:
          lower == 'selfie' ? CameraDevice.front : CameraDevice.rear,
      requestFullMetadata: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(widget.webUrl)),
      initialSettings: InAppWebViewSettings(
        mediaPlaybackRequiresUserGesture: false,
        useShouldOverrideUrlLoading: true,
        geolocationEnabled: true,
        cacheEnabled: true,
        clearCache: false,
        javaScriptEnabled: true,
        javaScriptCanOpenWindowsAutomatically: true,
        allowFileAccess: true,
        allowsInlineMediaPlayback: true,
        useHybridComposition: true, // Android
        allowFileAccessFromFileURLs: true,
        allowUniversalAccessFromFileURLs: true,
      ),
      onWebViewCreated: (controller) async {
        _controller = controller;

        // WEB -> NATIVE: document/OCR camera. The web build calls
        // `callHandler('openCamera', action)` and awaits the base64 string.
        controller.addJavaScriptHandler(
          handlerName: _kOpenCameraHandler,
          callback: (args) async {
            final action =
                (args.isNotEmpty && args.first != null) ? '${args.first}' : '';
            final file = await _openCameraForAction(action);
            if (file == null) return null; // cancelled / no image
            final dataUrl = await _convertImageToString(file);
            return dataUrl.isEmpty ? null : dataUrl;
          },
        );

        // WEB -> NATIVE: close this host page.
        controller.addJavaScriptHandler(
          handlerName: _kCloseWebviewHandler,
          callback: (args) async {
            await widget.closeWebviewAction();
            return null;
          },
        );

        await widget.onFinishedLoading(true);
      },
      onLoadStop: (controller, url) async {
        _controller = controller;
        _webLoaded = true;
        // If we recovered a capture before the web was ready, push it now.
        await _flushRecoveredImage();
        // Web build finished loading -> let the host drop its loading overlay.
        await widget.onFinishedLoading(false);
      },
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        final uri = navigationAction.request.url;
        // Launch tel: links externally (the webview itself can't dial).
        if (uri != null && uri.scheme == 'tel') {
          try {
            await launchUrl(uri);
          } catch (e) {
            debugPrint('Could not launch $uri: $e');
          }
          return NavigationActionPolicy.CANCEL;
        }
        return NavigationActionPolicy.ALLOW;
      },
      onGeolocationPermissionsShowPrompt: (controller, origin) async {
        return GeolocationPermissionShowPromptResponse(
          origin: origin,
          allow: true,
          retain: true,
        );
      },
      onPermissionRequest: (controller, request) async {
        // Grant camera/mic/etc. the web build asks for.
        return PermissionResponse(
          resources: request.resources,
          action: PermissionResponseAction.GRANT,
        );
      },
    );
  }
}
