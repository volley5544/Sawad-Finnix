import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../data/loan_account_repository.dart';

/// QR / barcode payment screen. Shows the real amount due, lets the user save
/// the QR image to their photo gallery, and (on simulated success) deducts the
/// payment from the active loan.
class PaymentQrPage extends StatefulWidget {
  const PaymentQrPage({super.key});

  @override
  State<PaymentQrPage> createState() => _PaymentQrPageState();
}

class _PaymentQrPageState extends State<PaymentQrPage> {
  static const _initialSeconds = 15 * 60; // 15:00
  int _remaining = _initialSeconds;
  Timer? _timer;
  bool _saving = false;
  bool _processing = false;

  final GlobalKey _qrKey = GlobalKey();
  final LoanAccountRepository _loanRepo = LoanAccountRepository();

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

  double _amount(AppState s) =>
      s.pendingPaymentAmount ?? s.activeLoan?.installmentAmount ?? 0;

  /// Captures the QR widget and saves it to the device photo gallery.
  Future<void> _saveQrToGallery() async {
    if (kIsWeb) {
      _snack('การบันทึกรูปไม่รองรับบนเว็บ');
      return;
    }
    setState(() => _saving = true);
    try {
      final boundary = _qrKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) throw Exception('ไม่พบ QR');
      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception('แปลงรูปไม่สำเร็จ');
      final bytes = byteData.buffer.asUint8List();

      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess) await Gal.requestAccess(toAlbum: true);
      await Gal.putImageBytes(bytes,
          name: 'sawad-finnix-qr-${DateTime.now().millisecondsSinceEpoch}');
      if (!mounted) return;
      _snack('บันทึกคิวอาร์โค้ดลงในอัลบั้มรูปแล้ว');
    } on GalException catch (e) {
      if (!mounted) return;
      _snack('บันทึกรูปไม่สำเร็จ: ${e.type.message}');
    } catch (e) {
      if (!mounted) return;
      _snack('บันทึกรูปไม่สำเร็จ: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Simulates a successful payment: deducts the amount from the active loan,
  /// best-effort-persists it, then shows the receipt.
  Future<void> _confirmPayment() async {
    final appState = context.read<AppState>();
    final loan = appState.activeLoan;
    final amount = _amount(appState);
    if (loan == null || amount <= 0) return;

    setState(() => _processing = true);

    // Update app state immediately so the UI reflects the new balance.
    appState.applyPayment(amount);

    // Best-effort persistence (won't block the success flow).
    try {
      await _loanRepo.recordPayment(loan: loan, amount: amount);
    } catch (_) {/* already logged in repo */}

    if (!mounted) return;
    setState(() => _processing = false);
    context.push(AppRoutes.receipt);
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final amount = _amount(appState);

    return AppScaffold(
      title: 'ชำระผ่านบาร์โค้ดหรือคิวอาร์โค้ด',
      backgroundColor: AppColors.primary,
      padding: const EdgeInsets.all(16),
      body: ListView(
        children: [
          _qrCard(context, amount),
          const SizedBox(height: 16),
          _channelsCard(),
        ],
      ),
    );
  }

  Widget _qrCard(BuildContext context, double amount) {
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
          // RepaintBoundary lets us capture the QR as an image to save it.
          Center(
            child: RepaintBoundary(
              key: _qrKey,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(12),
                child: QrImageView(
                  data: 'SAWAD-FINNIX|PAY|${amount.toStringAsFixed(2)}|'
                      '${DateTime.now().millisecondsSinceEpoch}',
                  version: QrVersions.auto,
                  size: 200,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('จำนวนเงินที่ต้องชำระ ${Formatters.baht(amount)}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _saving ? null : _saveQrToGallery,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download),
            label: Text(_saving ? 'กำลังบันทึก...' : 'บันทึกลงในอัลบั้มรูป'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              minimumSize: const Size.fromHeight(48),
              shape: const StadiumBorder(),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _processing ? null : _confirmPayment,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: const StadiumBorder(),
            ),
            child: Text(_processing ? 'กำลังดำเนินการ...' : 'จำลองชำระเงินสำเร็จ'),
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
        ],
      ),
    );
  }
}
