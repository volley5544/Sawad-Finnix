import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/security/biometric_service.dart';
import '../../../core/security/pin_service.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../data/user_repository.dart';

/// Returning-user sign-in (second use of the app).
///
/// Two ways to authenticate:
///   1. PIN code (always available).
///   2. Biometrics (fingerprint / Face ID) — shown only when the device
///      supports it and the user enrolled at least one biometric.
///
/// Priority: when biometrics are enabled, they are the first choice and are
/// prompted automatically on entry; the PIN is the fallback. When biometrics
/// are available but the user has not enabled them yet, we prompt (once) to
/// suggest turning them on, while still allowing PIN sign-in.
///
/// After a successful authentication we re-fetch the profile from Firestore so
/// [AppState] reflects any server-side changes before continuing to home.
class PinLoginPage extends StatefulWidget {
  const PinLoginPage({super.key});

  @override
  State<PinLoginPage> createState() => _PinLoginPageState();
}

class _PinLoginPageState extends State<PinLoginPage> {
  final _controller = TextEditingController();
  final PinService _pin = PinService();
  final BiometricService _bio = BiometricService();
  final UserRepository _userRepo = UserRepository();

  String? _ownerId;
  bool _bioAvailable = false;
  bool _bioEnabled = false;
  bool _initializing = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final owner = await _pin.getOwner();
    final available = await _bio.isAvailable();
    final enabled = available && await _bio.isEnabled();
    if (!mounted) return;
    setState(() {
      _ownerId = owner;
      _bioAvailable = available;
      _bioEnabled = enabled;
      _initializing = false;
    });

    if (enabled) {
      // Biometrics are the first-priority sign-in: prompt immediately.
      await _authenticateBiometric();
    } else if (available) {
      // Supported but not yet enabled: invite the user to turn it on.
      _promptEnableBiometric();
    }
  }

  // ---- Authentication paths -------------------------------------------------

  Future<void> _authenticateBiometric() async {
    if (_busy) return;
    final ok = await _bio.authenticate(
      reason: 'ยืนยันตัวตนเพื่อเข้าสู่ระบบ',
    );
    if (!mounted) return;
    if (ok) {
      await _loginSuccess();
    } else {
      setState(() => _error = 'การยืนยันด้วยไบโอเมตริกซ์ไม่สำเร็จ '
          'กรุณาลองใหม่ หรือเข้าสู่ระบบด้วยรหัส PIN');
    }
  }

  Future<void> _onPinCompleted(String value) async {
    final ok = await _pin.verifyPin(value);
    if (!mounted) return;
    if (ok) {
      await _loginSuccess();
    } else {
      setState(() {
        _error = 'รหัส PIN ไม่ถูกต้อง';
        _controller.clear();
      });
    }
  }

  /// Common success path: refresh the profile from Firestore, push it into
  /// [AppState], then continue to home.
  Future<void> _loginSuccess() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final owner = _ownerId;
      if (owner != null && owner.isNotEmpty) {
        final profile = await _userRepo.loadProfileByThaiId(owner);
        if (profile != null) {
          // Use the shared singleton: this runs after an await, so avoid
          // reaching back through BuildContext.
          AppState.instance.setProfile(profile);
        }
      }
      if (!mounted) return;
      context.go(AppRoutes.home);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _controller.clear();
        _error = 'เข้าสู่ระบบไม่สำเร็จ: $e';
      });
    }
  }

  // ---- Enable-biometric prompt ---------------------------------------------

  Future<void> _promptEnableBiometric() async {
    final enable = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('เปิดใช้งานการเข้าสู่ระบบด้วยไบโอเมตริกซ์'),
        content: const Text(
          'เข้าสู่ระบบได้รวดเร็วและปลอดภัยยิ่งขึ้นด้วยลายนิ้วมือหรือ Face ID '
          'คุณต้องการเปิดใช้งานหรือไม่?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('ไว้ภายหลัง'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('เปิดใช้งาน'),
          ),
        ],
      ),
    );
    if (enable == true) {
      await _enableBiometric();
    }
  }

  Future<void> _enableBiometric() async {
    final ok = await _bio.authenticate(
      reason: 'ยืนยันตัวตนเพื่อเปิดใช้งานการเข้าสู่ระบบด้วยไบโอเมตริกซ์',
    );
    if (!mounted) return;
    if (ok) {
      await _bio.setEnabled(true);
      if (!mounted) return;
      setState(() => _bioEnabled = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เปิดใช้งานไบโอเมตริกซ์เรียบร้อยแล้ว')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่สามารถเปิดใช้งานไบโอเมตริกซ์ได้')),
      );
    }
  }

  // ---- UI -------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'เข้าสู่ระบบ',
      automaticallyImplyLeading: false,
      padding: const EdgeInsets.all(24),
      body: _initializing
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_busy) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_outline, color: Colors.white, size: 44),
          ),
          const SizedBox(height: 24),
          const Text(
            'กรอกรหัส PIN',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'กรอกรหัส PIN 6 หลักเพื่อเข้าสู่ระบบ',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 32),
          PinCodeTextField(
            appContext: context,
            length: 6,
            controller: _controller,
            obscureText: true,
            keyboardType: TextInputType.number,
            animationType: AnimationType.fade,
            autoDisposeControllers: false,
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            onCompleted: _onPinCompleted,
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
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ],
          const SizedBox(height: 24),
          if (_bioAvailable) _buildBiometricSection(),
        ],
      ),
    );
  }

  Widget _buildBiometricSection() {
    if (_bioEnabled) {
      // Enabled: offer a quick re-trigger of the biometric prompt.
      return Column(
        children: [
          const Divider(height: 32),
          OutlinedButton.icon(
            onPressed: _authenticateBiometric,
            icon: const Icon(Icons.fingerprint, color: AppColors.primary),
            label: const Text('เข้าสู่ระบบด้วยไบโอเมตริกซ์'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              minimumSize: const Size.fromHeight(52),
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
        ],
      );
    }

    // Available but not enabled: nudge the user to turn it on.
    return Column(
      children: [
        const Divider(height: 32),
        TextButton.icon(
          onPressed: _promptEnableBiometric,
          icon: const Icon(Icons.fingerprint, color: AppColors.primary),
          label: const Text('เปิดใช้งานการเข้าสู่ระบบด้วยไบโอเมตริกซ์'),
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
        ),
      ],
    );
  }
}
