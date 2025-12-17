import 'package:myfin/features/authentication/domain/repositories/auth_repository.dart';
import 'package:myfin/features/authentication/domain/repositories/member_repository.dart';
import 'package:myfin/features/authentication/domain/repositories/admin_repository.dart';
import 'package:myfin/features/authentication/domain/usecases/sign_in_usecase.dart';

class SignInWithGoogleUseCase {
  final AuthRepository authRepository;
  final MemberRepository memberRepository;
  final AdminRepository adminRepository;

  SignInWithGoogleUseCase({
    required this.authRepository,
    required this.memberRepository,
    required this.adminRepository,
  });

  Future<SignInResult> call() async {
    final uid = await authRepository.signInWithGoogle();

    try {
      final admin = await adminRepository.getAdmin(uid);
      return SignInResult(uid: uid, userType: UserType.admin, userData: admin);
    } catch (e) {
      try {
        final member = await memberRepository.getMember(uid);
        return SignInResult(
          uid: uid,
          userType: UserType.member,
          userData: member,
        );
      } catch (e) {
        throw Exception(
          'User profile not found. Please complete registration.',
        );
      }
    }
  }
}
