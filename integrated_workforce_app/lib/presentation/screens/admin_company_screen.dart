import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_colors_extension.dart';
import '../../data/api/api_client.dart';
import '../../data/models/attendance_model.dart';
import '../../data/models/company_models.dart';
import '../../logic/company/company_cubit.dart';
import '../../logic/company/company_state.dart';
import '../../logic/notifications/notifications_cubit.dart';
import '../widgets/app_avatar.dart';
import '../widgets/employee_attendance_history_dialog.dart';
import '../widgets/status_chip.dart';

class AdminCompanyScreen extends StatefulWidget {
  const AdminCompanyScreen({super.key});

  @override
  State<AdminCompanyScreen> createState() => _AdminCompanyScreenState();
}

class _AdminCompanyScreenState extends State<AdminCompanyScreen> {
  bool _showAnalytics = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: const Text('Company Organization'),
      ),
      body: BlocConsumer<CompanyCubit, CompanyState>(
        listener: (context, state) {
          if (state is CompanyLoaded && state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor: AppColors.onTime,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CompanyLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CompanyError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.absent, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.colors.textMain),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => context.read<CompanyCubit>().loadCompanyData(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry Loading Data'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is! CompanyLoaded) {
            return const Center(child: Text('Loading company data...'));
          }

          // Level 4: Employee Dossier
          if (state.selectedEmployeeId != null) {
            final emp = state.selectedEmployee;
            final team = state.selectedTeam;
            final branch = state.selectedBranch;
            if (emp != null && team != null && branch != null) {
              return _buildEmployeeDossierView(context, state, emp, team, branch);
            }
          }

          // Level 3: Team Roster
          if (state.selectedTeamId != null) {
            final team = state.selectedTeam;
            final branch = state.selectedBranch;
            if (team != null && branch != null) {
              return _buildTeamMembersListView(context, team, branch);
            }
          }

          // Level 2: Branch Teams
          if (state.selectedBranchId != null) {
            final branch = state.selectedBranch;
            if (branch != null) {
              return _buildBranchTeamsListView(context, branch);
            }
          }

          // Level 1: Branches List
          return _buildBranchesListView(context, state.branches);
        },
      ),
    );
  }

  // LEVEL 1: Branches
  Widget _buildBranchesListView(BuildContext context, List<BranchModel> branches) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Executive HR Analytics & Live Operations Dashboard
        _buildExecutiveAnalyticsDashboard(context, branches),
        const SizedBox(height: 24),
        Divider(color: context.colors.borderSubtle, thickness: 1),
        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BRANCHES & LOCATIONS',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.8, color: context.colors.textMuted),
                ),
                SizedBox(height: 2),
                Text(
                  'Geofenced Office Branches',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: context.colors.textMain),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showEditOfficeLocationDialog(context),
                  icon: const Icon(Icons.location_on_outlined, size: 16),
                  label: const Text('Edit Office GPS', style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddBranchDialog(context),
                  icon: const Icon(Icons.add_business, size: 16),
                  label: const Text('Add Branch', style: TextStyle(fontSize: 11)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Tap any branch to explore its departments, staff roster, and payroll.',
          style: TextStyle(fontSize: 12, color: context.colors.textMuted),
        ),
        const SizedBox(height: 16),

        ...branches.map((b) {
          return GestureDetector(
            onTap: () => context.read<CompanyCubit>().selectBranch(b.id),
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: context.colors.bgCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: context.colors.borderSubtle),
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 10, offset: const Offset(0, 3)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: context.colors.primaryLight,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(Icons.business, color: context.colors.primary, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                b.name,
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: context.colors.textMain),
                              ),
                              Text(
                                b.address,
                                style: TextStyle(fontSize: 11, color: context.colors.textMuted),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Icon(Icons.chevron_right, color: context.colors.textDim),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: context.colors.bgCanvas,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: AppColors.onTime),
                            const SizedBox(width: 4),
                            Text(
                              'Geofence: ${b.radiusMeters.toInt()}m Radius',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        Text(
                          '${b.teams.length} Teams • ${b.activeCount} Staff',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: context.colors.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    ),
  ),
);
  }

  // LEVEL 2: Branch Teams
  Widget _buildBranchTeamsListView(BuildContext context, BranchModel branch) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
        TextButton.icon(
          onPressed: () => context.read<CompanyCubit>().selectBranch(null),
          icon: const Icon(Icons.arrow_back, size: 16),
          label: const Text('Back to All Branches'),
          style: TextButton.styleFrom(alignment: Alignment.centerLeft, padding: EdgeInsets.zero),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  branch.name.toUpperCase(),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.8, color: context.colors.textMuted),
                ),
                const SizedBox(height: 2),
                Text(
                  'Department Teams',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: context.colors.textMain),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => _showAddTeamAndManagerDialog(context, branch.id),
              icon: const Icon(Icons.group_add, size: 16),
              label: const Text('Add Team & Manager'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...branch.teams.map((t) {
          return GestureDetector(
            onTap: () => context.read<CompanyCubit>().selectTeam(t.id),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.bgCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.colors.borderSubtle),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: context.colors.primaryLight, borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.groups, color: context.colors.primary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.name,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: context.colors.textMain),
                        ),
                        Text(
                          'Lead: ${t.headName} (${t.headTitle})',
                          style: TextStyle(fontSize: 11, color: context.colors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${t.memberCount} Staff',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: context.colors.primary),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right, size: 18, color: context.colors.textDim),
                ],
              ),
            ),
          );
        }),
      ],
    ),
  ),
);
  }

  // LEVEL 3: Team Staff Roster
  Widget _buildTeamMembersListView(BuildContext context, DepartmentTeamModel team, BranchModel branch) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        TextButton.icon(
          onPressed: () => context.read<CompanyCubit>().selectTeam(null),
          icon: const Icon(Icons.arrow_back, size: 16),
          label: Text('Back to ${branch.name}'),
          style: TextButton.styleFrom(alignment: Alignment.centerLeft, padding: EdgeInsets.zero),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  team.name.toUpperCase(),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.8, color: context.colors.textMuted),
                ),
                const SizedBox(height: 2),
                Text(
                  'Team Staff Roster',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: context.colors.textMain),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => _showAddEmployeeDialog(context, branch.id, team.id),
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
              label: const Text('Add Employee'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Dedicated Team Leader Profile Container (Edit 2)
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.primaryLight,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: context.colors.primary.withAlpha(90), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: context.colors.primary.withAlpha(15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.colors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.stars_rounded, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'TEAM LEADER PROFILE',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: context.colors.bgCard,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: context.colors.primary.withAlpha(50)),
                    ),
                    child: Text(
                      'Direct Supervisor',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: context.colors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  AppAvatar(
                    name: team.headName,
                    photoUrl: team.headPhotoUrl,
                    radius: 26,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          team.headName, // Full First & Secondary Name e.g. "Mohamed Adel"
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: context.colors.textMain),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${team.headTitle} • Team Lead',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: context.colors.primary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          team.headEmail ?? '${team.headName.toLowerCase().replaceAll(' ', '.')}@company.com',
                          style: TextStyle(fontSize: 11, color: context.colors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Section Title
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TEAM MEMBERS (${team.employees.length})',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.8, color: context.colors.textMuted),
            ),
            Text(
              'Active Roster',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: context.colors.primary),
            ),
          ],
        ),
        const SizedBox(height: 10),

        ...team.employees.map((emp) {
          return GestureDetector(
            onTap: () => context.read<CompanyCubit>().selectEmployee(emp.id),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.bgCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: emp.isSuspended
                      ? AppColors.absent.withAlpha(120)
                      : (emp.issuesCount > 0 ? AppColors.late.withAlpha(120) : context.colors.borderSubtle),
                ),
              ),
              child: Row(
                children: [
                  AppAvatar(
                    name: emp.name,
                    photoUrl: emp.photoUrl,
                    radius: 22,
                    status: emp.status,
                    showStatusDot: true,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              emp.name,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: context.colors.textMain),
                            ),
                            if (emp.isSuspended) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.absentLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Closed',
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.absent),
                                ),
                              ),
                            ],
                            if (emp.isPendingAdminApproval) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.lateLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Pending HR Salary',
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.late),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          '${emp.role} • ${emp.code}',
                          style: TextStyle(fontSize: 11, color: context.colors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      StatusChip(status: emp.status),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(4),
                            icon: Icon(Icons.calendar_month_rounded, color: context.colors.primary, size: 20),
                            tooltip: 'Full Attendance History & Search Dates',
                            onPressed: () {
                              EmployeeAttendanceHistoryDialog.show(
                                context,
                                employeeName: emp.name,
                                employeeCode: emp.code,
                                photoUrl: emp.photoUrl,
                                role: emp.role,
                                department: team.name,
                                branchName: branch.name,
                                branchRadius: branch.radiusMeters,
                              );
                            },
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Dossier →',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: context.colors.primary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    ),
  ),
);
  }

  // LEVEL 4: Comprehensive Employee Dossier (Profile + Payroll + Activities)
  Widget _buildEmployeeDossierView(
    BuildContext context,
    CompanyLoaded state,
    EmployeeDossierModel emp,
    DepartmentTeamModel team,
    BranchModel branch,
  ) {
    final currentTab = state.dossierTab;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextButton.icon(
              onPressed: () => context.read<CompanyCubit>().selectEmployee(null),
              icon: const Icon(Icons.arrow_back, size: 16),
              label: Text('Back to ${team.name}'),
              style: TextButton.styleFrom(alignment: Alignment.centerLeft, padding: EdgeInsets.zero),
            ),
            const SizedBox(height: 10),

            // Header Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: context.colors.bgCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: context.colors.borderSubtle),
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 16, offset: const Offset(0, 6)),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      AppAvatar(
                        name: emp.name,
                        photoUrl: emp.photoUrl,
                        radius: 28,
                        status: emp.status,
                        showStatusDot: true,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              emp.name,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: context.colors.textMain),
                            ),
                            Text(
                              '${emp.role} • ${emp.code}',
                              style: TextStyle(fontSize: 12, color: context.colors.textMuted),
                            ),
                            Text(
                              '${branch.name} • ${team.name}',
                              style: TextStyle(fontSize: 11, color: context.colors.primary, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Full History & Specific Date Search Direct Action
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        EmployeeAttendanceHistoryDialog.show(
                          context,
                          employeeName: emp.name,
                          employeeCode: emp.code,
                          photoUrl: emp.photoUrl,
                          role: emp.role,
                          department: team.name,
                          branchName: branch.name,
                          branchRadius: branch.radiusMeters,
                        );
                      },
                      icon: const Icon(Icons.calendar_month_rounded, size: 16),
                      label: const Text(
                        'View Full Attendance History & Search Dates',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tab Switcher Pills (Profile | Payroll | Activities)
                  Row(
                    children: [
                      _buildDossierTabButton(context, 'Profile', 'profile', currentTab),
                      const SizedBox(width: 8),
                      _buildDossierTabButton(context, 'Payroll', 'payroll', currentTab),
                      const SizedBox(width: 8),
                      _buildDossierTabButton(context, 'Activities', 'activities', currentTab),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Tab Content
            if (currentTab == 'profile') _buildDossierProfileTab(emp, team, branch),
            if (currentTab == 'payroll') _buildDossierPayrollTab(context, emp),
            if (currentTab == 'activities') _buildDossierActivitiesTab(context, emp, team, branch),
          ],
        ),
      ),
    );
  }

  Widget _buildDossierTabButton(BuildContext context, String label, String tabKey, String activeKey) {
    final isActive = tabKey == activeKey;
    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<CompanyCubit>().setDossierTab(tabKey),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? context.colors.primary : context.colors.bgCardSubtle,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? context.colors.primary : context.colors.borderSubtle,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isActive ? Colors.white : context.colors.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDossierProfileTab(EmployeeDossierModel emp, DepartmentTeamModel team, BranchModel branch) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.colors.bgCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('STAFF CONTACT & EMPLOYMENT INFO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: context.colors.textMuted)),
          const SizedBox(height: 12),
          _buildInfoRow('Work Email', emp.email),
          _buildInfoRow('Verified Phone', emp.phone),
          _buildInfoRow('Home Address', emp.address),
          _buildInfoRow('Shift Schedule', emp.shift),
          _buildInfoRow('Direct Manager', '${team.headName} (${team.headTitle})'),
          _buildInfoRow('Hire Date', emp.hireDate),
        ],
      ),
    );
  }

  Widget _buildDossierPayrollTab(BuildContext context, EmployeeDossierModel emp) {
    return Column(
      children: [
        // Net Salary Box
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.colors.bgCard,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: context.colors.borderSubtle),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.colors.primary.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'CALCULATED NET SALARY (ADMIN PRIVILEGE)',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: context.colors.primary,
                      ),
                    ),
                  ),
                  Text(
                    'EGP PAYROLL',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: context.colors.textDim,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '${emp.netSalary.toStringAsFixed(2)} EGP',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: context.colors.textMain,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Formula: Base (${emp.baseSalary.toInt()} EGP) - Deductions (${emp.deductions.toInt()} EGP) + OT (1.5x)',
                style: TextStyle(fontSize: 11, color: context.colors.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Breakdown card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: context.colors.bgCard,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: context.colors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInfoRow('Base Salary', '${emp.baseSalary.toStringAsFixed(2)} EGP'),
              _buildInfoRow('Ladder Deductions', '-${emp.deductions.toStringAsFixed(2)} EGP'),
              if (emp.bonus > 0)
                _buildInfoRow('Discretionary Bonus', '+${emp.bonus.toStringAsFixed(2)} EGP'),
              _buildInfoRow('Overtime Hours', '+${emp.overtimeHours} hrs (Multiplier: ${emp.overtimeRate}x)'),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _showManualCheckInDialog(context, emp),
                icon: Icon(Icons.fingerprint, size: 16, color: context.colors.primary),
                label: Text('Log Manual Check-In (HR Override)', style: TextStyle(color: context.colors.primary, fontSize: 12, fontWeight: FontWeight.w800)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: context.colors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => _openSalaryEditorDialog(context, emp),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Adjust Base Salary (EGP)'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showAwardBonusOrDeductionDialog(context, emp),
                      icon: const Icon(Icons.card_giftcard, size: 16, color: AppColors.onTime),
                      label: Text('Award Bonus / Penalty', style: TextStyle(color: AppColors.onTime, fontSize: 11)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.onTime),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => emp.isSuspended
                          ? _showReactivateEmployeeDialog(context, emp)
                          : _showDeactivateEmployeeDialog(context, emp),
                      icon: Icon(
                        emp.isSuspended ? Icons.lock_open_rounded : Icons.block,
                        size: 16,
                        color: emp.isSuspended ? AppColors.onTime : AppColors.absent,
                      ),
                      label: Text(
                        emp.isSuspended ? 'Reopen Account' : 'Close Account',
                        style: TextStyle(
                          color: emp.isSuspended ? AppColors.onTime : AppColors.absent,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: emp.isSuspended ? AppColors.onTime : AppColors.absent),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _showRemoveEmployeeDialog(context, emp),
                icon: const Icon(Icons.delete_forever, size: 16, color: AppColors.absent),
                label: Text('Remove Account Permanently', style: TextStyle(color: AppColors.absent, fontSize: 11, fontWeight: FontWeight.w800)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  side: BorderSide(color: AppColors.absent.withAlpha(80)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDossierActivitiesTab(
    BuildContext context,
    EmployeeDossierModel emp,
    DepartmentTeamModel team,
    BranchModel branch,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: context.colors.primaryLight,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: context.colors.primary.withAlpha(60)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.colors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.calendar_month_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Full Attendance History & Specific Date Search',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: context.colors.textMain),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Browse 31-day records, jump to any specific date, review lateness ladders & offline gaps.',
                      style: TextStyle(fontSize: 10, color: context.colors.textMuted),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  EmployeeAttendanceHistoryDialog.show(
                    context,
                    employeeName: emp.name,
                    employeeCode: emp.code,
                    photoUrl: emp.photoUrl,
                    role: emp.role,
                    department: team.name,
                    branchName: branch.name,
                    branchRadius: branch.radiusMeters,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Open Calendar', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: context.colors.bgCard,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: context.colors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('15-MIN PRESENCE LOGS (TODAY)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: context.colors.textMuted)),
                  StatusChip(status: emp.status),
                ],
              ),
              const SizedBox(height: 12),
              ...emp.intervals.map((iv) {
                Color color;
                IconData icon;
                if (iv.status == 'inside') {
                  color = AppColors.onTime;
                  icon = Icons.check_circle;
                } else if (iv.status == 'outside') {
                  color = AppColors.absent;
                  icon = Icons.warning_amber_rounded;
                } else if (iv.status == 'signal_lost') {
                  color = AppColors.late;
                  icon = Icons.phonelink_erase_rounded;
                } else {
                  color = context.colors.textDim;
                  icon = Icons.schedule;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withAlpha(15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withAlpha(40)),
                  ),
                  child: Row(
                    children: [
                      Icon(icon, size: 16, color: color),
                      const SizedBox(width: 8),
                      Text(iv.time, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: color)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(iv.label, style: TextStyle(fontSize: 11, color: context.colors.textMain))),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: context.colors.textMuted, fontWeight: FontWeight.w600)),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: context.colors.textMain)),
        ],
      ),
    );
  }

  void _showManualCheckInDialog(BuildContext context, EmployeeDossierModel emp) {
    final reasonCtrl = TextEditingController(text: 'Device battery / hardware malfunction');

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: context.colors.bgCard,
        title: Row(
          children: [
            Icon(Icons.edit_calendar_rounded, color: context.colors.primary, size: 26),
            SizedBox(width: 8),
            Text('HR Manual Check-In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manually clock in ${emp.name}. This is logged under Admin / HR credentials for full audit accountability.',
              style: TextStyle(fontSize: 12, color: context.colors.textMuted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Reason for Override',
                hintText: 'e.g. Broken screen / lost phone...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<CompanyCubit>().manualCheckInEmployee(
                    employeeId: emp.id,
                    adminName: 'Admin Yahia',
                    reason: reasonCtrl.text.trim().isNotEmpty
                        ? reasonCtrl.text.trim()
                        : 'Phone battery died',
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm Manual Check-In'),
          ),
        ],
      ),
    );
  }

  void _openSalaryEditorDialog(BuildContext context, EmployeeDossierModel emp) {
    final salaryCtrl = TextEditingController(text: '${emp.baseSalary.toInt()}');
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: context.colors.bgCard,
        title: Text('Adjust Base Salary for ${emp.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter new base monthly salary in Egyptian Pounds (EGP):', style: TextStyle(fontSize: 12, color: context.colors.textMuted)),
            const SizedBox(height: 12),
            TextField(
              controller: salaryCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(prefixText: 'EGP ', hintText: 'e.g. 5200'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogCtx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newSalary = double.tryParse(salaryCtrl.text.trim());
              if (newSalary != null) {
                context.read<CompanyCubit>().updateSalary(emp.id, newSalary);
                Navigator.of(dialogCtx).pop();
              }
            },
            child: const Text('Save Salary'),
          ),
        ],
      ),
    );
  }

  void _showEditOfficeLocationDialog(BuildContext context) async {
    final colors = context.colors;
    final latCtrl = TextEditingController(text: '30.0444');
    final lonCtrl = TextEditingController(text: '31.2357');
    final radiusCtrl = TextEditingController(text: '500');

    try {
      final res = await ApiClient.get('/admin/branches/current');
      if (res is Map<String, dynamic>) {
        latCtrl.text = (res['latitude'] as num?)?.toString() ?? '30.0444';
        lonCtrl.text = (res['longitude'] as num?)?.toString() ?? '31.2357';
        radiusCtrl.text = (res['radiusMeters'] as num?)?.toString() ?? '500';
      }
    } catch (_) {}

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: colors.bgCard,
        title: Row(
          children: [
            Icon(Icons.edit_location_alt_rounded, color: colors.primary, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Edit Office GPS & Geofence',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: colors.textMain),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Set your exact office coordinates. Employees within the radius can check-in smoothly.',
                style: TextStyle(fontSize: 11, color: colors.textMuted),
              ),
              const SizedBox(height: 14),
              Text(
                'Office Latitude',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: colors.textMain),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: latCtrl,
                style: TextStyle(color: colors.textMain),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'e.g. 30.0444',
                  hintStyle: TextStyle(color: colors.textMuted),
                  filled: true,
                  fillColor: colors.bgCardSubtle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.borderSubtle),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Office Longitude',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: colors.textMain),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: lonCtrl,
                style: TextStyle(color: colors.textMain),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'e.g. 31.2357',
                  hintStyle: TextStyle(color: colors.textMuted),
                  filled: true,
                  fillColor: colors.bgCardSubtle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.borderSubtle),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Geofence Radius (Meters)',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: colors.textMain),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: radiusCtrl,
                style: TextStyle(color: colors.textMain),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'e.g. 500 or 50000',
                  hintStyle: TextStyle(color: colors.textMuted),
                  filled: true,
                  fillColor: colors.bgCardSubtle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.borderSubtle),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Tip: If testing remotely, enter a larger radius (e.g. 50000 meters) to cover your current location.',
                style: TextStyle(fontSize: 10, color: colors.primary, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text('Cancel', style: TextStyle(color: colors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              final lat = double.tryParse(latCtrl.text.trim()) ?? 30.0444;
              final lon = double.tryParse(lonCtrl.text.trim()) ?? 31.2357;
              final rad = double.tryParse(radiusCtrl.text.trim()) ?? 500.0;

              Navigator.of(dialogCtx).pop();

              try {
                await ApiClient.post('/admin/branches/set-current-gps', body: {
                  'latitude': lat,
                  'longitude': lon,
                  'radiusMeters': rad,
                });
                if (context.mounted) {
                  context.read<CompanyCubit>().loadCompanyData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Office GPS updated: (' + lat.toString() + ', ' + lon.toString() + ') • Radius: ' + rad.toInt().toString() + 'm'),
                      backgroundColor: colors.statusSuccess,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error updating location: ' + e.toString()),
                      backgroundColor: colors.statusDanger,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Save & Update GPS'),
          ),
        ],
      ),
    );
  }

  void _showAddBranchDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final radiusCtrl = TextEditingController(text: '50');

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: context.colors.bgCard,
        title: Row(
          children: [
            Icon(Icons.add_business, color: context.colors.primary, size: 22),
            SizedBox(width: 8),
            Text('Add Office Branch', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Branch Name', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              TextField(controller: nameCtrl, decoration: const InputDecoration(hintText: 'e.g. New Cairo Tech Branch')),
              const SizedBox(height: 12),
              const Text('Physical Address', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              TextField(controller: addressCtrl, decoration: const InputDecoration(hintText: 'e.g. 90 North St, New Cairo')),
              const SizedBox(height: 12),
              const Text('Geofence Radius (meters)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              TextField(controller: radiusCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: '50')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty && addressCtrl.text.trim().isNotEmpty) {
                final radius = double.tryParse(radiusCtrl.text.trim()) ?? 50.0;
                context.read<CompanyCubit>().addBranch(
                      name: nameCtrl.text.trim(),
                      address: addressCtrl.text.trim(),
                      radiusMeters: radius,
                    );
                Navigator.pop(dialogCtx);
              }
            },
            child: const Text('Create Branch'),
          ),
        ],
      ),
    );
  }

  void _showAddTeamAndManagerDialog(BuildContext context, String branchId) {
    final teamNameCtrl = TextEditingController();
    final managerNameCtrl = TextEditingController();
    final managerTitleCtrl = TextEditingController(text: 'Department Manager');

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: context.colors.bgCard,
        title: const Text('Add Team & Manager', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Team / Department Name', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              TextField(controller: teamNameCtrl, decoration: const InputDecoration(hintText: 'e.g. Cloud Infrastructure')),
              const SizedBox(height: 12),
              const Text('Manager Full Name', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              TextField(controller: managerNameCtrl, decoration: const InputDecoration(hintText: 'e.g. Eng. Hany Zaki')),
              const SizedBox(height: 12),
              const Text('Manager Job Title', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              TextField(controller: managerTitleCtrl, decoration: const InputDecoration(hintText: 'e.g. Director of Infrastructure')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (teamNameCtrl.text.trim().isNotEmpty && managerNameCtrl.text.trim().isNotEmpty) {
                context.read<CompanyCubit>().addManagerTeam(
                      branchId: branchId,
                      teamName: teamNameCtrl.text.trim(),
                      headName: managerNameCtrl.text.trim(),
                      headTitle: managerTitleCtrl.text.trim(),
                    );
                Navigator.pop(dialogCtx);
              }
            },
            child: const Text('Create Team & Manager'),
          ),
        ],
      ),
    );
  }

  void _showAddEmployeeDialog(BuildContext context, String branchId, String teamId) {
    final nameCtrl = TextEditingController();
    final roleCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final salaryCtrl = TextEditingController(text: '4500');

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: context.colors.bgCard,
        title: const Text('Add Employee to Team', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Full Name', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              TextField(controller: nameCtrl, decoration: const InputDecoration(hintText: 'e.g. Youssef Nabil')),
              const SizedBox(height: 12),
              const Text('Role / Job Title', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              TextField(controller: roleCtrl, decoration: const InputDecoration(hintText: 'e.g. Software Engineer')),
              const SizedBox(height: 12),
              const Text('Workplace Email', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              TextField(controller: emailCtrl, decoration: const InputDecoration(hintText: 'e.g. youssef@company.com')),
              const SizedBox(height: 12),
              const Text('Phone Number', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(hintText: 'e.g. 01022334455')),
              const SizedBox(height: 12),
              const Text('Base Monthly Salary (EGP)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              TextField(
                controller: salaryCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(prefixText: 'EGP ', hintText: '4500'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty && emailCtrl.text.trim().isNotEmpty) {
                final base = double.tryParse(salaryCtrl.text.trim()) ?? 4500.0;
                final newEmp = EmployeeDossierModel(
                  id: 'emp-${DateTime.now().millisecondsSinceEpoch}',
                  name: nameCtrl.text.trim(),
                  code: 'EMP-${1000 + DateTime.now().millisecond}',
                  role: roleCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  address: 'Cairo, Egypt',
                  shift: 'Morning Core (09:00 - 17:00)',
                  hireDate: 'Today',
                  status: AttendanceStatus.onTime,
                  statusText: 'Active',
                  issuesCount: 0,
                  issueLabel: 'All Good',
                  baseSalary: base,
                  deductions: 0.0,
                  overtimeHours: 0.0,
                  netSalary: base,
                  intervals: const [],
                );
                context.read<CompanyCubit>().addEmployee(
                      branchId: branchId,
                      teamId: teamId,
                      employee: newEmp,
                    );
                Navigator.pop(dialogCtx);
              }
            },
            child: const Text('Register Employee'),
          ),
        ],
      ),
    );
  }

  void _showAwardBonusOrDeductionDialog(BuildContext context, EmployeeDossierModel emp) {
    bool isBonus = true;
    final amountCtrl = TextEditingController(text: '200');
    final reasonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: context.colors.bgCard,
          title: Text('Adjust for ${emp.name}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Award Bonus (+)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
                      selected: isBonus,
                      selectedColor: AppColors.onTime,
                      labelStyle: TextStyle(color: isBonus ? Colors.white : context.colors.textMain),
                      onSelected: (val) => setDialogState(() => isBonus = true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Deduction (-)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
                      selected: !isBonus,
                      selectedColor: AppColors.absent,
                      labelStyle: TextStyle(color: !isBonus ? Colors.white : context.colors.textMain),
                      onSelected: (val) => setDialogState(() => isBonus = false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text('Amount (EGP)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(prefixText: 'EGP '),
              ),
              const SizedBox(height: 12),
              const Text('Official Reason / HR Note', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              TextField(
                controller: reasonCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: isBonus
                      ? 'e.g. Outstanding performance on client delivery...'
                      : 'e.g. Policy violation or disciplinary fine...',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                final reason = reasonCtrl.text.trim();
                if (amount > 0 && reason.isNotEmpty) {
                  context.read<CompanyCubit>().awardBonusOrDeduction(
                        employeeId: emp.id,
                        amount: amount,
                        isBonus: isBonus,
                        reason: reason,
                      );
                  context.read<NotificationsCubit>().addNotification(
                        title: isBonus ? 'Official Bonus Awarded (+${amount.toInt()} EGP)' : 'Official HR Deduction (-${amount.toInt()} EGP)',
                        description: 'HR notice for ${emp.name}: $reason (Processed for monthly payroll).',
                        type: isBonus ? 'approval' : 'warning',
                      );
                  Navigator.pop(dialogCtx);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isBonus ? AppColors.onTime : AppColors.absent,
                foregroundColor: Colors.white,
              ),
              child: Text(isBonus ? 'Award Bonus' : 'Apply Deduction'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeactivateEmployeeDialog(BuildContext context, EmployeeDossierModel emp) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: context.colors.bgCard,
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.absent, size: 28),
            SizedBox(width: 8),
            Text('Close Account?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          ],
        ),
        content: Text(
          'Are you sure you want to deactivate ${emp.name}\'s account company-wide? The employee will be suspended from clocking in or accessing workplace systems.',
          style: TextStyle(fontSize: 12, color: context.colors.textMuted),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<CompanyCubit>().deactivateEmployee(emp.id);
              Navigator.pop(dialogCtx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.absent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Deactivate Account'),
          ),
        ],
      ),
    );
  }

  void _showReactivateEmployeeDialog(BuildContext context, EmployeeDossierModel emp) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: context.colors.bgCard,
        title: const Row(
          children: [
            Icon(Icons.lock_open_rounded, color: AppColors.onTime, size: 28),
            SizedBox(width: 8),
            Text('Reopen Account?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          ],
        ),
        content: Text(
          'Do you want to reopen and restore full access for ${emp.name}? The account will be reactivated immediately.',
          style: TextStyle(fontSize: 12, color: context.colors.textMuted),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<CompanyCubit>().reactivateEmployee(emp.id);
              Navigator.pop(dialogCtx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.onTime,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reopen & Activate'),
          ),
        ],
      ),
    );
  }

  void _showRemoveEmployeeDialog(BuildContext context, EmployeeDossierModel emp) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: context.colors.bgCard,
        title: const Row(
          children: [
            Icon(Icons.delete_forever, color: AppColors.absent, size: 28),
            SizedBox(width: 8),
            Text('Remove Account?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          ],
        ),
        content: Text(
          'Are you sure you want to permanently remove ${emp.name} (${emp.code})? This will delete the account from the workplace roster.',
          style: TextStyle(fontSize: 12, color: context.colors.textMuted),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<CompanyCubit>().removeEmployee(emp.id);
              Navigator.pop(dialogCtx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.absent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Permanently Remove'),
          ),
        ],
      ),
    );
  }

  // ─── Executive HR Analytics & Operations Dashboard ───────────────────────────
  Widget _buildExecutiveAnalyticsDashboard(BuildContext context, List<BranchModel> branches) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 900;

    if (!_showAnalytics) {
      return Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: context.colors.bgCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: context.colors.borderSubtle),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 10, offset: const Offset(0, 3)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.analytics_rounded, color: context.colors.primary, size: 24),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Executive HR Intelligence Console',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: context.colors.textMain),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Real-time attendance ring, weekly SLA, geofence hardware audit & trends',
                      style: TextStyle(fontSize: 11, color: context.colors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => setState(() => _showAnalytics = true),
              icon: const Icon(Icons.insights_rounded, size: 16),
              label: const Text('Show Analytics', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primaryLight,
                foregroundColor: context.colors.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Executive Header Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [context.colors.textMain, Color(0xFF1E293B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: context.colors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.analytics_rounded, color: Colors.white, size: 13),
                          SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'HR ANALYTICS',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.onTime.withAlpha(35),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.onTime.withAlpha(80)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, size: 7, color: AppColors.onTime),
                            SizedBox(width: 5),
                            Text(
                              'Live Synced',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.onTime,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        tooltip: 'Collapse Analytics to View Branches Only',
                        onPressed: () => setState(() => _showAnalytics = false),
                        icon: const Icon(Icons.close_fullscreen_rounded, color: Colors.white70, size: 18),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Workforce Intelligence Hub',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Live operational oversight across ${branches.length} branches • Real-time geofence telemetry',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Consolidated Charts Grid (Desktop: 2 columns side-by-side; Mobile: stacked)
        if (isDesktop) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildAttendanceEngineCard()),
              const SizedBox(width: 16),
              Expanded(child: _buildSecurityAndTrendCard()),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildDepartmentBreakdownCard(branches)),
              const SizedBox(width: 16),
              Expanded(child: _buildTopPerformersCard()),
            ],
          ),
        ] else ...[
          _buildAttendanceEngineCard(),
          const SizedBox(height: 14),
          _buildSecurityAndTrendCard(),
          const SizedBox(height: 14),
          _buildDepartmentBreakdownCard(branches),
          const SizedBox(height: 14),
          _buildTopPerformersCard(),
        ],
      ],
    );
  }

  // ─── Consolidated Card 1: Attendance Adherence & Punctuality Engine ─────────
  Widget _buildAttendanceEngineCard() {
    final List<Map<String, dynamic>> days = [
      {'day': 'Sun', 'percent': 94, 'count': '47/50', 'isTop': false},
      {'day': 'Mon', 'percent': 90, 'count': '45/50', 'isTop': false},
      {'day': 'Tue', 'percent': 96, 'count': '48/50', 'isTop': true},
      {'day': 'Wed', 'percent': 92, 'count': '46/50', 'isTop': false},
      {'day': 'Thu', 'percent': 95, 'count': '47/50', 'isTop': false},
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.colors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.borderSubtle),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ATTENDANCE & PUNCTUALITY ENGINE',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: context.colors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Live Adherence & Weekly SLA',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: context.colors.textMain,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.onTimeLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.onTime.withAlpha(60)),
                ),
                child: const Text(
                  '92% Present',
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: AppColors.onTime),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Donut Ring with Stats
          LayoutBuilder(
            builder: (context, constraints) {
              final isVeryNarrow = constraints.maxWidth < 280;
              final donut = SizedBox(
                width: 96,
                height: 96,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(96, 96),
                      painter: _AttendanceRingPainter(
                        ringColor: context.colors.borderSubtle.withAlpha(80),
                        onTimeFraction: 0.84,
                        lateFraction: 0.08,
                        absentFraction: 0.04,
                        leaveFraction: 0.04,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '92%',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: context.colors.textMain,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: AppColors.onTime,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 3),
                            const Text(
                              'PRESENT',
                              style: TextStyle(
                                fontSize: 7.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                                color: AppColors.onTime,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );

              final legend = Column(
                children: [
                  _buildLegendItem('On-Time', '42 (84%)', AppColors.onTime, AppColors.onTimeLight),
                  const SizedBox(height: 5),
                  _buildLegendItem('Late Arrivals', '4 (8%)', AppColors.late, AppColors.lateLight),
                  const SizedBox(height: 5),
                  _buildLegendItem('Absent Today', '2 (4%)', AppColors.absent, AppColors.absentLight),
                  const SizedBox(height: 5),
                  _buildLegendItem('Approved Leave', '2 (4%)', AppColors.onLeave, AppColors.onLeaveLight),
                ],
              );

              if (isVeryNarrow) {
                return Column(
                  children: [
                    donut,
                    const SizedBox(height: 12),
                    legend,
                  ],
                );
              }

              return Row(
                children: [
                  donut,
                  const SizedBox(width: 14),
                  Expanded(child: legend),
                ],
              );
            },
          ),

          const SizedBox(height: 16),
          Divider(color: context.colors.borderSubtle, height: 1),
          const SizedBox(height: 14),

          // 5-Day Weekly Punctuality Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '5-Day Working Week SLA Adherence',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: context.colors.textMain),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: context.colors.primaryLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Avg: 93.4%',
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: context.colors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Bars Row (Responsive Expanded columns)
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: days.map((d) {
              final double p = (d['percent'] as int) / 100.0;
              final String day = d['day'] as String;
              final String val = '${d['percent']}%';
              final bool isTop = d['isTop'] as bool;

              return Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isTop) ...[
                          const Icon(Icons.star_rounded, size: 9, color: AppColors.onTime),
                          const SizedBox(width: 1),
                        ],
                        Text(
                          val,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: isTop ? AppColors.onTime : context.colors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 28,
                      height: 80,
                      decoration: BoxDecoration(
                        color: context.colors.bgCanvas,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isTop ? AppColors.onTime.withAlpha(80) : context.colors.borderSubtle,
                        ),
                      ),
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: 28,
                        height: 80 * p,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isTop
                                ? [AppColors.onTime, const Color(0xFF34D399)]
                                : [context.colors.primary, const Color(0xFF818CF8)],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      day,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: isTop ? AppColors.onTime : context.colors.textMain,
                      ),
                    ),
                    Text(
                      d['count'] as String,
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        color: context.colors.textDim,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ─── Consolidated Card 2: Security Telemetry & 30-Day Attendance Trend ──────
  Widget _buildSecurityAndTrendCard() {
    final List<double> trendData = [
      88, 91, 93, 90, 87, 0, 0, 92, 94, 96, 93, 91, 0, 0,
      89, 92, 95, 97, 94, 0, 0, 90, 93, 96, 95, 92, 0, 0, 91, 94,
    ];
    final List<double> workDays = trendData.where((v) => v > 0).toList();
    final double maxVal = workDays.fold(0.0, (a, b) => a > b ? a : b);
    final double minVal = workDays.fold(100.0, (a, b) => a < b ? a : b);
    final double avg = workDays.fold(0.0, (a, b) => a + b) / workDays.length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.colors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.borderSubtle),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SECURITY TELEMETRY & 30-DAY TREND',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: context.colors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Hardware Audit & Trend Sparkline',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: context.colors.textMain,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.onTimeLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.onTime.withAlpha(60)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded, color: AppColors.onTime, size: 10),
                    SizedBox(width: 3),
                    Text('Anti-Spoofing', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.onTime)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Geofence & Hardware Progress Rows
          _buildGeofenceProgressRow(
            branchName: 'Main HQ (Smart Village - 50m)',
            bssid: '74:83:C2:A1:09:4E',
            percent: 0.94,
            label: '94% Inside (46/49 Staff)',
            isSecure: true,
          ),
          const SizedBox(height: 10),
          _buildGeofenceProgressRow(
            branchName: 'Alexandria Hub (Corniche - 50m)',
            bssid: '50:D4:F7:11:22:AA',
            percent: 0.88,
            label: '88% Inside (22/25 Staff)',
            isSecure: true,
          ),

          const SizedBox(height: 16),
          Divider(color: context.colors.borderSubtle, height: 1),
          const SizedBox(height: 14),

          // 30-Day Monthly Attendance Trend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '30-Day Monthly Attendance Trend',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: context.colors.textMain),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withAlpha(20),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Avg: ${avg.toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Color(0xFF7C3AED)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Sparkline chart
          SizedBox(
            height: 60,
            width: double.infinity,
            child: CustomPaint(
              painter: _SparklinePainter(
                values: trendData,
                lineColor: const Color(0xFF7C3AED),
                fillColor: const Color(0xFF7C3AED).withAlpha(30),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Summary pills
          Row(
            children: [
              Expanded(child: _buildTrendPill('Peak Day', '${maxVal.toInt()}%', AppColors.onTime, AppColors.onTimeLight)),
              const SizedBox(width: 6),
              Expanded(child: _buildTrendPill('Lowest', '${minVal.toInt()}%', AppColors.late, AppColors.lateLight)),
              const SizedBox(width: 6),
              Expanded(child: _buildTrendPill('This Week', '93.5%', context.colors.primary, context.colors.primaryLight)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, String count, Color color, Color pillBg) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textMuted,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: pillBg,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withAlpha(40)),
          ),
          child: Text(
            count,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGeofenceProgressRow({
    required String branchName,
    required String bssid,
    required double percent,
    required String label,
    required bool isSecure,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                branchName,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: context.colors.textMain,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSecure ? AppColors.onTimeLight : AppColors.lateLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isSecure ? 'Hardware Bound' : 'Warning',
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                  color: isSecure ? AppColors.onTime : AppColors.late,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: context.colors.bgCanvas,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: context.colors.borderSubtle),
              ),
              child: Text(
                'BSSID: $bssid',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  color: context.colors.primary,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 9.5, color: context.colors.textMuted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 5,
            backgroundColor: context.colors.borderSubtle,
            valueColor: AlwaysStoppedAnimation<Color>(
              percent >= 0.9 ? AppColors.onTime : AppColors.late,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendPill(String label, String value, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: color),
            ),
          ),
          const SizedBox(height: 1),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: color),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Consolidated Card 3: Department Breakdown ──────────────────────────────
  Widget _buildDepartmentBreakdownCard([List<BranchModel>? branches]) {
    final List<Map<String, dynamic>> departments = [];
    final colorsList = [
      context.colors.primary,
      AppColors.onTime,
      const Color(0xFF7C3AED),
      AppColors.late,
      AppColors.onLeave,
      const Color(0xFFEC4899),
      const Color(0xFF06B6D4),
    ];

    if (branches != null && branches.isNotEmpty) {
      int cIdx = 0;
      for (final b in branches) {
        for (final t in b.teams) {
          departments.add({
            'name': t.name,
            'count': t.memberCount,
            'color': colorsList[cIdx % colorsList.length],
          });
          cIdx++;
        }
      }
    }

    if (departments.isEmpty) {
      departments.addAll([
        {'name': 'Engineering', 'count': 18, 'color': context.colors.primary},
        {'name': 'Operations', 'count': 12, 'color': AppColors.onTime},
        {'name': 'Marketing', 'count': 8, 'color': const Color(0xFF7C3AED)},
        {'name': 'Finance', 'count': 7, 'color': AppColors.late},
        {'name': 'HR & Admin', 'count': 5, 'color': AppColors.onLeave},
      ]);
    }
    final int totalHeadcount = departments.fold(0, (a, d) => a + (d['count'] as int));
    final int maxCount = departments.fold(0, (a, d) {
      final c = d['count'] as int;
      return a > c ? a : c;
    });

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.colors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.borderSubtle),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ORGANIZATIONAL METRICS',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: context.colors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Department Headcount',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: context.colors.textMain,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: context.colors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.colors.primary.withAlpha(60)),
                ),
                child: Text(
                  'Total: $totalHeadcount',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: context.colors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          ...departments.map((dept) {
            final int count = dept['count'] as int;
            final Color color = dept['color'] as Color;
            final double fraction = count / maxCount;

            return Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          dept['name'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: context.colors.textMain,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: color.withAlpha(20),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          '$count staff',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: LinearProgressIndicator(
                      value: fraction,
                      minHeight: 5,
                      backgroundColor: context.colors.borderSubtle,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── Consolidated Card 4: Top Performers & Attendance Alerts ────────────────
  Widget _buildTopPerformersCard() {
    final List<Map<String, dynamic>> performers = [
      {
        'name': 'Ahmed Salah',
        'photoUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300',
        'rate': '99.2%',
        'streak': '22 days on-time',
        'badge': '🏆',
      },
      {
        'name': 'Sarah Mahmoud',
        'photoUrl': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=300',
        'rate': '98.5%',
        'streak': '19 days on-time',
        'badge': '⭐',
      },
      {
        'name': 'Omar Khaled',
        'photoUrl': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=300',
        'rate': '97.8%',
        'streak': '17 days on-time',
        'badge': '⭐',
      },
    ];

    final List<Map<String, dynamic>> alerts = [
      {
        'name': 'Mahmoud Hassan',
        'issue': '3 late arrivals this week',
        'severity': 'warning',
      },
      {
        'name': 'Nour Adel',
        'issue': 'Signal lost gap (45 min)',
        'severity': 'info',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.colors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.borderSubtle),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events_rounded, color: Color(0xFFF59E0B), size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'PERFORMANCE SPOTLIGHT',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    color: context.colors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Top Performers & Attendance Alerts',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: context.colors.textMain,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // Top performers
          ...performers.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.onTimeLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.onTime.withAlpha(30)),
              ),
              child: Row(
                children: [
                  Text(p['badge'] as String, style: const TextStyle(fontSize: 15)),
                  const SizedBox(width: 7),
                  AppAvatar(
                    name: p['name'] as String,
                    photoUrl: p['photoUrl'] as String?,
                    radius: 15,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p['name'] as String,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: context.colors.textMain,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          p['streak'] as String,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: context.colors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.onTime,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      p['rate'] as String,
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),

          const SizedBox(height: 6),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Alerts section
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 14),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'ATTENTION NEEDED',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                    color: AppColors.late,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),

          ...alerts.map((a) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
              decoration: BoxDecoration(
                color: (a['severity'] == 'warning') ? AppColors.lateLight : AppColors.absentLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: (a['severity'] == 'warning')
                      ? AppColors.late.withAlpha(40)
                      : AppColors.absent.withAlpha(40),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    (a['severity'] == 'warning')
                        ? Icons.access_time_filled_rounded
                        : Icons.phonelink_erase_rounded,
                    size: 14,
                    color: (a['severity'] == 'warning') ? AppColors.late : AppColors.absent,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a['name'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: context.colors.textMain,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          a['issue'] as String,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: (a['severity'] == 'warning') ? AppColors.late : AppColors.absent,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }
}

// ─── Custom Painters ────────────────────────────────────────────────────────

class _SparklinePainter extends CustomPainter {
  final List<double> values;
  final Color lineColor;
  final Color fillColor;

  _SparklinePainter({
    required this.values,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final double maxV = values.fold(0.0, (a, b) => a > b ? a : b);
    final double minV = values.fold(100.0, (a, b) => a < b ? a : b);
    final double range = (maxV - minV).clamp(1.0, 100.0);

    final double stepX = size.width / (values.length - 1);

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < values.length; i++) {
      final double x = i * stepX;
      final double y = size.height - ((values[i] - minV) / range) * (size.height - 4) - 2;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        // Smooth curve using quadratic bezier
        final double prevX = (i - 1) * stepX;
        final double prevY = size.height - ((values[i - 1] - minV) / range) * (size.height - 4) - 2;
        final double ctrlX = (prevX + x) / 2;
        path.quadraticBezierTo(ctrlX, prevY, (prevX + x) / 2, (prevY + y) / 2);
        path.quadraticBezierTo(ctrlX, y, x, y);
        fillPath.quadraticBezierTo(ctrlX, prevY, (prevX + x) / 2, (prevY + y) / 2);
        fillPath.quadraticBezierTo(ctrlX, y, x, y);
      }
    }

    // Close fill path
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Draw fill
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);

    // Draw end dot
    if (values.isNotEmpty) {
      final lastX = (values.length - 1) * stepX;
      final lastY = size.height - ((values.last - minV) / range) * (size.height - 4) - 2;
      final dotPaint = Paint()
        ..color = lineColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(lastX, lastY), 4, dotPaint);
      final outerDot = Paint()
        ..color = lineColor.withAlpha(50)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(lastX, lastY), 7, outerDot);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) => true;
}

class _AttendanceRingPainter extends CustomPainter {
  final double onTimeFraction;
  final double lateFraction;
  final double absentFraction;
  final double leaveFraction;
  final Color ringColor;

  _AttendanceRingPainter({
    required this.onTimeFraction,
    required this.lateFraction,
    required this.absentFraction,
    required this.leaveFraction,
    this.ringColor = const Color(0x33888888),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 8;
    const strokeWidth = 10.0;

    final bgPaint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    final rect = Rect.fromCircle(center: center, radius: radius);
    double startAngle = -math.pi / 2;

    void drawSegment(double fraction, Color color) {
      if (fraction <= 0) return;
      final sweepAngle = 2 * math.pi * fraction;
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, startAngle + 0.05, sweepAngle - 0.1, false, paint);
      startAngle += sweepAngle;
    }

    drawSegment(onTimeFraction, AppColors.onTime);
    drawSegment(lateFraction, AppColors.late);
    drawSegment(absentFraction, AppColors.absent);
    drawSegment(leaveFraction, AppColors.onLeave);
  }

  @override
  bool shouldRepaint(covariant _AttendanceRingPainter oldDelegate) => true;
}


