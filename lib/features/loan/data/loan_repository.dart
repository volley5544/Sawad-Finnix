import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../core/utils/thai_id.dart';
import '../../auth/models/user_profile.dart';
import '../models/loan_request.dart';

/// Persists loan (credit-line) requests to Firestore.
///
/// Requests are stored under the owning user document, keyed by the same
/// `sha256(thaiId)` id used for the profile:
///   `users/{sha256(thaiId)}/loanRequests/{autoId}`
///
/// This keeps each user's requests scoped to their record and lets Firestore
/// rules reuse the existing `users/{id}` ownership model. An (anonymous)
/// Firebase Auth session is ensured first so `request.auth != null` rules pass.
class LoanRepository {
  LoanRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  Future<User> _ensureSignedIn() async {
    final current = _auth.currentUser;
    if (current != null) return current;
    final cred = await _auth.signInAnonymously();
    return cred.user!;
  }

  /// Builds a [LoanRequest] from the verified [profile] and the collected
  /// [form] data, persists it, and returns the new document id.
  Future<String> submit({
    required UserProfile profile,
    required LoanRequest request,
  }) async {
    final user = await _ensureSignedIn();
    final thaiId = profile.thaiId ?? '';
    if (thaiId.isEmpty) {
      throw StateError('ไม่พบเลขบัตรประชาชนของผู้ใช้');
    }
    final docId = ThaiId.hash(thaiId);
    final collection =
        _db.collection('users').doc(docId).collection('loanRequests');

    // Stamp the current auth uid onto the persisted request.
    final payload = {
      ...request.toMap(),
      'uid': user.uid,
    };
    final ref = await collection.add(payload);
    debugPrint('[loan] submitted request ${ref.id} under users/$docId');
    return ref.id;
  }
}
