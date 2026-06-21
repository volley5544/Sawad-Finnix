/// Bridge between the finnix **web** build and the native Flutter host that
/// embeds it in a `flutter_inappwebview` WebView (see the mobile side:
/// `lib/core/widgets/web_feature_webview.dart`).
///
/// The document/OCR camera lives on the **native** side (proper camera +
/// framing, OS-level capture, lost-capture recovery). The web build asks for a
/// capture; the native host opens the camera, returns the photo as base64.
///
/// ## Contract with the native host (`flutter_inappwebview` JS handlers)
///
/// The web calls a JavaScript handler and `await`s its result — the captured
/// image comes straight back, no console-log / CustomEvent round trip:
///
/// ```js
/// // injected by flutter_inappwebview inside the WebView:
/// const base64 = await window.flutter_inappwebview.callHandler('openCamera', action);
/// ```
///
/// The finnix native host registers exactly these handlers:
///  - `openCamera`  → opens the camera for `action` (mask type, e.g.
///    `idcard` | `selfie` | `document`) and **returns** the photo as a
///    `data:image/...;base64,` URL (or `null`/`''` when cancelled).
///  - `closeWebview` → pops the host page.
///
/// And, after an Android process-kill mid-capture, the host **pushes** the
/// recovered photo back via a `window` `onRecoveredCapture` event carrying
/// `detail.dataBase64` — see [NativeCameraBridge.listenForRecoveredCapture].
///
/// The implementation is selected at compile time: the js_interop web version
/// when compiling to web, otherwise a no-op stub (so the same code still
/// compiles for the VM / mobile / desktop).
library;

export 'native_bridge_stub.dart'
    if (dart.library.js_interop) 'native_bridge_web.dart';
