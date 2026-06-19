/// User profile stored in Firebase and held in [AppState].
class UserProfile {
  const UserProfile({
    required this.uid,
    this.phoneNumber,
    this.thaiId,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.hasPin = false,
    this.createdAt,
  });

  final String uid;
  final String? phoneNumber;
  final String? thaiId;
  final String? firstName;
  final String? lastName;
  final DateTime? dateOfBirth;
  final bool hasPin;
  final DateTime? createdAt;

  String get fullName =>
      [firstName, lastName].whereType<String>().join(' ').trim();

  UserProfile copyWith({
    String? phoneNumber,
    String? thaiId,
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    bool? hasPin,
    DateTime? createdAt,
  }) {
    return UserProfile(
      uid: uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      thaiId: thaiId ?? this.thaiId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      hasPin: hasPin ?? this.hasPin,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'thaiId': thaiId,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'hasPin': hasPin,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] as String,
      phoneNumber: map['phoneNumber'] as String?,
      thaiId: map['thaiId'] as String?,
      firstName: map['firstName'] as String?,
      lastName: map['lastName'] as String?,
      dateOfBirth: map['dateOfBirth'] != null
          ? DateTime.tryParse(map['dateOfBirth'] as String)
          : null,
      hasPin: (map['hasPin'] as bool?) ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String)
          : null,
    );
  }
}
