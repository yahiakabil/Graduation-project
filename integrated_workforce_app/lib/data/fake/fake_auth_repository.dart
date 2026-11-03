import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

class FakeAuthRepository implements IAuthRepository {
  UserModel? _currentUser;

  // Pre-configured users matching project requirements:
  // Admin: Yahia
  // Managers: Mohamed, Khaled, Omar, Yousef
  // Employees: Ahmed Kamal, Sara Sami

  static const UserModel adminYahia = UserModel(
    id: 'adm-1',
    name: 'Yahia Hussien',
    email: 'yahia.hussien@company.com',
    role: UserRole.admin,
    code: 'ADM-0001',
    jobTitle: 'System Administrator & HR Director',
    department: 'Executive Administration',
    managerName: 'Executive Board',
    branchName: 'All Branches (Company-Wide)',
    branchRadiusMeters: 50.0,
    shiftName: 'Full System Access',
    shiftHours: '24/7 Access',
    phone: '01011112222',
    address: 'Smart Village, Cairo, Egypt',
    hireDate: '01 Jan 2020',
    mustChangePassword: false,
    registeredPhoneId: 'UUID-ADMIN-YAHIA',
    photoUrl: 'assets/images/yahia_hussien.jpg',
  );

  static const UserModel managerMohamed = UserModel(
    id: 'mgr-1',
    name: 'Mohamed Hussien',
    email: 'mohamed.hussien@company.com',
    role: UserRole.manager,
    code: 'MGR-1001',
    jobTitle: 'Mobile Engineering Lead',
    department: 'Mobile Engineering',
    managerName: 'Yahia Hussien (Admin)',
    branchName: 'Main HQ Branch',
    branchRadiusMeters: 50.0,
    shiftName: 'Morning Core Shift',
    shiftHours: '09:00 AM – 05:00 PM',
    phone: '01022223333',
    address: 'Maadi, Cairo, Egypt',
    hireDate: '10 Aug 2021',
    mustChangePassword: false,
    registeredPhoneId: 'UUID-MGR-MOHAMED',
    photoUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300',
  );

  static const UserModel managerKhaled = UserModel(
    id: 'mgr-2',
    name: 'Khaled Medhat',
    email: 'khaled.medhat@company.com',
    role: UserRole.manager,
    code: 'MGR-1002',
    jobTitle: 'Product Operations & QA Lead',
    department: 'Product & QA Team',
    managerName: 'Yahia Hussien (Admin)',
    branchName: 'Main HQ Branch',
    branchRadiusMeters: 50.0,
    shiftName: 'Morning Core Shift',
    shiftHours: '09:00 AM – 05:00 PM',
    phone: '01033334444',
    address: 'Heliopolis, Cairo, Egypt',
    hireDate: '15 Mar 2022',
    mustChangePassword: false,
    registeredPhoneId: 'UUID-MGR-KHALED',
    photoUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=300',
  );

  static const UserModel managerOmar = UserModel(
    id: 'mgr-3',
    name: 'Omar Othman',
    email: 'omar.othman@company.com',
    role: UserRole.manager,
    code: 'MGR-1003',
    jobTitle: 'Regional Branch Manager',
    department: 'Mediterranean Sales Team',
    managerName: 'Yahia Hussien (Admin)',
    branchName: 'Alexandria Regional Branch',
    branchRadiusMeters: 50.0,
    shiftName: 'Sales Shift (10:00 - 18:00)',
    shiftHours: '10:00 AM – 06:00 PM',
    phone: '01044445555',
    address: 'Roushdy, Alexandria, Egypt',
    hireDate: '01 Feb 2023',
    mustChangePassword: false,
    registeredPhoneId: 'UUID-MGR-OMAR',
    photoUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=300',
  );

  static const UserModel managerYousef = UserModel(
    id: 'mgr-4',
    name: 'Yousef Kamal',
    email: 'yousef.kamal@company.com',
    role: UserRole.manager,
    code: 'MGR-1004',
    jobTitle: 'Cloud & Infrastructure Lead',
    department: 'Cloud & DevOps Team',
    managerName: 'Yahia Hussien (Admin)',
    branchName: 'Main HQ Branch',
    branchRadiusMeters: 50.0,
    shiftName: 'Infrastructure Core Shift',
    shiftHours: '09:00 AM – 05:00 PM',
    phone: '01055556666',
    address: 'New Cairo, Egypt',
    hireDate: '20 Jul 2023',
    mustChangePassword: false,
    registeredPhoneId: 'UUID-MGR-YOUSEF',
    photoUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=300',
  );

  static const UserModel managerSalama = UserModel(
    id: 'mgr-5',
    name: 'Mohamed Salama',
    email: 'mohamed.salama@company.com',
    role: UserRole.manager,
    code: 'MGR-1005',
    jobTitle: 'Operations & Facilities Lead',
    department: 'Operations & Logistics',
    managerName: 'Yahia Hussien (Admin)',
    branchName: 'Main HQ Branch',
    branchRadiusMeters: 50.0,
    shiftName: 'Morning Core Shift',
    shiftHours: '09:00 AM – 05:00 PM',
    phone: '01066667777',
    address: 'Nasr City, Cairo, Egypt',
    hireDate: '01 Sep 2023',
    mustChangePassword: false,
    registeredPhoneId: 'UUID-MGR-SALAMA',
    photoUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=300',
  );

  static const UserModel employeeAhmed = UserModel(
    id: 'emp-1',
    name: 'Ahmed Kamal',
    email: 'ahmed.kamal@company.com',
    role: UserRole.employee,
    code: 'EMP-4092',
    jobTitle: 'Senior Flutter Developer',
    department: 'Mobile Engineering',
    managerName: 'Mohamed (Manager)',
    branchName: 'Main HQ Branch',
    branchRadiusMeters: 50.0,
    shiftName: 'Morning Core Shift',
    shiftHours: '09:00 AM – 05:00 PM',
    phone: '01012345678',
    address: '14 Al-Nasr St, New Cairo, Egypt',
    hireDate: '15 Jan 2024',
    mustChangePassword: false,
    registeredPhoneId: 'UUID-8FA1-90E2',
    photoUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300',
  );

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final normalized = email.trim().toLowerCase();
    if (normalized.contains('yahia') || normalized.contains('admin')) {
      _currentUser = adminYahia;
    } else if (normalized.contains('salama')) {
      _currentUser = managerSalama;
    } else if (normalized.contains('mohamed')) {
      _currentUser = managerMohamed;
    } else if (normalized.contains('khaled')) {
      _currentUser = managerKhaled;
    } else if (normalized.contains('omar')) {
      _currentUser = managerOmar;
    } else if (normalized.contains('yousef')) {
      _currentUser = managerYousef;
    } else if (normalized.contains('manager')) {
      _currentUser = managerMohamed;
    } else {
      _currentUser = employeeAhmed;
    }
    return _currentUser!;
  }

  @override
  Future<UserModel> loginAsRole(UserRole role) async {
    await Future.delayed(const Duration(milliseconds: 300));
    switch (role) {
      case UserRole.admin:
        _currentUser = adminYahia;
        break;
      case UserRole.manager:
        _currentUser = managerMohamed;
        break;
      case UserRole.employee:
        _currentUser = employeeAhmed;
        break;
    }
    return _currentUser!;
  }

  String _fakePassword = 'password123';

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (currentPassword != _fakePassword) {
      throw Exception('Current password is incorrect.');
    }
    _fakePassword = newPassword;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
  }
}
