import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_scaffold.dart';

/// In-memory data collected across the loan-request steps.
///
/// Not persisted yet — wire to the loan-register API (its own base URL per
/// environment via `ApiService`) once that endpoint is provided.
class LoanRequestData {
  // Device permissions
  bool contactsGranted = false;
  bool deviceInfoGranted = false;
  bool locationGranted = false;
  bool smsGranted = false;

  // Personal
  String address = '';
  String area = '';
  String postcode = '';
  bool sameAsIdCard = true;
  String email = '';
  String education = '';

  // Contacts
  String c1Relation = '', c1First = '', c1Last = '', c1Phone = '';
  String c2Relation = '', c2First = '', c2Last = '', c2Phone = '';

  // Bank
  String payrollBank = '';

  // Consents
  bool agreeTerms = false;
  bool marketingConsent = false;
  bool creditModelConsent = false;
  bool productConsent = false;
}

/// Multi-step loan request flow.
class LoanRequestPage extends StatefulWidget {
  const LoanRequestPage({super.key});

  @override
  State<LoanRequestPage> createState() => _LoanRequestPageState();
}

class _LoanRequestPageState extends State<LoanRequestPage> {
  final _data = LoanRequestData();
  int _step = 0;

  static const _steps = <String>[
    'สิทธิ์การเข้าถึงอุปกรณ์',
    'ข้อมูลบัตรประชาชน',
    'ข้อมูลส่วนตัวเพิ่มเติม',
    'บุคคลที่สามารถติดต่อได้',
    'ข้อมูลเครดิต',
    'ข้อมูลธนาคาร',
  ];

  void _next() {
    if (_step < _steps.length - 1) {
      setState(() => _step++);
    } else {
      _goToSummary();
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      context.pop();
    }
  }

  Future<void> _goToSummary() async {
    final confirmed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => _SummaryPage(data: _data),
      ),
    );
    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ยืนยันวงเงินเบื้องต้นเรียบร้อยแล้ว')),
      );
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: _steps[_step],
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          onPressed: _back,
          icon: const Icon(Icons.arrow_back),
        ),
      ],
      padding: const EdgeInsets.all(16),
      body: Column(
        children: [
          _StepIndicator(steps: _steps, current: _step),
          const SizedBox(height: 16),
          Expanded(child: _buildStep()),
        ],
      ),
      bottomBar: ElevatedButton(
        onPressed: _next,
        child: Text(_step == _steps.length - 1 ? 'ถัดไป' : 'ถัดไป'),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _DevicePermissionsStep(data: _data, onChanged: _refresh);
      case 1:
        return const _IdCardStep();
      case 2:
        return _PersonalInfoStep(data: _data, onChanged: _refresh);
      case 3:
        return _ContactsStep(data: _data, onChanged: _refresh);
      case 4:
        return const _CreditStep();
      case 5:
        return _BankInfoStep(data: _data, onChanged: _refresh);
      default:
        return const SizedBox.shrink();
    }
  }

  void _refresh() => setState(() {});
}

// --- Step indicator ---------------------------------------------------------

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.steps, required this.current});

  final List<String> steps;
  final int current;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final done = (i ~/ 2) < current;
            return Expanded(
              child: Container(
                height: 2,
                color: done ? AppColors.primary : AppColors.divider,
              ),
            );
          }
          final idx = i ~/ 2;
          final done = idx < current;
          final active = idx == current;
          return Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (done || active) ? AppColors.primary : AppColors.divider,
            ),
            child: done
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Center(
                    child: Text('${idx + 1}',
                        style: TextStyle(
                          color: active ? Colors.white : AppColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        )),
                  ),
          );
        }),
      ),
    );
  }
}

// --- Step 0: device permissions --------------------------------------------

class _DevicePermissionsStep extends StatelessWidget {
  const _DevicePermissionsStep({required this.data, required this.onChanged});

