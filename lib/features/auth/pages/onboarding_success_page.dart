import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_scaffold.dart';

/// Step 5: verification success, then continue to set a PIN.
class OnboardingSuccessPage extends StatelessWidget {
  const OnboardingSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final person = context.watch<AppState>().verifiedPerson;
    final name = person?.fullName ??
        [person?.firstName, person?.lastName]
            .whereType<String>()
            .join(' ')
            .trim();

    return AppScaffold(
      title: 'ยืนยันตัวตนสำเร็จ',
      padding: const EdgeInsets.all(24),
      body: Center(
        child: Column(
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
              Text(name,
                  style: const TextStyle(color: AppColors.textMuted)),
            ],
          ],
        ),
      ),
      bottomBar: ElevatedButton(
        onPressed: () => context.go(AppRoutes.setPin),
        child: const Text('ตั้งรหัส PIN'),
      ),
    );
  }
}
