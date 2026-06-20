import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/permissions/app_permissions.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/thai_id.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../auth/models/user_profile.dart';
import '../data/loan_repository.dart';
import '../data/loan_account_repository.dart';
import '../data/storage_repository.dart';
import '../models/loan_request.dart';
import '../models/uploaded_file.dart';

/// In-memory data collected across the loan-request steps.
///
/// Text inputs are backed by [TextEditingController]s owned by the page state
/// (so values persist when navigating between steps); their values are synced
/// into this object before validation / review. Dropdowns, checkboxes and
/// permission toggles write here directly.
class _LoanFormData {
  // Device permissions
  bool contactsGranted = false;
  bool deviceInfoGranted = false;
  bool locationGranted = false;
  bool smsGranted = false;

  // Current address + personal
  String address = '';
  String area = '';
  String postcode = '';
  bool sameAsIdCard = true;
  String email = '';
  String education = '';

  // Reference contacts
  String c1Relation = '', c1First = '', c1Last = '', c1Phone = '';
  String c2Relation = '', c2First = '', c2Last = '', c2Phone = '';

  // Bank
  String payrollBank = '';
  bool includeOtherBanks = false;

  // Statement attachments uploaded to Firebase Storage
  final List<UploadedFile> statements = [];

  LoanContact get contact1 => LoanContact(
        relation: c1Relation,
        firstName: c1First,
        lastName: c1Last,
        phone: c1Phone,
      );

  LoanContact get contact2 => LoanContact(
        relation: c2Relation,
        firstName: c2First,
        lastName: c2Last,
        phone: c2Phone,
      );
}

/// Multi-step loan (credit-line) request flow, pre-filled from the verified
/// [UserProfile] and persisted to Firestore on confirmation.
class LoanRequestPage extends StatefulWidget {
  const LoanRequestPage({super.key});

  @override
  State<LoanRequestPage> createState() => _LoanRequestPageState();
}

class _LoanRequestPageState extends State<LoanRequestPage> {
  final _data = _LoanFormData();
  UserProfile? _profile;
  int _step = 0;
  String? _stepError;

  final AppPermissions _permissions = const AppPermissions();
  final LoanRepository _loanRepo = LoanRepository();
  late final String _requestId;

  // Controllers for the free-text inputs.
  final _addressCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _postcodeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _c1FirstCtrl = TextEditingController();
  final _c1LastCtrl = TextEditingController();
  final _c1PhoneCtrl = TextEditingController();
  final _c2FirstCtrl = TextEditingController();
  final _c2LastCtrl = TextEditingController();
  final _c2PhoneCtrl = TextEditingController();

  static const _steps = <String>[
    'สิทธิ์การเข้าถึงอุปกรณ์',
    'ข้อมูลบัตรประชาชน',
    'ข้อมูลส่วนตัวเพิ่มเติม',
    'บุคคลที่สามารถติดต่อได้',
    'ข้อมูลเครดิต',
    'ข้อมูลธนาคาร',
  ];

  @override
  void initState() {
    super.initState();
    _profile = context.read<AppState>().profile;
    _requestId = _loanRepo.newRequestId(_profile?.thaiId ?? '');
    _loadPermissionStatuses();
  }

  /// Reflects any already-granted OS permissions in the tiles on entry.
  Future<void> _loadPermissionStatuses() async {
    var changed = false;
    for (final type in AppPermissionType.values) {
      if (await _permissions.check(type) == PermissionOutcome.granted) {
        _setGranted(type, true);
        changed = true;
      }
    }
    if (changed && mounted) setState(() {});
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _areaCtrl.dispose();
    _postcodeCtrl.dispose();
    _emailCtrl.dispose();
    _c1FirstCtrl.dispose();
    _c1LastCtrl.dispose();
    _c1PhoneCtrl.dispose();
    _c2FirstCtrl.dispose();
    _c2LastCtrl.dispose();
    _c2PhoneCtrl.dispose();
    super.dispose();
  }

  // ---- Sync + validation ----------------------------------------------------

