import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRemoteDataSource {
  Future<String> signInWithEmail(String email, String password);
  Future<String> signUpWithEmail(String email, String password);
  Future<void> signOut();
  Future<String?> getCurrentUserId();
  Future<void> resetPassword(String email);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;

  AuthRemoteDataSourceImpl({required this.firebaseAuth});

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
