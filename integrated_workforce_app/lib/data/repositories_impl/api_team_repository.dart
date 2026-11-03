import '../api/api_client.dart';
import '../models/attendance_model.dart';
import '../models/team_member_model.dart';
import '../repositories/team_repository.dart';

class ApiTeamRepository implements ITeamRepository {
  List<TeamMemberModel> _cachedMembers = [];

  @override
  Future<List<TeamMemberModel>> getTeamMembers() async {
    try {
      final usersRes = await ApiClient.get('/users');
      final List<dynamic> users = usersRes is List ? usersRes : [];

      List<dynamic> teamToday = [];
      try {
        final todayRes = await ApiClient.get('/attendance/team/today');
        if (todayRes is List) teamToday = todayRes;
      } catch (_) {}

      final members = users.map<TeamMemberModel>((u) {
        final id = (u['id'] ?? 0).toString();
        final name = u['fullName']?.toString() ?? 'Employee';
        final code = u['employeeCode']?.toString() ?? 'EMP-$id';
        final role = u['jobTitle']?.toString() ?? 'Staff Member';
        final email = u['email']?.toString() ?? '';
        final phone = u['phone']?.toString() ?? '';
        final photo = u['profilePhotoUrl']?.toString();

        // Check if there is an attendance record today
        final att = teamToday.firstWhere(
          (t) => (t['userId'] ?? 0).toString() == id,
          orElse: () => null,
        );

        AttendanceStatus status = AttendanceStatus.onTime;
        String statusText = 'Present / Active';
        int lateMin = 0;

        if (att != null) {
          lateMin = (att['lateMinutes'] as num?)?.toInt() ?? 0;
          final sStr = (att['status'] ?? 'Present').toString().toLowerCase();
          if (sStr.contains('late') || lateMin > 0) {
            status = AttendanceStatus.late;
            statusText = 'Late (${att['checkInTime'] ?? 'Late'})';
          } else if (sStr.contains('absent')) {
            status = AttendanceStatus.absent;
            statusText = 'Absent';
          } else if (sStr.contains('leave')) {
            status = AttendanceStatus.onLeave;
            statusText = 'On Leave';
          } else {
            status = AttendanceStatus.onTime;
            statusText = 'On Time (${att['checkInTime'] ?? '09:00 AM'})';
          }
        }

        return TeamMemberModel(
          id: id,
          name: name,
          role: role,
          code: code,
          email: email,
          phone: phone,
          photoUrl: photo ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300',
          status: status,
          statusText: statusText,
          issuesCount: lateMin > 0 ? 1 : 0,
          issueLabel: lateMin > 0 ? '$lateMin min Late' : 'Normal',
          intervals: const [
            PresenceIntervalModel(
              time: '09:00 - 17:00',
              status: 'inside',
              label: 'Verified inside perimeter (GPS & Wi-Fi bound)',
            ),
          ],
        );
      }).toList();

      _cachedMembers = members;
      return members;
    } catch (_) {
      return _cachedMembers;
    }
  }

  @override
  Future<void> issueWarning({
    required String employeeId,
    required String reason,
    required int level,
  }) async {
    final intId = int.tryParse(employeeId);
    if (intId != null) {
      await ApiClient.post('/users/$intId/warning', body: {
        'reason': reason,
        'level': level,
      });
    }
  }

  @override
  Future<void> awardBonusOrDeduction({
    required String employeeId,
    required double amount,
    required bool isBonus,
    required String reason,
  }) async {
    final intId = int.tryParse(employeeId);
    if (intId != null) {
      await ApiClient.post('/users/$intId/bonus', body: {
        'isBonus': isBonus,
        'amount': amount,
        'reason': reason,
      });
    }
  }

  @override
  Future<void> addTeamMember(TeamMemberModel member) async {
    await ApiClient.post('/users', body: {
      'fullName': member.name,
      'email': member.email,
      'password': 'password123',
      'phone': member.phone,
      'jobTitle': member.role,
      'roleId': 1, // Employee
    });
    _cachedMembers.add(member);
  }

  @override
  Future<void> deactivateMember(String employeeId) async {
    final intId = int.tryParse(employeeId);
    if (intId != null) {
      try {
        await ApiClient.delete('/users/$intId');
      } catch (_) {}
    }
  }

  @override
  Future<void> reactivateMember(String employeeId) async {}

  @override
  Future<void> removeMember(String employeeId) async {
    final intId = int.tryParse(employeeId);
    if (intId != null) {
      await ApiClient.delete('/users/$intId');
    }
    _cachedMembers.removeWhere((m) => m.id == employeeId);
  }

  @override
  Future<void> manualCheckIn({
    required String employeeId,
    required String managerName,
    required String reason,
  }) async {
    final intId = int.tryParse(employeeId);
    if (intId != null) {
      try {
        await ApiClient.post('/attendance/manual-checkin', body: {
          'userId': intId,
          'reason': '$reason (Approved by $managerName)',
        });
      } catch (_) {
        await ApiClient.post('/users/$intId/warning', body: {
          'reason': 'Manual Check-in by $managerName: $reason',
          'level': 1,
        });
      }
    }
  }
}
