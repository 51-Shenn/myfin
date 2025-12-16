import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:myfin/features/authentication/domain/entities/admin.dart';
import 'package:myfin/features/authentication/domain/entities/member.dart';
import 'package:myfin/features/authentication/domain/usecases/get_current_user_usecase.dart';
import 'package:myfin/features/authentication/domain/usecases/sign_in_usecase.dart';
import 'package:myfin/features/authentication/domain/usecases/sign_out_usecase.dart';
import 'package:myfin/features/authentication/domain/usecases/sign_up_usecase.dart';
import 'package:myfin/features/authentication/domain/usecases/reset_password_usecase.dart';
import 'package:myfin/features/authentication/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:myfin/features/authentication/domain/usecases/sign_in_with_facebook_usecase.dart';
import 'package:myfin/features/authentication/domain/usecases/sign_in_with_apple_usecase.dart';
import 'package:myfin/features/authentication/domain/usecases/phone_auth_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signIn;
  final SignUpUseCase signUp;
  final GetCurrentUserUseCase getCurrentUser;
  final SignOutUseCase signOut;
  final ResetPasswordUseCase resetPassword;
  final SignInWithGoogleUseCase signInWithGoogle;
  final SignInWithFacebookUseCase signInWithFacebook;
  final SignInWithAppleUseCase signInWithApple;
  final PhoneAuthUseCase phoneAuth;

  AuthBloc({
    required this.signIn,
    required this.signUp,
    required this.getCurrentUser,
    required this.signOut,
    required this.resetPassword,
    required this.signInWithGoogle,
    required this.signInWithFacebook,
    required this.signInWithApple,
    required this.phoneAuth,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(onAuthCheck);
    on<AuthLoginRequested>(onLogin);
    on<AuthLogoutRequested>(onLogout);
    on<AuthRegisterMemberRequested>(onMemberRegister);
    on<AuthRegisterAdminRequested>(onAdminRegister);
    on<AuthResetPasswordRequested>(onResetPassword);
    on<AuthPageChanged>(onPageChanged);
    // Social authentication handlers
    on<AuthGoogleSignInRequested>(onGoogleSignIn);
    on<AuthFacebookSignInRequested>(onFacebookSignIn);
    on<AuthAppleSignInRequested>(onAppleSignIn);
    // Phone authentication handlers
    on<AuthPhoneVerificationRequested>(onPhoneVerification);
    on<AuthPhoneOTPVerificationRequested>(onPhoneOTPVerification);
  }

  /// Converts technical exception messages to user-friendly error messages
  String _getFriendlyErrorMessage(dynamic error) {
    final errorMessage = error.toString().toLowerCase();

    // Login/Sign-in errors
    if (errorMessage.contains('user-not-found')) {
      return 'No account found with this email. Please sign up first.';
    }
    if (errorMessage.contains('wrong-password') ||
        errorMessage.contains('invalid-credential') ||
        errorMessage.contains('auth credential is incorrect')) {
      return 'Invalid email or password. Please try again.';
    }
    if (errorMessage.contains('too-many-requests')) {
      return 'Too many failed attempts. Please try again later.';
    }
    if (errorMessage.contains('user-disabled')) {
      return 'This account has been disabled. Please contact support.';
    }

    // Registration errors
    if (errorMessage.contains('email-already-in-use')) {
      return 'This email is already registered. Please sign in instead.';
    }
    if (errorMessage.contains('weak-password')) {
      return 'Password is too weak. Please use a stronger password.';
    }
    if (errorMessage.contains('invalid-email')) {
      return 'Invalid email address. Please check and try again.';
    }

    // Password reset errors
    if (errorMessage.contains('user-not-found')) {
      return 'No account found with this email address.';
    }

    // Network errors
    if (errorMessage.contains('network')) {
      return 'Network error. Please check your connection and try again.';
    }

    if (errorMessage.contains('user profile not found')) {
      return 'User not found. Please complete registration.';
    }

    // Generic fallback
    return 'Something went wrong. Please try again.';
  }

  void onPageChanged(AuthPageChanged event, Emitter<AuthState> emit) {
    // When switching pages, clear any error/success states to prevent
    // error messages from reappearing
    if (state is AuthFailure ||
        state is AuthRegisterFailure ||
        state is AuthRegisterSuccess ||
        state is AuthResetPasswordFailure ||
        state is AuthResetPasswordSuccess) {
      emit(AuthInitial(currentPage: event.page));
      return;
    }

    // For other states, preserve them with the new page number
    if (state is AuthInitial) {
      emit(AuthInitial(currentPage: event.page));
    } else if (state is AuthLoading) {
      emit(AuthLoading(currentPage: event.page));
    } else if (state is AuthAuthenticatedAsMember) {
      emit(
        AuthAuthenticatedAsMember(
          (state as AuthAuthenticatedAsMember).member,
          currentPage: event.page,
        ),
      );
    } else if (state is AuthAuthenticatedAsAdmin) {
      emit(
        AuthAuthenticatedAsAdmin(
          (state as AuthAuthenticatedAsAdmin).admin,
          currentPage: event.page,
        ),
      );
    } else if (state is AuthUnauthenticated) {
      emit(AuthUnauthenticated(currentPage: event.page));
    } else {
      emit(AuthInitial(currentPage: event.page));
    }
  }

  Future<void> onAuthCheck(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await getCurrentUser();

    if (result == null) {
      emit(AuthUnauthenticated());
      return;
    }

    if (result.userType == UserType.admin) {
      emit(AuthAuthenticatedAsAdmin(result.userData as Admin));
    } else {
      emit(AuthAuthenticatedAsMember(result.userData as Member));
    }
  }

  Future<void> onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await signIn(event.email, event.password);

      if (result.userType == UserType.admin) {
        emit(AuthAuthenticatedAsAdmin(result.userData as Admin));
      } else {
        emit(AuthAuthenticatedAsMember(result.userData as Member));
      }
    } catch (e) {
      emit(AuthFailure(_getFriendlyErrorMessage(e)));
    }
  }

  Future<void> onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthFailure(_getFriendlyErrorMessage(e)));
    }
  }

  Future<void> onMemberRegister(
    AuthRegisterMemberRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await signUp.signUpMember(
        email: event.email,
        password: event.password,
        username: event.username,
        firstName: event.first_name,
        lastName: event.last_name,
        phoneNumber: event.phone_number,
        address: event.address,
      );

      emit(
        AuthRegisterSuccess('Member registered successfully! Please sign in.'),
      );
    } catch (e) {
      emit(AuthRegisterFailure(_getFriendlyErrorMessage(e)));
    }
  }

  Future<void> onAdminRegister(
    AuthRegisterAdminRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await signUp.signUpAdmin(
        email: event.email,
        password: event.password,
        username: event.username,
        firstName: event.first_name,
        lastName: event.last_name,
      );

      emit(
        AuthRegisterSuccess('Admin registered successfully! Please sign in.'),
      );
    } catch (e) {
      emit(AuthRegisterFailure(_getFriendlyErrorMessage(e)));
    }
  }

  Future<void> onResetPassword(
    AuthResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await resetPassword(event.email);
      emit(AuthResetPasswordSuccess('Password reset successfully'));
    } catch (e) {
      emit(AuthResetPasswordFailure(_getFriendlyErrorMessage(e)));
    }
  }

  // Social authentication handlers
  Future<void> onGoogleSignIn(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await signInWithGoogle();

      if (result.userType == UserType.admin) {
        emit(AuthAuthenticatedAsAdmin(result.userData as Admin));
      } else {
        emit(AuthAuthenticatedAsMember(result.userData as Member));
      }
    } catch (e) {
      emit(AuthFailure(_getFriendlyErrorMessage(e)));
    }
  }

  Future<void> onFacebookSignIn(
    AuthFacebookSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await signInWithFacebook();

      if (result.userType == UserType.admin) {
        emit(AuthAuthenticatedAsAdmin(result.userData as Admin));
      } else {
        emit(AuthAuthenticatedAsMember(result.userData as Member));
      }
    } catch (e) {
      emit(AuthFailure(_getFriendlyErrorMessage(e)));
    }
  }

  Future<void> onAppleSignIn(
    AuthAppleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await signInWithApple();

      if (result.userType == UserType.admin) {
        emit(AuthAuthenticatedAsAdmin(result.userData as Admin));
      } else {
        emit(AuthAuthenticatedAsMember(result.userData as Member));
      }
    } catch (e) {
      emit(AuthFailure(_getFriendlyErrorMessage(e)));
    }
  }

  // Phone authentication handlers
  Future<void> onPhoneVerification(
    AuthPhoneVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await phoneAuth.verifyPhoneNumber(
        phoneNumber: event.phoneNumber,
        onCodeSent: (verificationId) {
          emit(AuthPhoneCodeSent(verificationId, event.phoneNumber));
        },
        onVerificationFailed: (error) {
          emit(AuthFailure(error));
        },
      );
    } catch (e) {
      emit(AuthFailure(_getFriendlyErrorMessage(e)));
    }
  }

  Future<void> onPhoneOTPVerification(
    AuthPhoneOTPVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await phoneAuth.verifyOTP(
        verificationId: event.verificationId,
        otp: event.otp,
      );

      if (result.userType == UserType.admin) {
        emit(AuthAuthenticatedAsAdmin(result.userData as Admin));
      } else {
        emit(AuthAuthenticatedAsMember(result.userData as Member));
      }
    } catch (e) {
      emit(AuthFailure(_getFriendlyErrorMessage(e)));
    }
  }
}
