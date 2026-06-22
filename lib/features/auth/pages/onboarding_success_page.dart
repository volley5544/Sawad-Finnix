import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_client.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../data/auth_repository.dart';
import '../data/user_repository.dart';
import '../models/thaid_status.dart';

/// Step 5: ThaiID callback landing + verification success.
///
/// ThaiID redirects (deep link) to `/onboarding/success?sessionId=...`. On
/// arrival we use the session id to fetch the verified ThaiID data, validate it
/// against the ID/DOB the user entered, then upsert the user in Firestore
/// (`users/{sha256(pid)}`) and create an anonymous Firebase Auth session via
/// [UserRepository.saveThaidProfile]:
///   - if `users/{sha256(pid)}` exists, only `authTime`/`uid` are updated;
///   - otherwise the full profile is created from the ThaiID data.
///
/// Only after the profile is persisted (and signed in) do we show success and
/// allow the user to continue to set a PIN.
class OnboardingSuccessPage extends StatefulWidget {
  const OnboardingSuccessPage({super.key, this.sessionId});

  /// Session id carried by the ThaiID redirect deep link (query param).
  final String? sessionId;

  @override
  State<OnboardingSuccessPage> createState() => _OnboardingSuccessPageState();
}

enum _Phase { loading, success, failed }

class _OnboardingSuccessPageState extends State<OnboardingSuccessPage> {
  late final AppState _appState = context.read<AppState>();
  late final AuthRepository _authRepo =
      AuthRepository(ApiClient(_appState.env));
  final UserRepository _userRepo = UserRepository();

