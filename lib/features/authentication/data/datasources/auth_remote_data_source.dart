import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class AuthRemoteDataSource {
  Future<String> signInWithEmail(String email, String password);
  Future<String> signUpWithEmail(String email, String password);
  Future<void> signOut();
  Future<String?> getCurrentUserId();
  Future<void> resetPassword(String email);
  Future<String> signInWithGoogle();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Future<String> signInWithEmail(String email, String password) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user!.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No user found');
      } else if (e.code == 'wrong-password') {
        throw Exception('Wrong password');
      }
      throw Exception('Sign in failed: ${e.message}');
    }
  }

  @override
  Future<String> signUpWithEmail(String email, String password) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user!.uid; // Return new Firebase UID
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('Email already registered');
      }
      throw Exception('Sign up failed: ${e.message}');
    }
  }

  // Google Sign-In
  @override
  Future<String> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google sign-in cancelled by user');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await firebaseAuth
          .signInWithCredential(credential);

      if (userCredential.additionalUserInfo?.isNewUser == true) {
        await userCredential.user?.delete();
        await _googleSignIn
            .signOut(); 
        throw Exception('Email not registered. Please sign up first.');
      }

      return userCredential.user!.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        throw Exception('Account exists with different sign-in method');
      } else if (e.code == 'invalid-credential') {
        throw Exception('Invalid Google credentials');
      } else if (e.code == 'user-disabled') {
        throw Exception('This account has been disabled');
      } else if (e.code == 'user-not-found') {
        throw Exception('No user found');
      }
      throw Exception('Google sign-in failed: ${e.message}');
    } catch (e) {
      throw Exception('Google sign-in failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await firebaseAuth.signOut();
  }

  @override
  Future<String?> getCurrentUserId() async {
    return firebaseAuth.currentUser?.uid;
  }

  @override
  Future<void> resetPassword(String email) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }
}
