import '../models/user_model.dart';

abstract class IAuthRepository {
  /// Authenticates using email and password
  Future<UserModel> login({required String email, required String password});

  /// Quick 1-tap demo login for testing during evaluation/defense
  Future<UserModel> loginAsRole(UserRole role);

  /// Changes user password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Retrieves the currently authenticated user session if token exists
  Future<UserModel?> getCurrentUser();

  /// Clears stored token and logs out
  Future<void> logout();
}