  final LoanRequestData data;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const Text(
          'ยิ่งรู้จัก ยิ่งเพิ่มโอกาสได้วงเงินสูงขึ้น อนุญาตให้เราเข้าถึงข้อมูลของคุณ '
          'เพื่อให้เราวิเคราะห์ความสามารถในการชำระหนี้ของคุณได้ดียิ่งขึ้นนะ!',
          style: TextStyle(color: AppColors.textBody),
        ),
        const SizedBox(height: 8),
        const Text('ดูข้อกำหนดและเงื่อนไขการใช้บริการ',
            style: TextStyle(
                color: AppColors.primary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        _permTile('รายชื่อติดต่อ', data.contactsGranted, () {
          data.contactsGranted = !data.contactsGranted;
          onChanged();
        }),
        _permTile('ข้อมูลอุปกรณ์', data.deviceInfoGranted, () {
          data.deviceInfoGranted = !data.deviceInfoGranted;
          onChanged();
        }),
        _permTile('ตำแหน่งปัจจุบัน', data.locationGranted, () {
          data.locationGranted = !data.locationGranted;
          onChanged();
        }),
        _permTile('ข้อความ SMS', data.smsGranted, () {
          data.smsGranted = !data.smsGranted;
          onChanged();
        }),
      ],
    );
  }

  Widget _permTile(String label, bool granted, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w600))),
          OutlinedButton(
            onPressed: granted ? null : onTap,
            style: OutlinedButton.styleFrom(
              backgroundColor: granted ? null : AppColors.primary,
              foregroundColor: granted ? AppColors.primary : Colors.white,
              side: const BorderSide(color: AppColors.primary),
              shape: const StadiumBorder(),
            ),
            child: Text(granted ? 'เชื่อมต่อแล้ว' : 'เชื่อมต่อเลย'),
          ),
        ],
      ),
    );
  }
}

// --- Step 1: ID card --------------------------------------------------------

class _IdCardStep extends StatelessWidget {
  const _IdCardStep();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        Text('ข้อมูลบัตรประชาชน',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        SizedBox(height: 8),
        Text('ข้อมูลนี้ดึงมาจากการยืนยันตัวตน ThaiID ของคุณ',
            style: TextStyle(color: AppColors.textMuted)),
        SizedBox(height: 16),
        _ReadonlyField(label: 'เลขประจำตัวประชาชน', value: 'XXXXXXXXX1234'),
        _ReadonlyField(label: 'ชื่อ - นามสกุล', value: 'Finnie'),
        _ReadonlyField(label: 'วันออกบัตร', value: '-'),
        _ReadonlyField(label: 'วันหมดอายุ', value: '-'),
      ],
    );
  }
}

class _ReadonlyField extends StatelessWidget {
  const _ReadonlyField({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
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
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// --- Step 2: personal info --------------------------------------------------

class _PersonalInfoStep extends StatelessWidget {
  const _PersonalInfoStep({required this.data, required this.onChanged});

  final LoanRequestData data;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const _GroupTitle('ที่อยู่ปัจจุบัน'),
        _field('รายละเอียดที่อยู่', 'ระบุบ้านเลขที่ หมู่บ้าน ตรอก/ซอย ถนน',
            (v) => data.address = v),
        _field('พื้นที่ตั้ง', 'เลือกพื้นที่ตั้ง', (v) => data.area = v),
        _field('รหัสไปรษณีย์', 'ระบุรหัสไปรษณีย์', (v) => data.postcode = v),
        const SizedBox(height: 8),
        const _GroupTitle('ที่อยู่ตามบัตรประชาชน'),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: data.sameAsIdCard,
          activeColor: AppColors.primary,
          title: const Text('เหมือนที่อยู่ปัจจุบัน'),
          onChanged: (v) {
            data.sameAsIdCard = v ?? false;
            onChanged();
          },
        ),
        const SizedBox(height: 8),
        const _GroupTitle('ข้อมูลส่วนตัว'),
        _field('อีเมล', 'ระบุอีเมล', (v) => data.email = v),
        _field('ระดับการศึกษาสูงสุด', 'เลือกระดับการศึกษาสูงสุด',
            (v) => data.education = v),
      ],
    );
  }

  Widget _field(String label, String hint, ValueChanged<String> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            onChanged: onChanged,
            decoration: InputDecoration(hintText: hint),
          ),
        ],
      ),
    );
  }
}

