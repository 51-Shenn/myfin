import 'package:myfin/features/authentication/domain/repositories/auth_repository.dart';

class GetSavedEmailUseCase {
  final AuthRepository authRepository;

  GetSavedEmailUseCase({required this.authRepository});

  Future<String?> call() async {
    return await authRepository.getSavedEmail();
  }
}
