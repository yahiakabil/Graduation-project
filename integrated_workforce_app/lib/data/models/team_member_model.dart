import 'package:equatable/equatable.dart';
import 'attendance_model.dart';

class PresenceIntervalModel extends Equatable {
  final String time;
  final String status; // 'inside', 'outside', 'pending'
  final String label;

  const PresenceIntervalModel({
    required this.time,
    required this.status,
    required this.label,
  });

  @override
  List<Object?> get props => [time, status, label];
}

class TeamMemberModel extends Equatable {
  final String id;
  final String name;
  final String role;
  final String code;
  final String email;
  final String phone;
  final AttendanceStatus status;
  final String statusText;
  final int issuesCount;
  final String issueLabel;
  final List<PresenceIntervalModel> intervals;
  final double bonus;
  final double discretionaryDeductions;
  final bool isSuspended;
  final bool isPendingAdminApproval;
  final String? photoUrl;

  const TeamMemberModel({
    required this.id,
    required this.name,
    required this.role,
    required this.code,
    required this.email,
    required this.phone,
    required this.status,
    required this.statusText,
    required this.issuesCount,
    required this.issueLabel,
    required this.intervals,
    this.bonus = 0.0,
    this.discretionaryDeductions = 0.0,
    this.isSuspended = false,
    this.isPendingAdminApproval = false,
    this.photoUrl,
  });

  TeamMemberModel copyWith({
    String? name,
    String? role,
    String? code,
    String? email,
    String? phone,
    AttendanceStatus? status,
    String? statusText,
    int? issuesCount,
    String? issueLabel,
    List<PresenceIntervalModel>? intervals,
    double? bonus,
    double? discretionaryDeductions,
    bool? isSuspended,
    bool? isPendingAdminApproval,
    String? photoUrl,
  }) {
    return TeamMemberModel(
      id: id,
      name: name ?? this.name,
      role: role ?? this.role,
      code: code ?? this.code,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      statusText: statusText ?? this.statusText,
      issuesCount: issuesCount ?? this.issuesCount,
      issueLabel: issueLabel ?? this.issueLabel,
      intervals: intervals ?? this.intervals,
      bonus: bonus ?? this.bonus,
      discretionaryDeductions: discretionaryDeductions ?? this.discretionaryDeductions,
      isSuspended: isSuspended ?? this.isSuspended,
      isPendingAdminApproval: isPendingAdminApproval ?? this.isPendingAdminApproval,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        role,
        code,
        email,
        phone,
        status,
        statusText,
        issuesCount,
        issueLabel,
        intervals,
        bonus,
        discretionaryDeductions,
        isSuspended,
        isPendingAdminApproval,
        photoUrl,
      ];
}
