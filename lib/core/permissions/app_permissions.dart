import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// The four device permissions requested in the loan-request flow.
enum AppPermissionType { contacts, deviceInfo, location, sms }

/// Normalized result of requesting / checking a permission.
enum PermissionOutcome {
  /// Granted (or limited / provisional) — treat as allowed.
  granted,

  /// Denied this time; can be requested again.
  denied,

  /// Denied for good (or restricted) — only resolvable in system settings.
  permanentlyDenied,

  /// The current platform can't request this permission (e.g. SMS / phone-state
  /// on iOS, or web).
  unsupported,
}

/// Thin wrapper over `permission_handler` that maps the loan-request
/// permissions to concrete OS permissions and degrades gracefully on platforms
/// that don't support a given one.
///
/// Platform notes:
///  - `deviceInfo` maps to READ_PHONE_STATE (Android only).
///  - `sms` maps to READ_SMS (Android only).
///  - iOS has no SMS-read / phone-state permission, so both are [unsupported].
///  - Web is treated as [unsupported] for all (these are mobile-only signals).
class AppPermissions {
  const AppPermissions();

  bool get _isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  Permission _permission(AppPermissionType type) {
    switch (type) {
      case AppPermissionType.contacts:
        return Permission.contacts;
      case AppPermissionType.deviceInfo:
        return Permission.phone;
      case AppPermissionType.location:
        return Permission.locationWhenInUse;
      case AppPermissionType.sms:
        return Permission.sms;
    }
  }

  /// Whether this permission can be requested on the current platform.
  bool isSupported(AppPermissionType type) {
    if (kIsWeb) return false;
    if (_isIOS &&
        (type == AppPermissionType.deviceInfo ||
            type == AppPermissionType.sms)) {
      return false;
    }
    return true;
  }

  /// Prompts the OS permission dialog and returns the normalized outcome.
  Future<PermissionOutcome> request(AppPermissionType type) async {
    if (!isSupported(type)) return PermissionOutcome.unsupported;
    try {
      return _map(await _permission(type).request());
    } catch (e) {
      debugPrint('[permissions] request($type) error: $e');
      return PermissionOutcome.unsupported;
    }
  }

  /// Reads the current status without prompting.
  Future<PermissionOutcome> check(AppPermissionType type) async {
    if (!isSupported(type)) return PermissionOutcome.unsupported;
    try {
      return _map(await _permission(type).status);
    } catch (e) {
      debugPrint('[permissions] check($type) error: $e');
      return PermissionOutcome.unsupported;
    }
  }

  /// Opens the system app-settings page (for permanently-denied permissions).
  Future<bool> openSettings() => openAppSettings();

  PermissionOutcome _map(PermissionStatus status) {
    if (status.isGranted || status.isLimited || status.isProvisional) {
      return PermissionOutcome.granted;
    }
    if (status.isPermanentlyDenied || status.isRestricted) {
      return PermissionOutcome.permanentlyDenied;
    }
    return PermissionOutcome.denied;
  }
}