  /// Copies controller text into [_data] so validation/review see fresh values.
  void _sync() {
    _data.address = _addressCtrl.text.trim();
    _data.area = _areaCtrl.text.trim();
    _data.postcode = _postcodeCtrl.text.trim();
    _data.email = _emailCtrl.text.trim();
    _data.c1First = _c1FirstCtrl.text.trim();
    _data.c1Last = _c1LastCtrl.text.trim();
    _data.c1Phone = _c1PhoneCtrl.text.trim();
    _data.c2First = _c2FirstCtrl.text.trim();
    _data.c2Last = _c2LastCtrl.text.trim();
    _data.c2Phone = _c2PhoneCtrl.text.trim();
  }

  bool _emailValid(String s) =>
      RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$').hasMatch(s);

  /// Returns a Thai error message when [step] is invalid, else null.
  String? _validate(int step) {
    switch (step) {
      case 1:
        if (_profile?.thaiId == null || _profile!.thaiId!.isEmpty) {
          return 'ไม่พบข้อมูลบัตรประชาชน กรุณายืนยันตัวตนใหม่';
        }
        return null;
      case 2:
        if (!_data.sameAsIdCard) {
          if (_data.address.isEmpty) return 'กรุณาระบุรายละเอียดที่อยู่ปัจจุบัน';
          if (_data.area.isEmpty) return 'กรุณาระบุพื้นที่ (อำเภอ/จังหวัด)';
          if (_data.postcode.length != 5) {
            return 'กรุณาระบุรหัสไปรษณีย์ 5 หลัก';
          }
        }
        if (_data.email.isEmpty || !_emailValid(_data.email)) {
          return 'กรุณาระบุอีเมลให้ถูกต้อง';
        }
        if (_data.education.isEmpty) return 'กรุณาเลือกระดับการศึกษาสูงสุด';
        return null;
      case 3:
        if (!_data.contact1.isComplete) {
          return 'กรุณากรอกข้อมูลผู้ติดต่อคนที่ 1 ให้ครบถ้วน '
              '(เบอร์โทร 10 หลัก)';
        }
        if (!_data.contact2.isEmpty && !_data.contact2.isComplete) {
          return 'กรุณากรอกข้อมูลผู้ติดต่อคนที่ 2 ให้ครบถ้วน หรือเว้นว่างไว้';
        }
        return null;
      case 5:
        if (_data.payrollBank.isEmpty) {
          return 'กรุณาเลือกธนาคารบัญชีเงินเดือน';
        }
        return null;
      default:
        return null;
    }
  }

  // ---- Navigation -----------------------------------------------------------

  void _next() {
    _sync();
    final err = _validate(_step);
    if (err != null) {
      setState(() => _stepError = err);
      return;
    }
    setState(() => _stepError = null);
    if (_step < _steps.length - 1) {
      setState(() => _step++);
    } else {
      _goToSummary();
    }
  }

  void _back() {
    setState(() => _stepError = null);
    if (_step > 0) {
      setState(() => _step--);
    } else {
      context.pop();
    }
  }

