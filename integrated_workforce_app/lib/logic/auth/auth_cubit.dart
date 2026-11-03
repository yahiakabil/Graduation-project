import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final IAuthRepository authRepository;

  AuthCubit({required this.authRepository}) : super(AuthInitial());

  Future<void> checkSession() async {
    try {
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(const Unauthenticated());
      }
    } catch (e) {
      emit(const Unauthenticated());
    }
  }

  Future<void> login(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) {
      emit(const AuthError('Please enter both corporate email and password.'));
      return;
    }
    emit(AuthLoading());
    try {
      final user = await authRepository.login(
        email: email.trim(),
        password: password,
      );
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> loginAsRole(UserRole role) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.loginAsRole(role);
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    await authRepository.logout();
    emit(const Unauthenticated(message: 'Successfully logged out.'));
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await authRepository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