  _Phase _phase = _Phase.loading;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _process());
  }

  bool _sameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Extracts the ThaiID `user` object from the status response, falling back
  /// to common nesting keys, then to the top-level map.
  Map<String, dynamic> _extractThaidUser(Map<String, dynamic>? raw) {
    if (raw == null) return const {};
    for (final key in ['user', 'data', 'person', 'result', 'profile']) {
      final v = raw[key];
      if (v is Map) return Map<String, dynamic>.from(v);
    }
    return raw;
  }

  Future<void> _process() async {
    // If the profile was already persisted (e.g. via the verify-page polling
    // path before this deep link arrived), don't refetch — just show success.
    final existing = _appState.profile;
    if (existing != null && existing.uid.isNotEmpty) {
      setState(() => _phase = _Phase.success);
      return;
    }

    // Prefer the session id from the redirect; fall back to the one stored when
    // the ThaiID link was requested.
    final sessionId = (widget.sessionId?.isNotEmpty ?? false)
        ? widget.sessionId
        : _appState.thaidSessionId;
    if (sessionId == null || sessionId.isEmpty) {
      await _fail('ไม่พบ session การยืนยันตัวตน กรุณาเริ่มใหม่');
      return;
    }

    setState(() {
      _phase = _Phase.loading;
      _error = null;
    });

    try {
      // The redirect may arrive a moment before the backend finalizes the
      // session, so retry briefly while it is still pending.
      ThaidStatus? status;
      for (var attempt = 0; attempt < 5; attempt++) {
        final s = await _authRepo.getThaidStatus(sessionId);
        if (s.isSuccess || s.state == ThaidVerifyState.failed) {
          status = s;
          break;
        }
        await Future<void>.delayed(const Duration(seconds: 2));
      }

      if (status == null || !status.isSuccess) {
        if (!mounted) return;
        final reason = status?.state == ThaidVerifyState.failed
            ? 'ThaiID แจ้งว่าการยืนยันตัวตนล้มเหลว (failed)'
            : 'การยืนยันตัวตนยังไม่สำเร็จ (timeout/pending)';
        await _fail('การยืนยันตัวตนไม่สำเร็จ กรุณาลองใหม่อีกครั้ง',
            detail: reason);
        return;
      }

      final person = status.person;

      // Validate the ID/DOB the user entered against the verified ThaiID data
      // (the same safeguard the verify page applied before this deep-link path).
      //
      // IMPORTANT (web): the ThaiID redirect is a full page reload on web, which
      // resets the in-memory [AppState] singleton — so the entered ID/DOB are
      // null here even though the user typed them earlier. We therefore only
      // treat it as a mismatch when an entered value is actually present AND
      // differs from the verified value. When the entered value is missing
      // (state lost on web), we skip the local safeguard and trust the
      // ThaiID-verified data.
      final enteredId = _appState.thaiId;
      final enteredDob = _appState.dateOfBirth;
      final verifiedId = person?.pid;
      final verifiedDob = person?.birthDate;
      final idProvided = enteredId != null && enteredId.isNotEmpty;
      final dobProvided = enteredDob != null;
      final idMismatch =
          idProvided && verifiedId != null && enteredId != verifiedId;
      final dobMismatch = dobProvided &&
          verifiedDob != null &&
          !_sameDate(enteredDob, verifiedDob);

      debugPrint('[success] callback hasPerson=${person != null} '
          'idProvided=$idProvided dobProvided=$dobProvided '
          'idMismatch=$idMismatch dobMismatch=$dobMismatch');

      if (idMismatch || dobMismatch) {
        if (!mounted) return;
        // Surface what actually differed so the cause is visible, then send the
        // user back to re-enter their info.
        await _alert(
          'ข้อมูลไม่ตรงกัน',
          [
            if (idMismatch) 'เลขบัตรที่กรอก ($enteredId) ไม่ตรงกับ ThaiID ($verifiedId)',
            if (dobMismatch) 'วันเกิดที่กรอกไม่ตรงกับ ThaiID',
          ].join('\n'),
        );
        if (!mounted) return;
        context.go(AppRoutes.thaidMismatch);
        return;
      }

      _appState.verifiedPerson = person;
      _appState.thaiId = verifiedId;
      _appState.dateOfBirth = verifiedDob;

      // Upsert the user (create or update authTime) and create the anonymous
      // Firebase Auth session.
      final user = _extractThaidUser(status.raw);
      final profile = await _userRepo.saveThaidProfile(
        user,
        phoneNumber: _appState.phoneNumber,
      );
      if (!mounted) return;
      _appState.setProfile(profile);
      setState(() => _phase = _Phase.success);
    } catch (e, st) {
      debugPrint('[success] error after callback: $e\n$st');
      if (!mounted) return;
      await _fail('บันทึกข้อมูลผู้ใช้ไม่สำเร็จ', detail: '$e');
    }
  }

  /// Marks the page as failed, records [message] (+ optional [detail]) and pops
  /// an alert dialog so the actual error is visible to the user.
  Future<void> _fail(String message, {String? detail}) async {
    final full = detail == null || detail.isEmpty
        ? message
        : '$message\n\n$detail';
    if (mounted) {
      setState(() {
        _phase = _Phase.failed;
        _error = full;
      });
    }
    await _alert('เกิดข้อผิดพลาด', full);
  }

  /// Shows a simple alert dialog with [title] and [message].
  Future<void> _alert(String title, String message) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'ยืนยันตัวตน',
      padding: const EdgeInsets.all(24),
      body: Center(child: _buildBody()),
      bottomBar: _buildBottomBar(),
    );
  }

  Widget _buildBody() {
    switch (_phase) {
      case _Phase.loading:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 24),
            Text(
              'กำลังบันทึกข้อมูลการยืนยันตัวตน...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        );
      case _Phase.success:
        final person = _appState.profile != null
            ? null
            : context.watch<AppState>().verifiedPerson;
        final name = _appState.profile?.fullName.isNotEmpty == true
            ? _appState.profile!.fullName
            : (person?.fullName ??
                [person?.firstName, person?.lastName]
                    .whereType<String>()
                    .join(' ')
                    .trim());
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 56),
            ),
            const SizedBox(height: 24),
            const Text(
              'ยืนยันตัวตนเรียบร้อยแล้ว',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            if (name.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(name, style: const TextStyle(color: AppColors.textMuted)),
            ],
          ],
        );
      case _Phase.failed:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 72, color: Colors.red),
            const SizedBox(height: 24),
            Text(
              _error ?? 'เกิดข้อผิดพลาด',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: AppColors.textBody),
            ),
          ],
        );
    }
  }

  Widget? _buildBottomBar() {
    switch (_phase) {
      case _Phase.loading:
        return null;
      case _Phase.success:
        return ElevatedButton(
          onPressed: () => context.go(AppRoutes.setPin),
          child: const Text('ตั้งรหัส PIN'),
        );
      case _Phase.failed:
        return ElevatedButton(
          onPressed: _process,
          child: const Text('ลองใหม่อีกครั้ง'),
        );
    }
  }
}
