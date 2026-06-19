import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/network/api_client.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../data/auth_repository.dart';
import '../data/user_repository.dart';
import '../models/thaid_status.dart';

/// Step 4: launch ThaiID OAuth and wait for verification via status polling.
///
/// Because the ThaiID `redirect_uri` is server-side, the app cannot receive a
/// deep-link callback. Instead it polls `/auth/thaid/status/{sessionId}` until
/// the backend reports success (and returns the person data).
class ThaidVerifyPage extends StatefulWidget {
  const ThaidVerifyPage({super.key});

  @override
  State<ThaidVerifyPage> createState() => _ThaidVerifyPageState();
}

enum _Phase { intro, launching, waiting, failed }

class _ThaidVerifyPageState extends State<ThaidVerifyPage> {
  _Phase _phase = _Phase.intro;
  String? _error;
  Timer? _pollTimer;

  late final AuthRepository _repo =
      AuthRepository(ApiClient(context.read<AppState>().env));
  final UserRepository _userRepo = UserRepository();

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _start() async {
    setState(() {
      _phase = _Phase.launching;
      _error = null;
    });
    final appState = context.read<AppState>();
    try {
      final link = await _repo.getThaidLink();
      appState.thaidSessionId = link.sessionId;

      final uri = Uri.parse(link.url);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        throw Exception('ไม่สามารถเปิดหน้า ThaiID ได้');
      }
      if (!mounted) return;
      setState(() => _phase = _Phase.waiting);
      _startPolling(link.sessionId);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _phase = _Phase.failed;
        _error = '$e'.replaceFirst('AuthException: ', '');
      });
    }
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

  void _startPolling(String sessionId) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _checkOnce(sessionId);
    });
  }

  Future<void> _checkOnce(String sessionId) async {
    final appState = context.read<AppState>();
    try {
      final status = await _repo.getThaidStatus(sessionId);
      if (!mounted) return;
      if (status.isSuccess) {
        _pollTimer?.cancel();
        final person = status.person;

        // Compare the ID/DOB the user entered against the verified ThaiID data.
        final enteredId = appState.thaiId;
        final enteredDob = appState.dateOfBirth;
        final verifiedId = person?.pid;
        final verifiedDob = person?.birthDate;

        final idMatch =
            enteredId != null && verifiedId != null && enteredId == verifiedId;
        final dobMatch = enteredDob != null &&
            verifiedDob != null &&
            _sameDate(enteredDob, verifiedDob);

        debugPrint('[verify] success hasPerson=${person != null} '
            'idMatch=$idMatch dobMatch=$dobMatch');

        if (!idMatch || !dobMatch) {
          context.go(AppRoutes.thaidMismatch);
          return;
        }

        appState.verifiedPerson = person;
        // Backfill onboarding fields from the verified data.
        appState.thaiId = verifiedId;
        appState.dateOfBirth = verifiedDob;

        // Create (or update) the user profile from the verified ThaiID data.
        try {
          final user = _extractThaidUser(status.raw);
          final profile = await _userRepo.saveThaidProfile(
            user,
            phoneNumber: appState.phoneNumber,
          );
          if (!mounted) return;
          appState.setProfile(profile);
        } catch (e) {
          if (!mounted) return;
          setState(() {
            _phase = _Phase.failed;
            _error = 'บันทึกข้อมูลผู้ใช้ไม่สำเร็จ: $e';
          });
          return;
        }

        if (!mounted) return;
        context.go(AppRoutes.onboardingSuccess);
      } else if (status.state == ThaidVerifyState.failed) {
        _pollTimer?.cancel();
        setState(() {
          _phase = _Phase.failed;
          _error = 'การยืนยันตัวตนไม่สำเร็จ กรุณาลองใหม่อีกครั้ง';
        });
      }
      // pending/unknown: keep polling.
    } catch (e) {
      // Transient errors are ignored while polling continues.
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'ยืนยันตัวตนผ่าน ThaiID',
      padding: const EdgeInsets.all(24),
      body: Center(child: _buildBody()),
      bottomBar: _buildBottomBar(),
    );
  }

  Widget _buildBody() {
    switch (_phase) {
      case _Phase.intro:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.verified_user_outlined,
                size: 72, color: AppColors.primary),
            SizedBox(height: 24),
            Text(
              'ยืนยันตัวตนด้วย ThaiID',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'ระบบจะนำคุณไปยังแอป/เว็บ ThaiID เพื่อยืนยันตัวตน '
              'เมื่อยืนยันเสร็จสิ้น กรุณากลับมาที่แอปนี้',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        );
      case _Phase.launching:
      case _Phase.waiting:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 24),
            Text(
              _phase == _Phase.launching
                  ? 'กำลังเปิดหน้า ThaiID...'
                  : 'กำลังรอการยืนยันตัวตน...',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'หลังยืนยันตัวตนกับ ThaiID เสร็จแล้ว ระบบจะดำเนินการต่อให้อัตโนมัติ',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted),
            ),
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
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textBody,
              ),
            ),
          ],
        );
    }
  }

  Widget? _buildBottomBar() {
    final appState = context.read<AppState>();
    switch (_phase) {
      case _Phase.intro:
        return ElevatedButton(onPressed: _start, child: const Text('ถัดไป'));
      case _Phase.launching:
        return null;
      case _Phase.waiting:
        return OutlinedButton(
          onPressed: () {
            final sid = appState.thaidSessionId;
            if (sid != null) _checkOnce(sid);
          },
          child: const Text('ฉันยืนยันตัวตนเสร็จแล้ว'),
        );
      case _Phase.failed:
        return ElevatedButton(
          onPressed: _start,
          child: const Text('ลองใหม่อีกครั้ง'),
        );
    }
  }
}
