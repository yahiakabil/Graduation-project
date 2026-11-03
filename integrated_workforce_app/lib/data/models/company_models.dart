import 'package:equatable/equatable.dart';
import 'attendance_model.dart';
import 'team_member_model.dart';

class BranchModel extends Equatable {
  final String id;
  final String name;
  final String address;
  final double radiusMeters;
  final List<DepartmentTeamModel> teams;

  const BranchModel({
    required this.id,
    required this.name,
    required this.address,
    this.radiusMeters = 50.0,
    required this.teams,
  });

  int get activeCount => teams.fold(0, (sum, t) => sum + t.memberCount);

  @override
  List<Object?> get props => [id, name, address, radiusMeters, teams];
}

class DepartmentTeamModel extends Equatable {
  final String id;
  final String name;
  final String headName;
  final String headTitle;
  final String? headEmail;
  final String? headPhone;
  final String? headPhotoUrl;
  final List<EmployeeDossierModel> employees;

  const DepartmentTeamModel({
    required this.id,
    required this.name,
    required this.headName,
    required this.headTitle,
    this.headEmail,
    this.headPhone,
    this.headPhotoUrl,
    required this.employees,
  });

  int get memberCount => employees.length;

  @override
  List<Object?> get props => [id, name, headName, headTitle, headEmail, headPhone, headPhotoUrl, employees];
}

class EmployeeDossierModel extends Equatable {
  final String id;
  final String name;
  final String code;
  final String role;
  final String email;
  final String phone;
  final String address;
  final String shift;
  final String hireDate;
  final AttendanceStatus status;
  final String statusText;
  final int issuesCount;
  final String issueLabel;
  final double baseSalary;
  final double deductions;
  final double overtimeHours;
  final double overtimeRate;
  final double netSalary;
  final List<PresenceIntervalModel> intervals;
  final double bonus;
  final bool isSuspended;
  final bool isPendingAdminApproval;
  final String? photoUrl;

  const EmployeeDossierModel({
    required this.id,
    required this.name,
    required this.code,
    required this.role,
    required this.email,
    required this.phone,
    required this.address,
    required this.shift,
    required this.hireDate,
    required this.status,
    required this.statusText,
    required this.issuesCount,
    required this.issueLabel,
    required this.baseSalary,
    required this.deductions,
    required this.overtimeHours,
    this.overtimeRate = 1.5,
    required this.netSalary,
    required this.intervals,
    this.bonus = 0.0,
    this.isSuspended = false,
    this.isPendingAdminApproval = false,
    this.photoUrl,
  });

  EmployeeDossierModel copyWith({
    String? name,
    String? role,
    String? code,
    String? email,
    String? phone,
    String? address,
    String? shift,
    String? hireDate,
    AttendanceStatus? status,
    String? statusText,
    int? issuesCount,
    String? issueLabel,
    double? baseSalary,
    double? netSalary,
    double? deductions,
    double? overtimeHours,
    double? overtimeRate,
    List<PresenceIntervalModel>? intervals,
    double? bonus,
    bool? isSuspended,
    bool? isPendingAdminApproval,
    String? photoUrl,
  }) {
    return EmployeeDossierModel(
      id: id,
      name: name ?? this.name,
      code: code ?? this.code,
      role: role ?? this.role,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      shift: shift ?? this.shift,
      hireDate: hireDate ?? this.hireDate,
      status: status ?? this.status,
      statusText: statusText ?? this.statusText,
      issuesCount: issuesCount ?? this.issuesCount,
      issueLabel: issueLabel ?? this.issueLabel,
      baseSalary: baseSalary ?? this.baseSalary,
      deductions: deductions ?? this.deductions,
      overtimeHours: overtimeHours ?? this.overtimeHours,
      overtimeRate: overtimeRate ?? this.overtimeRate,
      netSalary: netSalary ?? this.netSalary,
      intervals: intervals ?? this.intervals,
      bonus: bonus ?? this.bonus,
      isSuspended: isSuspended ?? this.isSuspended,
      isPendingAdminApproval: isPendingAdminApproval ?? this.isPendingAdminApproval,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        code,
        role,
        email,
        phone,
        address,
        shift,
        hireDate,
        status,
        statusText,
        issuesCount,
        issueLabel,
        baseSalary,
        deductions,
        overtimeHours,
        overtimeRate,
        netSalary,
        intervals,
        bonus,
        isSuspended,
        isPendingAdminApproval,
        photoUrl,
      ];
}

class TeamPayrollSummaryModel extends Equatable {
  final String teamName;
  final double totalNet;
  final double deductions;
  final double overtimeAmount;

  const TeamPayrollSummaryModel({
    required this.teamName,
    required this.totalNet,
    required this.deductions,
    required this.overtimeAmount,
  });

  @override
  List<Object?> get props => [teamName, totalNet, deductions, overtimeAmount];
}

class PayrollMonthModel extends Equatable {
  final String id;
  final String label;
  final String status;
  final bool isLocked;
  final double totalBase;
  final double totalDeductions;
  final double overtimeAmount;
  final double totalNet;
  final int overtimeHours;
  final List<TeamPayrollSummaryModel> teams;

  const PayrollMonthModel({
    required this.id,
    required this.label,
    required this.status,
    required this.isLocked,
    required this.totalBase,
    required this.totalDeductions,
    required this.overtimeAmount,
    required this.totalNet,
    required this.overtimeHours,
    required this.teams,
  });

