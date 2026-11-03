import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/team_member_model.dart';
import '../../data/repositories/team_repository.dart';
import 'team_state.dart';

class TeamCubit extends Cubit<TeamState> {
  final ITeamRepository teamRepository;

  TeamCubit({required this.teamRepository}) : super(TeamInitial());

  Future<void> loadTeam() async {
    emit(TeamLoading());
    try {
      final members = await teamRepository.getTeamMembers();
      emit(TeamLoaded(members: members));
    } catch (e) {
      emit(TeamError(e.toString()));
    }
  }

  Future<void> issueWarning({
    required String employeeId,
    required String reason,
    required int level,
  }) async {
    try {
      await teamRepository.issueWarning(
        employeeId: employeeId,
        reason: reason,
        level: level,
      );
      final members = await teamRepository.getTeamMembers();
      emit(TeamLoaded(
        members: members,
        message: 'Official warning issued successfully.',
      ));
    } catch (e) {
      emit(TeamError(e.toString()));
    }
  }

  Future<void> awardBonusOrDeduction({
    required String employeeId,
    required double amount,
    required bool isBonus,
    required String reason,
  }) async {
    try {
      await teamRepository.awardBonusOrDeduction(
        employeeId: employeeId,
        amount: amount,
        isBonus: isBonus,
        reason: reason,
      );
      final members = await teamRepository.getTeamMembers();
      emit(TeamLoaded(
        members: members,
        message: isBonus
            ? 'Bonus of ${amount.toInt()} EGP awarded with official note.'
            : 'Disciplinary deduction of ${amount.toInt()} EGP recorded.',
      ));
    } catch (e) {
      emit(TeamError(e.toString()));
    }
  }

  Future<void> addMember(TeamMemberModel member) async {
    try {
      await teamRepository.addTeamMember(member);
      final members = await teamRepository.getTeamMembers();
      emit(TeamLoaded(
        members: members,
        message: member.isPendingAdminApproval
            ? 'Employee registration submitted to Admin for approval and salary setting.'
            : 'New team member added successfully.',
      ));
    } catch (e) {
      emit(TeamError(e.toString()));
    }
  }

  Future<void> deactivateMember(String employeeId) async {
    try {
      await teamRepository.deactivateMember(employeeId);
      final members = await teamRepository.getTeamMembers();
      emit(TeamLoaded(
        members: members,
        message: 'Employee account closed / deactivated.',
      ));
    } catch (e) {
      emit(TeamError(e.toString()));
    }
  }

  Future<void> reactivateMember(String employeeId) async {
    try {
      await teamRepository.reactivateMember(employeeId);
      final members = await teamRepository.getTeamMembers();
      emit(TeamLoaded(
        members: members,
        message: 'Employee account reopened & activated.',
      ));
    } catch (e) {
      emit(TeamError(e.toString()));
    }
  }

  Future<void> removeMember(String employeeId) async {
    try {
      await teamRepository.removeMember(employeeId);
      final members = await teamRepository.getTeamMembers();
      emit(TeamLoaded(
        members: members,
        message: 'Employee account removed permanently.',
      ));
    } catch (e) {
      emit(TeamError(e.toString()));
    }
  }

  Future<void> manualCheckIn({
    required String employeeId,
    required String managerName,
    required String reason,
  }) async {
    try {
      await teamRepository.manualCheckIn(
        employeeId: employeeId,
        managerName: managerName,
        reason: reason,
      );
      final members = await teamRepository.getTeamMembers();
      emit(TeamLoaded(
        members: members,
        message: 'Manual check-in override logged for employee.',
      ));
    } catch (e) {
      emit(TeamError(e.toString()));
    }
  }
}