class _GroupTitle extends StatelessWidget {
  const _GroupTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(
              fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
    );
  }
}

// --- Step 3: contacts -------------------------------------------------------

class _ContactsStep extends StatelessWidget {
  const _ContactsStep({required this.data, required this.onChanged});

  final LoanRequestData data;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _person('คนที่ 1 (โปรดระบุ)',
            relation: (v) => data.c1Relation = v,
            first: (v) => data.c1First = v,
            last: (v) => data.c1Last = v,
            phone: (v) => data.c1Phone = v),
        const SizedBox(height: 16),
        _person('คนที่ 2 (โปรดระบุ)',
            relation: (v) => data.c2Relation = v,
            first: (v) => data.c2First = v,
            last: (v) => data.c2Last = v,
            phone: (v) => data.c2Phone = v),
      ],
    );
  }

  Widget _person(
    String title, {
    required ValueChanged<String> relation,
    required ValueChanged<String> first,
    required ValueChanged<String> last,
    required ValueChanged<String> phone,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          _f('ความสัมพันธ์', 'เลือกความสัมพันธ์', relation),
          _f('ชื่อ', 'ระบุชื่อ (ภาษาไทย)', first),
          _f('นามสกุล', 'ระบุนามสกุล (ภาษาไทย)', last),
          _f('เบอร์โทรศัพท์มือถือ', 'XXX-XXX-XXXX', phone),
        ],
      ),
    );
  }

  Widget _f(String label, String hint, ValueChanged<String> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textMuted)),
          TextField(
            onChanged: onChanged,
            decoration: InputDecoration(hintText: hint),
          ),
        ],
      ),
    );
  }
}

// --- Step 4: credit (statement upload) -------------------------------------

class _CreditStep extends StatelessWidget {
  const _CreditStep();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Row(
          children: const [
            Icon(Icons.account_balance, color: AppColors.primary),
            SizedBox(width: 8),
            Text('ธนาคารฟินนิกซ์',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 16),
        const Text('อัพโหลดสเตทเม้นท์ตั้งแต่',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        SizedBox(
          height: 56,
          child: Row(
            children: const [
              _MonthChip('เม.ย. 64'),
              _MonthChip('พ.ค. 64'),
              _MonthChip('มิ.ย. 64'),
              _MonthChip('ก.ค. 64'),
              _MonthChip('ส.ค. 64'),
              _MonthChip('ก.ย. 64'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('กรอกรหัสผ่านเพื่อปลดล็อคไฟล์',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        const TextField(
          obscureText: true,
          decoration: InputDecoration(
            suffixIcon: Icon(Icons.visibility_outlined),
          ),
        ),
        const SizedBox(height: 16),
        _fileRow('XXXXXXXXXXXXXXXXXXXXXX'),
        _fileRow('XXXXXXXXXXXXXXXXXXXXXX'),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: FloatingActionButton.small(
            heroTag: 'add-statement',
            onPressed: () {},
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _fileRow(String name) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
              child: Text(name, overflow: TextOverflow.ellipsis)),
          const Icon(Icons.delete_outline, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class _MonthChip extends StatelessWidget {
  const _MonthChip(this.label);
  final String label;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(fontSize: 11, color: AppColors.textBody)),
        ],
      ),
    );
  }
}

// --- Step 5: bank info ------------------------------------------------------

class _BankInfoStep extends StatefulWidget {
  const _BankInfoStep({required this.data, required this.onChanged});

  final LoanRequestData data;
  final VoidCallback onChanged;

  @override
  State<_BankInfoStep> createState() => _BankInfoStepState();
}

class _BankInfoStepState extends State<_BankInfoStep> {
  bool _otherBanks = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const Text('กรุณาให้ข้อมูลมากที่สุด เพื่อให้เรารู้จักคุณมากขึ้น',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('คุณใช้ธนาคารอะไรเป็นบัญชีเงินเดือนของคุณ',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.textMuted)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.data.payrollBank.isEmpty
                          ? 'ธนาคารกสิกรไทย'
                          : widget.data.payrollBank,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textMuted),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('ข้อมูลที่จำเป็น',
            style: TextStyle(color: AppColors.textMuted)),
        const SizedBox(height: 8),
        _bankUploadRow('ธนาคารกสิกรไทย'),
        const SizedBox(height: 16),
        const Text('ข้อมูลเพิ่มเติม (ถ้ามี)',
            style: TextStyle(color: AppColors.textMuted)),
        const Text('กรุณาให้ข้อมูลธนาคารอื่นๆ เพื่อเพิ่มโอกาสการได้รับวงเงินที่สูงขึ้น',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Expanded(child: Text('ธนาคารอื่นๆ')),
              Switch(
                value: _otherBanks,
                activeThumbColor: AppColors.primary,
                onChanged: (v) => setState(() => _otherBanks = v),
              ),
            ],
          ),
        ),
        if (_otherBanks) ...[
          const SizedBox(height: 12),
          _bankUploadRow('ธนาคารไทยพาณิชย์'),
          _bankUploadRow('ธนาคารกรุงไทย'),
          _bankUploadRow('ธนาคารกรุงศรีอยุธยา'),
        ],
      ],
    );
  }

