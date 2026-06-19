import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_scaffold.dart';

/// Step 3: capture Thai national ID (13 digits) and date of birth.
/// Date of birth is displayed in the Thai Buddhist calendar (year + 543).
class ThaidInfoPage extends StatefulWidget {
  const ThaidInfoPage({super.key});

  @override
  State<ThaidInfoPage> createState() => _ThaidInfoPageState();
}

class _ThaidInfoPageState extends State<ThaidInfoPage> {
  final _idController = TextEditingController();
  DateTime? _dob;

  static const _thaiMonths = [
    'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
    'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม',
  ];

  String get _dobLabel {
    final d = _dob;
    if (d == null) return 'วัน/เดือน/ปี (พ.ศ.)';
    return '${d.day} ${_thaiMonths[d.month - 1]} ${d.year + 543}';
  }

  bool get _isValid => _idController.text.trim().length == 13 && _dob != null;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 20),
      firstDate: DateTime(1920),
      lastDate: now,
      helpText: 'เลือกวันเกิด',
    );
    if (picked != null) setState(() => _dob = picked);
  }

  void _next() {
    final appState = context.read<AppState>();
    appState.thaiId = _idController.text.trim();
    appState.dateOfBirth = _dob;
    context.push(AppRoutes.thaidVerify);
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'ยืนยันตัวตน',
      padding: const EdgeInsets.all(24),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'ข้อมูลส่วนตัว',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'กรุณากรอกเลขบัตรประจำตัวประชาชนและวันเดือนปีเกิด',
              style: TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 28),
            const Text('เลขบัตรประจำตัวประชาชน',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _idController,
              keyboardType: TextInputType.number,
              maxLength: 13,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'X-XXXX-XXXXX-XX-X',
                counterText: '',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: 16),
            const Text('วันเดือนปีเกิด',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                child: Text(
                  _dobLabel,
                  style: TextStyle(
                    color: _dob == null
                        ? AppColors.textMuted
                        : AppColors.textBody,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomBar: ElevatedButton(
        onPressed: _isValid ? _next : null,
        child: const Text('ถัดไป'),
      ),
    );
  }
}
