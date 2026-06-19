import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/security/pin_service.dart';
import '../models/thaid_status.dart';
import '../models/user_profile.dart';

/// Creates/loads the Firebase user + profile and stores the PIN.
///
/// Identity is keyed by the Thai national ID (the stable identifier returned by
/// ThaiID). The `users/{thaiId}` document holds the profile. An anonymous
/// Firebase Auth session is established so Firestore security rules can require
/// authentication.
class UserRepository {
  UserRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    PinService? pinService,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance,
        _pin = pinService ?? PinService();

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  final PinService _pin;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  /// Ensures there is an authenticated (anonymous) Firebase session.
  Future<User> ensureSignedIn() async {
    final current = _auth.currentUser;
    if (current != null) return current;
    final cred = await _auth.signInAnonymously();
    return cred.user!;
  }

  /// Create-or-get: returns the existing profile for [thaiId], or creates a new
  /// user + profile from the onboarding data if none exists.
  Future<UserProfile> createOrGetProfile({
    required String thaiId,
    String? phoneNumber,
    ThaidPerson? person,
    DateTime? dateOfBirth,
  }) async {
    await ensureSignedIn();
    final docRef = _users.doc(thaiId);
    final snapshot = await docRef.get();

    if (snapshot.exists && snapshot.data() != null) {
      return UserProfile.fromMap(snapshot.data()!);
    }

    final profile = UserProfile(
      uid: thaiId,
      phoneNumber: phoneNumber,
      thaiId: thaiId,
      firstName: person?.firstName,
      lastName: person?.lastName,
      dateOfBirth: person?.birthDate ?? dateOfBirth,
      hasPin: false,
      createdAt: DateTime.now(),
    );
    await docRef.set(profile.toMap());
    return profile;
  }

  /// Stores the PIN (hashed) locally and in the user's Firebase profile.
  Future<UserProfile> savePin({
    required UserProfile profile,
    required String pin,
  }) async {
    final ownerId = profile.thaiId ?? profile.uid;
    await _pin.savePinLocal(ownerId: ownerId, pin: pin);
    final hash = PinService.hashPin(pin: pin, salt: ownerId);

    await _users.doc(profile.uid).set(
      {'pinHash': hash, 'hasPin': true},
      SetOptions(merge: true),
    );
    return profile.copyWith(hasPin: true);
  }
}
