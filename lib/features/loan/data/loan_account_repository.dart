import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../core/utils/thai_id.dart';
import '../../auth/models/user_profile.dart';
import '../models/loan.dart';

/// Manages the user's approved loan account in Firestore.
///
/// Loans live under the owning user, keyed by `sha256(thaiId)`:
///   `users/{sha256(thaiId)}/loans/{loanId}`
///
/// Firestore persistence is best-effort: the approved loan and payments are
/// kept in app state for an immediate, reliable UX (this is a mock approval),
/// and writes are attempted but never block the flow if rules/network fail.
class LoanAccountRepository {
  LoanAccountRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>>? _loans(String thaiId) {
    if (thaiId.isEmpty) return null;
    return _db.collection('users').doc(ThaiId.hash(thaiId)).collection('loans');
  }

  Future<void> _ensureSignedIn() async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
  }

  /// Creates a (mock) approved loan for [profile]. Returns the loan immediately;
  /// the Firestore write is best-effort.
  Future<Loan> createApprovedLoan({
    required UserProfile profile,
    String? loanId,
  }) async {
    final thaiId = profile.thaiId ?? '';
    final col = _loans(thaiId);
    final id = (loanId != null && loanId.isNotEmpty)
        ? loanId
        : (col?.doc().id ?? DateTime.now().millisecondsSinceEpoch.toString());
    final loan = Loan.approved(loanId: id, thaiId: thaiId);

    try {
      await _ensureSignedIn();
      if (col != null) {
        await col.doc(id).set(loan.toMap());
        debugPrint('[loan] approved loan $id persisted');
      }
    } catch (e) {
      debugPrint('[loan] persist approved loan failed (continuing): $e');
    }
    return loan;
  }

  /// Records a payment of [amount] against [loan], returning the updated loan.
  /// Updates app-state math locally and best-effort-persists to Firestore.
  Future<Loan> recordPayment({
    required Loan loan,
    required double amount,
  }) async {
    final newPaid = (loan.paidAmount + amount).clamp(0, loan.totalPayable);
    final updated = loan.copyWith(
      paidAmount: newPaid.toDouble(),
      status: newPaid >= loan.totalPayable - 0.005 ? 'closed' : 'active',
    );

    try {
      await _ensureSignedIn();
      final col = _loans(loan.thaiId ?? '');
      if (col != null && loan.loanId.isNotEmpty) {
        final doc = col.doc(loan.loanId);
        await doc.set(
          {'paidAmount': updated.paidAmount, 'status': updated.status},
          SetOptions(merge: true),
        );
        await doc.collection('payments').add({
          'amount': amount,
          'paidAt': DateTime.now().toIso8601String(),
          'outstandingAfter': updated.outstandingBalance,
          'installmentsPaid': updated.installmentsPaid,
        });
        debugPrint('[loan] payment $amount recorded for ${loan.loanId}');
      }
    } catch (e) {
      debugPrint('[loan] persist payment failed (continuing): $e');
    }
    return updated;
  }

  /// Loads the most recent active loan for [thaiId], or null.
  Future<Loan?> loadActiveLoan(String thaiId) async {
    final col = _loans(thaiId);
    if (col == null) return null;
    try {
      await _ensureSignedIn();
      final snap = await col
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return null;
      return Loan.fromMap(snap.docs.first.data());
    } catch (e) {
      debugPrint('[loan] loadActiveLoan failed: $e');
      return null;
    }
  }
}
