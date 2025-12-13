import 'package:myfin/features/authentication/domain/entities/admin.dart';
import 'package:myfin/features/authentication/domain/entities/member.dart';
import 'package:myfin/features/authentication/domain/repositories/auth_repository.dart';
import 'package:myfin/features/authentication/domain/repositories/admin_repository.dart';
import 'package:myfin/features/authentication/domain/repositories/member_repository.dart';
import 'package:myfin/features/authentication/domain/usecases/sign_in_usecase.dart';

class SignUpUseCase {
  final AuthRepository authRepository;
  final MemberRepository memberRepository;
  final AdminRepository adminRepository;

  SignUpUseCase({
    required this.authRepository,
    required this.memberRepository,
    required this.adminRepository,
  });

  Future<SignInResult> signUpMember({
    required String email,
    required String password,
    required String username,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String address,
  }) async {
    try {
      final uid = await authRepository.signUpWithEmail(email, password);

      final member = Member(
        member_id: uid,
        username: username,
        first_name: firstName,
        last_name: lastName,
        email: email,
        phone_number: phoneNumber,
        address: address,
        created_at: DateTime.now(),
        status: 'active',
      );

      await memberRepository.createMember(member);

      return SignInResult(
        uid: uid,
        userType: UserType.member,
        userData: member,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<SignInResult> signUpAdmin({
    required String email,
    required String password,
    required String username,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final uid = await authRepository.signUpWithEmail(email, password);

      final admin = Admin(
        admin_id: uid,
        username: username,
        first_name: firstName,
        last_name: lastName,
        email: email,
        created_at: DateTime.now(),
        status: 'active',
      );

      await adminRepository.createAdmin(admin);

      return SignInResult(uid: uid, userType: UserType.admin, userData: admin);
    } catch (e) {
      rethrow;
    }
  }
}
