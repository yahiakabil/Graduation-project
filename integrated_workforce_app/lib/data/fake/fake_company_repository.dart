import '../models/attendance_model.dart';
import '../models/company_models.dart';
import '../models/team_member_model.dart';
import '../repositories/company_repository.dart';

class FakeCompanyRepository implements ICompanyRepository {
  List<BranchModel> _branches = [
    BranchModel(
      id: 'b-main',
      name: 'Main Headquarters',
      address: 'Building 42, Smart Village, Cairo, Egypt',
      radiusMeters: 50.0,
      teams: [
        DepartmentTeamModel(
          id: 't-eng',
          name: 'Mobile Engineering Team',
          headName: 'Mohamed Hussien',
          headTitle: 'Engineering Director',
          headEmail: 'mohamed.hussien@company.com',
          headPhone: '01011122233',
          headPhotoUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300',
          employees: [
            const EmployeeDossierModel(
              id: 'emp-1',
              name: 'Ahmed Kamal',
              code: 'EMP-4092',
              role: 'Senior Flutter Developer',
              email: 'ahmed.kamal@company.com',
              phone: '01012345678',
              photoUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300',
              address: '14 Al-Nasr St, New Cairo, Egypt',
              shift: 'Morning Core (09:00 - 17:00)',
              hireDate: '15 Jan 2024',
              status: AttendanceStatus.late,
              statusText: 'Late (09:28 AM)',
              issuesCount: 2,
              issueLabel: '2 Issues (Late + Left Branch)',
              baseSalary: 5000.0,
              deductions: 280.0,
              overtimeHours: 2.0,
              overtimeRate: 1.5,
              netSalary: 4870.0,
              intervals: [
                PresenceIntervalModel(
                  time: '09:00 - 09:15',
                  status: 'pending',
                  label: 'Not checked in yet',
                ),
                PresenceIntervalModel(
                  time: '09:15 - 09:30',
                  status: 'inside',
                  label: 'Checked in at 09:28 AM (28m Late)',
                ),
                PresenceIntervalModel(
                  time: '09:30 - 11:42',
                  status: 'inside',
                  label: 'Inside HQ (50m Radius & Router BSSID Verified)',
                ),
                PresenceIntervalModel(
                  time: '11:42 - 12:15',
                  status: 'signal_lost',
                  label: 'Signal Lost / Offline Gap (Last ping 11:42 AM - Restored 12:15 PM - Check-In Preserved)',
                ),
                PresenceIntervalModel(
                  time: '12:15 - 13:00',
                  status: 'inside',
                  label: 'Returned Online Inside Branch',
                ),
              ],
            ),
            const EmployeeDossierModel(
              id: 'emp-2',
              name: 'Sara Sami',
              code: 'EMP-4095',
              role: 'Lead UI/UX Designer',
              email: 'sara.sami@company.com',
              phone: '01099887766',
              photoUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=300',
              address: 'Al-Haram St, Giza, Egypt',
              shift: 'Morning Core (09:00 - 17:00)',
              hireDate: '01 Mar 2023',
              status: AttendanceStatus.onTime,
              statusText: 'On Time (08:52 AM)',
              issuesCount: 0,
              issueLabel: 'All Good',
              baseSalary: 4500.0,
              deductions: 0.0,
              overtimeHours: 4.0,
              overtimeRate: 1.5,
              netSalary: 4680.0,
              intervals: [
                PresenceIntervalModel(
                  time: '09:00 - 11:30',
                  status: 'inside',
                  label: 'Continuously Inside HQ (50m Radius)',
                ),
              ],
            ),
            const EmployeeDossierModel(
              id: 'emp-eng-3',
              name: 'Ramy Mansour',
              code: 'EMP-4098',
              role: 'Backend Developer',
              email: 'ramy.mansour@company.com',
              phone: '01022334455',
              photoUrl: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=300',
              address: 'Shoubra, Cairo',
              shift: 'Morning Core (09:00 - 17:00)',
              hireDate: '10 Apr 2025',
              status: AttendanceStatus.onTime,
              statusText: 'On Time (08:50 AM)',
              issuesCount: 0,
              issueLabel: 'All Good',
              baseSalary: 4200.0,
              deductions: 0.0,
              overtimeHours: 1.0,
              overtimeRate: 1.5,
              netSalary: 4240.0,
              intervals: [
                PresenceIntervalModel(time: '09:00 - 11:30', status: 'inside', label: 'Inside Branch'),
              ],
            ),
            const EmployeeDossierModel(
              id: 'emp-eng-4',
              name: 'Nour Ibrahim',
              code: 'EMP-4101',
              role: 'Junior Flutter Developer',
              email: 'nour.ibrahim@company.com',
              phone: '01133445566',
              photoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300',
              address: 'Ain Shams, Cairo',
              shift: 'Morning Core (09:00 - 17:00)',
              hireDate: '01 Sep 2025',
              status: AttendanceStatus.late,
              statusText: 'Late (09:18 AM)',
              issuesCount: 1,
              issueLabel: '1 Issue (Late)',
              baseSalary: 3000.0,
              deductions: 200.0,
              overtimeHours: 0.0,
              overtimeRate: 1.5,
              netSalary: 2800.0,
              intervals: [
                PresenceIntervalModel(time: '09:00 - 09:18', status: 'pending', label: 'Not checked in yet'),
                PresenceIntervalModel(time: '09:18 - 11:30', status: 'inside', label: 'Checked in at 09:18 AM (18m Late)'),
              ],
            ),
          ],
        ),
        DepartmentTeamModel(
          id: 't-product',
          name: 'Product & QA Team',
          headName: 'Khaled Medhat',
          headTitle: 'Product Operations Lead',
          headEmail: 'khaled.medhat@company.com',
          headPhone: '01022233344',
          headPhotoUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=300',
          employees: const [
            EmployeeDossierModel(
              id: 'emp-4',
              name: 'Kareem Adel',
              code: 'EMP-5012',
              role: 'Senior QA Tester',
              email: 'kareem.adel@company.com',
              phone: '01233445566',
              photoUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=300',
              address: 'Heliopolis, Cairo',
              shift: 'Morning Core',
              hireDate: '20 Jul 2023',
              status: AttendanceStatus.onTime,
              statusText: 'On Time (08:58 AM)',
              issuesCount: 0,
              issueLabel: 'All Good',
              baseSalary: 3800.0,
              deductions: 0.0,
              overtimeHours: 3.0,
              overtimeRate: 1.5,
              netSalary: 3950.0,
              intervals: [
                PresenceIntervalModel(time: '09:00 - 11:30', status: 'inside', label: 'Inside Branch'),
              ],
            ),
            EmployeeDossierModel(
              id: 'emp-qa-2',
              name: 'Heba Mostafa',
              code: 'EMP-5018',
              role: 'QA Automation Engineer',
              email: 'heba.mostafa@company.com',
              phone: '01244556677',
              photoUrl: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=300',
              address: 'Maadi, Cairo',
              shift: 'Morning Core',
              hireDate: '15 Feb 2024',
              status: AttendanceStatus.onTime,
              statusText: 'On Time (08:50 AM)',
              issuesCount: 0,
              issueLabel: 'All Good',
              baseSalary: 3500.0,
              deductions: 0.0,
              overtimeHours: 1.0,
              overtimeRate: 1.5,
              netSalary: 3530.0,
              intervals: [
                PresenceIntervalModel(time: '09:00 - 11:30', status: 'inside', label: 'Inside Branch'),
              ],
            ),
            EmployeeDossierModel(
              id: 'emp-qa-3',
              name: 'Tamer Hosny',
              code: 'EMP-5022',
              role: 'Junior QA Tester',
              email: 'tamer.hosny@company.com',
              phone: '01255667788',
              photoUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=300',
              address: 'Dokki, Giza',
              shift: 'Morning Core',
              hireDate: '01 Jun 2025',
              status: AttendanceStatus.late,
              statusText: 'Late (09:35 AM)',
              issuesCount: 1,
              issueLabel: '1 Issue (Late)',
              baseSalary: 2800.0,
              deductions: 200.0,
              overtimeHours: 0.0,
              overtimeRate: 1.5,
              netSalary: 2600.0,
              intervals: [
                PresenceIntervalModel(time: '09:00 - 09:35', status: 'pending', label: 'Not checked in yet'),
                PresenceIntervalModel(time: '09:35 - 11:30', status: 'inside', label: 'Checked in at 09:35 AM (35m Late)'),
              ],
            ),
          ],
        ),
        DepartmentTeamModel(
          id: 't-cloud',
          name: 'Cloud & Infrastructure Team',
          headName: 'Youssef Kamal',
          headTitle: 'Cloud & Infrastructure Lead',
          headEmail: 'youssef.kamal@company.com',
          headPhone: '01033344455',
          headPhotoUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=300',
          employees: const [
            EmployeeDossierModel(
              id: 'emp-6',
              name: 'Mahmoud Reda',
              code: 'EMP-7010',
              role: 'DevOps & Site Reliability Engineer',
              email: 'mahmoud.reda@company.com',
              phone: '01077889900',
              photoUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300',
              address: 'Nasr City, Cairo',
              shift: 'Infrastructure Core',
              hireDate: '10 Jan 2024',
              status: AttendanceStatus.onTime,
              statusText: 'On Time (08:45 AM)',
              issuesCount: 0,
              issueLabel: 'All Good',
              baseSalary: 4800.0,
              deductions: 0.0,
              overtimeHours: 2.0,
              overtimeRate: 1.5,
              netSalary: 4920.0,
              intervals: [
                PresenceIntervalModel(time: '09:00 - 11:30', status: 'inside', label: 'Inside Branch'),
              ],
            ),
            EmployeeDossierModel(
              id: 'emp-cloud-2',
              name: 'Amr Hassan',
              code: 'EMP-7015',
              role: 'Cloud Security Specialist',
              email: 'amr.hassan@company.com',
              phone: '01088990011',
              photoUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300',
              address: 'Zamalek, Cairo',
              shift: 'Infrastructure Core',
              hireDate: '01 Mar 2025',
              status: AttendanceStatus.onTime,
              statusText: 'On Time (08:40 AM)',
              issuesCount: 0,
              issueLabel: 'All Good',
              baseSalary: 5200.0,
              deductions: 0.0,
              overtimeHours: 0.0,
              overtimeRate: 1.5,
              netSalary: 5200.0,
              intervals: [
                PresenceIntervalModel(time: '09:00 - 11:30', status: 'inside', label: 'Inside Branch'),
              ],
            ),
          ],
        ),
        DepartmentTeamModel(
          id: 't-ux',
          name: 'UX & Design Team',
          headName: 'Sara Mostafa',
          headTitle: 'Design Director',
          headEmail: 'sara.mostafa@company.com',
          headPhone: '01044455566',
          headPhotoUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=300',
          employees: const [
            EmployeeDossierModel(
              id: 'emp-ux-1',
              name: 'Dina Khaled',
              code: 'EMP-8001',
              role: 'UI Designer',
              email: 'dina.khaled@company.com',
              phone: '01166778899',
              photoUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=300',
              address: 'Mohandessin, Giza',
              shift: 'Morning Core',
              hireDate: '15 Jun 2024',
              status: AttendanceStatus.onTime,
              statusText: 'On Time (08:52 AM)',
              issuesCount: 0,
              issueLabel: 'All Good',
              baseSalary: 3600.0,
              deductions: 0.0,
              overtimeHours: 1.5,
              overtimeRate: 1.5,
              netSalary: 3630.0,
              intervals: [
                PresenceIntervalModel(time: '09:00 - 11:30', status: 'inside', label: 'Inside Branch'),
              ],
            ),
            EmployeeDossierModel(
              id: 'emp-ux-2',
              name: 'Youssef Tarek',
              code: 'EMP-8005',
              role: 'Motion Graphics Designer',
              email: 'youssef.tarek@company.com',
              phone: '01277889900',
              photoUrl: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=300',
              address: 'October City, Giza',
              shift: 'Morning Core',
              hireDate: '01 Aug 2024',
              status: AttendanceStatus.absent,
              statusText: 'Absent',
              issuesCount: 1,
              issueLabel: '1 Issue (Absent)',
              baseSalary: 3400.0,
              deductions: 680.0,
              overtimeHours: 0.0,
              overtimeRate: 1.5,
              netSalary: 2720.0,
              intervals: [],
            ),
            EmployeeDossierModel(
              id: 'emp-ux-3',
              name: 'Mariam Sayed',
              code: 'EMP-8010',
              role: 'UX Researcher',
              email: 'mariam.sayed@company.com',
              phone: '01188990011',
              photoUrl: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=300',
              address: 'Rehab City, Cairo',
              shift: 'Morning Core',
              hireDate: '20 Sep 2024',
              status: AttendanceStatus.onTime,
              statusText: 'On Time (08:55 AM)',
              issuesCount: 0,
              issueLabel: 'All Good',
              baseSalary: 3300.0,
              deductions: 0.0,
              overtimeHours: 2.0,
              overtimeRate: 1.5,
              netSalary: 3340.0,
              intervals: [
                PresenceIntervalModel(time: '09:00 - 11:30', status: 'inside', label: 'Inside Branch'),
              ],
            ),
          ],
        ),
        DepartmentTeamModel(
          id: 't-hr',
          name: 'HR & Operations Team',
          headName: 'Mohamed Salama',
          headTitle: 'HR Operations Manager',
          headEmail: 'mohamed.salama@company.com',
          headPhone: '01055566677',
          headPhotoUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=300',
          employees: const [
            EmployeeDossierModel(
              id: 'emp-hr-1',
              name: 'Fatma Ali',
              code: 'EMP-9001',
              role: 'HR Coordinator',
              email: 'fatma.ali@company.com',
              phone: '01099001122',
              photoUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=300',
              address: 'Sheraton, Cairo',
              shift: 'Morning Core',
              hireDate: '01 Apr 2024',
              status: AttendanceStatus.onTime,
              statusText: 'On Time (08:48 AM)',
              issuesCount: 0,
              issueLabel: 'All Good',
              baseSalary: 3000.0,
              deductions: 0.0,
              overtimeHours: 0.0,
              overtimeRate: 1.5,
              netSalary: 3000.0,
              intervals: [
                PresenceIntervalModel(time: '09:00 - 11:30', status: 'inside', label: 'Inside Branch'),
              ],
            ),
            EmployeeDossierModel(
              id: 'emp-hr-2',
              name: 'Ali Gamal',
              code: 'EMP-9005',
              role: 'Payroll Specialist',
              email: 'ali.gamal@company.com',
              phone: '01200112233',
              photoUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=300',
              address: 'Tagamoa, Cairo',
              shift: 'Morning Core',
              hireDate: '15 May 2025',
              status: AttendanceStatus.late,
              statusText: 'Late (09:22 AM)',
              issuesCount: 1,
              issueLabel: '1 Issue (Late)',
              baseSalary: 3200.0,
              deductions: 200.0,
              overtimeHours: 0.0,
              overtimeRate: 1.5,
              netSalary: 3000.0,
              intervals: [
                PresenceIntervalModel(time: '09:00 - 09:22', status: 'pending', label: 'Not checked in yet'),
                PresenceIntervalModel(time: '09:22 - 11:30', status: 'inside', label: 'Checked in at 09:22 AM (22m Late)'),
              ],
            ),
          ],
        ),
      ],
    ),
    BranchModel(
      id: 'b-alex',
      name: 'Alexandria Regional Branch',
      address: 'Corniche Road, Saba Pasha, Alexandria, Egypt',
      radiusMeters: 50.0,
      teams: [
        DepartmentTeamModel(
          id: 't-alex-sales',
          name: 'Mediterranean Sales Team',
          headName: 'Omar Othman',
          headTitle: 'Regional Sales Manager',
          headEmail: 'omar.othman@company.com',
          headPhone: '01066677788',
          headPhotoUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=300',
          employees: const [
            EmployeeDossierModel(
              id: 'emp-5',
              name: 'Nouran Aly',
              code: 'EMP-6001',
              role: 'Senior Account Executive',
              email: 'nouran.aly@company.com',
              phone: '01511223344',
              photoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300',
              address: 'Roushdy, Alexandria',
              shift: 'Sales Shift (10:00 - 18:00)',
              hireDate: '01 Sep 2024',
              status: AttendanceStatus.onTime,
              statusText: 'On Time (09:50 AM)',
              issuesCount: 0,
              issueLabel: 'All Good',
              baseSalary: 4200.0,
              deductions: 0.0,
              overtimeHours: 2.0,
              overtimeRate: 1.5,
              netSalary: 4310.0,
              intervals: [
                PresenceIntervalModel(
                  time: '10:00 - 11:30',
                  status: 'inside',
                  label: 'Inside Alex Branch (50m Radius)',
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ];

  DeductionRulesModel _rules = const DeductionRulesModel();

  @override
  Future<List<BranchModel>> getBranches() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _branches;
  }

  @override
  Future<void> updateEmployeeSalary(String employeeId, double newBase) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _branches = _branches.map((b) {
      return BranchModel(
        id: b.id,
        name: b.name,
        address: b.address,
        radiusMeters: b.radiusMeters,
        teams: b.teams.map((t) {
          return DepartmentTeamModel(
            id: t.id,
            name: t.name,
            headName: t.headName,
            headTitle: t.headTitle,
            headEmail: t.headEmail,
            headPhone: t.headPhone,
            headPhotoUrl: t.headPhotoUrl,
            employees: t.employees.map((e) {
              if (e.id == employeeId) {
                final net = newBase - e.deductions + (e.overtimeHours * (newBase / 160) * e.overtimeRate);
                return e.copyWith(baseSalary: newBase, netSalary: net);
              }
              return e;
            }).toList(),
          );
        }).toList(),
      );
    }).toList();
  }

  @override
  Future<DeductionRulesModel> getDeductionRules() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _rules;
  }

  @override
  Future<void> saveDeductionRules(DeductionRulesModel rules) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _rules = rules;
  }

  @override
  Future<void> addBranch({
    required String name,
    required String address,
    double radiusMeters = 50.0,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newBranch = BranchModel(
      id: 'b-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      address: address,
      radiusMeters: radiusMeters,
      teams: const [],
    );
    _branches = [..._branches, newBranch];
  }

  @override
  Future<void> addEmployee({
    required String branchId,
    required String teamId,
    required EmployeeDossierModel employee,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _branches = _branches.map((b) {
      if (b.id != branchId) return b;
      return BranchModel(
        id: b.id,
        name: b.name,
        address: b.address,
        radiusMeters: b.radiusMeters,
        teams: b.teams.map((t) {
          if (t.id != teamId) return t;
          return DepartmentTeamModel(
            id: t.id,
            name: t.name,
            headName: t.headName,
            headTitle: t.headTitle,
            headEmail: t.headEmail,
            headPhone: t.headPhone,
            headPhotoUrl: t.headPhotoUrl,
            employees: [...t.employees, employee],
          );
        }).toList(),
      );
    }).toList();
  }

  @override
  Future<void> addManagerTeam({
    required String branchId,
    required String teamName,
    required String headName,
    required String headTitle,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newTeam = DepartmentTeamModel(
      id: 't-${DateTime.now().millisecondsSinceEpoch}',
      name: teamName,
      headName: headName,
      headTitle: headTitle,
      employees: const [],
    );
    _branches = _branches.map((b) {
      if (b.id != branchId) return b;
      return BranchModel(
        id: b.id,
        name: b.name,
        address: b.address,
        radiusMeters: b.radiusMeters,
        teams: [...b.teams, newTeam],
      );
    }).toList();
  }

  @override
  Future<void> awardBonusOrDeduction({
    required String employeeId,
    required double amount,
    required bool isBonus,
    required String reason,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _branches = _branches.map((b) {
      return BranchModel(
        id: b.id,
        name: b.name,
        address: b.address,
        radiusMeters: b.radiusMeters,
        teams: b.teams.map((t) {
          return DepartmentTeamModel(
            id: t.id,
            name: t.name,
            headName: t.headName,
            headTitle: t.headTitle,
            headEmail: t.headEmail,
            headPhone: t.headPhone,
            headPhotoUrl: t.headPhotoUrl,
            employees: t.employees.map((e) {
              if (e.id != employeeId) return e;
              if (isBonus) {
                final net = e.netSalary + amount;
                return e.copyWith(bonus: e.bonus + amount, netSalary: net);
              } else {
                final net = e.netSalary - amount;
                return e.copyWith(deductions: e.deductions + amount, netSalary: net);
              }
            }).toList(),
          );
        }).toList(),
      );
    }).toList();
  }

  @override
  Future<void> deactivateEmployee(String employeeId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _branches = _branches.map((b) {
      return BranchModel(
        id: b.id,
        name: b.name,
        address: b.address,
        radiusMeters: b.radiusMeters,
        teams: b.teams.map((t) {
          return DepartmentTeamModel(
            id: t.id,
            name: t.name,
            headName: t.headName,
            headTitle: t.headTitle,
            headEmail: t.headEmail,
            headPhone: t.headPhone,
            headPhotoUrl: t.headPhotoUrl,
            employees: t.employees.map((e) {
              if (e.id != employeeId) return e;
              return e.copyWith(isSuspended: true, statusText: 'Suspended (Closed)');
            }).toList(),
          );
        }).toList(),
      );
    }).toList();
  }

  @override
  Future<void> reactivateEmployee(String employeeId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _branches = _branches.map((b) {
      return BranchModel(
        id: b.id,
        name: b.name,
        address: b.address,
        radiusMeters: b.radiusMeters,
        teams: b.teams.map((t) {
          return DepartmentTeamModel(
            id: t.id,
            name: t.name,
            headName: t.headName,
            headTitle: t.headTitle,
            headEmail: t.headEmail,
            headPhone: t.headPhone,
            headPhotoUrl: t.headPhotoUrl,
            employees: t.employees.map((e) {
              if (e.id != employeeId) return e;
              return e.copyWith(isSuspended: false, statusText: 'Active');
            }).toList(),
          );
        }).toList(),
      );
    }).toList();
  }

  @override
  Future<void> removeEmployee(String employeeId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _branches = _branches.map((b) {
      return BranchModel(
        id: b.id,
        name: b.name,
        address: b.address,
        radiusMeters: b.radiusMeters,
        teams: b.teams.map((t) {
          return DepartmentTeamModel(
            id: t.id,
            name: t.name,
            headName: t.headName,
            headTitle: t.headTitle,
            headEmail: t.headEmail,
            headPhone: t.headPhone,
            headPhotoUrl: t.headPhotoUrl,
            employees: t.employees.where((e) => e.id != employeeId).toList(),
          );
        }).toList(),
      );
    }).toList();
  }

  @override
  Future<void> manualCheckInEmployee({
    required String employeeId,
    required String adminName,
    required String reason,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _branches = _branches.map((b) {
      return BranchModel(
        id: b.id,
        name: b.name,
        address: b.address,
        radiusMeters: b.radiusMeters,
        teams: b.teams.map((t) {
          return DepartmentTeamModel(
            id: t.id,
            name: t.name,
            headName: t.headName,
            headTitle: t.headTitle,
            headEmail: t.headEmail,
            headPhone: t.headPhone,
            headPhotoUrl: t.headPhotoUrl,
            employees: t.employees.map((e) {
              if (e.id != employeeId) return e;
              final newIntervals = List<PresenceIntervalModel>.from(e.intervals);
              newIntervals.insert(
                0,
                PresenceIntervalModel(
                  time: '09:05 AM (Manual)',
                  status: 'inside',
                  label: 'Manual Check-In by HR ($adminName): $reason',
                ),
              );
              return e.copyWith(
                status: AttendanceStatus.onTime,
                statusText: 'Checked in manually by HR ($adminName)',
                intervals: newIntervals,
              );
            }).toList(),
          );
        }).toList(),
      );
    }).toList();
  }
}
