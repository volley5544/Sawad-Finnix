import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// Wraps device biometric authentication (fingerprint / Face ID) and persists
/// the user's opt-in preference.
///
/// Two concerns are handled here:
///  1. Device capability — whether the hardware supports biometrics and the
///     user has enrolled at least one (see [isAvailable]).
///  2. User preference — whether the user has chosen to use biometrics to sign
///     in to this app (see [isEnabled] / [setEnabled]). The flag is stored in
///     secure storage so it survives restarts.
///
/// The PIN remains the fallback; biometrics never replace it, they are just a
/// faster first-choice when enabled.
class BiometricService {
  BiometricService([
    LocalAuthentication? auth,
    FlutterSecureStorage? storage,
  ])  : _auth = auth ?? LocalAuthentication(),
        _storage = storage ?? const FlutterSecureStorage();

  final LocalAuthentication _auth;
  final FlutterSecureStorage _storage;

  static const _kEnabled = 'biometric_enabled';

  /// True when the device has biometric hardware that can currently be used
  /// (supported + the OS reports it can check biometrics).
  Future<bool> isDeviceSupported() async {
    try {
      final supported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      return supported && canCheck;
    } catch (e) {
      debugPrint('[biometric] isDeviceSupported error: $e');
      return false;
    }
  }

  /// True when the user has enrolled at least one biometric (fingerprint/face).
  Future<bool> hasEnrolledBiometrics() async {
    try {
      final available = await _auth.getAvailableBiometrics();
      return available.isNotEmpty;
    } catch (e) {
      debugPrint('[biometric] getAvailableBiometrics error: $e');
      return false;
    }
  }

  /// True when biometrics can be used right now (supported + enrolled).
  Future<bool> isAvailable() async {
    if (!await isDeviceSupported()) return false;
    return hasEnrolledBiometrics();
  }

  /// Whether the user opted in to biometric sign-in for this app.
  Future<bool> isEnabled() async {
    return (await _storage.read(key: _kEnabled)) == 'true';
  }

  /// Persists the user's biometric sign-in preference.
  Future<void> setEnabled(bool value) async {
    await _storage.write(key: _kEnabled, value: value ? 'true' : 'false');
  }

  /// Clears the stored preference (e.g. on sign-out).
  Future<void> clear() async {
    await _storage.delete(key: _kEnabled);
  }

  /// Prompts the OS biometric dialog. Returns true only on a successful match.
  ///
  /// [biometricOnly] keeps the prompt to biometrics (no device PIN/pattern
  /// fallback) so our own app PIN stays the single non-biometric path.
  Future<bool> authenticate({
    required String reason,
    bool biometricOnly = true,
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          biometricOnly: biometricOnly,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      debugPrint('[biometric] authenticate error: $e');
      return false;
    }
  }
}
