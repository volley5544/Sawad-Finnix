import 'env_config.dart';

/// Frequently-changing product flows that are served as Flutter-web builds on
/// Firebase Hosting and embedded in the mobile app via an in-app webview.
///
/// Hosting these on the web lets the business update the product flow,
/// conditions, copy, etc. and deploy instantly — no app-store release. The
/// native app is just a thin host (see `WebFeatureWebviewPage`).
///
/// Each helper builds the Hosting URL for one feature. A `hashThaiId`
/// (sha256 of the Thai national ID) is appended so the web build can identify
/// the signed-in user on startup, mirroring the universal-webview
/// `?hashThaiId=` contract.
class WebFeatures {
  WebFeatures._();

  /// Path (under the Hosting site) of the loan-request web flow. Kept as a
  /// constant so the deployed location is documented in one place.
  static const String loanRequestPath = '/loan-request';

  /// Loan-request multi-step flow (step 1 onward), served from Hosting.
  static String loanRequest(EnvConfig env, {String? hashThaiId}) {
    return _withHash('${env.webBaseUrl}$loanRequestPath', hashThaiId);
  }

  /// Appends `?hashThaiId=` (or `&hashThaiId=`) when a hash is provided.
  static String _withHash(String url, String? hashThaiId) {
    if (hashThaiId == null || hashThaiId.isEmpty) return url;
    final sep = url.contains('?') ? '&' : '?';
    return '$url${sep}hashThaiId=$hashThaiId';
  }
}
