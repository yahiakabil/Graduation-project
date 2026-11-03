import 'package:equatable/equatable.dart';

enum RequestType {
  leave,
  excuse,
  permission,
  correction,
  overtime,
  deviceChange,
  profileUpdate,
  cashAdvance,
  complaint,
}

enum RequestStatus {
  pending,
  approved,
  rejected,
}

class RequestModel extends Equatable {
  final String id;
  final String employeeId;
  final String employeeName;
  final String employeeRole;
  final RequestType type;
  final RequestStatus status;
  final DateTime submissionDate;
  final String targetDate;
  final String reason;
  final String? managerComment;
  final int? minutes;
  final String? requestedCheckOutTime;
  final String? actualCheckInTime;
  final String? updatedPhone;
  final String? updatedAddress;
  final double? advanceAmount;
  final String? repaymentSchedule;
  final String reviewerRole; // 'Direct Manager' or 'Admin HR'
  final String department;

  const RequestModel({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.employeeRole,
    required this.type,
    required this.status,
    required this.submissionDate,
    required this.targetDate,
    required this.reason,
    this.managerComment,
    this.minutes,
    this.requestedCheckOutTime,
    this.actualCheckInTime,
    this.updatedPhone,
    this.updatedAddress,
    this.advanceAmount,
    this.repaymentSchedule,
    this.reviewerRole = 'Direct Manager',
    this.department = 'Mobile Engineering Team',
  });

  String get typeLabel {
    switch (type) {
      case RequestType.leave:
        return 'Leave Request';
      case RequestType.excuse:
        return 'Single-Day Excuse';
      case RequestType.permission:
        return 'Late/Early Permission';
      case RequestType.correction:
        return 'Check-Out Correction';
      case RequestType.overtime:
        return 'Overtime Request';
      case RequestType.deviceChange:
        return 'Device Change Request';
      case RequestType.profileUpdate:
        return 'Profile Data Update';
      case RequestType.cashAdvance:
        return 'Cash Advance (سلفة)';
      case RequestType.complaint:
        return 'Direct HR Grievance / Inquiry';
    }
  }

  RequestModel copyWith({
    RequestStatus? status,
    String? managerComment,
    double? advanceAmount,
    String? repaymentSchedule,
  }) {
    return RequestModel(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      employeeRole: employeeRole,
      type: type,
      status: status ?? this.status,
      submissionDate: submissionDate,
      targetDate: targetDate,
      reason: reason,
      managerComment: managerComment ?? this.managerComment,
      minutes: minutes,
      requestedCheckOutTime: requestedCheckOutTime,
      actualCheckInTime: actualCheckInTime,
      updatedPhone: updatedPhone,
      updatedAddress: updatedAddress,
      advanceAmount: advanceAmount ?? this.advanceAmount,
      repaymentSchedule: repaymentSchedule ?? this.repaymentSchedule,
      reviewerRole: reviewerRole,
      department: department,
    );
  }


  factory RequestModel.fromApiJson(Map<String, dynamic> json) {
    final typeStr = (json['type'] ?? 'leave').toString().toLowerCase();
    RequestType resolvedType = RequestType.leave;
    if (typeStr.contains('excuse')) {
      resolvedType = RequestType.excuse;
    } else if (typeStr.contains('permission')) {
      resolvedType = RequestType.permission;
    } else if (typeStr.contains('correct')) {
      resolvedType = RequestType.correction;
    } else if (typeStr.contains('overtime')) {
      resolvedType = RequestType.overtime;
    } else if (typeStr.contains('device')) {
      resolvedType = RequestType.deviceChange;
    } else if (typeStr.contains('profile')) {
      resolvedType = RequestType.profileUpdate;
    } else if (typeStr.contains('cash') || typeStr.contains('advance')) {
      resolvedType = RequestType.cashAdvance;
    } else if (typeStr.contains('complaint')) {
      resolvedType = RequestType.complaint;
    }

    final statusStr = (json['status'] ?? 'pending').toString().toLowerCase();
    RequestStatus resolvedStatus = RequestStatus.pending;
    if (statusStr == 'approved') {
      resolvedStatus = RequestStatus.approved;
    } else if (statusStr == 'rejected') {
      resolvedStatus = RequestStatus.rejected;
    }

    final fromDate = json['fromDate']?.toString();
    final toDate = json['toDate']?.toString();
    String targetDate = fromDate ?? DateTime.now().toIso8601String().split('T').first;
    if (fromDate != null && toDate != null && fromDate != toDate) {
      targetDate = '$fromDate – $toDate';
    }

    DateTime subDate = DateTime.now();
    if (json['createdAt'] != null) {
      subDate = DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now();
    }

    return RequestModel(
      id: (json['id'] ?? 0).toString(),
      employeeId: (json['userId'] ?? 0).toString(),
      employeeName: json['employeeName']?.toString() ?? 'Employee',
      employeeRole: 'Staff Member',
      type: resolvedType,
      status: resolvedStatus,
      submissionDate: subDate,
      targetDate: targetDate,
      reason: json['reason']?.toString() ?? '',
      managerComment: json['decisionComment']?.toString(),
      advanceAmount: (json['advanceAmount'] as num?)?.toDouble(),
      reviewerRole: json['decidedByName']?.toString() ?? 'Direct Manager / HR',
      department: 'Company',
    );
  }

  Map<String, dynamic> toApiPayload() {
    String apiType;
    switch (type) {
      case RequestType.leave:
        apiType = 'Leave';
        break;
      case RequestType.excuse:
        apiType = 'Excuse';
        break;
      case RequestType.permission:
        apiType = 'Permission';
        break;
      case RequestType.correction:
        apiType = 'Correction';
        break;
      case RequestType.overtime:
        apiType = 'Overtime';
        break;
      case RequestType.deviceChange:
        apiType = 'DeviceChange';
        break;
      case RequestType.profileUpdate:
        apiType = 'ProfileUpdate';
        break;
      case RequestType.cashAdvance:
        apiType = 'CashAdvance';
        break;
      case RequestType.complaint:
        apiType = 'Complaint';
        break;
    }

    // Extract ISO date from targetDate if possible
    String isoDate = DateTime.now().toIso8601String().split('T').first;
    final isoMatch = RegExp(r'\d{4}-\d{2}-\d{2}').firstMatch(targetDate);
    if (isoMatch != null) {
      isoDate = isoMatch.group(0)!;
    }

    String reasonText = reason;
    if (type == RequestType.profileUpdate) {
      reasonText = '[NewPhone: ${updatedPhone ?? ""}] [NewAddress: ${updatedAddress ?? ""}] $reason'.trim();
    }

    return {
      'type': apiType,
      'leaveType': type == RequestType.leave ? 'annual' : null,
      'permissionKind': type == RequestType.permission ? 'Standard' : null,
      'requestedMinutes': minutes,
      'fromDate': isoDate,
      'toDate': isoDate,
      'reason': reasonText,
      'advanceAmount': advanceAmount,
      'repaymentSchedule': repaymentSchedule ?? 'Next Month Salary Deduction',
      'updatedPhone': updatedPhone,
      'updatedAddress': updatedAddress,
    };
  }

  @override
  List<Object?> get props => [
        id,
        employeeId,
        employeeName,
        employeeRole,
        type,
        status,
        submissionDate,
        targetDate,
        reason,
        managerComment,
        minutes,
        requestedCheckOutTime,
        actualCheckInTime,
        updatedPhone,
        updatedAddress,
        advanceAmount,
        repaymentSchedule,
        reviewerRole,
        department,
      ];
}
