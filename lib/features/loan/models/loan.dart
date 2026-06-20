/// An approved installment loan held by the user.
///
/// Money is tracked with a cumulative [paidAmount] against [totalPayable]
/// (principal + interest). Everything else (outstanding balance, installments
/// paid, next due date, closed state) is derived, so a payment only needs to
/// update [paidAmount] for the whole model to stay consistent — even when the
/// user pays custom amounts rather than exact installments.
class Loan {
  const Loan({
    required this.loanId,
    required this.thaiId,
    required this.principal,
    required this.annualInterestRate,
    required this.termMonths,
    required this.totalPayable,
    required this.installmentAmount,
    required this.paidAmount,
    required this.startedAt,
    required this.status,
    this.approvedAt,
  });

  final String loanId;
  final String? thaiId;

  /// Approved/disbursed amount.
  final double principal;

  /// Annual interest rate as a fraction, e.g. 0.28 for 28%.
  final double annualInterestRate;

  final int termMonths;

  /// principal + total interest.
  final double totalPayable;

  /// Scheduled amount per month.
  final double installmentAmount;

  /// Cumulative amount paid so far.
  final double paidAmount;

  final DateTime startedAt;

  /// 'active' | 'closed'.
  final String status;

  final DateTime? approvedAt;

  double get totalInterest => totalPayable - principal;

  double get outstandingBalance {
    final remaining = totalPayable - paidAmount;
    return remaining < 0 ? 0 : remaining;
  }

  /// Whole installments covered by [paidAmount], capped at [termMonths].
  int get installmentsPaid {
    if (installmentAmount <= 0) return 0;
    final n = (paidAmount / installmentAmount).floor();
    if (n < 0) return 0;
    return n > termMonths ? termMonths : n;
  }

  int get installmentsRemaining {
    final r = termMonths - installmentsPaid;
    return r < 0 ? 0 : r;
  }

  bool get isClosed => status == 'closed' || outstandingBalance <= 0.005;

  /// The next payment due date (one month after the last paid installment).
  DateTime get nextDueDate => _addMonths(startedAt, installmentsPaid + 1);

  int get daysUntilDue {
    final today = DateTime.now();
    final due = DateTime(nextDueDate.year, nextDueDate.month, nextDueDate.day);
    final d0 = DateTime(today.year, today.month, today.day);
    return due.difference(d0).inDays;
  }

  Loan copyWith({double? paidAmount, String? status}) => Loan(
        loanId: loanId,
        thaiId: thaiId,
        principal: principal,
        annualInterestRate: annualInterestRate,
        termMonths: termMonths,
        totalPayable: totalPayable,
        installmentAmount: installmentAmount,
        paidAmount: paidAmount ?? this.paidAmount,
        startedAt: startedAt,
        status: status ?? this.status,
        approvedAt: approvedAt,
      );

  Map<String, dynamic> toMap() => {
        'loanId': loanId,
        'thaiId': thaiId,
        'principal': principal,
        'annualInterestRate': annualInterestRate,
        'termMonths': termMonths,
        'totalPayable': totalPayable,
        'installmentAmount': installmentAmount,
        'paidAmount': paidAmount,
        'startedAt': startedAt.toIso8601String(),
        'status': status,
        'approvedAt': (approvedAt ?? DateTime.now()).toIso8601String(),
      };

  factory Loan.fromMap(Map<String, dynamic> map) {
    double toD(dynamic v) =>
        v is num ? v.toDouble() : (double.tryParse('$v') ?? 0);
    return Loan(
      loanId: map['loanId'] as String? ?? '',
      thaiId: map['thaiId'] as String?,
      principal: toD(map['principal']),
      annualInterestRate: toD(map['annualInterestRate']),
      termMonths: (map['termMonths'] as num?)?.toInt() ?? 12,
      totalPayable: toD(map['totalPayable']),
      installmentAmount: toD(map['installmentAmount']),
      paidAmount: toD(map['paidAmount']),
      startedAt: DateTime.tryParse('${map['startedAt']}') ?? DateTime.now(),
      status: map['status'] as String? ?? 'active',
      approvedAt: map['approvedAt'] != null
          ? DateTime.tryParse('${map['approvedAt']}')
          : null,
    );
  }

  /// Builds a freshly-approved loan using a simple flat-interest schedule.
  ///
  /// Defaults model a 30,000 THB loan at 28%/yr over 12 months (mock approval).
  factory Loan.approved({
    required String loanId,
    required String? thaiId,
    double principal = 30000,
    double annualInterestRate = 0.28,
    int termMonths = 12,
    DateTime? startedAt,
  }) {
    final start = startedAt ?? DateTime.now();
    final interest = principal * annualInterestRate * (termMonths / 12);
    final total = double.parse((principal + interest).toStringAsFixed(2));
    final installment = double.parse((total / termMonths).toStringAsFixed(2));
    return Loan(
      loanId: loanId,
      thaiId: thaiId,
      principal: principal,
      annualInterestRate: annualInterestRate,
      termMonths: termMonths,
      totalPayable: total,
      installmentAmount: installment,
      paidAmount: 0,
      startedAt: start,
      status: 'active',
      approvedAt: DateTime.now(),
    );
  }

  static DateTime _addMonths(DateTime d, int months) {
    final total = (d.month - 1) + months;
    final year = d.year + (total ~/ 12);
    final month = (total % 12) + 1;
    final lastDay = DateTime(year, month + 1, 0).day;
    final day = d.day > lastDay ? lastDay : d.day;
    return DateTime(year, month, day);
  }
}
