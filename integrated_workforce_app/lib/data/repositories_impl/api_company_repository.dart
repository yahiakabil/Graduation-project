import '../api/api_client.dart';
import '../models/attendance_model.dart';
import '../models/company_models.dart';
import '../models/team_member_model.dart';
import '../repositories/company_repository.dart';

class ApiCompanyRepository implements ICompanyRepository {
  List<BranchModel> _cachedBranches = [];

  @override
  Future<List<BranchModel>> getBranches() async {
    try {
      // 1. Fetch branches from real API
      final branchesJson = await ApiClient.get('/admin/branches');
      final deptsJson = await ApiClient.get('/admin/departments');
      final usersJson = await ApiClient.get('/users');

      final List<dynamic> rawBranches = branchesJson is List ? branchesJson : [];
      final List<dynamic> rawDepts = deptsJson is List ? deptsJson : [];
      final List<dynamic> rawUsers = usersJson is List ? usersJson : [];

      // Map users to EmployeeDossierModel
      final List<EmployeeDossierModel> allEmployees = rawUsers.map<EmployeeDossierModel>((u) {
        final int id = u['id'] ?? 0;
        final String name = u['fullName'] ?? 'Employee';
        final String code = u['employeeCode'] ?? 'EMP-$id';
        final String email = u['email'] ?? '';
        final String phone = u['phone'] ?? '';
        final String jobTitle = u['jobTitle'] ?? 'Staff Member';
        // final String deptName = u['department'] ?? 'General';
        final String branchName = u['branch'] ?? 'Main Headquarters';
        final String shiftName = u['shiftName'] ?? 'Morning Core (09:00 - 17:00)';
        final String hireDate = u['hireDate'] ?? '2024-01-01';
        final double baseSalary = (u['monthlySalary'] as num?)?.toDouble() ?? 5000.0;
        final bool isActive = u['isActive'] ?? true;
        final String? photo = u['profilePhotoUrl'];

        return EmployeeDossierModel(
          id: id.toString(),
          name: name,
          code: code,
          role: jobTitle,
          email: email,
          phone: phone,
          address: branchName,
          shift: shiftName,
          hireDate: hireDate,
          status: isActive ? AttendanceStatus.onTime : AttendanceStatus.absent,
          statusText: isActive ? 'Active / On-Time' : 'Inactive',
          issuesCount: 0,
          issueLabel: 'Normal',
          baseSalary: baseSalary,
          deductions: 0.0,
          overtimeHours: 0.0,
          overtimeRate: 1.5,
          netSalary: baseSalary,
          intervals: const [
            PresenceIntervalModel(
              time: '09:00 - 17:00',
              status: 'inside',
              label: 'Verified within perimeter',
            ),
          ],
          bonus: 0.0,
          isSuspended: !isActive,
          photoUrl: photo,
        );
      }).toList();

      // If no branches returned from API yet, build default branches container
      // final Map<String, List<DepartmentTeamModel>> teamsByBranch = {};

      // Group employees by Department
      final Map<String, List<EmployeeDossierModel>> employeesByDept = {};
      for (final emp in allEmployees) {
        // Find user raw object to get department name
        final rawUser = rawUsers.firstWhere(
          (u) => (u['id'] ?? 0).toString() == emp.id,
          orElse: () => null,
        );
        final dept = rawUser != null ? (rawUser['department'] ?? 'General') : 'General';
        employeesByDept.putIfAbsent(dept, () => []).add(emp);
      }

      // Build teams for each department
      final List<DepartmentTeamModel> allTeams = [];
      if (rawDepts.isNotEmpty) {
        for (final d in rawDepts) {
          final String dName = d['name'] ?? 'Department';
          final deptEmployees = employeesByDept[dName] ?? [];
          
          // Head of team can be first manager or first employee
          final head = deptEmployees.isNotEmpty ? deptEmployees.first : null;

          allTeams.add(DepartmentTeamModel(
            id: 'dept-${d['id']}',
            name: dName,
            headName: head?.name ?? 'Assigned Manager',
            headTitle: head?.role ?? 'Department Lead',
            headEmail: head?.email,
            headPhone: head?.phone,
            headPhotoUrl: head?.photoUrl,
            employees: deptEmployees,
          ));
        }
      } else {
        // Fallback from employees departments directly
        employeesByDept.forEach((dName, emps) {
          final head = emps.isNotEmpty ? emps.first : null;
          allTeams.add(DepartmentTeamModel(
            id: 'dept-${dName.hashCode}',
            name: dName,
            headName: head?.name ?? 'Assigned Manager',
            headTitle: head?.role ?? 'Lead',
            headEmail: head?.email,
            headPhone: head?.phone,
            headPhotoUrl: head?.photoUrl,
            employees: emps,
          ));
        });
      }

      // Group teams under branches
      final List<BranchModel> branches = [];
      if (rawBranches.isNotEmpty) {
        for (int i = 0; i < rawBranches.length; i++) {
          final b = rawBranches[i];
          final String bId = b['id'].toString();
          final String bName = b['name'] ?? 'Branch';
          final String bAddress = b['address'] ?? '';
          final double bRadius = (b['radiusMeters'] as num?)?.toDouble() ?? 50.0;

          // Split teams across branches or attach all to the main branch
          branches.add(BranchModel(
            id: bId,
            name: bName,
            address: bAddress,
            radiusMeters: bRadius,
            teams: i == 0 ? allTeams : [],
          ));
        }
      } else {
        branches.add(BranchModel(
          id: 'b-main',
          name: 'Main Headquarters',
          address: 'Smart Village, Cairo, Egypt',
          radiusMeters: 50.0,
          teams: allTeams,
        ));
      }

      _cachedBranches = branches;
      return branches;
    } catch (e) {
      // In case backend is offline, return cached or empty
      if (_cachedBranches.isNotEmpty) return _cachedBranches;
      rethrow;
    }
  }

