import 'package:firebase_auth/firebase_auth.dart';
import 'package:myfin/features/authentication/domain/repositories/auth_repository.dart';
import 'package:myfin/features/authentication/domain/repositories/member_repository.dart';
import 'package:myfin/features/authentication/domain/repositories/admin_repository.dart';
import 'package:myfin/features/authentication/domain/usecases/sign_in_usecase.dart';

class PhoneAuthUseCase {
  final AuthRepository authRepository;
  final MemberRepository memberRepository;
  final AdminRepository adminRepository;

  PhoneAuthUseCase({
    required this.authRepository,
    required this.memberRepository,
    required this.adminRepository,
  });

  /// Step 1: Verify phone number and send OTP
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onVerificationFailed,
  }) async {
    if (phoneNumber.isEmpty) {
      throw Exception('Phone number cannot be empty');
    }

    // Validate phone number format (should start with +)
    if (!phoneNumber.startsWith('+')) {
      throw Exception(
        'Phone number must include country code (e.g., +1234567890)',
      );
    }

    await authRepository.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onVerificationFailed: (error) {
        if (error is FirebaseAuthException) {
          if (error.code == 'invalid-phone-number') {
            onVerificationFailed('Invalid phone number format');
          } else if (error.code == 'too-many-requests') {
            onVerificationFailed('Too many requests. Please try again later');
          } else {
            onVerificationFailed('Verification failed: ${error.message}');
          }
        } else {
          onVerificationFailed('Verification failed: $error');
        }
      },
    );
  }

  /// Step 2: Verify OTP and sign in
  Future<SignInResult> verifyOTP({
    required String verificationId,
    required String otp,
  }) async {
    if (otp.isEmpty) {
      throw Exception('Verification code cannot be empty');
    }

    if (otp.length != 6) {
      throw Exception('Verification code must be 6 digits');
    }

    // Sign in with phone credential and get the Firebase UID
    final uid = await authRepository.signInWithPhoneCredential(
      verificationId,
      otp,
    );

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
        // User doesn't exist in database
        throw Exception(
          'User profile not found. Please complete registration.',
        );
      }
    }
  }
}
