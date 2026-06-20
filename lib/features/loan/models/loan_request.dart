import '../../auth/models/user_profile.dart';
import 'uploaded_file.dart';

/// A single emergency / reference contact supplied in the loan request.
class LoanContact {
  const LoanContact({
    this.relation = '',
    this.firstName = '',
    this.lastName = '',
    this.phone = '',
  });

  final String relation;
  final String firstName;
  final String lastName;
  final String phone;

  bool get isEmpty =>
      relation.isEmpty &&
      firstName.isEmpty &&
      lastName.isEmpty &&
      phone.isEmpty;

  bool get isComplete =>
      relation.isNotEmpty &&
      firstName.isNotEmpty &&
      lastName.isNotEmpty &&
      phone.replaceAll(RegExp(r'\D'), '').length == 10;

  String get fullName => '$firstName $lastName'.trim();

  Map<String, dynamic> toMap() => {
        'relation': relation,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
      };
}

/// A loan (credit-line) request assembled from the user's verified profile plus
/// the data collected across the multi-step form, ready to persist to Firestore.
///
/// Identity fields ([thaiId], [nameTh], [idCardAddress], [dateOfBirth]) are
/// snapshotted from the [UserProfile] so the request is self-contained even if
/// the profile changes later. The document is stored under the user
/// (`users/{sha256(thaiId)}/loanRequests/{id}`); see `LoanRepository`.
class LoanRequest {
  const LoanRequest({
    required this.uid,
    required this.thaiId,
    required this.nameTh,
    required this.dateOfBirth,
    required this.idCardAddress,
    // Device-permission consents
    required this.contactsGranted,
    required this.deviceInfoGranted,
    required this.locationGranted,
    required this.smsGranted,
    // Current address + personal
    required this.currentAddress,
    required this.area,
    required this.postcode,
    required this.sameAsIdCard,
    required this.email,
    required this.education,
    // Reference contacts
    required this.contacts,
    // Bank
    required this.payrollBank,
    required this.includeOtherBanks,
    // Statement attachments (Firebase Storage)
    this.statements = const [],
    // Consents
    required this.agreeTerms,
    required this.marketingConsent,
    required this.creditModelConsent,
    required this.productConsent,
    this.status = 'submitted',
    this.createdAt,
  });

  final String uid;
  final String? thaiId;
  final String nameTh;
  final DateTime? dateOfBirth;
  final String idCardAddress;

  final bool contactsGranted;
  final bool deviceInfoGranted;
  final bool locationGranted;
  final bool smsGranted;

  final String currentAddress;
  final String area;
  final String postcode;
  final bool sameAsIdCard;
  final String email;
  final String education;

  final List<LoanContact> contacts;

  final String payrollBank;
  final bool includeOtherBanks;

  final List<UploadedFile> statements;

  final bool agreeTerms;
  final bool marketingConsent;
  final bool creditModelConsent;
  final bool productConsent;

  final String status;
  final DateTime? createdAt;

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'thaiId': thaiId,
      'nameTh': nameTh,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'idCardAddress': idCardAddress,
      'permissions': {
        'contacts': contactsGranted,
        'deviceInfo': deviceInfoGranted,
        'location': locationGranted,
        'sms': smsGranted,
      },
      'currentAddress': sameAsIdCard ? idCardAddress : currentAddress,
      'area': area,
      'postcode': postcode,
      'sameAsIdCard': sameAsIdCard,
      'email': email,
      'education': education,
      'contacts': contacts
          .where((c) => !c.isEmpty)
          .map((c) => c.toMap())
          .toList(),
      'payrollBank': payrollBank,
      'includeOtherBanks': includeOtherBanks,
      'statements': statements.map((f) => f.toMap()).toList(),
      'consents': {
        'agreeTerms': agreeTerms,
        'marketing': marketingConsent,
        'creditModel': creditModelConsent,
        'product': productConsent,
      },
      'status': status,
      'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  /// Selectable options for the education dropdown.
  static const educationOptions = <String>[
    'ต่ำกว่ามัธยมศึกษา',
    'มัธยมศึกษา',
    'ปวช.',
    'ปวส. / อนุปริญญา',
    'ปริญญาตรี',
    'ปริญญาโท',
    'ปริญญาเอก',
    'อื่นๆ',
  ];

  /// Selectable options for the contact-relationship dropdown.
  static const relationOptions = <String>[
    'บิดา / มารดา',
    'คู่สมรส',
    'พี่ / น้อง',
    'ญาติ',
    'เพื่อน',
    'เพื่อนร่วมงาน',
    'อื่นๆ',
  ];

  /// Selectable options for the payroll-bank dropdown.
  static const bankOptions = <String>[
    'ธนาคารกสิกรไทย',
    'ธนาคารไทยพาณิชย์',
    'ธนาคารกรุงเทพ',
    'ธนาคารกรุงไทย',
    'ธนาคารกรุงศรีอยุธยา',
    'ธนาคารทหารไทยธนชาต',
    'ธนาคารออมสิน',
    'ธนาคารเพื่อการเกษตรและสหกรณ์การเกษตร',
    'อื่นๆ',
  ];
}
