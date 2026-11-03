import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/company_models.dart';
import '../../data/repositories/company_repository.dart';
import 'company_state.dart';

class CompanyCubit extends Cubit<CompanyState> {
  final ICompanyRepository companyRepository;

  CompanyCubit({required this.companyRepository}) : super(CompanyInitial());

  Future<void> loadCompanyData() async {
    emit(CompanyLoading());
    try {
      final branches = await companyRepository.getBranches();
      final rules = await companyRepository.getDeductionRules();
      emit(CompanyLoaded(branches: branches, rules: rules));
    } catch (e) {
      emit(CompanyError(e.toString()));
    }
  }

  void selectBranch(String? branchId) {
    if (state is CompanyLoaded) {
      final cur = state as CompanyLoaded;
      emit(cur.copyWith(
        selectedBranchId: branchId,
        clearBranch: branchId == null,
        clearTeam: true,
        clearEmployee: true,
      ));
    }
  }

  void selectTeam(String? teamId) {
    if (state is CompanyLoaded) {
      final cur = state as CompanyLoaded;
      emit(cur.copyWith(
        selectedTeamId: teamId,
        clearTeam: teamId == null,
        clearEmployee: true,
      ));
    }
  }

  void selectEmployee(String? employeeId) {
    if (state is CompanyLoaded) {
      final cur = state as CompanyLoaded;
      emit(cur.copyWith(
        selectedEmployeeId: employeeId,
        clearEmployee: employeeId == null,
        dossierTab: 'profile',
      ));
    }
  }

  void setDossierTab(String tab) {
    if (state is CompanyLoaded) {
      final cur = state as CompanyLoaded;
      emit(cur.copyWith(dossierTab: tab));
    }
  }

  Future<void> updateSalary(String employeeId, double newBase) async {
    try {
      await companyRepository.updateEmployeeSalary(employeeId, newBase);
      final branches = await companyRepository.getBranches();
      if (state is CompanyLoaded) {
        final cur = state as CompanyLoaded;
        emit(cur.copyWith(
          branches: branches,
          message: 'Base salary adjusted successfully.',
        ));
      }
    } catch (e) {
      if (state is CompanyLoaded) {
        final cur = state as CompanyLoaded;
        emit(cur.copyWith(
          message: 'Failed to adjust salary: ${e.toString().replaceAll('Exception: ', '')}',
        ));
      } else {
        emit(CompanyError(e.toString()));
      }
    }
  }

  Future<void> saveRules(DeductionRulesModel rules) async {
    try {
      await companyRepository.saveDeductionRules(rules);
      if (state is CompanyLoaded) {
        final cur = state as CompanyLoaded;
        emit(cur.copyWith(
          rules: rules,
          message: 'Deduction ladder rules updated successfully.',
        ));
      }
    } catch (e) {
      if (state is CompanyLoaded) {
        final cur = state as CompanyLoaded;
        emit(cur.copyWith(
          message: 'Failed to update rules: ${e.toString().replaceAll('Exception: ', '')}',
        ));
      } else {
        emit(CompanyError(e.toString()));
      }
    }
  }

  Future<void> addEmployee({
    required String branchId,
    required String teamId,
    required EmployeeDossierModel employee,
  }) async {
    try {
      await companyRepository.addEmployee(
        branchId: branchId,
        teamId: teamId,
        employee: employee,
      );
      final branches = await companyRepository.getBranches();
      if (state is CompanyLoaded) {
        final cur = state as CompanyLoaded;
        emit(cur.copyWith(branches: branches, message: 'New employee registered successfully.'));
      }
    } catch (e) {
      emit(CompanyError(e.toString()));
    }
  }

  Future<void> addBranch({
    required String name,
    required String address,
    double radiusMeters = 50.0,
  }) async {
    try {
      await companyRepository.addBranch(
        name: name,
        address: address,
        radiusMeters: radiusMeters,
      );
      final branches = await companyRepository.getBranches();
      if (state is CompanyLoaded) {
        final cur = state as CompanyLoaded;
        emit(cur.copyWith(
          branches: branches,
          message: 'Branch "$name" created successfully.',
        ));
      }
    } catch (e) {
      emit(CompanyError(e.toString()));
    }
  }

