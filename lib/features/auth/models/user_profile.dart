/// User profile stored in Firestore and held in [AppState].
///
/// The Firestore document id is the SHA-256 hash of the Thai national ID
/// (`sha256(pid)`), [thaiId] keeps the plain `pid`, and [uid] holds the
/// Firebase Auth UID. The ThaiID fields are populated from the get-ThaiID-data
/// API response (see [UserProfile.fromThaidUser]).
class UserProfile {
  const UserProfile({
    required this.uid,
    this.phoneNumber,
    this.thaiId,
    this.nameTh,
    this.nameEn,
    this.gender,
    this.address,
    this.houseAddress,
    this.dateOfBirth,
    this.tokenIssuedAt,
    this.tokenExpiresAt,
    this.authTime,
    this.hasPin = false,
    this.createdAt,
  });

  final String uid;
  final String? phoneNumber;
  final String? thaiId;

  /// Full name in Thai (ThaiID `name`), e.g. "นาย วรรธนัย แสงสุนทร".
  final String? nameTh;

  /// Full name in English (ThaiID `name_en`).
  final String? nameEn;

  /// Gender (ThaiID `gender`), e.g. "male".
  final String? gender;

  /// Formatted current address (ThaiID `address.formatted`).
  final String? address;

  /// Formatted house registration address (ThaiID `house_address.formatted`).
  final String? houseAddress;

  final DateTime? dateOfBirth;

  /// ThaiID token `iat` (issued-at, epoch seconds).
  final int? tokenIssuedAt;

  /// ThaiID token `exp` (expiry, epoch seconds).
  final int? tokenExpiresAt;

  /// ThaiID `auth_time` (authentication time, epoch seconds).
  final int? authTime;

  final bool hasPin;
  final DateTime? createdAt;

  /// Display name (Thai name from ThaiID).
  String get fullName => nameTh?.trim() ?? '';

  UserProfile copyWith({
    String? uid,
    String? phoneNumber,
    String? thaiId,
    String? nameTh,
    String? nameEn,
    String? gender,
    String? address,
    String? houseAddress,
    DateTime? dateOfBirth,
    int? tokenIssuedAt,
    int? tokenExpiresAt,
    int? authTime,
    bool? hasPin,
    DateTime? createdAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      thaiId: thaiId ?? this.thaiId,
      nameTh: nameTh ?? this.nameTh,
      nameEn: nameEn ?? this.nameEn,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      houseAddress: houseAddress ?? this.houseAddress,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      tokenIssuedAt: tokenIssuedAt ?? this.tokenIssuedAt,
      tokenExpiresAt: tokenExpiresAt ?? this.tokenExpiresAt,
      authTime: authTime ?? this.authTime,
      hasPin: hasPin ?? this.hasPin,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'thaiId': thaiId,
      'nameTh': nameTh,
      'nameEn': nameEn,
      'gender': gender,
      'address': address,
      'houseAddress': houseAddress,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'tokenIssuedAt': tokenIssuedAt,
      'tokenExpiresAt': tokenExpiresAt,
      'authTime': authTime,
      'hasPin': hasPin,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    int? toInt(dynamic v) =>
        v is int ? v : (v == null ? null : int.tryParse('$v'));

    return UserProfile(
      uid: map['uid'] as String,
      phoneNumber: map['phoneNumber'] as String?,
      thaiId: map['thaiId'] as String?,
      nameTh: map['nameTh'] as String?,
      nameEn: map['nameEn'] as String?,
      gender: map['gender'] as String?,
      address: map['address'] as String?,
      houseAddress: map['houseAddress'] as String?,
      dateOfBirth: map['dateOfBirth'] != null
          ? DateTime.tryParse(map['dateOfBirth'] as String)
          : null,
      tokenIssuedAt: toInt(map['tokenIssuedAt']),
      tokenExpiresAt: toInt(map['tokenExpiresAt']),
      authTime: toInt(map['authTime']),
      hasPin: (map['hasPin'] as bool?) ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String)
          : null,
    );
  }

  /// Builds a profile from the `user` object of the get-ThaiID-data API
  /// response. Only the fields needed across the app are kept.
  factory UserProfile.fromThaidUser(
    Map<String, dynamic> user, {
    String? phoneNumber,
  }) {
    int? toInt(dynamic v) =>
        v is int ? v : (v == null ? null : int.tryParse('$v'));

    String? formatted(dynamic node) {
      if (node is Map && node['formatted'] != null) {
        return '${node['formatted']}';
      }
      if (node is String && node.isNotEmpty) return node;
      return null;
    }

    final pid = '${user['pid'] ?? user['sub'] ?? ''}';
    final birthRaw = user['birthdate'];

    return UserProfile(
      // uid is set to the Firebase Auth UID when the profile is persisted.
      uid: '',
      thaiId: pid,
      phoneNumber: phoneNumber,
      nameTh: user['name'] as String?,
      nameEn: user['name_en'] as String?,
      gender: user['gender'] as String?,
      address: formatted(user['address']),
      houseAddress: formatted(user['house_address']),
      dateOfBirth:
          birthRaw is String ? DateTime.tryParse(birthRaw) : null,
      tokenIssuedAt: toInt(user['iat']),
      tokenExpiresAt: toInt(user['exp']),
      authTime: toInt(user['auth_time']),
      createdAt: DateTime.now(),
    );
  }
}
