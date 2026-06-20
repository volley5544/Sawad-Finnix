import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../core/security/pin_service.dart';
import '../../../core/utils/thai_id.dart';
import '../models/thaid_status.dart';
import '../models/user_profile.dart';

/// Builds the user profile and persists it.
///
/// The Firestore document id is `sha256(pid)`; the document's `uid` field holds
/// the Firebase Auth UID. The profile (from ThaiID) is stored in
/// `users/{sha256(pid)}` so it can be used across the app, while the PIN is kept
/// on-device via [PinService] (flutter_secure_storage) and is never written to
/// Firestore.
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

  /// Ensures there is an authenticated (anonymous) Firebase session so that
  /// Firestore security rules requiring `request.auth != null` are satisfied.
  Future<User> ensureSignedIn() async {
    final current = _auth.currentUser;
    if (current != null) {
      debugPrint('[auth] reusing session uid=${current.uid} '
          'anonymous=${current.isAnonymous}');
      return current;
    }
    final cred = await _auth.signInAnonymously();
    final user = cred.user!;
    debugPrint('[auth] anonymous sign-in created uid=${user.uid} '
        'anonymous=${user.isAnonymous}');
    return user;
  }

  /// Builds a [UserProfile] from the verified onboarding data (no network).
  Future<UserProfile> createOrGetProfile({
    required String thaiId,
    String? phoneNumber,
    ThaidPerson? person,
    DateTime? dateOfBirth,
  }) async {
    return UserProfile(
      // uid is set to the Firebase Auth UID when the profile is persisted.
      uid: '',
      phoneNumber: phoneNumber,
      thaiId: thaiId,
      dateOfBirth: person?.birthDate ?? dateOfBirth,
      hasPin: false,
      createdAt: DateTime.now(),
    );
  }

  /// Parses the `user` object from the get-ThaiID-data API response and upserts
  /// the profile in Firestore `users/{sha256(pid)}`:
  ///  - if the document does not exist, the full profile is created;
  ///  - if it already exists, only `authTime` and `uid` are updated.
  ///
  /// The `uid` field stores the current Firebase Auth UID. Returns the profile.
  Future<UserProfile> saveThaidProfile(
    Map<String, dynamic> user, {
    String? phoneNumber,
  }) async {
    final authUser = await ensureSignedIn();
    final parsed = UserProfile.fromThaidUser(user, phoneNumber: phoneNumber);
    final docId = ThaiId.hash(parsed.thaiId ?? '');
    final profile = parsed.copyWith(uid: authUser.uid);
    final docRef = _users.doc(docId);
    debugPrint('[profile] saving docId=$docId uid=${profile.uid} '
        'pidLen=${parsed.thaiId?.length}');
    final snapshot = await docRef.get();

    if (snapshot.exists && snapshot.data() != null) {
      // Existing user: refresh the authentication time and the auth uid.
      await docRef.set(
        {'authTime': profile.authTime, 'uid': profile.uid},
        SetOptions(merge: true),
      );
      debugPrint('[profile] updated existing doc');
      return UserProfile.fromMap(snapshot.data()!)
          .copyWith(authTime: profile.authTime, uid: profile.uid);
    }

    // New user: create the full profile document.
    await docRef.set(profile.toMap());
    debugPrint('[profile] created new doc');
    return profile;
  }

  /// Persists [profile] to Firestore `users/{sha256(pid)}` (merge). The `uid`
  /// field is set to the current Firebase Auth UID. PIN data is excluded.
  Future<UserProfile> saveProfile(UserProfile profile) async {
    final authUser = await ensureSignedIn();
    final docId = ThaiId.hash(profile.thaiId ?? '');
    final toSave = profile.copyWith(uid: authUser.uid);
    await _users.doc(docId).set(toSave.toMap(), SetOptions(merge: true));
    return toSave;
  }

  /// Stores the PIN (hashed) in local secure storage only.
  ///
  /// The PIN is persisted on-device via [PinService] (flutter_secure_storage)
  /// and reflected in [AppState] for the current session. It is never written
  /// to Firestore.
  Future<UserProfile> savePin({
    required UserProfile profile,
    required String pin,
  }) async {
    final ownerId = profile.thaiId ?? profile.uid;
    await _pin.savePinLocal(ownerId: ownerId, pin: pin);
    return profile.copyWith(hasPin: true);
  }

  /// Reloads the latest profile from Firestore `users/{sha256(thaiId)}`.
  ///
  /// Used by the PIN-login flow on a cold start: after the user authenticates
  /// (PIN or biometric) we re-fetch the profile so [AppState] reflects any
  /// server-side changes that happened since the last session. Ensures an
  /// (anonymous) Firebase Auth session exists first so Firestore rules pass.
  /// Returns null when no document exists for [thaiId].
  Future<UserProfile?> loadProfileByThaiId(String thaiId) async {
    if (thaiId.isEmpty) return null;
    await ensureSignedIn();
    final docId = ThaiId.hash(thaiId);
    final snapshot = await _users.doc(docId).get();
    final data = snapshot.data();
    if (!snapshot.exists || data == null) {
      debugPrint('[profile] loadProfileByThaiId: no doc for $docId');
      return null;
    }
    debugPrint('[profile] loadProfileByThaiId: loaded $docId');
    return UserProfile.fromMap(data);
  }
}
