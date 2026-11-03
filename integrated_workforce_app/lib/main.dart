import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'data/fake/fake_attendance_repository.dart';
import 'data/fake/fake_auth_repository.dart';
import 'data/fake/fake_company_repository.dart';
import 'data/fake/fake_notifications_repository.dart';
import 'data/fake/fake_payroll_repository.dart';
import 'data/fake/fake_requests_repository.dart';
import 'data/fake/fake_team_repository.dart';
import 'data/repositories/attendance_repository.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/company_repository.dart';
import 'data/repositories/notifications_repository.dart';
import 'data/repositories/payroll_repository.dart';
import 'data/repositories/requests_repository.dart';
import 'data/repositories/team_repository.dart';
import 'logic/attendance/attendance_cubit.dart';
import 'logic/auth/auth_cubit.dart';
import 'logic/auth/auth_state.dart';
import 'logic/company/company_cubit.dart';
import 'logic/notifications/notifications_cubit.dart';
import 'logic/payroll/payroll_cubit.dart';
import 'logic/requests/requests_cubit.dart';
import 'logic/team/team_cubit.dart';
import 'logic/theme/theme_cubit.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/main_layout_screen.dart';

import 'data/repositories_impl/api_auth_repository.dart';
import 'data/repositories_impl/api_company_repository.dart';
import 'data/repositories_impl/api_requests_repository.dart';
import 'data/repositories_impl/api_notifications_repository.dart';
import 'data/repositories_impl/api_attendance_repository.dart';
import 'data/repositories_impl/api_team_repository.dart';
import 'data/repositories_impl/api_payroll_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Dependency injection: Toggle between Fake and Real API with AppConfig.useFakeData
  final IAuthRepository authRepository =
      AppConfig.useFakeData ? FakeAuthRepository() : ApiAuthRepository();
  final IAttendanceRepository attendanceRepository =
      AppConfig.useFakeData ? FakeAttendanceRepository() : ApiAttendanceRepository();
  final IRequestsRepository requestsRepository =
      AppConfig.useFakeData ? FakeRequestsRepository() : ApiRequestsRepository();
  final ITeamRepository teamRepository =
      AppConfig.useFakeData ? FakeTeamRepository() : ApiTeamRepository();
  final INotificationsRepository notificationsRepository =
      AppConfig.useFakeData ? FakeNotificationsRepository() : ApiNotificationsRepository();
  final ICompanyRepository companyRepository =
      AppConfig.useFakeData ? FakeCompanyRepository() : ApiCompanyRepository();
  final IPayrollRepository payrollRepository =
      AppConfig.useFakeData ? FakePayrollRepository() : ApiPayrollRepository();

  runApp(WorkforceApp(
    authRepository: authRepository,
    attendanceRepository: attendanceRepository,
    requestsRepository: requestsRepository,
    teamRepository: teamRepository,
    notificationsRepository: notificationsRepository,
    companyRepository: companyRepository,
    payrollRepository: payrollRepository,
  ));
}

class WorkforceApp extends StatelessWidget {
  final IAuthRepository authRepository;
  final IAttendanceRepository attendanceRepository;
  final IRequestsRepository requestsRepository;
  final ITeamRepository teamRepository;
  final INotificationsRepository notificationsRepository;
  final ICompanyRepository companyRepository;
  final IPayrollRepository payrollRepository;

  const WorkforceApp({
    super.key,
    required this.authRepository,
    required this.attendanceRepository,
    required this.requestsRepository,
    required this.teamRepository,
    required this.notificationsRepository,
    required this.companyRepository,
    required this.payrollRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(authRepository: authRepository)..checkSession(),
        ),
        BlocProvider<AttendanceCubit>(
          create: (context) => AttendanceCubit(attendanceRepository: attendanceRepository)
            ..loadAttendanceData(),
        ),
        BlocProvider<RequestsCubit>(
          create: (context) => RequestsCubit(requestsRepository: requestsRepository)
            ..loadRequests(),
        ),
        BlocProvider<TeamCubit>(
          create: (context) => TeamCubit(teamRepository: teamRepository)
            ..loadTeam(),
        ),
        BlocProvider<NotificationsCubit>(
          create: (context) => NotificationsCubit(notificationsRepository: notificationsRepository)
            ..loadNotifications(),
        ),
        BlocProvider<CompanyCubit>(
          create: (context) => CompanyCubit(companyRepository: companyRepository)
            ..loadCompanyData(),
        ),
        BlocProvider<PayrollCubit>(
          create: (context) => PayrollCubit(payrollRepository: payrollRepository)
            ..loadPayroll(),
        ),
        BlocProvider<ThemeCubit>(
          create: (context) => ThemeCubit(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: AppConfig.appTitle,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

class AppRootView extends StatelessWidget {
  const AppRootView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          // Scope attendance to this specific authenticated user
          context.read<AttendanceCubit>().loadAttendanceData(userId: state.user.id);
          context.read<RequestsCubit>().loadRequests();
          context.read<TeamCubit>().loadTeam();
          context.read<NotificationsCubit>().loadNotifications();
          context.read<CompanyCubit>().loadCompanyData();
          context.read<PayrollCubit>().loadPayroll();
        } else if (state is Unauthenticated) {
          // Reset attendance state so next login starts with fresh user records
          context.read<AttendanceCubit>().reset();
        }
      },
      builder: (context, state) {
        if (state is Authenticated) {
          return MainLayoutScreen(user: state.user);
        }
        return const LoginScreen();
      },
    );
  }
}
