import 'package:myfin/features/authentication/domain/repositories/auth_repository.dart';

class SignOutUseCase {
  final AuthRepository authRepository;

  SignOutUseCase({required this.authRepository});

  Future<void> call() async {
    await authRepository.signOut();
  }
}
