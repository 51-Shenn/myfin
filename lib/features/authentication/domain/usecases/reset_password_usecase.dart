import 'package:myfin/features/authentication/domain/repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository authRepository;

  ResetPasswordUseCase({required this.authRepository});

  Future<void> call(String email) async {
    if (email.isEmpty) {
      throw Exception('Email cannot be empty');
    }

    if (!isValidEmail(email)) {
      throw Exception('Please enter a valid email address');
    }

    await authRepository.resetPassword(email);
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}
