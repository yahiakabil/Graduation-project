import 'package:intl/intl.dart';
import '../models/attendance_model.dart';
import '../repositories/attendance_repository.dart';

class FakeAttendanceRepository implements IAttendanceRepository {
  static FakeAttendanceRepository? instance;

  FakeAttendanceRepository() {
    instance = this;
  }

  // Branch HQ Coordinates (Smart Village, Cairo)
  static const double branchLatitude = 30.0735;
  static const double branchLongitude = 31.0205;
  static const double branchRadiusMeters = 50.0;

  final Map<String, AttendanceRecordModel> _historyOverrides = {};

  void applyApprovedRequest(dynamic req) {
    final String uId = req.employeeId ?? 'emp-1';
    // final String targetDateStr = (req.targetDate ?? '').toString();
    
    // Check if target is today or Oct 18
    final isLatePerm = req.typeLabel.toString().toLowerCase().contains('permission') || 
                       req.type.toString().contains('permission');

    if (isLatePerm) {
      if (_recordsByUserId.containsKey(uId)) {
        final cur = _recordsByUserId[uId]!;
        _recordsByUserId[uId] = cur.copyWith(
          minutesLate: 0,
          deductionHours: 0.0,
          deductionLabel: '0 min (Permission Approved)',
          status: AttendanceStatus.onTime,
          notes: 'Late Permission Accepted: ${req.reason}',
        );
      }
      _historyOverrides['hist-1'] = AttendanceRecordModel(
        id: 'hist-1',
        date: DateTime(2026, 10, 18),
        checkInTime: '09:28 AM',
        checkOutTime: null,
        minutesLate: 0,
        status: AttendanceStatus.onTime,
        deductionLabel: '0 min (Permission Approved)',
        deductionHours: 0.0,
        isInsideRadius: true,
        notes: 'Late Permission Accepted: ${req.reason}',
      );
    } else {
      // Leave / Single Day Excuse
      _historyOverrides['hist-3'] = AttendanceRecordModel(
        id: 'hist-3',
        date: DateTime(2026, 10, 16),
        checkInTime: null,
        checkOutTime: null,
        minutesLate: 0,
        status: AttendanceStatus.onLeave,
        deductionLabel: '0 deduction (Approved Excuse)',
        deductionHours: 0.0,
        isInsideRadius: false,
        notes: 'Excused: ${req.reason}',
      );
    }
  }

  // Separate, independent attendance records by userId so Employee & Manager never conflict
  final Map<String, AttendanceRecordModel> _recordsByUserId = {
    // Employee (Ahmed Kamal) - Starts late (28m)
    'emp-1': AttendanceRecordModel(
      id: 'att-emp-1',
      date: DateTime.now(),
      checkInTime: null,
      checkOutTime: null,
      minutesLate: 28,
      status: AttendanceStatus.late,
      deductionLabel: '1.0 hr Deduction (Ladder 16-60m)',
      deductionHours: 1.0,
      isInsideRadius: true,
    ),
    // Manager (Eng. Tarek Fathy) - Independent shift, starts un-clocked-in (on time)
    'mgr-1': AttendanceRecordModel(
      id: 'att-mgr-1',
      date: DateTime.now(),
      checkInTime: null,
      checkOutTime: null,
      minutesLate: 0,
      status: AttendanceStatus.onTime,
      deductionLabel: '0 min deduction (Grace)',
      deductionHours: 0.0,
      isInsideRadius: true,
    ),
    // Admin (Sherif Mostafa)
    'adm-1': AttendanceRecordModel(
      id: 'att-adm-1',
      date: DateTime.now(),
      checkInTime: null,
      checkOutTime: null,
      minutesLate: 0,
      status: AttendanceStatus.onTime,
      deductionLabel: '0 min deduction',
      deductionHours: 0.0,
      isInsideRadius: true,
    ),
  };

  AttendanceRecordModel _getOrCreateRecord(String uId) {
    return _recordsByUserId.putIfAbsent(
      uId,
      () => AttendanceRecordModel(
        id: 'att-$uId',
        date: DateTime.now(),
        checkInTime: null,
        checkOutTime: null,
        minutesLate: 0,
        status: AttendanceStatus.onTime,
        deductionLabel: '0 min deduction',
        deductionHours: 0.0,
        isInsideRadius: true,
      ),
    );
  }

