import 'package:equatable/equatable.dart';

enum UserRole {
  employee,
  manager,
  admin,
}

class UserModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String code;
  final String jobTitle;
  final String department;
  final String managerName;
  final String branchName;
  final double branchRadiusMeters;
  final String shiftName;
  final String shiftHours;
  final String phone;
  final String address;
  final String hireDate;
  final bool mustChangePassword;
  final String? registeredPhoneId;
  final String? photoUrl;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.code,
    required this.jobTitle,
    required this.department,
    required this.managerName,
    required this.branchName,
    this.branchRadiusMeters = 50.0,
    required this.shiftName,
    required this.shiftHours,
    required this.phone,
    required this.address,
    required this.hireDate,
    this.mustChangePassword = false,
    this.registeredPhoneId,
    this.photoUrl,
  });

  UserModel copyWith({
    String? phone,
    String? address,
    bool? mustChangePassword,
    String? registeredPhoneId,
    String? photoUrl,
  }) {
    return UserModel(
      id: id,
      name: name,
      email: email,
      role: role,
      code: code,
      jobTitle: jobTitle,
      department: department,
      managerName: managerName,
      branchName: branchName,
      branchRadiusMeters: branchRadiusMeters,
      shiftName: shiftName,
      shiftHours: shiftHours,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      hireDate: hireDate,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
      registeredPhoneId: registeredPhoneId ?? this.registeredPhoneId,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawRole = (json['roleName'] ?? json['role'] ?? 'employee').toString().toLowerCase();
    UserRole parsedRole = UserRole.employee;
    if (rawRole.contains('admin') || json['roleId'] == 3) {
      parsedRole = UserRole.admin;
    } else if (rawRole.contains('manager') || json['roleId'] == 2) {
      parsedRole = UserRole.manager;
    }

    return UserModel(
      id: json['id'].toString(),
      name: (json['fullName'] ?? json['name'] ?? 'Unknown User').toString(),
      email: (json['email'] ?? '').toString(),
      role: parsedRole,
      code: (json['employeeCode'] ?? json['code'] ?? 'EMP-0000').toString(),
      jobTitle: (json['jobTitle'] ?? 'Staff Member').toString(),
      department: (json['department'] ?? 'General').toString(),
      managerName: (json['managerName'] ?? 'Executive Administration').toString(),
      branchName: (json['branch'] ?? json['branchName'] ?? 'Main HQ').toString(),
      branchRadiusMeters: (json['branchRadiusMeters'] as num?)?.toDouble() ?? 50.0,
      shiftName: (json['shiftName'] ?? 'Standard Shift').toString(),
      shiftHours: (json['shiftHours'] ?? '09:00 AM – 05:00 PM').toString(),
      phone: (json['phone'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      hireDate: (json['hireDate'] ?? '').toString(),
      mustChangePassword: json['mustChangePassword'] as bool? ?? false,
      registeredPhoneId: json['registeredPhoneId'] as String?,
      photoUrl: (json['profilePhotoUrl'] ?? json['photoUrl']) as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'code': code,
      'jobTitle': jobTitle,
      'department': department,
      'managerName': managerName,
      'branchName': branchName,
      'branchRadiusMeters': branchRadiusMeters,
      'shiftName': shiftName,
      'shiftHours': shiftHours,
      'phone': phone,
      'address': address,
      'hireDate': hireDate,
      'mustChangePassword': mustChangePassword,
      'registeredPhoneId': registeredPhoneId,
      'photoUrl': photoUrl,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        role,
        code,
        jobTitle,
        department,
        managerName,
        branchName,
        branchRadiusMeters,
        shiftName,
        shiftHours,
        phone,
        address,
        hireDate,
        mustChangePassword,
        registeredPhoneId,
        photoUrl,
      ];
}
