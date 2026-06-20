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
      setState(() {
        _phase = _Phase.failed;
        _error = 'ไม่พบ session การยืนยันตัวตน กรุณาเริ่มใหม่';
      });
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
        setState(() {
          _phase = _Phase.failed;
          _error = 'การยืนยันตัวตนไม่สำเร็จ กรุณาลองใหม่อีกครั้ง';
        });
        return;
      }

      final person = status.person;

      // Validate the ID/DOB the user entered against the verified ThaiID data
      // (the same safeguard the verify page applied before this deep-link path).
      final enteredId = _appState.thaiId;
      final enteredDob = _appState.dateOfBirth;
      final verifiedId = person?.pid;
      final verifiedDob = person?.birthDate;
      final idMatch =
          enteredId != null && verifiedId != null && enteredId == verifiedId;
      final dobMatch = enteredDob != null &&
          verifiedDob != null &&
          _sameDate(enteredDob, verifiedDob);

      debugPrint('[success] callback hasPerson=${person != null} '
          'idMatch=$idMatch dobMatch=$dobMatch');

      if (!idMatch || !dobMatch) {
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
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _phase = _Phase.failed;
        _error = 'บันทึกข้อมูลผู้ใช้ไม่สำเร็จ: $e';
      });
    }
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