  Future<void> _goToSummary() async {
    _sync();
    final profile = _profile;
    if (profile == null || (profile.thaiId ?? '').isEmpty) {
      setState(() => _stepError =
          'ไม่พบข้อมูลผู้ใช้ที่ยืนยันแล้ว กรุณายืนยันตัวตนใหม่');
      return;
    }
    final confirmed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            _SummaryPage(profile: profile, data: _data, requestId: _requestId),
      ),
    );
    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ส่งคำขอวงเงินเบื้องต้นเรียบร้อยแล้ว')),
      );
      context.go(AppRoutes.home);
    }
  }

  // ---- Build ----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final isLast = _step == _steps.length - 1;
    return AppScaffold(
      title: _steps[_step],
      automaticallyImplyLeading: false,
      actions: [
        IconButton(onPressed: _back, icon: const Icon(Icons.arrow_back)),
      ],
      padding: const EdgeInsets.all(16),
      body: Column(
        children: [
          _StepIndicator(steps: _steps, current: _step),
          const SizedBox(height: 16),
          Expanded(child: _buildStep()),
          if (_stepError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _stepError!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ),
        ],
      ),
      bottomBar: ElevatedButton(
        onPressed: _next,
        child: Text(isLast ? 'ตรวจสอบและยืนยัน' : 'ถัดไป'),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _buildPermissionsStep();
      case 1:
        return _buildIdCardStep();
      case 2:
        return _buildPersonalStep();
      case 3:
        return _buildContactsStep();
      case 4:
        return _buildCreditStep();
      case 5:
        return _buildBankStep();
      default:
        return const SizedBox.shrink();
    }
  }

  // ---- Step 0: permissions --------------------------------------------------

  Widget _buildPermissionsStep() {
    return ListView(
      children: [
        const Text(
          'ยิ่งรู้จัก ยิ่งเพิ่มโอกาสได้วงเงินสูงขึ้น อนุญาตให้เราเข้าถึงข้อมูลของคุณ '
          'เพื่อให้เราวิเคราะห์ความสามารถในการชำระหนี้ของคุณได้ดียิ่งขึ้นนะ!',
          style: TextStyle(color: AppColors.textBody),
        ),
        const SizedBox(height: 16),
        _permTile(AppPermissionType.contacts, 'รายชื่อติดต่อ',
            Icons.contacts_outlined),
        _permTile(AppPermissionType.deviceInfo, 'ข้อมูลอุปกรณ์',
            Icons.phone_android_outlined),
        _permTile(AppPermissionType.location, 'ตำแหน่งปัจจุบัน',
            Icons.location_on_outlined),
        _permTile(AppPermissionType.sms, 'ข้อความ SMS', Icons.sms_outlined),
      ],
    );
  }

  Widget _permTile(AppPermissionType type, String label, IconData icon) {
    final supported = _permissions.isSupported(type);
    final granted = _isGranted(type);

    final String btnText;
    final VoidCallback? onPressed;
    if (!supported) {
      btnText = 'ไม่รองรับ';
      onPressed = null;
    } else if (granted) {
      btnText = 'อนุญาตแล้ว';
      onPressed = null;
    } else {
      btnText = 'อนุญาต';
      onPressed = () => _requestPermission(type, label);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon,
              color: granted ? AppColors.primary : AppColors.textMuted,
              size: 22),
          const SizedBox(width: 12),
          Expanded(
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w600))),
          OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              backgroundColor: granted || !supported ? null : AppColors.primary,
              foregroundColor:
                  granted ? AppColors.primary : (supported ? Colors.white : AppColors.textMuted),
              side: BorderSide(
                  color: supported ? AppColors.primary : AppColors.divider),
              shape: const StadiumBorder(),
            ),
            child: Text(btnText),
          ),
        ],
      ),
    );
  }

  // ---- Permission helpers ---------------------------------------------------

  bool _isGranted(AppPermissionType type) {
    switch (type) {
      case AppPermissionType.contacts:
        return _data.contactsGranted;
      case AppPermissionType.deviceInfo:
        return _data.deviceInfoGranted;
      case AppPermissionType.location:
        return _data.locationGranted;
      case AppPermissionType.sms:
        return _data.smsGranted;
    }
  }

  void _setGranted(AppPermissionType type, bool value) {
    switch (type) {
      case AppPermissionType.contacts:
        _data.contactsGranted = value;
        break;
      case AppPermissionType.deviceInfo:
        _data.deviceInfoGranted = value;
        break;
      case AppPermissionType.location:
        _data.locationGranted = value;
        break;
      case AppPermissionType.sms:
        _data.smsGranted = value;
        break;
    }
  }

  Future<void> _requestPermission(AppPermissionType type, String label) async {
    final outcome = await _permissions.request(type);
    if (!mounted) return;
    switch (outcome) {
      case PermissionOutcome.granted:
        setState(() => _setGranted(type, true));
        break;
      case PermissionOutcome.denied:
        setState(() => _setGranted(type, false));
        _snack('ยังไม่ได้รับอนุญาตให้เข้าถึง$label');
        break;
      case PermissionOutcome.permanentlyDenied:
        setState(() => _setGranted(type, false));
        await _showSettingsDialog(label);
        break;
      case PermissionOutcome.unsupported:
        _snack('อุปกรณ์นี้ไม่รองรับการขอสิทธิ์$label');
        break;
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showSettingsDialog(String label) async {
    final open = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ต้องการสิทธิ์การเข้าถึง'),
        content: Text(
          'คุณได้ปิดการอนุญาต "$label" ไว้ '
          'กรุณาเปิดสิทธิ์ในการตั้งค่าของระบบเพื่อดำเนินการต่อ',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('เปิดการตั้งค่า'),
          ),
        ],
      ),
    );
    if (open == true) {
      await _permissions.openSettings();
    }
  }

  // ---- Step 1: ID card (from profile) --------------------------------------

  Widget _buildIdCardStep() {
    final p = _profile;
    final maskedId = (p?.thaiId != null && p!.thaiId!.isNotEmpty)
        ? ThaiId.mask(p.thaiId!)
        : '-';
    final name = (p?.fullName.isNotEmpty ?? false) ? p!.fullName : '-';
    final dob = p?.dateOfBirth != null ? Formatters.thaiDate(p!.dateOfBirth!) : '-';
    final gender = _genderTh(p?.gender);
    final idAddress = _idCardAddress(p);

    return ListView(
      children: [
        const Text('ข้อมูลบัตรประชาชน',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        const Text('ข้อมูลนี้ดึงมาจากการยืนยันตัวตน ThaiID ของคุณ',
            style: TextStyle(color: AppColors.textMuted)),
        const SizedBox(height: 16),
        _readonly('เลขประจำตัวประชาชน', maskedId),
        _readonly('ชื่อ - นามสกุล', name),
        _readonly('วัน/เดือน/ปีเกิด', dob),
        if (gender != '-') _readonly('เพศ', gender),
        if (idAddress != '-') _readonly('ที่อยู่ตามบัตรประชาชน', idAddress),
      ],
    );
  }

  // ---- Step 2: personal info -----------------------------------------------

  Widget _buildPersonalStep() {
    final idAddress = _idCardAddress(_profile);
    return ListView(
      children: [
        const _GroupTitle('ที่อยู่ตามบัตรประชาชน'),
        _readonly('ที่อยู่', idAddress),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: _data.sameAsIdCard,
          activeColor: AppColors.primary,
          title: const Text('ที่อยู่ปัจจุบันเหมือนที่อยู่ตามบัตรประชาชน'),
          onChanged: (v) => setState(() => _data.sameAsIdCard = v ?? false),
        ),
        if (!_data.sameAsIdCard) ...[
          const SizedBox(height: 8),
          const _GroupTitle('ที่อยู่ปัจจุบัน'),
          _textField(
            label: 'รายละเอียดที่อยู่',
            controller: _addressCtrl,
            hint: 'บ้านเลขที่ หมู่บ้าน ตรอก/ซอย ถนน',
          ),
          _textField(
            label: 'พื้นที่ (อำเภอ/จังหวัด)',
            controller: _areaCtrl,
            hint: 'ระบุอำเภอและจังหวัด',
          ),
          _textField(
            label: 'รหัสไปรษณีย์',
            controller: _postcodeCtrl,
            hint: 'ระบุรหัสไปรษณีย์ 5 หลัก',
            keyboardType: TextInputType.number,
            formatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 5,
          ),
        ],
        const SizedBox(height: 8),
        const _GroupTitle('ข้อมูลส่วนตัว'),
        _textField(
          label: 'อีเมล',
          controller: _emailCtrl,
          hint: 'ระบุอีเมล',
          keyboardType: TextInputType.emailAddress,
        ),
        _dropdown(
          label: 'ระดับการศึกษาสูงสุด',
          hint: 'เลือกระดับการศึกษาสูงสุด',
          value: _data.education.isEmpty ? null : _data.education,
          options: LoanRequest.educationOptions,
          onChanged: (v) => setState(() => _data.education = v ?? ''),
        ),
      ],
    );
  }

  // ---- Step 3: contacts -----------------------------------------------------

  Widget _buildContactsStep() {
    return ListView(
      children: [
        const Text('ระบุบุคคลที่สามารถติดต่อได้ อย่างน้อย 1 คน',
            style: TextStyle(color: AppColors.textMuted)),
        const SizedBox(height: 12),
        _contactCard(
          title: 'คนที่ 1 (จำเป็น)',
          relation: _data.c1Relation,
          onRelation: (v) => setState(() => _data.c1Relation = v ?? ''),
          firstCtrl: _c1FirstCtrl,
          lastCtrl: _c1LastCtrl,
          phoneCtrl: _c1PhoneCtrl,
        ),
        const SizedBox(height: 16),
        _contactCard(
          title: 'คนที่ 2 (ถ้ามี)',
          relation: _data.c2Relation,
          onRelation: (v) => setState(() => _data.c2Relation = v ?? ''),
          firstCtrl: _c2FirstCtrl,
          lastCtrl: _c2LastCtrl,
          phoneCtrl: _c2PhoneCtrl,
        ),
      ],
    );
  }

  Widget _contactCard({
    required String title,
    required String relation,
    required ValueChanged<String?> onRelation,
    required TextEditingController firstCtrl,
    required TextEditingController lastCtrl,
    required TextEditingController phoneCtrl,
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
          _dropdown(
            label: 'ความสัมพันธ์',
            hint: 'เลือกความสัมพันธ์',
            value: relation.isEmpty ? null : relation,
            options: LoanRequest.relationOptions,
            onChanged: onRelation,
            dense: true,
          ),
          _textField(label: 'ชื่อ', controller: firstCtrl, hint: 'ระบุชื่อ', dense: true),
          _textField(label: 'นามสกุล', controller: lastCtrl, hint: 'ระบุนามสกุล', dense: true),
          _textField(
            label: 'เบอร์โทรศัพท์มือถือ',
            controller: phoneCtrl,
            hint: 'ระบุเบอร์ 10 หลัก',
            keyboardType: TextInputType.phone,
            formatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 10,
            dense: true,
          ),
        ],
      ),
    );
  }

  // ---- Step 4: credit (statement upload to Firebase Storage) ---------------

  Widget _buildCreditStep() {
    return _CreditStep(data: _data, profile: _profile, requestId: _requestId);
  }

  // ---- Step 5: bank ---------------------------------------------------------

  Widget _buildBankStep() {
    return ListView(
      children: [
        const Text('กรุณาให้ข้อมูลมากที่สุด เพื่อให้เรารู้จักคุณมากขึ้น',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        _dropdown(
          label: 'ธนาคารบัญชีเงินเดือน',
          hint: 'เลือกธนาคาร',
          value: _data.payrollBank.isEmpty ? null : _data.payrollBank,
          options: LoanRequest.bankOptions,
          onChanged: (v) => setState(() => _data.payrollBank = v ?? ''),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text('แนบข้อมูลธนาคารอื่น ๆ เพิ่มเติม'),
              ),
              Switch(
                value: _data.includeOtherBanks,
                activeThumbColor: AppColors.primary,
                onChanged: (v) => setState(() => _data.includeOtherBanks = v),
              ),
            ],
          ),
        ),
        if (_data.includeOtherBanks) ...[
          const SizedBox(height: 8),
          const Text(
            'การให้ข้อมูลธนาคารอื่นเพิ่มเติมจะช่วยเพิ่มโอกาสได้รับวงเงินที่สูงขึ้น',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ],
    );
  }

  // ---- Shared field helpers -------------------------------------------------

  Widget _textField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? formatters,
    int? maxLength,
    bool dense = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: dense ? 10 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                fontWeight: dense ? FontWeight.w500 : FontWeight.w600,
                fontSize: dense ? 12 : 14,
                color: dense ? AppColors.textMuted : AppColors.textBody,
              )),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: formatters,
            maxLength: maxLength,
            onChanged: (_) {
              if (_stepError != null) setState(() => _stepError = null);
            },
            decoration: InputDecoration(
              hintText: hint,
              counterText: '',
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String hint,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    bool dense = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: dense ? 10 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                fontWeight: dense ? FontWeight.w500 : FontWeight.w600,
                fontSize: dense ? 12 : 14,
                color: dense ? AppColors.textMuted : AppColors.textBody,
              )),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: value,
            isExpanded: true,
            hint: Text(hint, style: const TextStyle(color: AppColors.textMuted)),
            items: options
                .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                .toList(),
            onChanged: (v) {
              if (_stepError != null) setState(() => _stepError = null);
              onChanged(v);
            },
          ),
        ],
      ),
    );
  }

  Widget _readonly(String label, String value) =>
      _ReadonlyField(label: label, value: value);

  // ---- Profile helpers ------------------------------------------------------

  static String _genderTh(String? g) {
    switch ((g ?? '').toLowerCase()) {
      case 'male':
      case 'ชาย':
        return 'ชาย';
      case 'female':
      case 'หญิง':
        return 'หญิง';
      default:
        return g?.isNotEmpty == true ? g! : '-';
    }
  }

  static String _idCardAddress(UserProfile? p) {
    final a = p?.houseAddress?.trim();
    if (a != null && a.isNotEmpty) return a;
    final b = p?.address?.trim();
    if (b != null && b.isNotEmpty) return b;
    return '-';
  }
}