  Widget _bankUploadRow(String name) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_balance, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
              child: Text(name,
                  style: const TextStyle(fontWeight: FontWeight.w600))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(100, 40),
              shape: const StadiumBorder(),
            ),
            onPressed: () {},
            child: const Text('อัพโหลดเลย'),
          ),
        ],
      ),
    );
  }
}

// --- Summary + consents -----------------------------------------------------

class _SummaryPage extends StatefulWidget {
  const _SummaryPage({required this.data});
  final LoanRequestData data;

  @override
  State<_SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<_SummaryPage> {
  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    return AppScaffold(
      title: 'สรุปข้อมูลการขอวงเงินเบื้องต้น',
      padding: const EdgeInsets.all(16),
      body: ListView(
        children: [
          const _GroupTitle('ข้อมูลเครดิต'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: const [
                Expanded(child: Text('บริษัท ข้อมูลเครดิตแห่งชาติ จำกัด')),
                Text('ยินยอม',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _consentCheckbox(
            'ฉันได้อ่านและขอยอมรับ ข้อตกลงและคำรับรองในการสมัครขอใช้บริการสินเชื่อ',
            d.agreeTerms,
            (v) => setState(() => d.agreeTerms = v),
          ),
          _consentChoice(
            'ยินยอมในการเปิดเผยข้อมูลเพื่อวัตถุประสงค์ทางการตลาด',
            d.marketingConsent,
            (v) => setState(() => d.marketingConsent = v),
          ),
          _consentChoice(
            'ความยินยอมให้นำข้อมูลไปใช้จัดทำแบบจำลองด้านเครดิต',
            d.creditModelConsent,
            (v) => setState(() => d.creditModelConsent = v),
          ),
          _consentChoice(
            'ความยินยอมเพื่อใช้ข้อมูลในการพัฒนาและเสนอผลิตภัณฑ์',
            d.productConsent,
            (v) => setState(() => d.productConsent = v),
          ),
        ],
      ),
      bottomBar: ElevatedButton(
        onPressed: widget.data.agreeTerms
            ? () => Navigator.of(context).pop(true)
            : null,
        child: const Text('ยืนยันวงเงินเบื้องต้น'),
      ),
    );
  }

  Widget _consentCheckbox(String text, bool value, ValueChanged<bool> onCh) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      value: value,
      activeColor: AppColors.primary,
      title: Text(text, style: const TextStyle(fontSize: 13)),
      onChanged: (v) => onCh(v ?? false),
    );
  }

  Widget _consentChoice(String text, bool value, ValueChanged<bool> onCh) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text,
              style: const TextStyle(
                  color: AppColors.primary, fontWeight: FontWeight.w600)),
          Row(
            children: [
              _radio('ยินยอม', value == true, () => onCh(true)),
              const SizedBox(width: 16),
              _radio('ไม่ยินยอม', value == false, () => onCh(false)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _radio(String label, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? AppColors.primary : AppColors.textMuted,
              size: 20),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
    );
  }
}
