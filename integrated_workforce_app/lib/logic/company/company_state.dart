import 'package:equatable/equatable.dart';
import '../../data/models/company_models.dart';

abstract class CompanyState extends Equatable {
  const CompanyState();
  @override
  List<Object?> get props => [];
}

class CompanyInitial extends CompanyState {}

class CompanyLoading extends CompanyState {}

class CompanyLoaded extends CompanyState {
  final List<BranchModel> branches;
  final DeductionRulesModel rules;
  final String? selectedBranchId;
  final String? selectedTeamId;
  final String? selectedEmployeeId;
  final String dossierTab; // 'profile', 'payroll', 'activities'
  final String? message;

  const CompanyLoaded({
    required this.branches,
    required this.rules,
    this.selectedBranchId,
    this.selectedTeamId,
    this.selectedEmployeeId,
    this.dossierTab = 'profile',
    this.message,
  });

  CompanyLoaded copyWith({
    List<BranchModel>? branches,
    DeductionRulesModel? rules,
    String? selectedBranchId,
    bool clearBranch = false,
    String? selectedTeamId,
    bool clearTeam = false,
    String? selectedEmployeeId,
    bool clearEmployee = false,
    String? dossierTab,
    String? message,
  }) {
    return CompanyLoaded(
      branches: branches ?? this.branches,
      rules: rules ?? this.rules,
      selectedBranchId: clearBranch ? null : (selectedBranchId ?? this.selectedBranchId),
      selectedTeamId: clearTeam ? null : (selectedTeamId ?? this.selectedTeamId),
      selectedEmployeeId: clearEmployee ? null : (selectedEmployeeId ?? this.selectedEmployeeId),
      dossierTab: dossierTab ?? this.dossierTab,
      message: message,
    );
  }

  BranchModel? get selectedBranch {
    if (selectedBranchId == null || branches.isEmpty) return null;
    try {
      return branches.firstWhere((b) => b.id == selectedBranchId);
    } catch (_) {
      return branches.isNotEmpty ? branches.first : null;
    }
  }

  DepartmentTeamModel? get selectedTeam {
    final branch = selectedBranch;
    if (branch == null || selectedTeamId == null || branch.teams.isEmpty) return null;
    try {
      return branch.teams.firstWhere((t) => t.id == selectedTeamId);
    } catch (_) {
      return branch.teams.isNotEmpty ? branch.teams.first : null;
    }
  }

  EmployeeDossierModel? get selectedEmployee {
    final team = selectedTeam;
    if (team == null || selectedEmployeeId == null || team.employees.isEmpty) return null;
    try {
      return team.employees.firstWhere((e) => e.id == selectedEmployeeId);
    } catch (_) {
      return team.employees.isNotEmpty ? team.employees.first : null;
    }
  }

  @override
  List<Object?> get props => [
        branches,
        rules,
        selectedBranchId,
        selectedTeamId,
        selectedEmployeeId,
        dossierTab,
        message,
      ];
}

class CompanyError extends CompanyState {
  final String message;
  const CompanyError(this.message);
  @override
  List<Object?> get props => [message];
}
