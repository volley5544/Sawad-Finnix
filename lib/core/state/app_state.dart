import 'package:flutter/foundation.dart';

import '../config/env_config.dart';
import '../../features/auth/models/user_profile.dart';
import '../../features/auth/models/thaid_status.dart';
import '../../features/loan/models/loan.dart';

/// Global application state, accessible everywhere in the app.
///
/// Two access patterns are supported:
///  1. Reactive (preferred in widgets): `context.watch<AppState>()` /
///     `Provider.of<AppState>(context)` — rebuilds on change.
///  2. Direct (services, non-widget code): `AppState.instance` — the same
///     singleton instance that is provided to the widget tree.
class AppState extends ChangeNotifier {
  AppState._() : env = EnvConfig.resolve();

  /// The single shared instance used across the whole app.
  static final AppState instance = AppState._();

  /// Active environment configuration (prod/uat).
  final EnvConfig env;

  AppEnvironment get environment => env.environment;
  bool get isUat => env.environment.isUat;
  String get bannerText => env.banner;

  // ---- Session / onboarding scratch state ----------------------------------

  String? _phoneNumber;
  String? get phoneNumber => _phoneNumber;
  set phoneNumber(String? value) {
    _phoneNumber = value;
    notifyListeners();
  }

  String? _thaiId;
  String? get thaiId => _thaiId;
  set thaiId(String? value) {
    _thaiId = value;
    notifyListeners();
  }

  /// Date of birth captured in onboarding (stored as DateTime, displayed in
  /// Thai Buddhist year format by the UI layer).
  DateTime? _dateOfBirth;
  DateTime? get dateOfBirth => _dateOfBirth;
  set dateOfBirth(DateTime? value) {
    _dateOfBirth = value;
    notifyListeners();
  }

  /// ThaiID verification session id returned by `/auth/thaid/link`.
  String? _thaidSessionId;
  String? get thaidSessionId => _thaidSessionId;
  set thaidSessionId(String? value) {
    _thaidSessionId = value;
    notifyListeners();
  }

  /// OTP value + reference from the most recent send-OTP response.
  String? _otpCode;
  String? get otpCode => _otpCode;
  String? _otpRef;
  String? get otpRef => _otpRef;
  void setOtp({required String code, required String ref}) {
    _otpCode = code;
    _otpRef = ref;
    notifyListeners();
  }

  /// Person data returned by ThaiID after successful verification.
  ThaidPerson? _verifiedPerson;
  ThaidPerson? get verifiedPerson => _verifiedPerson;
  set verifiedPerson(ThaidPerson? value) {
    _verifiedPerson = value;
    notifyListeners();
  }

  // ---- Authenticated user --------------------------------------------------

  UserProfile? _profile;
  UserProfile? get profile => _profile;
  bool get isSignedIn => _profile != null;

  void setProfile(UserProfile? profile) {
    _profile = profile;
    notifyListeners();
  }

  // ---- Loan account --------------------------------------------------------

  /// The user's current approved loan (mock-approved on request submit).
  Loan? _activeLoan;
  Loan? get activeLoan => _activeLoan;

  /// True when there is a loan that still has an outstanding balance.
  bool get hasActiveLoan => _activeLoan != null && !_activeLoan!.isClosed;

  void setActiveLoan(Loan? loan) {
    _activeLoan = loan;
    notifyListeners();
  }

  /// Applies a payment of [amount] to the active loan, deducting it from the
  /// outstanding balance and closing the loan when fully paid.
  void applyPayment(double amount) {
    final loan = _activeLoan;
    if (loan == null || amount <= 0) return;
    final newPaid =
        (loan.paidAmount + amount).clamp(0, loan.totalPayable).toDouble();
    _activeLoan = loan.copyWith(
      paidAmount: newPaid,
      status: newPaid >= loan.totalPayable - 0.005 ? 'closed' : 'active',
    );
    notifyListeners();
  }

  /// Amount the user is about to pay (carried from the pay screen to the QR /
  /// receipt screens).
  double? _pendingPaymentAmount;
  double? get pendingPaymentAmount => _pendingPaymentAmount;
  set pendingPaymentAmount(double? value) {
    _pendingPaymentAmount = value;
    notifyListeners();
  }

  /// Clears all session/onboarding state (e.g. on sign-out).
  void reset() {
    _phoneNumber = null;
    _thaiId = null;
    _dateOfBirth = null;
    _thaidSessionId = null;
    _otpCode = null;
    _otpRef = null;
    _verifiedPerson = null;
    _profile = null;
    _activeLoan = null;
    _pendingPaymentAmount = null;
    notifyListeners();
  }
}
