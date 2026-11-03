import 'package:equatable/equatable.dart';
import '../../data/models/attendance_model.dart';

abstract class AttendanceState extends Equatable {
  const AttendanceState();
  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceLoaded extends AttendanceState {
  final AttendanceRecordModel todayRecord;
  final List<AttendanceRecordModel> historyList;
  final MonthSummaryModel monthSummary;
  final bool isActionInProgress;
  final String? successMessage;

  const AttendanceLoaded({
    required this.todayRecord,
    required this.historyList,
    required this.monthSummary,
    this.isActionInProgress = false,
    this.successMessage,
  });

  AttendanceLoaded copyWith({
    AttendanceRecordModel? todayRecord,
    List<AttendanceRecordModel>? historyList,
    MonthSummaryModel? monthSummary,
    bool? isActionInProgress,
    String? successMessage,
  }) {
    return AttendanceLoaded(
      todayRecord: todayRecord ?? this.todayRecord,
      historyList: historyList ?? this.historyList,
      monthSummary: monthSummary ?? this.monthSummary,
      isActionInProgress: isActionInProgress ?? this.isActionInProgress,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        todayRecord,
        historyList,
        monthSummary,
        isActionInProgress,
        successMessage,
      ];
}

class AttendanceError extends AttendanceState {
  final String message;
  const AttendanceError(this.message);
  @override
  List<Object?> get props => [message];
}