  @override
  Future<void> updateEmployeeSalary(String employeeId, double newBase) async {
    final int? id = int.tryParse(employeeId);
    if (id != null) {
      await ApiClient.put('/users/$id', body: {
        'monthlySalary': newBase,
      });
    }
  }

  @override
  Future<DeductionRulesModel> getDeductionRules() async {
    try {
      final res = await ApiClient.get('/admin/rules/policy');
      if (res is Map<String, dynamic>) {
        return DeductionRulesModel.fromApiJson(res);
      } else if (res is List) {
        return DeductionRulesModel.fromApiList(res);
      }
      return const DeductionRulesModel();
    } catch (_) {
      try {
        final res = await ApiClient.get('/admin/rules');
        final List<dynamic> list = res is List ? res : [];
        return DeductionRulesModel.fromApiList(list);
      } catch (e) {
        return const DeductionRulesModel(
          gracePeriod: '0 min deduction',
          tier1: '1.0 Hour deduction',
          tier2: '2.0 Hours deduction',
          tier3: 'Half Day deduction',
          tier4: 'Full Day deduction',
          unexcusedAbsence: '2.0 Days deduction',
          missingCheckout: 'Half Day deduction (if not fixed in 24h)',
          geofenceRadius: 50.0,
          overtimeMultiplier: 1.5,
        );
      }
    }
  }

  @override
  Future<void> saveDeductionRules(DeductionRulesModel rules) async {
    try {
      await ApiClient.post('/admin/rules/policy', body: rules.toApiPayload());
    } catch (_) {
      await ApiClient.put('/admin/rules/policy', body: rules.toApiPayload());
    }
  }

  @override
  Future<void> addBranch({
    required String name,
    required String address,
    double radiusMeters = 50.0,
  }) async {
    await ApiClient.post('/admin/branches', body: {
      'name': name,
      'address': address,
      'latitude': 30.0735,
      'longitude': 31.0205,
      'radiusMeters': radiusMeters,
    });
  }

  @override
  Future<void> addEmployee({
    required String branchId,
    required String teamId,
    required EmployeeDossierModel employee,
  }) async {
    final deptId = int.tryParse(teamId.replaceAll('dept-', ''));
    final bId = int.tryParse(branchId.replaceAll('b-', ''));

    await ApiClient.post('/users', body: {
      'fullName': employee.name,
      'email': employee.email,
      'password': 'password123',
      'phone': employee.phone,
      'jobTitle': employee.role,
      'monthlySalary': employee.baseSalary,
      'roleId': 3, // Employee
      'departmentId': deptId,
      'branchId': bId,
    });
  }

  @override
  Future<void> addManagerTeam({
    required String branchId,
    required String teamName,
    required String headName,
    required String headTitle,
  }) async {
    await ApiClient.post('/admin/departments', body: teamName);
  }

  @override
  Future<void> awardBonusOrDeduction({
    required String employeeId,
    required double amount,
    required bool isBonus,
    required String reason,
  }) async {
    final int? id = int.tryParse(employeeId);
    if (id != null) {
      await ApiClient.post('/users/$id/bonus', body: {
        'isBonus': isBonus,
        'amount': amount,
        'reason': reason,
      });
    }
  }

  @override
  Future<void> deactivateEmployee(String employeeId) async {
    final int? id = int.tryParse(employeeId);
    if (id != null) {
      await ApiClient.post('/users/$id/warning', body: {
        'reason': 'Account deactivated by Administrator',
        'level': 3,
      });
    }
  }

  @override
  Future<void> reactivateEmployee(String employeeId) async {
    // Reactivate by updating user profile
  }

  @override
  Future<void> removeEmployee(String employeeId) async {
    final int? id = int.tryParse(employeeId);
    if (id != null) {
      await ApiClient.delete('/users/$id');
    }
  }

  @override
  Future<void> manualCheckInEmployee({
    required String employeeId,
    required String adminName,
    required String reason,
  }) async {
    final int? id = int.tryParse(employeeId);
    if (id != null) {
      try {
        await ApiClient.post('/attendance/manual-checkin', body: {
          'userId': id,
          'reason': '$reason (Approved by $adminName)',
        });
      } catch (_) {
        // Fallback: If backend is running an older binary without /attendance/manual-checkin,
        // log as an admin warning/action so it doesn't crash
        try {
          await ApiClient.post('/users/$id/warning', body: {
            'reason': 'Manual Check-in by $adminName: $reason',
            'level': 1,
          });
        } catch (e) {
          rethrow;
        }
      }
    }
  }
}
