import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_scaffold.dart';

/// Payment receipt shown after a successful payment, with the real paid amount
/// and the remaining loan balance.
class ReceiptPage extends StatelessWidget {
  const ReceiptPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final paid = appState.pendingPaymentAmount ?? 0;
    final loan = appState.activeLoan;

    return AppScaffold(
      title: 'ใบเสร็จรับเงิน',
      padding: const EdgeInsets.all(16),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          _receiptCard(context, paid, loan?.outstandingBalance ?? 0,
              loan?.installmentsPaid ?? 0, loan?.termMonths ?? 0,
              loan?.isClosed ?? false),
        ],
      ),
      bottomBar: ElevatedButton(
        onPressed: () {
          // Clear the just-paid amount before leaving the flow.
          appState.pendingPaymentAmount = null;
          context.go(AppRoutes.home);
        },
        child: const Text('ทำรายการอื่นต่อ'),
      ),
    );
  }

  Widget _receiptCard(
    BuildContext context,
    double paid,
    double remaining,
    int installmentsPaid,
    int termMonths,
    bool isClosed,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 44),
          ),
          const SizedBox(height: 16),
          const Text('ชำระเงินเรียบร้อยแล้ว',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('ยอดชำระทั้งสิ้น',
              style: TextStyle(color: AppColors.textMuted)),
          Text(Formatters.baht(paid),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              Column(
                children: [
                  Text('จาก', style: TextStyle(color: AppColors.textMuted)),
                  SizedBox(height: 4),
                  Text('คุณ', style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              Icon(Icons.arrow_forward, color: AppColors.textBody),
              Column(
                children: [
                  Text('ไปยัง', style: TextStyle(color: AppColors.textMuted)),
                  SizedBox(height: 4),
                  Text('สินเชื่อฟินนิกซ์',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ส่งใบเสร็จไปยังอีเมลแล้ว')),
              );
            },
            icon: const Icon(Icons.email_outlined),
            label: const Text('ส่งไปยังอีเมล'),
          ),
          const Divider(height: 28),
          _section('สรุปการชำระเงิน', [
            ['ยอดที่ชำระ', Formatters.baht(paid)],
            ['งวดที่ผ่อนแล้ว', '$installmentsPaid/$termMonths งวด'],
          ]),
          const Divider(height: 28),
          _section('ยอดคงเหลือ ณ วันรับชำระ', [
            ['ยอดสินเชื่อคงเหลือ', Formatters.baht(remaining)],
            ['สถานะสินเชื่อ', isClosed ? 'ชำระครบแล้ว' : 'อยู่ระหว่างผ่อนชำระ'],
          ]),
        ],
      ),
    );
  }

  Widget _section(String title, List<List<String>> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        ...rows.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                      child: Text(r[0],
                          style: const TextStyle(color: AppColors.textBody))),
                  Text(r[1],
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            )),
      ],
    );
  }
}
