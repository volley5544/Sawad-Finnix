import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_scaffold.dart';

/// Pay loan: choose minimum or custom amount, enter amount, review breakdown.
class PayLoanPage extends StatefulWidget {
  const PayLoanPage({super.key});

  @override
  State<PayLoanPage> createState() => _PayLoanPageState();
}

class _PayLoanPageState extends State<PayLoanPage> {
  static const double _totalDue = 5000.68;
  bool _custom = true; // จ่ายตามใจ selected by default in the design
  final _amountController = TextEditingController();

  double get _amount {
    if (!_custom) return _totalDue;
    return double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
  }

  bool get _canPay => _amount > 0;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'ชำระเงินสินเชื่อ',
      actions: const [
        Icon(Icons.help_outline),
        SizedBox(width: 12),
      ],
      padding: const EdgeInsets.all(16),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          _toggle(),
          const SizedBox(height: 16),
          _summaryRow('สรุปยอดที่ต้องชำระ', Formatters.baht(_totalDue)),
          const SizedBox(height: 16),
          _amountCard(),
          const SizedBox(height: 16),
          _breakdownCard(),
        ],
      ),
      bottomBar: ElevatedButton(
        onPressed: _canPay ? () => context.push(AppRoutes.paymentQr) : null,
        child: const Text('ชำระเงินล่วงหน้า'),
      ),
    );
  }

  Widget _toggle() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _segment('จ่ายขั้นต่ำ', !_custom, () {
              setState(() => _custom = false);
            }),
            _segment('จ่ายตามใจ', _custom, () {
              setState(() => _custom = true);
            }),
          ],
        ),
      ),
    );
  }

  Widget _segment(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textMuted,
              fontWeight: FontWeight.w700,
            )),
      ),
    );
  }

  Widget _summaryRow(String k, String v) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: const TextStyle(color: AppColors.textBody)),
          Text(v, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _amountCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          const Text('จำนวนเงินที่ต้องจ่าย',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('฿',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted)),
              const SizedBox(width: 8),
              Expanded(
                child: _custom
                    ? TextField(
                        controller: _amountController,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.center,
                        onChanged: (_) => setState(() {}),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.]')),
                        ],
                        decoration: const InputDecoration(
                          hintText: 'กรุณาใส่จำนวนเงิน',
                          border: InputBorder.none,
                          filled: false,
                        ),
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary),
                      )
                    : Text(
                        Formatters.money(_totalDue),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary),
                      ),
              ),
              const Icon(Icons.edit, color: AppColors.primary, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'อีก 42 วัน จะถึงวันครบกำหนดชำระ สามารถเลือกจ่ายขั้นต่ำได้หลังจาก 28 วัน',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _breakdownCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('รายการชำระเงิน',
              style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          _row('จำนวนเงินที่ต้องจ่าย', Formatters.baht(_amount)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ส่วนลด',
                  style: TextStyle(color: AppColors.textBody)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('ไม่มีคูปองที่ใช้ได้',
                    style: TextStyle(
                        color: AppColors.textMuted, fontSize: 12)),
              ),
            ],
          ),
          const Divider(height: 24),
          _row('ยอดชำระจริง', Formatters.baht(_amount), bold: true),
        ],
      ),
    );
  }

  Widget _row(String k, String v, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(k, style: const TextStyle(color: AppColors.textBody)),
        Text(v,
            style: TextStyle(
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
      ],
    );
  }
}
