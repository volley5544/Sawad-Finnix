import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/thai_id.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../models/loan.dart';

/// Loan detail: contract acknowledgement, outstanding balance, per-month
/// schedule, due date and a billing summary — all from the active loan.
class LoanDetailPage extends StatefulWidget {
  const LoanDetailPage({super.key});

  @override
  State<LoanDetailPage> createState() => _LoanDetailPageState();
}

class _LoanDetailPageState extends State<LoanDetailPage> {
  int? _month;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final loan = appState.activeLoan;
    final profile = appState.profile;

    if (loan == null) {
      return const AppScaffold(
        title: 'รายละเอียดสินเชื่อ',
        padding: EdgeInsets.all(16),
        body: Center(
          child: Text('ยังไม่มีสินเชื่อที่ใช้งานอยู่',
              style: TextStyle(color: AppColors.textMuted)),
        ),
      );
    }

    // Default the selected month to the current (next-due) installment.
    final selected = _month ?? loan.installmentsPaid.clamp(0, loan.termMonths - 1);
    final name = (profile?.fullName.isNotEmpty ?? false) ? profile!.fullName : '-';
    final maskedId = (profile?.thaiId != null && profile!.thaiId!.isNotEmpty)
        ? ThaiId.mask(profile.thaiId!)
        : '-';

    return AppScaffold(
      title: 'รายละเอียดสินเชื่อ',
      padding: const EdgeInsets.all(16),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _contractCard(name, maskedId),
            const SizedBox(height: 16),
            _summaryCard(loan, selected),
          ],
        ),
      ),
      bottomBar: ElevatedButton(
        onPressed: loan.isClosed
            ? null
            : () => context.push(AppRoutes.paymentChannels),
        child: Text(loan.isClosed ? 'ชำระครบแล้ว' : 'จ่ายเลย'),
      ),
    );
  }

  Widget _contractCard(String name, String maskedId) {
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
          Text('ข้าพเจ้า $name',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('เลขประจำตัวประชาชน $maskedId',
              style: const TextStyle(fontWeight: FontWeight.w600)),
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
              children: [
                const Text('ลงชื่อ ',
                    style: TextStyle(color: AppColors.textMuted)),
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(width: 4),
                const Icon(Icons.fingerprint, color: AppColors.accent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(Loan loan, int selected) {
    // Flat schedule: equal principal + interest portions each month.
    final principalPortion = loan.principal / loan.termMonths;
    final interestPortion = loan.totalInterest / loan.termMonths;
    final dueDate = _addMonths(loan.startedAt, selected + 1);

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
          Center(
            child: Text('฿ ${Formatters.money(loan.outstandingBalance)}',
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(loan.termMonths, (i) {
                final isSelected = i == selected;
                final paid = i < loan.installmentsPaid;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(
                      Formatters.thaiMonthYearShort(
                          _addMonths(loan.startedAt, i + 1)),
                    ),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _month = i),
                    avatar: paid
                        ? const Icon(Icons.check_circle,
                            color: Colors.green, size: 16)
                        : null,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textBody,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: const StadiumBorder(),
                  ),
                );
              }),
            ),
          ),
          const Divider(height: 28),
          _kv('วันครบกำหนดชำระ', Formatters.thaiDate(dueDate)),
          const SizedBox(height: 6),
          _kv('สถานะงวดนี้',
              selected < loan.installmentsPaid ? 'ชำระแล้ว' : 'รอชำระ',
              bold: true),
          const Divider(height: 28),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('สรุปยอดสินเชื่อ',
                style: TextStyle(fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 12),
          _kv('เงินต้นทั้งหมด', Formatters.baht(loan.principal)),
          const SizedBox(height: 6),
          _kv('ดอกเบี้ยทั้งหมด (${(loan.annualInterestRate * 100).toStringAsFixed(0)}%/ปี)',
              Formatters.baht(loan.totalInterest)),
          const SizedBox(height: 6),
          _kv('ยอดรวมที่ต้องชำระ', Formatters.baht(loan.totalPayable)),
          const Divider(height: 28),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('งวดที่เลือก',
                style: TextStyle(fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 12),
          _kv('เงินต้น', Formatters.baht(principalPortion)),
          const SizedBox(height: 6),
          _kv('ดอกเบี้ย', Formatters.baht(interestPortion)),
          const SizedBox(height: 6),
          _kv('ค่างวดที่ต้องชำระ', Formatters.baht(loan.installmentAmount),
              bold: true),
          const Divider(height: 28),
          _kv('ชำระแล้วทั้งหมด', Formatters.baht(loan.paidAmount)),
          const SizedBox(height: 6),
          _kv('ผ่อนแล้ว', '${loan.installmentsPaid}/${loan.termMonths} งวด'),
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

  static DateTime _addMonths(DateTime d, int months) {
    final total = (d.month - 1) + months;
    final year = d.year + (total ~/ 12);
    final month = (total % 12) + 1;
    final lastDay = DateTime(year, month + 1, 0).day;
    final day = d.day > lastDay ? lastDay : d.day;
    return DateTime(year, month, day);
  }
}
