import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

abstract class AuthRemoteDataSource {
  Future<String> signInWithEmail(String email, String password);
  Future<String> signUpWithEmail(String email, String password);
  Future<void> signOut();
  Future<String?> getCurrentUserId();
  Future<void> resetPassword(String email);
  Future<String> signInWithGoogle();
  Future<String> signInWithFacebook();
  Future<String> signInWithApple();
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(FirebaseAuthException error) onVerificationFailed,
  });
  Future<String> signInWithPhoneCredential(
    String verificationId,
    String smsCode,
  );
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

      return userCredential.user!.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        throw Exception('Account exists with different sign-in method');
      } else if (e.code == 'invalid-credential') {
        throw Exception('Invalid Google credentials');
      } else if (e.code == 'user-disabled') {
        throw Exception('This account has been disabled');
      }
      throw Exception('Google sign-in failed: ${e.message}');
    } catch (e) {
      throw Exception('Google sign-in failed: $e');
    }
  }

  // Facebook Sign-In
  @override
  Future<String> signInWithFacebook() async {
    try {
      // Trigger the sign-in flow
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;

        // Create a credential from the access token
        final OAuthCredential credential = FacebookAuthProvider.credential(
          accessToken.tokenString,
        );

        // Sign in to Firebase with the credential
        final UserCredential userCredential = await firebaseAuth
            .signInWithCredential(credential);

        return userCredential.user!.uid;
      } else if (result.status == LoginStatus.cancelled) {
        throw Exception('Facebook sign-in cancelled by user');
      } else {
        throw Exception('Facebook sign-in failed: ${result.message}');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        throw Exception('Account exists with different sign-in method');
      } else if (e.code == 'invalid-credential') {
        throw Exception('Invalid Facebook credentials');
      } else if (e.code == 'user-disabled') {
        throw Exception('This account has been disabled');
      }
      throw Exception('Facebook sign-in failed: ${e.message}');
    } catch (e) {
      throw Exception('Facebook sign-in failed: $e');
    }
  }

  // Apple Sign-In
  // Apple Sign-In
  @override
  Future<String> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final OAuthCredential credential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final UserCredential userCredential = await firebaseAuth
          .signInWithCredential(credential);

      return userCredential.user!.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        throw Exception('Account exists with different sign-in method');
      } else if (e.code == 'invalid-credential') {
        throw Exception('Invalid Apple credentials');
      } else if (e.code == 'user-disabled') {
        throw Exception('This account has been disabled');
      }
      throw Exception('Apple sign-in failed: ${e.message}');
    } catch (e) {
      // Handle cancellation specifically if needed, otherwise generic catch
      if (e.toString().contains('cancelled')) {
        // Simplified check as SignInWithApple cancellation might vary
        throw Exception('Apple sign-in cancelled by user');
      }
      throw Exception('Apple sign-in failed: $e');
    }
  }

  // Phone Number Verification - Step 1: Send SMS code
  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(FirebaseAuthException error) onVerificationFailed,
  }) async {
    await firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-retrieval on Android - sign in automatically
        await firebaseAuth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        onVerificationFailed(e);
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Auto-retrieval timed out
      },
      timeout: const Duration(seconds: 60),
    );
  }

  // Phone Number Verification - Step 2: Verify SMS code
  @override
  Future<String> signInWithPhoneCredential(
    String verificationId,
    String smsCode,
  ) async {
    try {
      // Create phone auth credential
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // Sign in with the credential
      final UserCredential userCredential = await firebaseAuth
          .signInWithCredential(credential);

      return userCredential.user!.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        throw Exception('Invalid verification code');
      } else if (e.code == 'invalid-verification-id') {
        throw Exception('Verification session expired. Please try again');
      }
      throw Exception('Phone sign-in failed: ${e.message}');
    }
  }

  @override
  Future<void> signOut() async {
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
