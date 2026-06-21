import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'web_feature_webview.dart';

/// Native host page for a hybrid "web feature" flow.
///
/// Renders a full-screen [WebFeatureWebview] (a Flutter-web build served from
/// Firebase Hosting) with a brand close bar and a loading overlay shown until
/// the embedded web build finishes loading. The embedded build can also ask to
/// close this page via the `closeWebview` JS handler.
///
/// This is the thin native shell of the hybrid pattern: business-critical,
/// frequently-changing flows (e.g. the loan request) live on the web so they
/// can be updated by redeploying Hosting — no app-store release. See
/// `WebFeatures` for the URLs.
class WebFeatureWebviewPage extends StatefulWidget {
  const WebFeatureWebviewPage({
    super.key,
    required this.webUrl,
    this.title,
  });

  /// URL of the web build to embed. When null/empty an error message is shown.
  final String? webUrl;

  /// Optional title shown on the close bar.
  final String? title;

  @override
  State<WebFeatureWebviewPage> createState() => _WebFeatureWebviewPageState();
}

class _WebFeatureWebviewPageState extends State<WebFeatureWebviewPage> {
  bool _loading = true;

  void _close() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final url = widget.webUrl;

    return PopScope(
      // Block the system back gesture while the web build is in control; the
      // close bar (or the web's closeWebview handler) is the way out.
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _CloseBar(title: widget.title, onClose: _close),
              Expanded(
                child: (url == null || url.isEmpty)
                    ? const _ErrorView()
                    : Stack(
                        children: [
                          WebFeatureWebview(
                            webUrl: url,
                            onFinishedLoading: (isLoading) async {
                              if (mounted && _loading != isLoading) {
                                setState(() => _loading = isLoading);
                              }
                            },
                            closeWebviewAction: () async => _close(),
                          ),
                          if (_loading) const _LoadingOverlay(),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CloseBar extends StatelessWidget {
  const _CloseBar({required this.title, required this.onClose});

  final String? title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title ?? '',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: onClose,
            icon: const Icon(Icons.close, size: 18),
            label: const Text('ปิดหน้านี้'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      alignment: Alignment.center,
      child: const CircularProgressIndicator(color: AppColors.primary),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'ไม่พบลิงก์สำหรับเปิดหน้านี้',
          style: TextStyle(color: AppColors.textBody, fontSize: 16),
        ),
      ),
    );
  }
}
