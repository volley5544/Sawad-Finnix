import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_scaffold.dart';

/// Payment channels: a fee-free SCB EASY option and other channels (barcode/QR).
class PaymentChannelsPage extends StatelessWidget {
  const PaymentChannelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'ช่องทางการชำระเงิน',
      padding: const EdgeInsets.all(16),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          const _SectionLabel('ฟรีค่าธรรมเนียม สะดวกรวดเร็ว'),
          const SizedBox(height: 8),
          _ChannelCard(
            icon: Icons.account_balance,
            iconColor: const Color(0xFF4E2A84),
            title: 'SCB EASY',
            subtitle: '(จ่ายผ่านเอสซีบี อีซี่)',
            onPay: () => context.push(AppRoutes.payLoan),
          ),
          const SizedBox(height: 20),
          const _SectionLabel('ช่องทางอื่นๆ'),
          const SizedBox(height: 8),
          _ChannelCard(
            icon: Icons.qr_code_2,
            iconColor: AppColors.primary,
            title: 'ชำระผ่านบาร์โค้ดหรือ\nคิวอาร์โค้ด',
            onPay: () => context.push(AppRoutes.paymentQr),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            color: AppColors.textMuted, fontWeight: FontWeight.w600));
  }
}

class _ChannelCard extends StatelessWidget {
  const _ChannelCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.onPay,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                if (subtitle != null)
                  Text(subtitle!,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(88, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: onPay,
            child: const Text('จ่ายเลย'),
          ),
        ],
      ),
    );
  }
}
