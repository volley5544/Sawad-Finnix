import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Remote (Firestore-backed) feature configuration.
///
/// Stored in Firestore at `config/app` so behaviour can be toggled from the
/// Firebase console without an app release. Reads are best-effort: any missing
/// doc/field or error falls back to safe defaults.
@immutable
class AppConfig {
  const AppConfig({this.loanRequestUseWeb = false});

  /// When `true`, the loan-request entry opens the flow hosted on Firebase
  /// Hosting inside an in-app webview; when `false`, it opens the native
  /// [LoanRequestPage] (step 1). Defaults to `false` (native) for safety.
  final bool loanRequestUseWeb;

  static const AppConfig defaults = AppConfig();

  factory AppConfig.fromMap(Map<String, dynamic>? map) {
    if (map == null) return defaults;
    return AppConfig(
      loanRequestUseWeb: map['loanRequestUseWeb'] as bool? ?? false,
    );
  }

  @override
  String toString() => 'AppConfig(loanRequestUseWeb: $loanRequestUseWeb)';
}

/// Reads [AppConfig] from Firestore `config/app`.
class AppConfigRepository {
  AppConfigRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// Document path of the remote app config.
  static const String collection = 'config';
  static const String docId = 'app';

  /// Fetches the current config. Returns [AppConfig.defaults] on any error or
  /// when the document does not exist (so the app degrades to native behaviour).
  Future<AppConfig> fetch() async {
    try {
      final snap = await _db.collection(collection).doc(docId).get();
      if (!snap.exists) {
        debugPrint('[config] $collection/$docId missing -> defaults');
        return AppConfig.defaults;
      }
      final config = AppConfig.fromMap(snap.data());
      debugPrint('[config] loaded $config');
      return config;
    } catch (e) {
      debugPrint('[config] fetch failed (using defaults): $e');
      return AppConfig.defaults;
    }
  }
}
