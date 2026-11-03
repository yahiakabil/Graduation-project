import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/payroll_repository.dart';
import 'payroll_state.dart';

class PayrollCubit extends Cubit<PayrollState> {
  final IPayrollRepository payrollRepository;

  PayrollCubit({required this.payrollRepository}) : super(PayrollInitial());

  Future<void> loadPayroll() async {
    emit(PayrollLoading());
    try {
      final list = await payrollRepository.getPayrollMonths();
      Map<String, dynamic> disburseStatus = {};
      try {
        disburseStatus = await payrollRepository.getDisbursementStatus();
      } catch (_) {}

      emit(PayrollLoaded(
        months: list,
        selectedMonthId: list.isNotEmpty ? list.first.id : 'oct_2026',
        isDisbursedToday: disburseStatus['isDisbursedToday'] == true,
        daysAccrued: (disburseStatus['daysAccrued'] as num?)?.toInt() ?? 1,
        dailyAccrualRate: (disburseStatus['dailyAccrualRate'] as num?)?.toDouble() ?? 0.0,
        estimatedAccruedNet: (disburseStatus['estimatedAccruedNet'] as num?)?.toDouble() ?? 0.0,
        lastDisbursedDate: disburseStatus['lastDisbursedDate']?.toString(),
        disbursementStatusMessage: disburseStatus['statusMessage']?.toString(),
      ));
    } catch (e) {
      emit(PayrollError(e.toString()));
    }
  }

  void selectMonth(String monthId) {
    if (state is PayrollLoaded) {
      final cur = state as PayrollLoaded;
      emit(cur.copyWith(selectedMonthId: monthId));
    }
  }

  Future<void> lockMonth(String monthId) async {
    try {
      await payrollRepository.lockMonth(monthId);
      final list = await payrollRepository.getPayrollMonths();
      if (state is PayrollLoaded) {
        final cur = state as PayrollLoaded;
        emit(cur.copyWith(
          months: list,
          message: 'Payroll locked and finalized successfully.',
        ));
      }
    } catch (e) {
      emit(PayrollError(e.toString()));
    }
  }

  Future<void> disburseSalaries() async {
    if (state is! PayrollLoaded) return;
    final cur = state as PayrollLoaded;
    emit(cur.copyWith(isDisbursing: true));
    try {
      final result = await payrollRepository.disburseSalaries();
      final list = await payrollRepository.getPayrollMonths();
      Map<String, dynamic> disburseStatus = {};
      try {
        disburseStatus = await payrollRepository.getDisbursementStatus();
      } catch (_) {}

      final msg = result['message']?.toString() ?? 'Salaries successfully disbursed!';
      emit(cur.copyWith(
        months: list,
        isDisbursedToday: disburseStatus['isDisbursedToday'] == true,
        daysAccrued: (disburseStatus['daysAccrued'] as num?)?.toInt() ?? 0,
        dailyAccrualRate: (disburseStatus['dailyAccrualRate'] as num?)?.toDouble() ?? 0.0,
        estimatedAccruedNet: (disburseStatus['estimatedAccruedNet'] as num?)?.toDouble() ?? 0.0,
        lastDisbursedDate: disburseStatus['lastDisbursedDate']?.toString(),
        disbursementStatusMessage: disburseStatus['statusMessage']?.toString(),
        isDisbursing: false,
        message: msg,
      ));
    } catch (e) {
      emit(cur.copyWith(
        isDisbursing: false,
        message: 'Disbursement failed: ',
      ));
    }
  }
}