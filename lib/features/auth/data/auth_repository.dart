import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../../core/network/api_client.dart';
import '../../../core/router/app_routes.dart';
import '../models/auth_responses.dart';
import '../models/thaid_status.dart';

/// Thrown when an auth API call fails.
class AuthException implements Exception {
  AuthException(this.message);
  final String message;
  @override
  String toString() => 'AuthException: $message';
}

/// Handles OTP and ThaiID API interactions.
class AuthRepository {
  AuthRepository(this._api);

  final ApiClient _api;

  /// Sends an OTP to [phoneNumber]. The response contains the OTP `code`, which
  /// is verified client-side (see [verifyOtp]).
  Future<OtpResponse> sendOtp(String phoneNumber) async {
    try {
      final res = await _api.otp().post(
        '/otp',
        data: {'phone_number': phoneNumber},
      );
      final data = res.data;
      if (res.statusCode == 200 && data is Map) {
        return OtpResponse.fromMap(Map<String, dynamic>.from(data));
      }
      throw AuthException('ส่ง OTP ไม่สำเร็จ (${res.statusCode})');
    } on DioException catch (e) {
      throw AuthException('เชื่อมต่อ OTP ไม่สำเร็จ: ${e.message}');
    }
  }

  /// Client-side OTP verification: the entered code must match the `code`
  /// returned by [sendOtp].
  bool verifyOtp({required String expectedCode, required String input}) {
    return input.trim() == expectedCode.trim() && expectedCode.isNotEmpty;
  }

  /// ThaiID redirect target on native mobile: a custom-scheme deep link that
  /// reopens the installed app on the success route.
  static const _mobileRedirect =
      'sawadfinnix://sawadfinnix.com/onboarding/success';

  /// The URL ThaiID should redirect back to after verification.
  ///
  /// - **Native (iOS/Android)**: the [_mobileRedirect] custom-scheme deep link
  ///   reopens the app.
  /// - **Web**: there is no app to deep-link into, so we return to the Firebase
  ///   Hosting site currently serving the app. [Uri.base] is the live page URL,
  ///   so its origin is the hosting domain (this also works for local
  ///   `flutter run -d chrome`). The app uses Flutter web's default *hash* URL
  ///   strategy, so the success route is reached via `/#/onboarding/success`.
  String _thaidRedirect() {
    if (kIsWeb) {
      return '${Uri.base.origin}/#${AppRoutes.onboardingSuccess}';
    }
    return _mobileRedirect;
  }

  /// Requests a ThaiID verification link + session id.
  Future<ThaidLinkResponse> getThaidLink() async {
    try {
      final res = await _api.thaid().get(
        '/auth/thaid/link',
        queryParameters: {
          'redirect': _thaidRedirect(),
        },
      );
      final data = res.data;
      if (res.statusCode == 200 && data is Map) {
        return ThaidLinkResponse.fromMap(Map<String, dynamic>.from(data));
      }
      throw AuthException('ขอลิงก์ ThaiID ไม่สำเร็จ (${res.statusCode})');
    } on DioException catch (e) {
      throw AuthException('เชื่อมต่อ ThaiID ไม่สำเร็จ: ${e.message}');
    }
  }

  /// Polls the verification status for [sessionId].
  Future<ThaidStatus> getThaidStatus(String sessionId) async {
    try {
      final res =
          await _api.thaid().get('/auth/thaid/status/$sessionId');
      final data = res.data;
      if (res.statusCode == 200 && data is Map) {
        return ThaidStatus.fromMap(Map<String, dynamic>.from(data));
      }
      // Treat non-200 as still pending rather than a hard error while polling.
      return const ThaidStatus(state: ThaidVerifyState.pending);
    } on DioException catch (e) {
      throw AuthException('ตรวจสอบสถานะ ThaiID ไม่สำเร็จ: ${e.message}');
    }
  }
}
