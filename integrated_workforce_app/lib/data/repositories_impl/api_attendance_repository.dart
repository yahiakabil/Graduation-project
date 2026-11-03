import 'package:intl/intl.dart';
import '../api/api_client.dart';
import '../models/attendance_model.dart';
import '../repositories/attendance_repository.dart';

class ApiAttendanceRepository implements IAttendanceRepository {
  double _lastLat = 31.462085;
  double _lastLon = 31.454358;
  AttendanceRecordModel _currentToday = AttendanceRecordModel(
    id: 'att-today',
    date: DateTime.now(),
    status: AttendanceStatus.weekend,
    deductionLabel: 'Not checked in',
  );

  @override
  Future<AttendanceRecordModel> getTodayAttendance({String? userId}) async {
    try {
      final res = await ApiClient.get('/attendance/today');
      if (res is Map<String, dynamic>) {
        final checkedIn = res['checkedIn'] as bool? ?? false;
        final checkInTime = res['checkInTime']?.toString();
        final checkedOut = res['checkedOut'] as bool? ?? false;
        final checkOutTime = res['checkOutTime']?.toString();
        final lateMinutes = (res['lateMinutes'] as num?)?.toInt() ?? 0;
        final statusStr = (res['status'] ?? 'Absent').toString().toLowerCase();
        final isInside = res['isInsideBranch'] as bool? ?? true;

        AttendanceStatus status = AttendanceStatus.absent;
        if (checkedIn) {
          status = lateMinutes > 0 ? AttendanceStatus.late : AttendanceStatus.onTime;
        } else if (statusStr.contains('leave')) {
          status = AttendanceStatus.onLeave;
        }

        _currentToday = AttendanceRecordModel(
          id: 'att-today-${DateTime.now().millisecondsSinceEpoch}',
          date: DateTime.now(),
          checkInTime: checkInTime,
          checkOutTime: checkedOut ? checkOutTime : null,
          minutesLate: lateMinutes,
          status: status,
          deductionLabel: lateMinutes > 0 ? '$lateMinutes min Late' : (checkedIn ? '0 min deduction' : 'Not checked in'),
          isInsideRadius: isInside,
          biometricVerified: checkedIn,
        );
      }
      return _currentToday;
    } catch (_) {
      return _currentToday;
    }
  }

  @override
  Future<AttendanceRecordModel> checkIn({
    String? userId,
    required double latitude,
    required double longitude,
    required bool biometricVerified,
    required bool isMockLocation,
  }) async {
    _lastLat = latitude;
    _lastLon = longitude;
    final res = await ApiClient.post('/attendance/checkin', body: {
      'latitude': latitude,
      'longitude': longitude,
      'isMockLocation': isMockLocation,
      'biometricVerified': biometricVerified,
      'deviceIdentifier': 'Shiftly-Mobile-App',
      'faceLivenessScore': biometricVerified ? 0.99 : 0.0,
    });

    if (res is Map<String, dynamic>) {
      final lateMinutes = (res['lateMinutes'] as num?)?.toInt() ?? 0;
      final statusStr = (res['status'] ?? 'Present').toString().toLowerCase();

      AttendanceStatus status = lateMinutes > 0 ? AttendanceStatus.late : AttendanceStatus.onTime;
      if (statusStr.contains('leave')) status = AttendanceStatus.onLeave;

      _currentToday = AttendanceRecordModel(
        id: (res['id'] ?? 0).toString(),
        date: DateTime.now(),
        checkInTime: res['checkInTime']?.toString() ?? DateFormat('hh:mm a').format(DateTime.now()),
        checkOutTime: res['checkOutTime']?.toString(),
        minutesLate: lateMinutes,
        status: status,
        deductionLabel: lateMinutes > 0 ? '$lateMinutes min Late' : '0 min deduction',
        isInsideRadius: true,
        latitude: latitude,
        longitude: longitude,
        biometricVerified: biometricVerified,
      );
      return _currentToday;
    }

    return _currentToday;
  }

  @override
  Future<AttendanceRecordModel> checkOut({String? userId}) async {
    final res = await ApiClient.post('/attendance/checkout', body: {
      'latitude': _lastLat,
      'longitude': _lastLon,
    });

    if (res is Map<String, dynamic>) {
      final lateMinutes = (res['lateMinutes'] as num?)?.toInt() ?? _currentToday.minutesLate;
      _currentToday = _currentToday.copyWith(
        checkOutTime: res['checkOutTime']?.toString() ?? DateFormat('hh:mm a').format(DateTime.now()),
      );
    } else {
      _currentToday = _currentToday.copyWith(
        checkOutTime: DateFormat('hh:mm a').format(DateTime.now()),
      );
    }
    return _currentToday;
  }

  @override
  Future<List<AttendanceRecordModel>> getMonthlyHistory({
    String? userId,
    required int year,
    required int month,
  }) async {
    try {
      final res = await ApiClient.get('/attendance/history', queryParams: {'days': 31});
      if (res is List) {
        return res.map((item) {
          final m = item as Map<String, dynamic>;
          final dateStr = m['attendanceDate']?.toString() ?? '';
          final date = DateTime.tryParse(dateStr) ?? DateTime(year, month, 1);
          final lateMin = (m['lateMinutes'] as num?)?.toInt() ?? 0;
          final statusStr = (m['status'] ?? 'Present').toString().toLowerCase();

          AttendanceStatus status = AttendanceStatus.onTime;
          if (statusStr.contains('late') || lateMin > 0) {
            status = AttendanceStatus.late;
          } else if (statusStr.contains('absent')) {
            status = AttendanceStatus.absent;
          } else if (statusStr.contains('leave')) {
            status = AttendanceStatus.onLeave;
          }

          return AttendanceRecordModel(
            id: (m['id'] ?? 0).toString(),
            date: date,
            checkInTime: m['checkInTime']?.toString(),
            checkOutTime: m['checkOutTime']?.toString(),
            minutesLate: lateMin,
            status: status,
            deductionLabel: lateMin > 0 ? '$lateMin min Late' : '0 deduction',
            notes: m['note']?.toString(),
          );
        }).toList();
      }
      return [];
    } catch (_) {
      return [_currentToday];
    }
  }

  @override
  Future<MonthSummaryModel> getMonthSummary({
    String? userId,
    required int year,
    required int month,
  }) async {
    final history = await getMonthlyHistory(userId: userId, year: year, month: month);
    int present = 0;
    int late = 0;
    int absent = 0;
    int onLeave = 0;
    double deductedHours = 0.0;

    for (final r in history) {
      switch (r.status) {
        case AttendanceStatus.onTime:
          present++;
          break;
        case AttendanceStatus.late:
          present++;
          late++;
          deductedHours += (r.minutesLate / 60.0);
          break;
        case AttendanceStatus.absent:
          absent++;
          deductedHours += 8.0;
          break;
        case AttendanceStatus.onLeave:
          onLeave++;
          break;
        case AttendanceStatus.weekend:
          break;
      }
    }

    return MonthSummaryModel(
      year: year,
      month: month,
      presentDays: present,
      lateDays: late,
      absentDays: absent,
      onLeaveDays: onLeave,
      totalDeductedHours: deductedHours,
      totalOvertimeHours: 0.0,
      penaltyDaysCount: late + absent,
      maxPenaltyThreshold: 5,
    );
  }
}
