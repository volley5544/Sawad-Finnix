import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_client.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../data/auth_repository.dart';

/// Step 1: enter phone number and request an OTP.
class PhonePage extends StatefulWidget {
  const PhonePage({super.key});

  @override
  State<PhonePage> createState() => _PhonePageState();
}

class _PhonePageState extends State<PhonePage> {
  final _controller = TextEditingController();
  bool _loading = false;
  String? _error;

  bool get _isValid => _controller.text.trim().length == 10;

  Future<void> _sendOtp() async {
    final phone = _controller.text.trim();
    setState(() {
      _loading = true;
      _error = null;
    });
    final appState = context.read<AppState>();
    final repo = AuthRepository(ApiClient(appState.env));
    try {
      final otp = await repo.sendOtp(phone);
      appState.phoneNumber = phone;
      appState.setOtp(code: otp.code, ref: otp.ref);
      if (!mounted) return;
      context.push(AppRoutes.otp);
    } catch (e) {
      setState(() => _error = '$e'.replaceFirst('AuthException: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
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
      title: 'เข้าสู่ระบบ',
      padding: const EdgeInsets.all(24),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'ยินดีต้อนรับ',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'กรุณากรอกหมายเลขโทรศัพท์มือถือเพื่อรับรหัส OTP',
              style: TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 32),
            const Text('หมายเลขโทรศัพท์มือถือ',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: '0XXXXXXXXX',
                counterText: '',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
      bottomBar: ElevatedButton(
        onPressed: (_isValid && !_loading) ? _sendOtp : null,
        child: _loading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Text('ขอรหัส OTP'),
      ),
    );
  }
}
