import 'package:myfin/features/authentication/domain/repositories/auth_repository.dart';
import 'package:myfin/features/authentication/domain/repositories/admin_repository.dart';
import 'package:myfin/features/authentication/domain/repositories/member_repository.dart';
import 'package:myfin/features/authentication/domain/usecases/sign_in_usecase.dart';

class GetCurrentUserUseCase {
  final AuthRepository authRepository;
  final AdminRepository adminRepository;
  final MemberRepository memberRepository;

  GetCurrentUserUseCase({
    required this.authRepository,
    required this.adminRepository,
    required this.memberRepository,
  });

  Future<SignInResult?> call() async {
    final uid = await authRepository.getCurrentUserId();

    if (uid == null) {
      return null;
    }

    try {
      final admin = await adminRepository.getAdmin(uid);
      return SignInResult(uid: uid, userType: UserType.admin, userData: admin);
    } catch (e) {
      try {
        final member = await memberRepository.getMember(uid);

        if (member.status.toLowerCase() == 'banned') {
          await authRepository.signOut();
          return null; 
        }

        return SignInResult(
          uid: uid,
          userType: UserType.member,
          userData: member,
        );
      } catch (e) {
        throw Exception('User profile not found in database');
      }
    }
  }
}
