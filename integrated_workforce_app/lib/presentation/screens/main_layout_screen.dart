import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/notifications/notifications_cubit.dart';
import '../../logic/notifications/notifications_state.dart';
import '../../logic/requests/requests_cubit.dart';
import '../../logic/requests/requests_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_colors_extension.dart';
import '../../data/models/user_model.dart';
import 'admin_company_screen.dart';
import 'admin_payroll_screen.dart';
import 'admin_rules_screen.dart';
import 'alerts_screen.dart';
import 'approvals_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'requests_screen.dart';
import 'team_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  final UserModel user;

  const MainLayoutScreen({super.key, required this.user});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = widget.user.role == UserRole.admin;
    final bool isManager = widget.user.role == UserRole.manager;

    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (context, notifState) {
        final unreadCount = notifState is NotificationsLoaded ? notifState.unreadCount : 0;
        return BlocBuilder<RequestsCubit, RequestsState>(
          builder: (context, reqState) {
            final pendingCount = reqState is RequestsLoaded ? reqState.pendingApprovals.length : 0;

    // Define pages per role
    final List<Widget> pages = isAdmin
        ? [
            const AdminCompanyScreen(),
            const AdminPayrollScreen(),
            ApprovalsScreen(user: widget.user),
            const AdminRulesScreen(),
            ProfileScreen(user: widget.user),
          ]
        : isManager
            ? [
                HomeScreen(user: widget.user),
                const HistoryScreen(),
                const TeamScreen(),
                RequestsScreen(user: widget.user),
                ProfileScreen(user: widget.user),
              ]
            : [
                HomeScreen(user: widget.user),
                const HistoryScreen(),
                RequestsScreen(user: widget.user),
                const AlertsScreen(),
                ProfileScreen(user: widget.user),
              ];

    // Define nav items per role
    final List<BottomNavigationBarItem> navItems = isAdmin
        ? [
            BottomNavigationBarItem(
              icon: Icon(Icons.business_outlined),
              activeIcon: Icon(Icons.business),
              label: 'Company',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.payments_outlined),
              activeIcon: Icon(Icons.payments),
              label: 'Payroll',
            ),
            BottomNavigationBarItem(
              icon: Badge.count(
                count: pendingCount,
                isLabelVisible: pendingCount > 0,
                child: const Icon(Icons.assignment_turned_in_outlined),
              ),
              activeIcon: Badge.count(
                count: pendingCount,
                isLabelVisible: pendingCount > 0,
                child: const Icon(Icons.assignment_turned_in),
              ),
              label: 'Approvals',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.tune_outlined),
              activeIcon: Icon(Icons.tune),
              label: 'Rules',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ]
        : isManager
            ? [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month_outlined),
                  activeIcon: Icon(Icons.calendar_month),
                  label: 'History',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_outline),
                  activeIcon: Icon(Icons.people),
                  label: 'Team Radar',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.description_outlined),
                  activeIcon: Icon(Icons.description),
                  label: 'Requests',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ]
            : [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month_outlined),
                  activeIcon: Icon(Icons.calendar_month),
                  label: 'History',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.description_outlined),
                  activeIcon: Icon(Icons.description),
                  label: 'Requests',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.notifications_none_rounded),
                  activeIcon: Icon(Icons.notifications),
                  label: 'Alerts',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ];

    final colors = context.colors;
    final theme = Theme.of(context);
    final navBg = colors.bgCard;
    final borderColor = colors.borderSubtle;

    return Scaffold(
      backgroundColor: colors.bgCanvas,
      body: IndexedStack(key: ValueKey(theme.brightness),
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBg,
          border: Border(top: BorderSide(color: borderColor)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(theme.brightness == Brightness.dark ? 30 : 10),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: navBg,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor ?? context.colors.primary,
          unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor ?? context.colors.textMuted,
          selectedLabelStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
          items: navItems,
        ),
      ),
    );
          },
        );
      },
    );
  }
}



