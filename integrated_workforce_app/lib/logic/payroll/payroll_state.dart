import 'package:equatable/equatable.dart';
import '../../data/models/company_models.dart';

abstract class PayrollState extends Equatable {
  const PayrollState();
  @override
  List<Object?> get props => [];
}

class PayrollInitial extends PayrollState {}

class PayrollLoading extends PayrollState {}

class PayrollLoaded extends PayrollState {
  final List<PayrollMonthModel> months;
  final String selectedMonthId;
  final String? message;
  final bool isDisbursedToday;
  final int daysAccrued;
  final double dailyAccrualRate;
  final double estimatedAccruedNet;
  final String? lastDisbursedDate;
  final String? disbursementStatusMessage;
  final bool isDisbursing;

  const PayrollLoaded({
    required this.months,
    required this.selectedMonthId,
    this.message,
    this.isDisbursedToday = false,
    this.daysAccrued = 1,
    this.dailyAccrualRate = 0.0,
    this.estimatedAccruedNet = 0.0,
    this.lastDisbursedDate,
    this.disbursementStatusMessage,
    this.isDisbursing = false,
  });

  PayrollMonthModel get activeMonth {
    return months.firstWhere(
      (m) => m.id == selectedMonthId,
      orElse: () => months.first,
    );
  }

  PayrollLoaded copyWith({
    List<PayrollMonthModel>? months,
    String? selectedMonthId,
    String? message,
    bool? isDisbursedToday,
    int? daysAccrued,
    double? dailyAccrualRate,
    double? estimatedAccruedNet,
    String? lastDisbursedDate,
    String? disbursementStatusMessage,
    bool? isDisbursing,
  }) {
    return PayrollLoaded(
      months: months ?? this.months,
      selectedMonthId: selectedMonthId ?? this.selectedMonthId,
      message: message,
      isDisbursedToday: isDisbursedToday ?? this.isDisbursedToday,
      daysAccrued: daysAccrued ?? this.daysAccrued,
      dailyAccrualRate: dailyAccrualRate ?? this.dailyAccrualRate,
      estimatedAccruedNet: estimatedAccruedNet ?? this.estimatedAccruedNet,
      lastDisbursedDate: lastDisbursedDate ?? this.lastDisbursedDate,
      disbursementStatusMessage: disbursementStatusMessage ?? this.disbursementStatusMessage,
      isDisbursing: isDisbursing ?? this.isDisbursing,
    );
  }

  @override
  List<Object?> get props => [
        months,
        selectedMonthId,
        message,
        isDisbursedToday,
        daysAccrued,
        dailyAccrualRate,
        estimatedAccruedNet,
        lastDisbursedDate,
        disbursementStatusMessage,
        isDisbursing,
      ];
}

class PayrollError extends PayrollState {
  final String message;
  const PayrollError(this.message);
  @override
  List<Object?> get props => [message];
}