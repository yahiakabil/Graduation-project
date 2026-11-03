import '../models/company_models.dart';

abstract class IPayrollRepository {
  Future<List<PayrollMonthModel>> getPayrollMonths();
  Future<void> lockMonth(String monthId);
  Future<Map<String, dynamic>> getDisbursementStatus();
  Future<Map<String, dynamic>> disburseSalaries();
}