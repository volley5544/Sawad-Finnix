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

  CollectionReference<Map<String, dynamic>> _requests(String thaiId) =>
      _db.collection('users').doc(ThaiId.hash(thaiId)).collection('loanRequests');

  /// Pre-generates a loan-request document id (no network) so statement files
  /// can be grouped under the same id in Storage before the request is
  /// submitted. Falls back to a standalone id when [thaiId] is empty.
  String newRequestId(String thaiId) {
    if (thaiId.isEmpty) return _db.collection('loanRequests').doc().id;
    return _requests(thaiId).doc().id;
  }

  /// Builds a [LoanRequest] from the verified [profile] and the collected
  /// form data, persists it, and returns the document id.
  ///
  /// When [requestId] is supplied (from [newRequestId]) the document is written
  /// at that deterministic id and the id is stored on the document, so it lines
  /// up with the `loan_statements/{hash}/{requestId}/...` Storage folder.
  Future<String> submit({
    required UserProfile profile,
    required LoanRequest request,
    String? requestId,
  }) async {
    final user = await _ensureSignedIn();
    final thaiId = profile.thaiId ?? '';
    if (thaiId.isEmpty) {
      throw StateError('ไม่พบเลขบัตรประชาชนของผู้ใช้');
    }
    final docId = ThaiId.hash(thaiId);
    final collection = _requests(thaiId);
    final docRef =
        (requestId != null && requestId.isNotEmpty) ? collection.doc(requestId) : collection.doc();

    // Stamp the current auth uid and the request's own id onto the document.
    final payload = {
      ...request.toMap(),
      'uid': user.uid,
      'requestId': docRef.id,
    };
    await docRef.set(payload);
    debugPrint('[loan] submitted request ${docRef.id} under users/$docId');
    return docRef.id;
  }
}
