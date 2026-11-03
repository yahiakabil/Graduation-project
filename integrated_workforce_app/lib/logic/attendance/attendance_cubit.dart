import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/attendance_repository.dart';
import 'attendance_state.dart';

class AttendanceCubit extends Cubit<AttendanceState> {
  final IAttendanceRepository attendanceRepository;
  String? _currentUserId;

  AttendanceCubit({required this.attendanceRepository}) : super(AttendanceInitial());

  void reset() {
    _currentUserId = null;
    emit(AttendanceInitial());
  }

  Future<void> loadAttendanceData({String? userId, int? year, int? month}) async {
    if (userId != null) {
      _currentUserId = userId;
    }

    emit(AttendanceLoading());
    final now = DateTime.now();
    final targetYear = year ?? now.year;
    final targetMonth = month ?? now.month;

    try {
      final today = await attendanceRepository.getTodayAttendance(userId: _currentUserId);
      final history = await attendanceRepository.getMonthlyHistory(
        userId: _currentUserId,
        year: targetYear,
        month: targetMonth,
      );
      final summary = await attendanceRepository.getMonthSummary(
        userId: _currentUserId,
        year: targetYear,
        month: targetMonth,
      );

      emit(AttendanceLoaded(
        todayRecord: today,
        historyList: history,
        monthSummary: summary,
      ));
    } catch (e) {
      emit(AttendanceError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> checkIn({
    required double latitude,
    required double longitude,
    required bool biometricVerified,
    required bool isMockLocation,
  }) async {
    final current = state;
    if (current is AttendanceLoaded) {
      emit(current.copyWith(isActionInProgress: true));
    }

    try {
      final updated = await attendanceRepository.checkIn(
        userId: _currentUserId,
        latitude: latitude,
        longitude: longitude,
        biometricVerified: biometricVerified,
        isMockLocation: isMockLocation,
      );

      if (state is AttendanceLoaded) {
        final cur = state as AttendanceLoaded;
        emit(cur.copyWith(
          todayRecord: updated,
          isActionInProgress: false,
          successMessage: 'Clock-in verified with Biometrics & GPS (Inside 50m radius)!',
        ));
      } else {
        await loadAttendanceData(userId: _currentUserId);
      }
    } catch (e) {
      emit(AttendanceError(e.toString().replaceAll('Exception: ', '')));
      await loadAttendanceData(userId: _currentUserId);
    }
  }

  Future<void> checkOut() async {
    final current = state;
    if (current is AttendanceLoaded) {
      emit(current.copyWith(isActionInProgress: true));
    }

    try {
      final updated = await attendanceRepository.checkOut(userId: _currentUserId);

      if (state is AttendanceLoaded) {
        final cur = state as AttendanceLoaded;
        emit(cur.copyWith(
          todayRecord: updated,
          isActionInProgress: false,
          successMessage: 'Successfully clocked out for today!',
        ));
      } else {
        await loadAttendanceData(userId: _currentUserId);
      }
    } catch (e) {
      emit(AttendanceError(e.toString().replaceAll('Exception: ', '')));
      await loadAttendanceData(userId: _currentUserId);
    }
  }
}
