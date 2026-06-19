import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_scaffold.dart';

/// Loan detail: contract acknowledgement, outstanding balance, per-month tabs,
/// due date, and a billing summary.
class LoanDetailPage extends StatefulWidget {
  const LoanDetailPage({super.key});

  @override
  State<LoanDetailPage> createState() => _LoanDetailPageState();
}

class _LoanDetailPageState extends State<LoanDetailPage> {
  int _month = 0;
  static const _months = ['มิ.ย. 64', 'ก.ค. 64', 'ส.ค. 64'];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'รายละเอียดสินเชื่อ',
      padding: const EdgeInsets.all(16),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _contractCard(),
            const SizedBox(height: 16),
            _summaryCard(),
          ],
        ),
      ),
      bottomBar: ElevatedButton(
        onPressed: () => context.push(AppRoutes.paymentChannels),
        child: const Text('จ่ายเลย'),
      ),
    );
  }

  Widget _contractCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ข้าพเจ้า Finnie',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('เลขประจำตัวประชาชน XXXXXXXXX1234',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          const Text(
            '1. ขอยืนยันว่าได้สมัครใจกู้เงินฟินนิกซ์ติดปีก\n'
            '2. ขอสัญญาว่าจะทำตามเงื่อนไขและจะชำระเงินคืนให้ตรงเวลา',
            style: TextStyle(color: AppColors.textBody, height: 1.5),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('ลงชื่อ ',
                    style: TextStyle(color: AppColors.textMuted)),
                Text('Finnie',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                SizedBox(width: 4),
                Icon(Icons.fingerprint, color: AppColors.accent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Center(
            child: Text('ยอดค้างชำระรวม',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text('฿ ********',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_months.length, (i) {
              final selected = i == _month;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: ChoiceChip(
                  label: Text(_months[i]),
                  selected: selected,
                  onSelected: (_) => setState(() => _month = i),
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AppColors.textBody,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: const StadiumBorder(),
                ),
              );
            }),
          ),
          const Divider(height: 28),
          _kv('วันครบกำหนดชำระ', '**/**/****'),
          const SizedBox(height: 6),
          _kv('จะครบกำหนดชำระในอีก', 'วันนี้', bold: true),
          const Divider(height: 28),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('สรุปยอดการเรียกเก็บเงิน ณ วันนี้',
                style: TextStyle(fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 12),
          _kv('เงินต้นทั้งหมด', Formatters.baht(0).replaceAll('0.00', '********')),
          const SizedBox(height: 6),
          _kv('ดอกเบี้ยทั้งหมด',
              Formatters.baht(0).replaceAll('0.00', '********')),
          const SizedBox(height: 6),
          _kv('ค่างวดผ่อนจ่าย (XXXXXX)',
              Formatters.baht(0).replaceAll('0.00', '********')),
        ],
      ),
    );
  }

  Widget _kv(String k, String v, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
            child: Text(k, style: const TextStyle(color: AppColors.textBody))),
        Text(v,
            style: TextStyle(
              color: AppColors.textBody,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            )),
      ],
    );
  }
}
