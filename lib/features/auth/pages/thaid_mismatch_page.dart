import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_scaffold.dart';

/// Shown when the Thai ID / date of birth entered by the user does not match
/// the data returned by ThaiID. The user is sent back to re-enter their info.
class ThaidMismatchPage extends StatelessWidget {
  const ThaidMismatchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'ข้อมูลไม่ตรงกัน',
      padding: const EdgeInsets.all(24),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.report_gmailerrorred_outlined,
                size: 88, color: Colors.red),
            SizedBox(height: 24),
            Text(
              'ข้อมูลไม่ตรงกัน',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'เลขบัตรประชาชนหรือวันเดือนปีเกิดที่กรอก '
              'ไม่ตรงกับข้อมูลที่ยืนยันผ่าน ThaiID '
              'กรุณากรอกข้อมูลอีกครั้ง',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
      bottomBar: ElevatedButton(
        onPressed: () => context.go(AppRoutes.thaidInfo),
        child: const Text('กรอกข้อมูลอีกครั้ง'),
      ),
    );
  }
}
