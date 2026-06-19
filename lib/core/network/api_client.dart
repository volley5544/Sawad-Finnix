import 'package:dio/dio.dart';

import '../config/env_config.dart';

/// Builds preconfigured [Dio] clients for the backend services.
///
/// Each [ApiService] resolves to its own base URL + headers from the active
/// [EnvConfig], so different features can live on different hosts per
/// environment.
class ApiClient {
  ApiClient(this.config);

  final EnvConfig config;

  /// Dio configured for a specific backend service.
  Dio forService(ApiService service) {
    final endpoint = config.endpoint(service);
    return Dio(
      BaseOptions(
        baseUrl: endpoint.baseUrl,
        headers: {
          'Content-Type': 'application/json',
          ...endpoint.headers,
        },
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        // Don't throw on non-2xx so repositories can map errors explicitly.
        validateStatus: (status) => status != null && status < 500,
      ),
    );
  }

  /// Convenience accessors for the currently-known services.
  Dio otp() => forService(ApiService.otp);
  Dio thaid() => forService(ApiService.thaid);
}