  @override
  Future<AttendanceRecordModel> getTodayAttendance({String? userId}) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final uId = userId ?? 'emp-1';
    return _getOrCreateRecord(uId);
  }

  @override
  Future<AttendanceRecordModel> checkIn({
    String? userId,
    required double latitude,
    required double longitude,
    required bool biometricVerified,
    required bool isMockLocation,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final uId = userId ?? 'emp-1';

    if (isMockLocation) {
      throw Exception('MOCK_LOCATION_DETECTED: Mock GPS application detected on this device.');
    }

    if (!biometricVerified) {
      throw Exception('BIOMETRIC_NOT_VERIFIED: Strong biometrics required (Fingerprint/FaceID).');
    }

    final now = DateTime.now();
    final timeStr = DateFormat('hh:mm a').format(now);
    final currentRec = _getOrCreateRecord(uId);

    final updated = currentRec.copyWith(
      checkInTime: timeStr,
      isInsideRadius: true,
    );

    _recordsByUserId[uId] = updated;
    return updated;
  }

  @override
  Future<AttendanceRecordModel> checkOut({String? userId}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final uId = userId ?? 'emp-1';
    final now = DateTime.now();
    final timeStr = DateFormat('hh:mm a').format(now);

    final currentRec = _getOrCreateRecord(uId);
    final updated = currentRec.copyWith(
      checkOutTime: timeStr,
    );

    _recordsByUserId[uId] = updated;
    return updated;
  }

  @override
  Future<List<AttendanceRecordModel>> getMonthlyHistory({
    String? userId,
    required int year,
    required int month,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final uId = userId ?? 'emp-1';
    final today = _getOrCreateRecord(uId);

    if (uId == 'mgr-1') {
      // Manager's own attendance history
      return [
        AttendanceRecordModel(
          id: 'mgr-hist-1',
          date: DateTime(year, month, 18),
          checkInTime: today.checkInTime ?? '08:48 AM',
          checkOutTime: today.checkOutTime,
          minutesLate: 0,
          status: AttendanceStatus.onTime,
          deductionLabel: '0 min deduction (Grace)',
          deductionHours: 0.0,
          isInsideRadius: true,
        ),
        AttendanceRecordModel(
          id: 'mgr-hist-2',
          date: DateTime(year, month, 17),
          checkInTime: '08:50 AM',
          checkOutTime: '05:10 PM',
          minutesLate: 0,
          status: AttendanceStatus.onTime,
          deductionLabel: '0 min deduction',
          deductionHours: 0.0,
          isInsideRadius: true,
        ),
      ];
    }

    // Default employee history (Ahmed Kamal) — 3 months of data
    return [
      // ── October 2026 ──
      _historyOverrides['hist-1'] ?? AttendanceRecordModel(
        id: 'hist-1',
        date: DateTime(2026, 10, 18),
        checkInTime: today.checkInTime ?? '09:28 AM',
        checkOutTime: today.checkOutTime,
        minutesLate: 28,
        status: AttendanceStatus.late,
        deductionLabel: '1.0 hr Deduction',
        deductionHours: 1.0,
        isInsideRadius: true,
      ),
      AttendanceRecordModel(
        id: 'hist-2',
        date: DateTime(2026, 10, 17),
        checkInTime: '08:55 AM',
        checkOutTime: '05:02 PM',
        minutesLate: 0,
        status: AttendanceStatus.onTime,
        deductionLabel: '0 min deduction (Grace)',
        deductionHours: 0.0,
        overtimeMinutes: 30,
        isInsideRadius: true,
      ),
      _historyOverrides['hist-3'] ?? AttendanceRecordModel(
        id: 'hist-3',
        date: DateTime(2026, 10, 16),
        checkInTime: null,
        checkOutTime: null,
        minutesLate: 0,
        status: AttendanceStatus.absent,
        deductionLabel: '2.0 Days (Unexcused Absence)',
        deductionHours: 16.0,
        isInsideRadius: false,
      ),
      AttendanceRecordModel(
        id: 'hist-4',
        date: DateTime(2026, 10, 15),
        checkInTime: '09:05 AM',
        checkOutTime: '05:15 PM',
        minutesLate: 5,
        status: AttendanceStatus.onTime,
        deductionLabel: '0 min (Grace 0-15m)',
        deductionHours: 0.0,
        isInsideRadius: true,
      ),
      AttendanceRecordModel(
        id: 'hist-5',
        date: DateTime(2026, 10, 14),
        checkInTime: '09:45 AM',
        checkOutTime: '05:00 PM',
        minutesLate: 45,
        status: AttendanceStatus.late,
        deductionLabel: '1.0 hr Deduction',
        deductionHours: 1.0,
        isInsideRadius: true,
      ),
      // ── September 2026 ──
      AttendanceRecordModel(
        id: 'hist-sep-1',
        date: DateTime(2026, 9, 30),
        checkInTime: '08:50 AM',
        checkOutTime: '05:30 PM',
        minutesLate: 0,
        status: AttendanceStatus.onTime,
        deductionLabel: '0 min deduction',
        deductionHours: 0.0,
        overtimeMinutes: 30,
        isInsideRadius: true,
      ),
      AttendanceRecordModel(
        id: 'hist-sep-2',
        date: DateTime(2026, 9, 29),
        checkInTime: '09:20 AM',
        checkOutTime: '05:00 PM',
        minutesLate: 20,
        status: AttendanceStatus.late,
        deductionLabel: '1.0 hr Deduction (Ladder 16-60m)',
        deductionHours: 1.0,
        isInsideRadius: true,
      ),
      AttendanceRecordModel(
        id: 'hist-sep-3',
        date: DateTime(2026, 9, 28),
        checkInTime: '08:58 AM',
        checkOutTime: '05:05 PM',
        minutesLate: 0,
        status: AttendanceStatus.onTime,
        deductionLabel: '0 min deduction',
        deductionHours: 0.0,
        isInsideRadius: true,
      ),
      AttendanceRecordModel(
        id: 'hist-sep-4',
        date: DateTime(2026, 9, 25),
        checkInTime: null,
        checkOutTime: null,
        minutesLate: 0,
        status: AttendanceStatus.onLeave,
        deductionLabel: 'Annual Leave (Approved)',
        deductionHours: 0.0,
        isInsideRadius: false,
      ),
      AttendanceRecordModel(
        id: 'hist-sep-5',
        date: DateTime(2026, 9, 24),
        checkInTime: '09:10 AM',
        checkOutTime: '06:00 PM',
        minutesLate: 10,
        status: AttendanceStatus.onTime,
        deductionLabel: '0 min (Grace 0-15m)',
        deductionHours: 0.0,
        overtimeMinutes: 60,
        isInsideRadius: true,
      ),
      // ── August 2026 ──
      AttendanceRecordModel(
        id: 'hist-aug-1',
        date: DateTime(2026, 8, 31),
        checkInTime: '08:45 AM',
        checkOutTime: '05:00 PM',
        minutesLate: 0,
        status: AttendanceStatus.onTime,
        deductionLabel: '0 min deduction',
        deductionHours: 0.0,
        isInsideRadius: true,
      ),
      AttendanceRecordModel(
        id: 'hist-aug-2',
        date: DateTime(2026, 8, 28),
        checkInTime: '10:05 AM',
        checkOutTime: '05:00 PM',
        minutesLate: 65,
        status: AttendanceStatus.late,
        deductionLabel: '1.5 hr Deduction (Ladder 61-120m)',
        deductionHours: 1.5,
        isInsideRadius: true,
      ),
      AttendanceRecordModel(
        id: 'hist-aug-3',
        date: DateTime(2026, 8, 27),
        checkInTime: '09:00 AM',
        checkOutTime: '05:00 PM',
        minutesLate: 0,
        status: AttendanceStatus.onTime,
        deductionLabel: '0 min deduction',
        deductionHours: 0.0,
        isInsideRadius: true,
      ),
      AttendanceRecordModel(
        id: 'hist-aug-4',
        date: DateTime(2026, 8, 26),
        checkInTime: null,
        checkOutTime: null,
        minutesLate: 0,
        status: AttendanceStatus.absent,
        deductionLabel: '2.0 Days (Unexcused Absence)',
        deductionHours: 16.0,
        isInsideRadius: false,
      ),
      AttendanceRecordModel(
        id: 'hist-aug-5',
        date: DateTime(2026, 8, 25),
        checkInTime: '08:55 AM',
        checkOutTime: '05:15 PM',
        minutesLate: 0,
        status: AttendanceStatus.onTime,
        deductionLabel: '0 min deduction',
        deductionHours: 0.0,
        overtimeMinutes: 15,
        isInsideRadius: true,
      ),
    ];
  }

  @override
  Future<MonthSummaryModel> getMonthSummary({
    String? userId,
    required int year,
    required int month,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final uId = userId ?? 'emp-1';

    if (uId == 'mgr-1') {
      return MonthSummaryModel(
        year: year,
        month: month,
        presentDays: 18,
        lateDays: 0,
        absentDays: 0,
        onLeaveDays: 1,
        totalDeductedHours: 0.0,
        totalOvertimeHours: 6.0,
        penaltyDaysCount: 0,
        maxPenaltyThreshold: 5,
      );
    }

    return MonthSummaryModel(
      year: year,
      month: month,
      presentDays: 14,
      lateDays: 3,
      absentDays: 1,
      onLeaveDays: 2,
      totalDeductedHours: 4.0,
      totalOvertimeHours: 2.5,
      penaltyDaysCount: 4,
      maxPenaltyThreshold: 5,
    );
  }
}
