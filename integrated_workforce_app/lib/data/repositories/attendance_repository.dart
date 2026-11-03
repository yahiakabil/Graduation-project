import '../models/attendance_model.dart';

abstract class IAttendanceRepository {
  /// Fetches today's attendance status for a specific user
  Future<AttendanceRecordModel> getTodayAttendance({String? userId});

  /// Performs server-authoritative check-in with GPS and biometric verification
  Future<AttendanceRecordModel> checkIn({
    String? userId,
    required double latitude,
    required double longitude,
    required bool biometricVerified,
    required bool isMockLocation,
  });

  /// Performs check-out for a specific user
  Future<AttendanceRecordModel> checkOut({String? userId});

  /// Fetches attendance records list for given month and user
  Future<List<AttendanceRecordModel>> getMonthlyHistory({
    String? userId,
    required int year,
    required int month,
  });

  /// Fetches monthly summary counters and penalty warning meter
  Future<MonthSummaryModel> getMonthSummary({
    String? userId,
    required int year,
    required int month,
  });
}
