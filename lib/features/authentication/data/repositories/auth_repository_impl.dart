import 'package:myfin/features/authentication/domain/repositories/auth_repository.dart';
import 'package:myfin/features/authentication/data/datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;

  AuthRepositoryImpl(this.remote);

  @override
  Future<String> signInWithEmail(String email, String password) async {
    return await remote.signInWithEmail(email, password);
  }

  @override
  Future<String> signUpWithEmail(String email, String password) async {
    return await remote.signUpWithEmail(email, password);
  }

  @override
  Future<void> signOut() async {
    return await remote.signOut();
  }

  @override
  Future<String?> getCurrentUserId() async {
    return await remote.getCurrentUserId();
  }

  @override
  Future<void> resetPassword(String email) async {
    return await remote.resetPassword(email);
  }

  // Social authentication methods
  @override
  Future<String> signInWithGoogle() async {
    return await remote.signInWithGoogle();
  }

  @override
  Future<String> signInWithFacebook() async {
    return await remote.signInWithFacebook();
  }

  @override
  Future<String> signInWithApple() async {
    return await remote.signInWithApple();
  }

  // Phone authentication methods
  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(dynamic error) onVerificationFailed,
  }) async {
    return await remote.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onVerificationFailed: onVerificationFailed,
    );
  }

  @override
  Future<String> signInWithPhoneCredential(
    String verificationId,
    String smsCode,
  ) async {
    return await remote.signInWithPhoneCredential(verificationId, smsCode);
  }
}
