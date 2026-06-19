/// Response from `POST /otp`.
///
/// Note: the backend returns the OTP `code` in the response, so verification is
/// performed client-side by comparing the user's input to [code].
class OtpResponse {
  const OtpResponse({
    required this.code,
    required this.ref,
    required this.createDate,
  });

  /// The OTP value the user must enter.
  final String code;

  /// Reference shown to the user (e.g. "6o1jNC").
  final String ref;

  /// Epoch millis when the OTP was created.
  final int createDate;

  factory OtpResponse.fromMap(Map<String, dynamic> map) {
    return OtpResponse(
      code: '${map['code'] ?? ''}',
      ref: '${map['ref'] ?? ''}',
      createDate: (map['create_date'] is int)
          ? map['create_date'] as int
          : int.tryParse('${map['create_date']}') ?? 0,
    );
  }
}

/// Response from `/auth/thaid/link`.
class ThaidLinkResponse {
  const ThaidLinkResponse({required this.url, required this.sessionId});

  /// ThaiID OAuth authorize URL to launch.
  final String url;

  /// Session id used to poll `/auth/thaid/status/{sessionId}`.
  final String sessionId;

  factory ThaidLinkResponse.fromMap(Map<String, dynamic> map) {
    return ThaidLinkResponse(
      url: '${map['url'] ?? ''}',
      sessionId: '${map['sessionId'] ?? map['session_id'] ?? ''}',
    );
  }
}
