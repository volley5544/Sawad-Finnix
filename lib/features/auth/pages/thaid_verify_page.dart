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
import '../models/thaid_status.dart';

/// Step 4: launch ThaiID OAuth and wait for verification.
///
/// Completion is normally delivered by the ThaiID redirect deep link, which
/// lands on `/onboarding/success` (see [OnboardingSuccessPage]) where the
/// profile is persisted. As a fallback for devices where the deep link does not
/// fire, this page also polls `/auth/thaid/status/{sessionId}`; on detected
/// success it simply routes to the same success callback, which is the single
/// place that performs validation + persistence.
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

  void _startPolling(String sessionId) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _checkOnce(sessionId);
    });
  }

  Future<void> _checkOnce(String sessionId) async {
    try {
      final status = await _repo.getThaidStatus(sessionId);
      if (!mounted) return;
      if (status.isSuccess) {
        _pollTimer?.cancel();
        debugPrint('[verify] success -> routing to success callback');
        // Validation + persistence (Firestore upsert + anonymous auth) happen
        // on the success page, which is also the ThaiID deep-link landing
        // route. Routing here just covers the case where the deep link did not
        // fire on this device.
        context.go('${AppRoutes.onboardingSuccess}?sessionId=$sessionId');
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
