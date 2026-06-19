import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_scaffold.dart';

/// QR / barcode payment screen with an expiry countdown and a list of bank
/// channels the user can pay through.
class PaymentQrPage extends StatefulWidget {
  const PaymentQrPage({super.key});

  @override
  State<PaymentQrPage> createState() => _PaymentQrPageState();
}

class _PaymentQrPageState extends State<PaymentQrPage> {
  static const _initialSeconds = 15 * 60; // 15:00
  int _remaining = _initialSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remaining <= 0) {
        t.cancel();
      } else {
        setState(() => _remaining--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _countdown {
    final m = (_remaining ~/ 60).toString().padLeft(2, '0');
    final s = (_remaining % 60).toString().padLeft(2, '0');
    return '$m.$s';
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'ชำระผ่านบาร์โค้ดหรือคิวอาร์โค้ด',
      backgroundColor: AppColors.primary,
      padding: const EdgeInsets.all(16),
      body: ListView(
        children: [
          _qrCard(context),
          const SizedBox(height: 16),
          _channelsCard(),
        ],
      ),
    );
  }

  Widget _qrCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text('คิวอาร์โค้ดจะหมดอายุในเวลา $_countdown',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('กรุณาชำระเงินในระยะเวลาที่กำหนด',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          const SizedBox(height: 16),
          Center(
            child: QrImageView(
              data: 'SAWAD-FINNIX|PAY|5000.68|${DateTime.now().millisecondsSinceEpoch}',
              version: QrVersions.auto,
              size: 200,
            ),
          ),
          const SizedBox(height: 16),
          const Text('จำนวนเงินที่ต้องชำระ ******** บาท',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('บันทึกลงในอัลบั้มรูปแล้ว')),
              );
            },
            child: const Text('บันทึกลงในอัลบั้มรูป'),
          ),
          const Divider(height: 28),
          InkWell(
            onTap: () {},
            child: Row(
              children: const [
                Icon(Icons.view_week, color: AppColors.primary),
                SizedBox(width: 8),
                Text('บาร์โค้ด', style: TextStyle(fontWeight: FontWeight.w600)),
                Spacer(),
                Icon(Icons.chevron_right, color: AppColors.textMuted),
              ],
            ),
          ),
          // Demo shortcut to the receipt (real flow waits for payment webhook).
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.push(AppRoutes.receipt),
            child: const Text('จำลองชำระเงินสำเร็จ'),
          ),
        ],
      ),
    );
  }

  Widget _channelsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text('คุณสามารถชำระผ่านช่องทางต่างๆ ได้ดังนี้',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textBody)),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: List.generate(11, (i) {
              return Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.account_balance,
                    color: AppColors.primary),
              );
            }),
          ),
          const SizedBox(height: 16),
          const Text(
            'คุณสามารถชำระผ่านทางแอพพลิเคชันของธนาคารทุกธนาคาร',
            style: TextStyle(color: AppColors.textBody),
          ),
          const SizedBox(height: 8),
          const Text(
            'หมายเหตุ:\n- คุณสามารถตรวจสอบรายชื่อธนาคารและผู้ให้บริการที่เข้าร่วม'
            'ได้จากเว็บไซต์ของธนาคารแห่งประเทศไทย',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
