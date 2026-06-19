import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../data/user_repository.dart';

/// Step 6: set a 6-digit PIN for future sign-ins.
///
/// On confirmation: create-or-get the Firebase user/profile from the verified
/// onboarding data, then persist the PIN (hashed) locally and in Firebase.
class SetPinPage extends StatefulWidget {
  const SetPinPage({super.key});

  @override
  State<SetPinPage> createState() => _SetPinPageState();
}

class _SetPinPageState extends State<SetPinPage> {
  final _controller = TextEditingController();
  final UserRepository _userRepo = UserRepository();
  String? _firstEntry;
  String? _error;
  bool _saving = false;

  bool get _isConfirmStep => _firstEntry != null;

  Future<void> _onCompleted(String value) async {
    if (!_isConfirmStep) {
      setState(() {
        _firstEntry = value;
        _error = null;
        _controller.clear();
      });
      return;
    }

    if (value != _firstEntry) {
      setState(() {
        _error = 'รหัส PIN ไม่ตรงกัน กรุณาลองใหม่';
        _firstEntry = null;
        _controller.clear();
      });
      return;
    }

    await _finish(value);
  }

  Future<void> _finish(String pin) async {
    final appState = context.read<AppState>();
    final thaiId = appState.thaiId;
    if (thaiId == null || thaiId.isEmpty) {
      setState(() => _error = 'ไม่พบเลขบัตรประชาชน กรุณาเริ่มใหม่');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      // Reuse the profile created during ThaiID verification if present;
      // otherwise build one from the onboarding data. Then persist the PIN.
      var profile = appState.profile ??
          await _userRepo.createOrGetProfile(
            thaiId: thaiId,
            phoneNumber: appState.phoneNumber,
            person: appState.verifiedPerson,
            dateOfBirth: appState.dateOfBirth,
          );
      profile = await _userRepo.savePin(profile: profile, pin: pin);
      appState.setProfile(profile);
      if (!mounted) return;
      context.go(AppRoutes.home);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _firstEntry = null;
        _controller.clear();
        _error = 'บันทึกข้อมูลไม่สำเร็จ: $e';
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'ตั้งรหัส PIN',
      padding: const EdgeInsets.all(24),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Text(
              _isConfirmStep ? 'ยืนยันรหัส PIN' : 'ตั้งรหัส PIN 6 หลัก',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isConfirmStep
                  ? 'กรุณากรอกรหัส PIN อีกครั้งเพื่อยืนยัน'
                  : 'ใช้สำหรับเข้าสู่ระบบในครั้งถัดไป',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 32),
            if (_saving)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            else
              PinCodeTextField(
                appContext: context,
                length: 6,
                controller: _controller,
                obscureText: true,
                keyboardType: TextInputType.number,
                animationType: AnimationType.fade,
                // The controller is owned by this State; do not let the field
                // dispose it when it is swapped out (e.g. while _saving).
                autoDisposeControllers: false,
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
                onCompleted: _onCompleted,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.circle,
                  fieldHeight: 22,
                  fieldWidth: 22,
                  activeColor: AppColors.primary,
                  selectedColor: AppColors.primary,
                  inactiveColor: AppColors.divider,
                  activeFillColor: AppColors.primary,
                ),
              ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}
