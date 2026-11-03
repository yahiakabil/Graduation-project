import '../models/team_member_model.dart';

abstract class ITeamRepository {
  Future<List<TeamMemberModel>> getTeamMembers();
  Future<void> issueWarning({
    required String employeeId,
    required String reason,
    required int level,
  });
  Future<void> awardBonusOrDeduction({
    required String employeeId,
    required double amount,
    required bool isBonus,
    required String reason,
  });
  Future<void> addTeamMember(TeamMemberModel member);
  Future<void> deactivateMember(String employeeId);
  Future<void> reactivateMember(String employeeId);
  Future<void> removeMember(String employeeId);
  Future<void> manualCheckIn({
    required String employeeId,
    required String managerName,
    required String reason,
  });
}
