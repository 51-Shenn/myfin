abstract class AuthRepository {
  Future<String> signInWithEmail(String email, String password);
  Future<String> signUpWithEmail(String email, String password);
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Future<String?> getCurrentUserId();

  // Social authentication methods
  Future<String> signInWithGoogle();
  Future<String> signInWithFacebook();
  Future<String> signInWithApple();

  // Phone authentication methods
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(dynamic error) onVerificationFailed,
  });
  Future<String> signInWithPhoneCredential(
    String verificationId,
    String smsCode,
  );
}
