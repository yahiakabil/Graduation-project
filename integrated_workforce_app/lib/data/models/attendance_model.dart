import 'package:equatable/equatable.dart';

enum AttendanceStatus {
  onTime,
  late,
  absent,
  onLeave,
  weekend,
}

class AttendanceRecordModel extends Equatable {
  final String id;
  final DateTime date;
  final String? checkInTime;  // Formatted local time e.g. "09:28 AM"
  final String? checkOutTime; // Formatted local time e.g. "05:02 PM"
  final int minutesLate;
  final AttendanceStatus status;
  final String deductionLabel;
  final double deductionHours;
  final int overtimeMinutes;
  final bool isInsideRadius;
  final String? notes;
  final double? latitude;
  final double? longitude;
  final bool biometricVerified;

  const AttendanceRecordModel({
    required this.id,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    this.minutesLate = 0,
    required this.status,
    this.deductionLabel = '0 deduction',
    this.deductionHours = 0.0,
    this.overtimeMinutes = 0,
    this.isInsideRadius = true,
    this.notes,
    this.latitude,
    this.longitude,
    this.biometricVerified = false,
  });

  AttendanceRecordModel copyWith({
    String? checkInTime,
    String? checkOutTime,
    int? minutesLate,
    AttendanceStatus? status,
    String? deductionLabel,
    double? deductionHours,
    int? overtimeMinutes,
    bool? isInsideRadius,
    String? notes,
    double? latitude,
    double? longitude,
    bool? biometricVerified,
  }) {
    return AttendanceRecordModel(
      id: id,
      date: date,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      minutesLate: minutesLate ?? this.minutesLate,
      status: status ?? this.status,
      deductionLabel: deductionLabel ?? this.deductionLabel,
      deductionHours: deductionHours ?? this.deductionHours,
      overtimeMinutes: overtimeMinutes ?? this.overtimeMinutes,
      isInsideRadius: isInsideRadius ?? this.isInsideRadius,
      notes: notes ?? this.notes,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      biometricVerified: biometricVerified ?? this.biometricVerified,
    );
  }

  @override
  List<Object?> get props => [
        id,
        date,
        checkInTime,
        checkOutTime,
        minutesLate,
        status,
        deductionLabel,
        deductionHours,
        overtimeMinutes,
        isInsideRadius,
        notes,
        latitude,
        longitude,
        biometricVerified,
      ];
}

class MonthSummaryModel extends Equatable {
  final int year;
  final int month;
  final int presentDays;
  final int lateDays;
  final int absentDays;
  final int onLeaveDays;
  final double totalDeductedHours;
  final double totalOvertimeHours;
  final int penaltyDaysCount; // late + absent days this month
  final int maxPenaltyThreshold; // e.g. 5 days threshold for warning

  const MonthSummaryModel({
    required this.year,
    required this.month,
    required this.presentDays,
    required this.lateDays,
    required this.absentDays,
    required this.onLeaveDays,
    required this.totalDeductedHours,
    required this.totalOvertimeHours,
    required this.penaltyDaysCount,
    this.maxPenaltyThreshold = 5,
  });

  @override
  List<Object?> get props => [
        year,
        month,
        presentDays,
        lateDays,
        absentDays,
        onLeaveDays,
        totalDeductedHours,
        totalOvertimeHours,
        penaltyDaysCount,
        maxPenaltyThreshold,
      ];
}
