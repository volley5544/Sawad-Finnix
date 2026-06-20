import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/security/pin_service.dart';
import '../../../core/theme/app_theme.dart';

/// Startup gate shown at '/'.
///
/// Decides where a launch should land:
///  - if a local PIN exists, this is a returning user (second use) → go to the
///    PIN-login screen (which prefers biometrics when enabled);
///  - otherwise start the onboarding flow at the phone step.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final PinService _pin = PinService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _decide());
  }

  Future<void> _decide() async {
    var hasPin = false;
    try {
      hasPin = await _pin.hasLocalPin();
    } catch (_) {
      // Secure storage unavailable (e.g. in tests / unsupported platform):
      // fall back to the onboarding flow rather than getting stuck.
      hasPin = false;
    }
    if (!mounted) return;
    context.go(hasPin ? AppRoutes.pinLogin : AppRoutes.phone);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}
