/// Application environment flavors.
///
/// Selected at compile time via `--dart-define=ENV=prod` or `--dart-define=ENV=uat`.
/// Defaults to [AppEnvironment.uat] when not specified.
enum AppEnvironment {
  prod,
  uat;

  static AppEnvironment fromName(String name) {
    switch (name.toLowerCase()) {
      case 'prod':
      case 'production':
        return AppEnvironment.prod;
      case 'uat':
      default:
        return AppEnvironment.uat;
    }
  }

  bool get isProd => this == AppEnvironment.prod;
  bool get isUat => this == AppEnvironment.uat;
}

/// Logical backend services. Each may live on a *different* base URL per
/// environment (e.g. login on one host, loan-register on another), so they are
/// configured independently. Add new services here as features are built.
enum ApiService {
  /// OTP send service (login).
  otp,

  /// ThaiID identity verification service.
  thaid,
  // Example future services (give them their own base URL + headers):
  // loanRegister,
  // loanDetail,
}

/// A single backend endpoint: base URL plus the headers it requires.
class ServiceEndpoint {
  const ServiceEndpoint({required this.baseUrl, this.headers = const {}});

  final String baseUrl;
  final Map<String, String> headers;
}

/// Per-environment configuration.
///
/// API endpoints are kept in a per-[ApiService] registry so that, for example,
/// prod login and prod loan-register can sit on different base URLs. Replace
/// the placeholder URLs/keys with the real per-environment values as they are
/// provided.
class EnvConfig {
  const EnvConfig({
    required this.environment,
    required this.firebaseProjectId,
    required this.services,
    required this.banner,
    required this.webBaseUrl,
  });

  final AppEnvironment environment;
  final String firebaseProjectId;

  /// Base URL of the Firebase Hosting site for this environment. Hybrid web
  /// features (loaded in an in-app webview) are served from here, so the
  /// business can update those flows by redeploying Hosting — no app release.
  final String webBaseUrl;

  /// Registry of backend endpoints, one entry per [ApiService].
  final Map<ApiService, ServiceEndpoint> services;

  /// Banner text shown in every AppBar (empty in prod).
  final String banner;

  bool get showBanner => banner.isNotEmpty;

  /// Endpoint for a given service. Throws if a service is requested before it
  /// has been configured for this environment (fail-fast in development).
  ServiceEndpoint endpoint(ApiService service) {
    final e = services[service];
    if (e == null) {
      throw StateError(
        'No endpoint configured for $service in $environment environment.',
      );
    }
    return e;
  }

  // --- Shared endpoints (same for prod & uat for now) -----------------------
  // OTP and ThaiID currently use the same host in both environments per the
  // provided api-call.txt. Split these per environment when real values arrive.
  static const ServiceEndpoint _otp = ServiceEndpoint(
    baseUrl: 'https://mobile-api.swpfin.com',
    headers: {'x-srisawad': 'x1'},
  );
  static const ServiceEndpoint _thaid = ServiceEndpoint(
    baseUrl: 'https://dev.swpfin.com:8091',
    headers: {
      'x-api-key':
          '2f0eb52722ecbf228a4e44d9e14c600b9c4b2f65020484300839e799f58177b0',
    },
  );

  static const EnvConfig _prod = EnvConfig(
    environment: AppEnvironment.prod,
    firebaseProjectId: 'sawad-finnix',
    webBaseUrl: 'https://sawad-finnix.web.app',
    services: {
      ApiService.otp: _otp,
      ApiService.thaid: _thaid,
      // TODO: add prod-specific services on their own base URLs, e.g.
      // ApiService.loanRegister: ServiceEndpoint(baseUrl: 'https://base-url2.com'),
    },
    banner: '',
  );

  static const EnvConfig _uat = EnvConfig(
    environment: AppEnvironment.uat,
    firebaseProjectId: 'sawad-finnix-uat',
    webBaseUrl: 'https://sawad-finnix-uat.web.app',
    services: {
      ApiService.otp: _otp,
      ApiService.thaid: _thaid,
      // TODO: add uat-specific services on their own base URLs.
    },
    banner: 'UAT Ver 1',
  );

  /// Resolves the active config from the `ENV` dart-define (defaults to uat).
  static EnvConfig resolve() {
    const envName = String.fromEnvironment('ENV', defaultValue: 'uat');
    return forEnvironment(AppEnvironment.fromName(envName));
  }

  static EnvConfig forEnvironment(AppEnvironment env) {
    switch (env) {
      case AppEnvironment.prod:
        return _prod;
      case AppEnvironment.uat:
        return _uat;
    }
  }
}
