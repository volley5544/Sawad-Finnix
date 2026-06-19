import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_client.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../data/auth_repository.dart';

/// Step 2: enter the OTP. Verification is client-side against the `code`
/// returned by the send-OTP call (stored in [AppState]).
class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _controller = TextEditingController();
  bool _resending = false;
  String? _error;

  void _verify() {
    final appState = context.read<AppState>();
    final repo = AuthRepository(ApiClient(appState.env));
    final ok = repo.verifyOtp(
      expectedCode: appState.otpCode ?? '',
      input: _controller.text,
    );
    if (ok) {
      setState(() => _error = null);
      context.push(AppRoutes.thaidInfo);
    } else {
      setState(() => _error = 'รหัส OTP ไม่ถูกต้อง');
    }
  }

  Future<void> _resend() async {
    final appState = context.read<AppState>();
    final phone = appState.phoneNumber;
    if (phone == null) return;
    setState(() {
      _resending = true;
      _error = null;
    });
    try {
      final otp = await AuthRepository(ApiClient(appState.env)).sendOtp(phone);
      appState.setOtp(code: otp.code, ref: otp.ref);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ส่งรหัส OTP ใหม่แล้ว')),
        );
      }
    } catch (e) {
      setState(() => _error = '$e'.replaceFirst('AuthException: ', ''));
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return AppScaffold(
      title: 'ยืนยัน OTP',
      padding: const EdgeInsets.all(24),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'กรอกรหัส OTP',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'รหัส OTP ถูกส่งไปยังหมายเลข ${appState.phoneNumber ?? ''}'
              '${appState.otpRef != null ? '  (Ref: ${appState.otpRef})' : ''}',
              style: const TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),
            PinCodeTextField(
              appContext: context,
              length: 6,
              controller: _controller,
              keyboardType: TextInputType.number,
              animationType: AnimationType.fade,
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              onCompleted: (_) => _verify(),
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(10),
                fieldHeight: 52,
                fieldWidth: 44,
                activeColor: AppColors.primary,
                selectedColor: AppColors.primary,
                inactiveColor: AppColors.divider,
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 4),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: _resending ? null : _resend,
                child: Text(_resending ? 'กำลังส่ง...' : 'ขอรหัสใหม่อีกครั้ง'),
              ),
            ),
          ],
        ),
      ),
      bottomBar: ElevatedButton(
        onPressed: _controller.text.length == 6 ? _verify : _verify,
        child: const Text('ยืนยัน'),
      ),
    );
  }
}
