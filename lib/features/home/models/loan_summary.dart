/// Summary of the user's credit line and current statement.
///
/// Backed by mock data for now; replace with the loan API once its endpoint is
/// provided (add an `ApiService.loan` entry in EnvConfig and a repository).
class LoanSummary {
  const LoanSummary({
    required this.totalCreditLine,
    required this.availableCreditLine,
    required this.statementLabel,
    required this.totalDue,
    required this.dueDate,
    required this.daysUntilDue,
  });

  final double totalCreditLine;
  final double availableCreditLine;

  /// e.g. "ก.ค. 63"
  final String statementLabel;
  final double totalDue;
  final DateTime dueDate;
  final int daysUntilDue;

  /// Mock data approximating the design.
  factory LoanSummary.mock() {
    final now = DateTime.now();
    final due = now.add(const Duration(days: 12));
    return LoanSummary(
      totalCreditLine: 100000.00,
      availableCreditLine: 100000.00,
      statementLabel: 'ก.ค. 63',
      totalDue: 5000.68,
      dueDate: due,
      daysUntilDue: 12,
    );
  }
}