// --- Step indicator ---------------------------------------------------------

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.steps, required this.current});

  final List<String> steps;
  final int current;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(color: AppColors.textMuted)),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
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

/// A simple dashed-look upload affordance for the (optional) statement step.
class DottedUploadBox extends StatelessWidget {
  const DottedUploadBox({
    super.key,
    required this.onTap,
    this.enabled = true,
    this.label = 'แตะเพื่อแนบไฟล์ (PDF / รูปภาพ)',
  });

  final VoidCallback onTap;
  final bool enabled;
  final String label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: enabled ? AppColors.primary : AppColors.divider,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_upload_outlined,
                color: enabled ? AppColors.primary : AppColors.textMuted,
                size: 36),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

/// Step 4 body: pick statement files and upload them to Firebase Storage,
/// showing per-file progress and allowing removal. Uploaded file references are
/// written into [data.statements] for persistence on submit.
class _CreditStep extends StatefulWidget {
  const _CreditStep({
    required this.data,
    required this.profile,
    required this.requestId,
  });

  final _LoanFormData data;
  final UserProfile? profile;
  final String requestId;

  @override
  State<_CreditStep> createState() => _CreditStepState();
}

class _CreditStepState extends State<_CreditStep> {
  final StorageRepository _storage = StorageRepository();