  PayrollMonthModel copyWith({
    bool? isLocked,
    String? status,
  }) {
    return PayrollMonthModel(
      id: id,
      label: label,
      status: status ?? this.status,
      isLocked: isLocked ?? this.isLocked,
      totalBase: totalBase,
      totalDeductions: totalDeductions,
      overtimeAmount: overtimeAmount,
      totalNet: totalNet,
      overtimeHours: overtimeHours,
      teams: teams,
    );
  }

  @override
  List<Object?> get props => [
        id,
        label,
        status,
        isLocked,
        totalBase,
        totalDeductions,
        overtimeAmount,
        totalNet,
        overtimeHours,
        teams,
      ];
}

class DeductionRulesModel extends Equatable {
  final String gracePeriod;
  final String tier1;
  final String tier2;
  final String tier3;
  final String tier4;
  final String unexcusedAbsence;
  final String missingCheckout;
  final double geofenceRadius;
  final double overtimeMultiplier;

  const DeductionRulesModel({
    this.gracePeriod = '0 min deduction',
    this.tier1 = '1.0 Hour deduction',
    this.tier2 = '2.0 Hours deduction',
    this.tier3 = 'Half Day deduction',
    this.tier4 = 'Full Day deduction',
    this.unexcusedAbsence = '2.0 Days deduction',
    this.missingCheckout = 'Half Day deduction (if not fixed in 24h)',
    this.geofenceRadius = 50.0,
    this.overtimeMultiplier = 1.5,
  });

  DeductionRulesModel copyWith({
    String? gracePeriod,
    String? tier1,
    String? tier2,
    String? tier3,
    String? tier4,
    String? unexcusedAbsence,
    String? missingCheckout,
    double? geofenceRadius,
    double? overtimeMultiplier,
  }) {
    return DeductionRulesModel(
      gracePeriod: gracePeriod ?? this.gracePeriod,
      tier1: tier1 ?? this.tier1,
      tier2: tier2 ?? this.tier2,
      tier3: tier3 ?? this.tier3,
      tier4: tier4 ?? this.tier4,
      unexcusedAbsence: unexcusedAbsence ?? this.unexcusedAbsence,
      missingCheckout: missingCheckout ?? this.missingCheckout,
      geofenceRadius: geofenceRadius ?? this.geofenceRadius,
      overtimeMultiplier: overtimeMultiplier ?? this.overtimeMultiplier,
    );
  }

  factory DeductionRulesModel.fromApiJson(Map<String, dynamic> json) {
    return DeductionRulesModel(
      gracePeriod: json['gracePeriod'] as String? ?? '0 min deduction',
      tier1: json['tier1'] as String? ?? '1.0 Hour deduction',
      tier2: json['tier2'] as String? ?? '2.0 Hours deduction',
      tier3: json['tier3'] as String? ?? 'Half Day deduction',
      tier4: json['tier4'] as String? ?? 'Full Day deduction',
      unexcusedAbsence: json['unexcusedAbsence'] as String? ?? '2.0 Days deduction',
      missingCheckout: json['missingCheckout'] as String? ?? 'Half Day deduction (if not fixed in 24h)',
      geofenceRadius: (json['geofenceRadius'] as num?)?.toDouble() ?? 50.0,
      overtimeMultiplier: (json['overtimeMultiplier'] as num?)?.toDouble() ?? 1.5,
    );
  }

  factory DeductionRulesModel.fromApiList(List<dynamic> list) {
    String tier1 = '1.0 Hour deduction';
    String tier2 = '2.0 Hours deduction';
    String tier3 = 'Half Day deduction';
    String tier4 = 'Full Day deduction';
    String unexcused = '2.0 Days deduction';
    String missing = 'Half Day deduction (if not fixed in 24h)';

    for (final item in list) {
      if (item is Map) {
        final type = item['type']?.toString();
        final from = (item['fromMinutes'] as num?)?.toInt() ?? 0;
        final to = (item['toMinutes'] as num?)?.toInt() ?? 0;
        final label = item['label']?.toString();

        if (label != null && label.isNotEmpty) {
          if (type == 'Lateness') {
            if (from >= 16 && to <= 60) {
              tier1 = label;
            } else if (from >= 61 && to <= 120) {
              tier2 = label;
            } else if (from >= 121 && to <= 240) {
              tier3 = label;
            } else if (from >= 241) {
              tier4 = label;
            }
          } else if (type == 'Absence') {
            unexcused = label;
          } else if (type == 'MissingCheckout') {
            missing = label;
          }
        }
      }
    }

    return DeductionRulesModel(
      tier1: tier1,
      tier2: tier2,
      tier3: tier3,
      tier4: tier4,
      unexcusedAbsence: unexcused,
      missingCheckout: missing,
    );
  }

  Map<String, dynamic> toApiPayload() {
    return {
      'gracePeriod': gracePeriod,
      'tier1': tier1,
      'tier2': tier2,
      'tier3': tier3,
      'tier4': tier4,
      'unexcusedAbsence': unexcusedAbsence,
      'missingCheckout': missingCheckout,
      'geofenceRadius': geofenceRadius,
      'overtimeMultiplier': overtimeMultiplier,
    };
  }

  @override
  List<Object?> get props => [
        gracePeriod,
        tier1,
        tier2,
        tier3,
        tier4,
        unexcusedAbsence,
        missingCheckout,
        geofenceRadius,
        overtimeMultiplier,
      ];
}
