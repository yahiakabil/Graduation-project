import '../models/company_models.dart';
import '../repositories/payroll_repository.dart';

class FakePayrollRepository implements IPayrollRepository {
  final List<PayrollMonthModel> _months = [
    const PayrollMonthModel(
      id: 'oct_2026',
      label: 'October 2026',
      status: 'Open (Active)',
      isLocked: false,
      totalBase: 92000.0,
      totalDeductions: 2150.0,
      overtimeAmount: 4200.0,
      totalNet: 94050.0,
      overtimeHours: 58,
      teams: [
        TeamPayrollSummaryModel(
          teamName: 'Mobile Engineering Team',
          totalNet: 39200.0,
          deductions: 1200.0,
          overtimeAmount: 2400.0,
        ),
        TeamPayrollSummaryModel(
          teamName: 'Corporate Sales Team',
          totalNet: 54850.0,
          deductions: 950.0,
          overtimeAmount: 1800.0,
        ),
      ],
    ),
    const PayrollMonthModel(
      id: 'sep_2026',
      label: 'September 2026',
      status: 'Locked & Disbursed',
      isLocked: true,
      totalBase: 92000.0,
      totalDeductions: 1800.0,
      overtimeAmount: 3900.0,
      totalNet: 94100.0,
      overtimeHours: 52,
      teams: [
        TeamPayrollSummaryModel(
          teamName: 'Mobile Engineering Team',
          totalNet: 39400.0,
          deductions: 980.0,
          overtimeAmount: 2100.0,
        ),
        TeamPayrollSummaryModel(
          teamName: 'Corporate Sales Team',
          totalNet: 54700.0,
          deductions: 820.0,
          overtimeAmount: 1800.0,
        ),
      ],
    ),
    const PayrollMonthModel(
      id: 'aug_2026',
      label: 'August 2026',
      status: 'Locked & Disbursed',
      isLocked: true,
      totalBase: 88000.0,
      totalDeductions: 2400.0,
      overtimeAmount: 3100.0,
      totalNet: 88700.0,
      overtimeHours: 44,
      teams: [
        TeamPayrollSummaryModel(
          teamName: 'Mobile Engineering Team',
          totalNet: 38200.0,
          deductions: 1400.0,
          overtimeAmount: 1700.0,
        ),
        TeamPayrollSummaryModel(
          teamName: 'Corporate Sales Team',
          totalNet: 50500.0,
          deductions: 1000.0,
          overtimeAmount: 1400.0,
        ),
      ],
    ),
  ];

  @override
  Future<List<PayrollMonthModel>> getPayrollMonths() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_months);
  }

  @override
  Future<void> lockMonth(String monthId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _months.indexWhere((m) => m.id == monthId);
    if (index != -1) {
      _months[index] = _months[index].copyWith(
        isLocked: true,
        status: 'Paid & Disbursed (Salaries Transferred)',
      );

      // Automatically open next month in system cycle
      if (!_months.any((m) => m.id == 'nov_2026')) {
        _months.insert(
          0,
          const PayrollMonthModel(
            id: 'nov_2026',
            label: 'November 2026',
            status: 'Open (Active)',
            isLocked: false,
            totalBase: 92000.0,
            totalDeductions: 0.0,
            overtimeAmount: 0.0,
            totalNet: 92000.0,
            overtimeHours: 0,
            teams: [
              TeamPayrollSummaryModel(
                teamName: 'Mobile Engineering Team',
                totalNet: 39200.0,
                deductions: 0.0,
                overtimeAmount: 0.0,
              ),
              TeamPayrollSummaryModel(
                teamName: 'Corporate Sales Team',
                totalNet: 52800.0,
                deductions: 0.0,
                overtimeAmount: 0.0,
              ),
            ],
          ),
        );
      }
    }
  }
  @override
  Future<Map<String, dynamic>> getDisbursementStatus() async {
    return {
      'isDisbursedToday': false,
      'daysAccrued': 1,
      'dailyAccrualRate': 3100.0,
      'estimatedAccruedNet': 3100.0,
      'lastDisbursedDate': '2026-10-30',
      'statusMessage': '1 day accrued ready for disbursement.',
    };
  }

  @override
  Future<Map<String, dynamic>> disburseSalaries() async {
    return {
      'disbursedToday': true,
      'employeesCount': 100,
      'totalDisbursedAmount': 3100.0,
      'daysDisbursed': 1,
      'disbursedAt': DateTime.now().toIso8601String(),
      'message': 'Disbursed 1 day(s) salary to 100 employees.',
    };
  }
}