  static const int _maxBytes = 10 * 1024 * 1024; // 10 MB per file

  bool _busy = false;
  double _progress = 0;
  String? _currentName;
  String? _error;

  List<UploadedFile> get _files => widget.data.statements;

  Future<void> _pickAndUpload() async {
    final thaiId = widget.profile?.thaiId ?? '';
    if (thaiId.isEmpty) {
      setState(() => _error = 'ไม่พบข้อมูลผู้ใช้ กรุณายืนยันตัวตนใหม่');
      return;
    }

    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg'],
        allowMultiple: true,
        withData: true,
      );
    } catch (e) {
      setState(() => _error = 'เปิดตัวเลือกไฟล์ไม่สำเร็จ: $e');
      return;
    }
    if (result == null) return; // user cancelled

    setState(() => _error = null);
    for (final file in result.files) {
      final bytes = file.bytes;
      if (bytes == null) continue;
      if (bytes.length > _maxBytes) {
        setState(() => _error = 'ไฟล์ ${file.name} มีขนาดเกิน 10 MB');
        continue;
      }
      setState(() {
        _busy = true;
        _currentName = file.name;
        _progress = 0;
      });
      try {
        final uploaded = await _storage.uploadStatement(
          thaiId: thaiId,
          fileName: file.name,
          bytes: bytes,
          requestId: widget.requestId,
          onProgress: (p) {
            if (mounted) setState(() => _progress = p);
          },
        );
        if (!mounted) return;
        setState(() => _files.add(uploaded));
      } catch (e) {
        if (!mounted) return;
        setState(() => _error = 'อัพโหลด ${file.name} ไม่สำเร็จ: $e');
      }
    }
    if (mounted) {
      setState(() {
        _busy = false;
        _currentName = null;
        _progress = 0;
      });
    }
  }

  Future<void> _remove(UploadedFile file) async {
    setState(() => _files.remove(file));
    try {
      await _storage.delete(file.path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ลบไฟล์บนเซิร์ฟเวอร์ไม่สำเร็จ: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Row(
          children: const [
            Icon(Icons.account_balance, color: AppColors.primary),
            SizedBox(width: 8),
            Expanded(
              child: Text('ข้อมูลเครดิต / สเตทเม้นท์',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'แนบสเตทเม้นท์ย้อนหลังเพื่อเพิ่มโอกาสได้รับวงเงินที่สูงขึ้น '
          'รองรับไฟล์ PDF หรือรูปภาพ (ไม่บังคับ ข้ามขั้นตอนนี้ได้)',
          style: TextStyle(color: AppColors.textMuted),
        ),
        const SizedBox(height: 16),
        DottedUploadBox(enabled: !_busy, onTap: _pickAndUpload),
        if (_busy) ...[
          const SizedBox(height: 16),
          Text('กำลังอัพโหลด ${_currentName ?? ''}...',
              style: const TextStyle(color: AppColors.textBody)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _progress == 0 ? null : _progress,
              minHeight: 6,
              backgroundColor: AppColors.divider,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text('${(_progress * 100).toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ],
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: Colors.red)),
        ],
        if (_files.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text('ไฟล์ที่แนบแล้ว',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ..._files.map(_fileRow),
        ],
      ],
    );
  }

  Widget _fileRow(UploadedFile file) {
    final isPdf = (file.contentType ?? '').contains('pdf') ||
        file.name.toLowerCase().endsWith('.pdf');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(isPdf ? Icons.picture_as_pdf : Icons.image,
              color: isPdf ? Colors.red : AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(file.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(file.readableSize,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          IconButton(
            onPressed: _busy ? null : () => _remove(file),
            icon: const Icon(Icons.delete_outline, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

// --- Summary + consents + submit -------------------------------------------

class _SummaryPage extends StatefulWidget {
  const _SummaryPage({
    required this.profile,
    required this.data,
    required this.requestId,
  });
  final UserProfile profile;
  final _LoanFormData data;
  final String requestId;

  @override
  State<_SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<_SummaryPage> {
  final LoanRepository _repo = LoanRepository();
  final LoanAccountRepository _loanAccountRepo = LoanAccountRepository();

  bool _agreeTerms = false;
  bool _marketing = false;
  bool _creditModel = false;
  bool _product = false;
  bool _submitting = false;
  String? _error;

  LoanRequest _buildRequest() {
    final d = widget.data;
    final p = widget.profile;
    final idAddress = _LoanRequestPageState._idCardAddress(p);
    return LoanRequest(
      uid: p.uid,
      thaiId: p.thaiId,
      nameTh: p.fullName,
      dateOfBirth: p.dateOfBirth,
      idCardAddress: idAddress == '-' ? '' : idAddress,
      contactsGranted: d.contactsGranted,
      deviceInfoGranted: d.deviceInfoGranted,
      locationGranted: d.locationGranted,
      smsGranted: d.smsGranted,
      currentAddress: d.address,
      area: d.area,
      postcode: d.postcode,
      sameAsIdCard: d.sameAsIdCard,
      email: d.email,
      education: d.education,
      contacts: [d.contact1, d.contact2],
      payrollBank: d.payrollBank,
      includeOtherBanks: d.includeOtherBanks,
      statements: d.statements,
      agreeTerms: _agreeTerms,
      marketingConsent: _marketing,
      creditModelConsent: _creditModel,
      productConsent: _product,
    );
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await _repo.submit(
        profile: widget.profile,
        request: _buildRequest(),
        requestId: widget.requestId,
      );
      // Mock approval: immediately create an approved loan tied to this request
      // and set it as the active loan so it shows on the home page.
      final loan = await _loanAccountRepo.createApprovedLoan(
        profile: widget.profile,
        loanId: widget.requestId,
      );
      AppState.instance.setActiveLoan(loan);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = 'ส่งคำขอไม่สำเร็จ: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final p = widget.profile;
    final currentAddress = d.sameAsIdCard
        ? _LoanRequestPageState._idCardAddress(p)
        : [d.address, d.area, d.postcode]
            .where((s) => s.isNotEmpty)
            .join(' ');

    return AppScaffold(
      title: 'สรุปข้อมูลการขอวงเงินเบื้องต้น',
      padding: const EdgeInsets.all(16),
      body: _submitting
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : ListView(
              children: [
                const _GroupTitle('ข้อมูลผู้สมัคร'),
                _reviewCard([
                  _kv('ชื่อ - นามสกุล', p.fullName.isNotEmpty ? p.fullName : '-'),
                  _kv('เลขบัตรประชาชน',
                      (p.thaiId ?? '').isNotEmpty ? ThaiId.mask(p.thaiId!) : '-'),
                  _kv('อีเมล', d.email.isNotEmpty ? d.email : '-'),
                  _kv('ระดับการศึกษา', d.education.isNotEmpty ? d.education : '-'),
                  _kv('ที่อยู่ปัจจุบัน',
                      currentAddress.isNotEmpty ? currentAddress : '-'),
                ]),
                const SizedBox(height: 16),
                const _GroupTitle('บุคคลที่ติดต่อได้'),
                _reviewCard([
                  _kv('คนที่ 1',
                      '${d.contact1.fullName} (${d.contact1.relation}) ${d.contact1.phone}'),
                  if (!d.contact2.isEmpty)
                    _kv('คนที่ 2',
                        '${d.contact2.fullName} (${d.contact2.relation}) ${d.contact2.phone}'),
                ]),
                const SizedBox(height: 16),
                const _GroupTitle('ข้อมูลธนาคาร'),
                _reviewCard([
                  _kv('บัญชีเงินเดือน',
                      d.payrollBank.isNotEmpty ? d.payrollBank : '-'),
                ]),
                const SizedBox(height: 16),
                const _GroupTitle('สเตทเม้นท์ที่แนบ'),
                _reviewCard([
                  if (d.statements.isEmpty)
                    _kv('ไฟล์แนบ', 'ไม่มี')
                  else
                    ...d.statements.map(
                      (f) => _kv(f.name, f.readableSize),
                    ),
                ]),
                const SizedBox(height: 20),
                const _GroupTitle('ความยินยอม'),
                _consentCheckbox(
                  'ฉันได้อ่านและยอมรับ ข้อตกลงและคำรับรองในการสมัครขอใช้บริการสินเชื่อ',
                  _agreeTerms,
                  (v) => setState(() => _agreeTerms = v),
                ),
                _consentChoice(
                  'ยินยอมในการเปิดเผยข้อมูลเพื่อวัตถุประสงค์ทางการตลาด',
                  _marketing,
                  (v) => setState(() => _marketing = v),
                ),
                _consentChoice(
                  'ยินยอมให้นำข้อมูลไปใช้จัดทำแบบจำลองด้านเครดิต',
                  _creditModel,
                  (v) => setState(() => _creditModel = v),
                ),
                _consentChoice(
                  'ยินยอมเพื่อใช้ข้อมูลในการพัฒนาและนำเสนอผลิตภัณฑ์',
                  _product,
                  (v) => setState(() => _product = v),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
              ],
            ),
      bottomBar: _submitting
          ? null
          : ElevatedButton(
              onPressed: _agreeTerms ? _submit : null,
              child: const Text('ยืนยันวงเงินเบื้องต้น'),
            ),
    );
  }

  Widget _reviewCard(List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: rows),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(k, style: const TextStyle(color: AppColors.textMuted)),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(v,
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
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
          const SizedBox(height: 4),
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
