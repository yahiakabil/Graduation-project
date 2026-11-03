import '../models/company_models.dart';

abstract class ICompanyRepository {
  Future<List<BranchModel>> getBranches();
  Future<void> updateEmployeeSalary(String employeeId, double newBase);
  Future<DeductionRulesModel> getDeductionRules();
  Future<void> saveDeductionRules(DeductionRulesModel rules);
  Future<void> addBranch({required String name, required String address, double radiusMeters = 50.0});
  Future<void> addEmployee({required String branchId, required String teamId, required EmployeeDossierModel employee});
  Future<void> addManagerTeam({required String branchId, required String teamName, required String headName, required String headTitle});
  Future<void> awardBonusOrDeduction({required String employeeId, required double amount, required bool isBonus, required String reason});
  Future<void> deactivateEmployee(String employeeId);
  Future<void> reactivateEmployee(String employeeId);
  Future<void> removeEmployee(String employeeId);
  Future<void> manualCheckInEmployee({required String employeeId, required String adminName, required String reason});
}