  Future<void> addManagerTeam({
    required String branchId,
    required String teamName,
    required String headName,
    required String headTitle,
  }) async {
    try {
      await companyRepository.addManagerTeam(
        branchId: branchId,
        teamName: teamName,
        headName: headName,
        headTitle: headTitle,
      );
      final branches = await companyRepository.getBranches();
      if (state is CompanyLoaded) {
        final cur = state as CompanyLoaded;
        emit(cur.copyWith(branches: branches, message: 'New department team & manager registered.'));
      }
    } catch (e) {
      emit(CompanyError(e.toString()));
    }
  }

  Future<void> awardBonusOrDeduction({
    required String employeeId,
    required double amount,
    required bool isBonus,
    required String reason,
  }) async {
    try {
      await companyRepository.awardBonusOrDeduction(
        employeeId: employeeId,
        amount: amount,
        isBonus: isBonus,
        reason: reason,
      );
      final branches = await companyRepository.getBranches();
      if (state is CompanyLoaded) {
        final cur = state as CompanyLoaded;
        emit(cur.copyWith(
          branches: branches,
          message: isBonus
              ? 'Bonus of ${amount.toInt()} EGP awarded by Admin.'
              : 'Disciplinary deduction of ${amount.toInt()} EGP applied.',
        ));
      }
    } catch (e) {
      if (state is CompanyLoaded) {
        final cur = state as CompanyLoaded;
        emit(cur.copyWith(
          message: 'Operation failed: ${e.toString().replaceAll('Exception: ', '')}',
        ));
      } else {
        emit(CompanyError(e.toString()));
      }
    }
  }

  Future<void> deactivateEmployee(String employeeId) async {
    try {
      await companyRepository.deactivateEmployee(employeeId);
      final branches = await companyRepository.getBranches();
      if (state is CompanyLoaded) {
        final cur = state as CompanyLoaded;
        emit(cur.copyWith(
          branches: branches,
          message: 'Employee account deactivated / closed by Admin.',
        ));
      }
    } catch (e) {
      if (state is CompanyLoaded) {
        final cur = state as CompanyLoaded;
        emit(cur.copyWith(
          message: 'Failed to deactivate: ${e.toString().replaceAll('Exception: ', '')}',
        ));
      } else {
        emit(CompanyError(e.toString()));
      }
    }
  }

  Future<void> reactivateEmployee(String employeeId) async {
    try {
      await companyRepository.reactivateEmployee(employeeId);
      final branches = await companyRepository.getBranches();
      if (state is CompanyLoaded) {
        final cur = state as CompanyLoaded;
        emit(cur.copyWith(
          branches: branches,
          message: 'Employee account reopened and activated by Admin.',
        ));
      }
    } catch (e) {
      if (state is CompanyLoaded) {
        final cur = state as CompanyLoaded;
        emit(cur.copyWith(
          message: 'Failed to reactivate: ${e.toString().replaceAll('Exception: ', '')}',
        ));
      } else {
        emit(CompanyError(e.toString()));
      }
    }
  }

  Future<void> removeEmployee(String employeeId) async {
    try {
      await companyRepository.removeEmployee(employeeId);
      final branches = await companyRepository.getBranches();
      if (state is CompanyLoaded) {
        final cur = state as CompanyLoaded;
        emit(cur.copyWith(
          branches: branches,
          selectedEmployeeId: null,
          clearEmployee: true,
          message: 'Employee account permanently deleted.',
        ));
      }
    } catch (e) {
      if (state is CompanyLoaded) {
        final cur = state as CompanyLoaded;
        emit(cur.copyWith(
          message: 'Failed to delete: ${e.toString().replaceAll('Exception: ', '')}',
        ));
      } else {
        emit(CompanyError(e.toString()));
      }
    }
  }

  Future<void> manualCheckInEmployee({
    required String employeeId,
    required String adminName,
    required String reason,
  }) async {
    try {
      await companyRepository.manualCheckInEmployee(
        employeeId: employeeId,
        adminName: adminName,
        reason: reason,
      );
      final branches = await companyRepository.getBranches();
      if (state is CompanyLoaded) {
        final cur = state as CompanyLoaded;
        emit(cur.copyWith(
          branches: branches,
          message: 'Manual check-in override logged by HR / Admin.',
        ));
      }
    } catch (e) {
      // If error occurs, keep the loaded UI view and show SnackBar message instead of replacing whole screen with red error
      if (state is CompanyLoaded) {
        final cur = state as CompanyLoaded;
        emit(cur.copyWith(
          message: 'Manual Check-In: ${e.toString().replaceAll('Exception: ', '')}',
        ));
      } else {
        emit(CompanyError(e.toString()));
      }
    }
  }
}
