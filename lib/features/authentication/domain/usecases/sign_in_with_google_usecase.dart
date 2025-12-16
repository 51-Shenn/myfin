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
    // Sign in with Google and get the Firebase UID
    final uid = await authRepository.signInWithGoogle();

    // Try to get admin data first
    try {
      final admin = await adminRepository.getAdmin(uid);
      return SignInResult(uid: uid, userType: UserType.admin, userData: admin);
    } catch (e) {
      // If not admin, try to get member data
      try {
        final member = await memberRepository.getMember(uid);
        return SignInResult(
          uid: uid,
          userType: UserType.member,
          userData: member,
        );
      } catch (e) {
        // User doesn't exist in database - this is expected for first-time social login
        throw Exception(
          'User profile not found. Please complete registration.',
        );
      }
    }
  }
}
