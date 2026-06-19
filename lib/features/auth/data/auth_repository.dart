import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
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

  /// Requests a ThaiID verification link + session id.
  Future<ThaidLinkResponse> getThaidLink() async {
    try {
      final res = await _api.thaid().get(
        '/auth/thaid/link',
        queryParameters: {
          'redirect': 'sawadfinnix://sawadfinnix.com/onboarding/success',
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
