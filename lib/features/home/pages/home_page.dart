import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/config/web_features.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/thai_id.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../loan/data/loan_account_repository.dart';
import '../../loan/models/loan.dart';
import '../models/loan_summary.dart';

/// Opens the loan-request flow, choosing native vs hosted-web based on the
/// remote config flag `loanRequestUseWeb` (Firestore `config/app`).
///
/// - flag **true** (and on mobile): launches the loan-request flow hosted on
///   Firebase Hosting inside an in-app webview, so the business can update the
///   flow/conditions by redeploying the web build — no app-store release.
/// - flag **false**: opens the native [LoanRequestPage] (step 1).
///
/// On **web** we are already in a browser, so the native page is always used
/// (avoids embedding the app within itself).
void openLoanRequest(BuildContext context) {
  final appState = AppState.instance;

  if (appState.loanRequestUseWeb && !kIsWeb) {
    final thaiId = appState.profile?.thaiId ?? appState.thaiId ?? '';
    final hash = thaiId.isEmpty ? null : ThaiId.hash(thaiId);
    final url = WebFeatures.loanRequest(appState.env, hashThaiId: hash);
    context.push(AppRoutes.loanRequestWeb, extra: url);
    return;
  }

  context.push(AppRoutes.loanRequest);
}

/// Home page with credit-line card, statement summary, promo banner and a
/// bottom navigation between the home and "my info" tabs.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tab = 0;
  final LoanSummary _summary = LoanSummary.mock();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLoan();
      // Refresh remote feature flags (e.g. loanRequestUseWeb) so the
      // loan-request entry reflects the latest Firestore config.
      context.read<AppState>().loadRemoteConfig();
    });
  }

  /// Best-effort: if we don't already have a loan in state, try to load one
  /// from Firestore for the signed-in user.
  Future<void> _loadLoan() async {
    final appState = context.read<AppState>();
    if (appState.activeLoan != null) return;
    final thaiId = appState.profile?.thaiId ?? '';
    if (thaiId.isEmpty) return;
    final loan = await LoanAccountRepository().loadActiveLoan(thaiId);
    if (loan != null && mounted) appState.setActiveLoan(loan);
  }

  @override
  Widget build(BuildContext context) {
    final loan = context.watch<AppState>().activeLoan;
    return AppScaffold(
      showAppBar: false,
      body: _tab == 0
          ? _HomeTab(summary: _summary, loan: loan)
          : const _MyInfoTab(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.1),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.primary),
            label: 'หน้าหลัก',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppColors.primary),
            label: 'ข้อมูลของฉัน',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({required this.summary, this.loan});

  final LoanSummary summary;
  final Loan? loan;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: greeting + notification bell.
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'สวัสดี',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_none,
                      color: AppColors.textPrimary, size: 28),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _BalanceCard(summary: summary),
            const SizedBox(height: 12),
            _LinkRow(
              label: 'โอกาสเพิ่มวงเงินให้สูงขึ้น',
              onTap: () => openLoanRequest(context),
            ),
            const SizedBox(height: 16),
            if (loan != null)
              _LoanCard(loan: loan!)
            else
              _StatementCard(summary: summary),
            const SizedBox(height: 16),
            const _PromoBanner(),
          ],
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.summary});

  final LoanSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [AppColors.accent, AppColors.accentDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('วงเงินคงเหลือ',
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                Formatters.money(summary.availableCreditLine),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 6),
              const Text('บาท',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('วงเงินทั้งหมด',
                        style:
                            TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 2),
                    Text(
                      Formatters.baht(summary.totalCreditLine),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.accentDark,
                  minimumSize: const Size(120, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () => openLoanRequest(context),
                child: const Text('ถอนเงิน',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: const TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w700)),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_circle_right,
                size: 18, color: AppColors.accent),
          ],
        ),
      ),
    );
  }
}

class _LoanCard extends StatelessWidget {
  const _LoanCard({required this.loan});

  final Loan loan;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('สินเชื่อของคุณ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: loan.isClosed
                      ? Colors.green.withValues(alpha: 0.12)
                      : AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  loan.isClosed ? 'ชำระครบแล้ว' : 'อนุมัติแล้ว',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: loan.isClosed ? Colors.green : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('ยอดสินเชื่อคงเหลือ',
              style: TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                Formatters.money(loan.outstandingBalance),
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 6),
              const Text('บาท', style: TextStyle(color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: loan.termMonths == 0
                  ? 0
                  : loan.installmentsPaid / loan.termMonths,
              minHeight: 6,
              backgroundColor: AppColors.divider,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'ผ่อนแล้ว ${loan.installmentsPaid}/${loan.termMonths} งวด',
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const Divider(height: 28),
          _kv('ค่างวดต่อเดือน', Formatters.baht(loan.installmentAmount)),
          const SizedBox(height: 6),
          _kv('วันครบกำหนดถัดไป', Formatters.thaiDate(loan.nextDueDate)),
          if (!loan.isClosed) ...[
            const SizedBox(height: 6),
            _kv('ครบกำหนดในอีก', '${loan.daysUntilDue} วัน', bold: true),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.push(AppRoutes.loanDetail),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    minimumSize: const Size.fromHeight(46),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('รายละเอียด'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: loan.isClosed
                      ? null
                      : () => context.push(AppRoutes.paymentChannels),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(46),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('จ่ายเลย'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(k, style: const TextStyle(color: AppColors.textBody)),
        Text(v,
            style: TextStyle(
              color: AppColors.textBody,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            )),
      ],
    );
  }
}

class _StatementCard extends StatelessWidget {
  const _StatementCard({required this.summary});

  final LoanSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(summary.statementLabel,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => context.push(AppRoutes.loanDetail),
                  child: const Row(
                    children: [
                      Text('รายละเอียดสินเชื่อ',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700)),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_circle_right,
                          size: 18, color: AppColors.accent),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('ชำระยอดล่วงหน้า',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(110, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () => context.push(AppRoutes.paymentChannels),
                  child: const Text('จ่ายเลย'),
                ),
              ],
            ),
            const Divider(height: 28),
            _kv('ยอดรวมที่ต้องชำระ', Formatters.baht(summary.totalDue)),
            const Divider(height: 28),
            _kv('วันครบกำหนดชำระ', Formatters.thaiDate(summary.dueDate)),
            const SizedBox(height: 6),
            _kv('จะครบกำหนดชำระในอีก', '${summary.daysUntilDue} วัน',
                bold: true),
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(k, style: const TextStyle(color: AppColors.textBody)),
        Text(v,
            style: TextStyle(
              color: AppColors.textBody,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            )),
      ],
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFFDDE7FF), Color(0xFFF0F4FF)],
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department,
              color: AppColors.accent, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('วิธีหมุนเงินให้ติดปีก',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        fontSize: 16)),
                SizedBox(height: 2),
                Text('มือใหม่หัดหมุนต้องอ่าน!',
                    style: TextStyle(color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MyInfoTab extends StatelessWidget {
  const _MyInfoTab();

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AppState>().profile;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 8),
          const Text('ข้อมูลของฉัน',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 20),
          _infoTile('ชื่อ-นามสกุล',
              profile?.fullName.isNotEmpty == true ? profile!.fullName : '-'),
          _infoTile('เลขบัตรประชาชน', profile?.thaiId ?? '-'),
          _infoTile('เบอร์โทรศัพท์', profile?.phoneNumber ?? '-'),
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted)),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
