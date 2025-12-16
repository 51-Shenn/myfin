abstract class AuthRepository {
  Future<String> signInWithEmail(String email, String password);
  Future<String> signUpWithEmail(String email, String password);
  Future<String?> getSavedEmail();
  Future<void> saveEmail(String email);
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Future<String?> getCurrentUserId();
  Future<String> signInWithGoogle();
}
