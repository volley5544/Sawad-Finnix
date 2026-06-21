import '../router/app_routes.dart';
import 'env_config.dart';

/// Frequently-changing product flows that are served as Flutter-web builds on
/// Firebase Hosting and embedded in the mobile app via an in-app webview.
///
/// Hosting these on the web lets the business update the product flow,
/// conditions, copy, etc. and deploy instantly — no app-store release. The
/// native app is just a thin host (see `WebFeatureWebviewPage`).
///
/// The finnix web build uses Flutter's default **hash** URL strategy, so we
/// deep-link straight to the target route via `/#<route>`. This lands the
/// webview directly on the feature route and **bypasses the splash/onboarding
/// gate** (which would otherwise redirect a fresh, unauthenticated web session
/// to the phone step). A `hashThaiId` (sha256 of the Thai national ID) is
/// appended so the web flow can identify the user, mirroring the
/// universal-webview `?hashThaiId=` contract.
class WebFeatures {
  WebFeatures._();

  /// Loan-request multi-step flow (step 1 onward), opened directly on its route.
  static String loanRequest(EnvConfig env, {String? hashThaiId}) {
    return _withHash('${env.webBaseUrl}/#${AppRoutes.loanRequest}', hashThaiId);
  }

  /// Appends `?hashThaiId=` (or `&hashThaiId=`) when a hash is provided.
  static String _withHash(String url, String? hashThaiId) {
    if (hashThaiId == null || hashThaiId.isEmpty) return url;
    final sep = url.contains('?') ? '&' : '?';
    return '$url${sep}hashThaiId=$hashThaiId';
  }
}
