import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists small pieces of onboarding "scratch" state that must survive a
/// process/page restart.
///
/// This exists primarily for the **web** flow: the ThaiID verification redirect
/// is a full page reload, which resets the in-memory [AppState] singleton. Any
/// value the user entered earlier (e.g. their phone number) is therefore lost
/// by the time we land back on `/onboarding/success` and upsert the profile.
///
/// The phone number is not returned by ThaiID, so — unlike the Thai ID / DOB,
/// which can be recovered from the verified ThaiID data — it can only be
/// restored from persistence. We store it via [FlutterSecureStorage] (the same
/// mechanism used for the PIN), which is backed by localStorage on web and so
/// survives the reload.
class OnboardingStore {
  OnboardingStore([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _kPhoneNumber = 'onboarding_phone_number';

  /// Persists the phone number entered during onboarding.
  Future<void> savePhoneNumber(String phoneNumber) =>
      _storage.write(key: _kPhoneNumber, value: phoneNumber);

  /// Reads the persisted onboarding phone number, or null if none is stored.
  Future<String?> readPhoneNumber() => _storage.read(key: _kPhoneNumber);

  /// Clears the persisted onboarding phone number (call once the profile has
  /// been saved, so it does not leak into a later onboarding attempt).
  Future<void> clearPhoneNumber() => _storage.delete(key: _kPhoneNumber);
}
