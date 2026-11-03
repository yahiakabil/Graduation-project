import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integrated_workforce_app/core/theme/app_theme.dart';
import 'package:integrated_workforce_app/data/fake/fake_attendance_repository.dart';
import 'package:integrated_workforce_app/data/fake/fake_auth_repository.dart';
import 'package:integrated_workforce_app/data/fake/fake_company_repository.dart';
import 'package:integrated_workforce_app/data/fake/fake_notifications_repository.dart';
import 'package:integrated_workforce_app/data/fake/fake_payroll_repository.dart';
import 'package:integrated_workforce_app/data/fake/fake_requests_repository.dart';
import 'package:integrated_workforce_app/data/fake/fake_team_repository.dart';
import 'package:integrated_workforce_app/data/models/attendance_model.dart';
import 'package:integrated_workforce_app/data/models/company_models.dart';
import 'package:integrated_workforce_app/data/models/request_model.dart';
import 'package:integrated_workforce_app/data/models/team_member_model.dart';
import 'package:integrated_workforce_app/logic/company/company_cubit.dart';
import 'package:integrated_workforce_app/main.dart';
import 'package:integrated_workforce_app/presentation/screens/admin_company_screen.dart';

void main() {
  testWidgets('App smoke test loads LoginScreen initially', (WidgetTester tester) async {
    final authRepo = FakeAuthRepository();
    final attendanceRepo = FakeAttendanceRepository();
    final requestsRepo = FakeRequestsRepository();
    final teamRepo = FakeTeamRepository();
    final notifsRepo = FakeNotificationsRepository();
    final companyRepo = FakeCompanyRepository();
    final payrollRepo = FakePayrollRepository();

    await tester.pumpWidget(WorkforceApp(
      authRepository: authRepo,
      attendanceRepository: attendanceRepo,
      requestsRepository: requestsRepo,
      teamRepository: teamRepo,
      notificationsRepository: notifsRepo,
      companyRepository: companyRepo,
      payrollRepository: payrollRepo,
    ));

    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    expect(find.text('Integrated Workforce'), findsOneWidget);
    expect(find.text('Sign In to Workplace'), findsOneWidget);
  });

  testWidgets('AdminCompanyScreen renders without exception', (WidgetTester tester) async {
    final companyRepo = FakeCompanyRepository();

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: BlocProvider<CompanyCubit>(
        create: (context) => CompanyCubit(companyRepository: companyRepo)..loadCompanyData(),
        child: const AdminCompanyScreen(),
      ),
    ));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Company Organization'), findsOneWidget);
  });

  test('DeductionRulesModel copyWith and update test', () {
    const rules = DeductionRulesModel();
    expect(rules.geofenceRadius, 50.0);
    expect(rules.overtimeMultiplier, 1.5);

    final updated = rules.copyWith(
      tier1: '1.5 Hours deduction',
      geofenceRadius: 75.0,
      overtimeMultiplier: 2.0,
    );

    expect(updated.tier1, '1.5 Hours deduction');
    expect(updated.geofenceRadius, 75.0);
    expect(updated.overtimeMultiplier, 2.0);
    expect(updated.tier2, rules.tier2); // unchanged
  });

  test('RequestModel cash advance attributes test', () {
    final req = RequestModel(
      id: 'req-ca-1',
      employeeId: 'emp-1',
      employeeName: 'Ahmed Kamal',
      employeeRole: 'Developer',
      type: RequestType.cashAdvance,
      status: RequestStatus.pending,
      submissionDate: DateTime.now(),
      targetDate: '2026-11-01',
      reason: 'Personal emergency medical expense',
      advanceAmount: 2500.0,
      repaymentSchedule: 'Split across 2 months (50% each)',
      reviewerRole: 'Admin HR',
    );

    expect(req.type, RequestType.cashAdvance);
    expect(req.typeLabel, 'Cash Advance (سلفة)');
    expect(req.advanceAmount, 2500.0);
    expect(req.repaymentSchedule, 'Split across 2 months (50% each)');
  });

  test('TeamMemberModel bonus and account deactivation test', () {
    const member = TeamMemberModel(
      id: 'emp-test',
      name: 'Test Staff',
      role: 'QA Engineer',
      code: 'EMP-9999',
      email: 'test@company.com',
      phone: '01000000000',
      status: AttendanceStatus.onTime,
      statusText: 'Active',
      issuesCount: 0,
      issueLabel: 'All Good',
      intervals: [],
    );

    expect(member.bonus, 0.0);
    expect(member.isSuspended, false);

    final updated = member.copyWith(
      bonus: 250.0,
      isSuspended: true,
    );

    expect(updated.bonus, 250.0);
    expect(updated.isSuspended, true);
  });
}
