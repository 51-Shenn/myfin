import 'package:myfin/features/authentication/domain/repositories/auth_repository.dart';
import 'package:myfin/core/validators/auth_validator.dart';

class ResetPasswordUseCase {
  final AuthRepository authRepository;

  ResetPasswordUseCase({required this.authRepository});

  Future<void> call(String email) async {
    if (email.isEmpty) {
      throw Exception('Email cannot be empty');
    }

    if (!AuthValidator.isValidEmail(email)) {
      throw Exception('Please enter a valid email address');
    }

    await authRepository.resetPassword(email);
  }

}
