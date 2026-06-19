import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_scaffold.dart';

/// Payment receipt shown after a successful payment.
class ReceiptPage extends StatelessWidget {
  const ReceiptPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'ใบเสร็จรับเงิน',
      padding: const EdgeInsets.all(16),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          _receiptCard(context),
        ],
      ),
      bottomBar: ElevatedButton(
        onPressed: () => context.go(AppRoutes.home),
        child: const Text('ทำรายการอื่นต่อ'),
      ),
    );
  }

  Widget _receiptCard(BuildContext context) {
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
          const Text('******** บาท',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              Column(
                children: [
                  Text('จาก', style: TextStyle(color: AppColors.textMuted)),
                  SizedBox(height: 4),
                  Text('ฟินนิกซ์',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              Icon(Icons.arrow_forward, color: AppColors.textBody),
              Column(
                children: [
                  Text('ไปยัง', style: TextStyle(color: AppColors.textMuted)),
                  SizedBox(height: 4),
                  Text('บริษัท มันนิกซ์ จำกัด',
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
          _section('ข้อมูลการจ่ายค่างวดสินเชื่อฟินนิกซ์', const [
            ['เงินต้นและยอดผ่อนจ่าย', '********** บาท'],
            ['ดอกเบี้ยทั้งหมด', '********** บาท'],
            ['ค่าใช้จ่ายในการทวงถามหนี้', '***** บาท'],
            ['ค่าธรรมเนียมอื่นๆ', '***** บาท'],
          ]),
          const Divider(height: 28),
          _section('สรุปยอดคงเหลือ ณ วันรับชำระ', const [
            ['เงินต้นและยอดผ่อนจ่าย', '********** บาท'],
            ['ดอกเบี้ยทั้งหมด', '********** บาท'],
            ['ค่าใช้จ่ายในการทวงถามหนี้', '***** บาท'],
            ['ค่าธรรมเนียมอื่นๆ', '***** บาท'],
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
                          style:
                              const TextStyle(color: AppColors.textBody))),
                  Text(r[1],
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            )),
      ],
    );
  }
}
