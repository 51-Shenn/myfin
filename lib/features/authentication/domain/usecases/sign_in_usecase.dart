
import 'package:myfin/features/authentication/domain/repositories/auth_repository.dart';
import 'package:myfin/features/authentication/domain/repositories/admin_repository.dart';
import 'package:myfin/features/authentication/domain/repositories/member_repository.dart';

enum UserType { admin, member }

class SignInResult {
  final String uid;
  final UserType userType;
  final dynamic userData;

  SignInResult({
    required this.uid,
    required this.userType,
    required this.userData,
  });
}

class SignInUseCase {
  final AuthRepository authRepository;
  final AdminRepository adminRepository;
  final MemberRepository memberRepository;

  SignInUseCase({
    required this.authRepository,
    required this.adminRepository,
    required this.memberRepository,
  });

  Future<SignInResult> call(String email, String password) async {
    final uid = await authRepository.signInWithEmail(email, password);
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
        throw Exception('User profile not found in database');
      }
    }
  }
}
