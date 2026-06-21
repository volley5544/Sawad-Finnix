import 'env_config.dart';

/// Frequently-changing product flows that are served as Flutter-web builds on
/// Firebase Hosting and embedded in the mobile app via an in-app webview.
///
/// Hosting these on the web lets the business update the product flow,
/// conditions, copy, etc. and deploy instantly — no app-store release. The
/// native app is just a thin host (see `WebFeatureWebviewPage`).
///
/// ## Why a `?feature=` query param (not a hash route)
///
/// The finnix web build uses Flutter's default **hash** URL strategy, so a
/// route only comes from the URL *fragment*. To open a feature directly and
/// reliably — bypassing the splash/onboarding gate that would otherwise send a
/// fresh, unauthenticated web session to the phone step — we pass the target as
/// a normal query parameter. The web app reads it via `Uri.base` at startup and
/// uses it as the router's `initialLocation` (see `AppRouter`). Query params
/// are always preserved (no fragment/deep-link quirks). `hashThaiId` (sha256 of
/// the Thai national ID) is included so the web flow can identify the user.
class WebFeatures {
  WebFeatures._();

  /// Value of `?feature=` that maps to the loan-request flow.
  static const String loanRequestFeature = 'loan-request';

  /// Loan-request multi-step flow, opened directly (skips splash/onboarding).
  static String loanRequest(EnvConfig env, {String? hashThaiId}) {
    final params = <String, String>{'feature': loanRequestFeature};
    if (hashThaiId != null && hashThaiId.isNotEmpty) {
      params['hashThaiId'] = hashThaiId;
    }
    return Uri.parse(env.webBaseUrl).replace(queryParameters: params).toString();
  }
}
