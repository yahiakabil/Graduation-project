import '../models/attendance_model.dart';
import '../models/team_member_model.dart';
import '../repositories/team_repository.dart';

class FakeTeamRepository implements ITeamRepository {
  final List<TeamMemberModel> _members = [
    const TeamMemberModel(
      id: 'emp-1',
      name: 'Ahmed Kamal',
      role: 'Senior Flutter Developer',
      code: 'EMP-4092',
      email: 'ahmed.kamal@company.com',
      phone: '01012345678',
      photoUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300',
      status: AttendanceStatus.late,
      statusText: 'Late (09:28 AM)',
      issuesCount: 2,
      issueLabel: '2 Issues (Late + Left Branch)',
      intervals: [
        PresenceIntervalModel(
          time: '09:00 - 09:15',
          status: 'pending',
          label: 'Not checked in yet',
        ),
        PresenceIntervalModel(
          time: '09:15 - 09:30',
          status: 'inside',
          label: 'Checked in at 09:28 AM (28m Late)',
        ),
        PresenceIntervalModel(
          time: '09:30 - 11:42',
          status: 'inside',
          label: 'Inside HQ (50m Radius & Router BSSID Verified)',
        ),
        PresenceIntervalModel(
          time: '11:42 - 12:15',
          status: 'signal_lost',
          label: 'Signal Lost / Offline Gap (Last ping 11:42 AM - Restored 12:15 PM - Check-In Preserved)',
        ),
        PresenceIntervalModel(
          time: '12:15 - 13:00',
          status: 'inside',
          label: 'Returned Online Inside Branch',
        ),
      ],
    ),
    const TeamMemberModel(
      id: 'emp-2',
      name: 'Sara Sami',
      role: 'Lead UI/UX Designer',
      code: 'EMP-4095',
      email: 'sara.sami@company.com',
      phone: '01099887766',
      photoUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=300',
      status: AttendanceStatus.onTime,
      statusText: 'On Time (08:52 AM)',
      issuesCount: 0,
      issueLabel: 'All Good',
      intervals: [
        PresenceIntervalModel(
          time: '09:00 - 11:30',
          status: 'inside',
          label: 'Continuously Inside HQ (50m Radius)',
        ),
      ],
    ),
    const TeamMemberModel(
      id: 'emp-3',
      name: 'Omar Sherif',
      role: 'Backend API Engineer',
      code: 'EMP-4101',
      email: 'omar.sherif@company.com',
      phone: '01122334455',
      photoUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=300',
      status: AttendanceStatus.absent,
      statusText: 'Absent Today',
      issuesCount: 1,
      issueLabel: 'No Check-In Recorded',
      intervals: [
        PresenceIntervalModel(
          time: '09:00 - 11:30',
          status: 'outside',
          label: 'No Presence Recorded',
        ),
      ],
    ),
    const TeamMemberModel(
      id: 'emp-4',
      name: 'Kareem Adel',
      role: 'QA Automation Engineer',
      code: 'EMP-5012',
      email: 'kareem.adel@company.com',
      phone: '01233445566',
      photoUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300',
      status: AttendanceStatus.onTime,
      statusText: 'On Time (08:58 AM)',
      issuesCount: 0,
      issueLabel: 'All Good',
      intervals: [
        PresenceIntervalModel(
          time: '09:00 - 11:30',
          status: 'inside',
          label: 'Inside Branch',
        ),
      ],
    ),
  ];

  @override
  Future<List<TeamMemberModel>> getTeamMembers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_members);
  }

  @override
  Future<void> issueWarning({
    required String employeeId,
    required String reason,
    required int level,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // Simulated warning issuance
  }

  @override
  Future<void> awardBonusOrDeduction({
    required String employeeId,
    required double amount,
    required bool isBonus,
    required String reason,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _members.indexWhere((m) => m.id == employeeId);
    if (idx != -1) {
      final cur = _members[idx];
      if (isBonus) {
        _members[idx] = cur.copyWith(bonus: cur.bonus + amount);
      } else {
        _members[idx] = cur.copyWith(discretionaryDeductions: cur.discretionaryDeductions + amount);
      }
    }
  }

  @override
  Future<void> addTeamMember(TeamMemberModel member) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _members.add(member);
  }

  @override
  Future<void> deactivateMember(String employeeId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _members.indexWhere((m) => m.id == employeeId);
    if (idx != -1) {
      _members[idx] = _members[idx].copyWith(isSuspended: true, statusText: 'Suspended (Closed)');
    }
  }

  @override
  Future<void> reactivateMember(String employeeId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _members.indexWhere((m) => m.id == employeeId);
    if (idx != -1) {
      _members[idx] = _members[idx].copyWith(isSuspended: false, statusText: 'Active');
    }
  }

  @override
  Future<void> removeMember(String employeeId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _members.removeWhere((m) => m.id == employeeId);
  }

  @override
  Future<void> manualCheckIn({
    required String employeeId,
    required String managerName,
    required String reason,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _members.indexWhere((m) => m.id == employeeId);
    if (idx != -1) {
      final cur = _members[idx];
      final newIntervals = List<PresenceIntervalModel>.from(cur.intervals);
      newIntervals.insert(
        0,
        PresenceIntervalModel(
          time: '09:05 AM (Manual)',
          status: 'inside',
          label: 'Manual Check-In by $managerName: $reason',
        ),
      );
      _members[idx] = cur.copyWith(
        status: AttendanceStatus.onTime,
        statusText: 'Checked in manually by Manager ($managerName)',
        intervals: newIntervals,
      );
    }
  }
}
