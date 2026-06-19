import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Handles PIN hashing and local secure persistence.
///
/// The PIN is never stored in plaintext. We store a salted SHA-256 hash both
/// locally (for fast re-auth) and in the user's Firebase profile.
///
/// NOTE: SHA-256 is used here for simplicity. For production-grade protection
/// against brute force, prefer a slow KDF (e.g. PBKDF2/scrypt/Argon2). The
/// salt is the user's stable identifier (Thai ID).
class PinService {
  PinService([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _kPinHash = 'pin_hash';
  static const _kPinOwner = 'pin_owner';

  static String hashPin({required String pin, required String salt}) {
    final bytes = utf8.encode('$salt:$pin');
    return sha256.convert(bytes).toString();
  }

  /// Persists the PIN hash locally, scoped to [ownerId] (the Thai ID).
  Future<void> savePinLocal({
    required String ownerId,
    required String pin,
  }) async {
    final hash = hashPin(pin: pin, salt: ownerId);
    await _storage.write(key: _kPinHash, value: hash);
    await _storage.write(key: _kPinOwner, value: ownerId);
  }

  /// Verifies a PIN against the locally stored hash for [ownerId].
  Future<bool> verifyPinLocal({
    required String ownerId,
    required String pin,
  }) async {
    final stored = await _storage.read(key: _kPinHash);
    if (stored == null) return false;
    return stored == hashPin(pin: pin, salt: ownerId);
  }

  Future<bool> hasLocalPin() async {
    return (await _storage.read(key: _kPinHash)) != null;
  }

  Future<void> clear() async {
    await _storage.delete(key: _kPinHash);
    await _storage.delete(key: _kPinOwner);
  }
}
