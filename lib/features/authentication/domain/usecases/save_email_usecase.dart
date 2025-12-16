import 'package:myfin/features/authentication/domain/repositories/auth_repository.dart';

class SaveEmailUseCase {
  final AuthRepository authRepository;

  SaveEmailUseCase({required this.authRepository});

  Future<void> call(String email) async {
    return await authRepository.saveEmail(email);
  }
}
