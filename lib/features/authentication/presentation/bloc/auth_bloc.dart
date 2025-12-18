import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:myfin/features/authentication/domain/usecases/save_email_usecase.dart';
import 'package:myfin/features/authentication/domain/usecases/get_saved_email_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signIn;
  final SignUpUseCase signUp;
  final GetCurrentUserUseCase getCurrentUser;
  final SignOutUseCase signOut;
  final ResetPasswordUseCase resetPassword;
  final SignInWithGoogleUseCase signInWithGoogle;
  final SaveEmailUseCase saveEmail;
  final GetSavedEmailUseCase getSavedEmail;

  AuthBloc({
    required this.signIn,
    required this.signUp,
    required this.getCurrentUser,
    required this.signOut,
    required this.resetPassword,
    required this.signInWithGoogle,
    required this.saveEmail,
    required this.getSavedEmail,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(onAuthCheck);
    on<AuthLoginRequested>(onLogin);
    on<AuthLogoutRequested>(onLogout);
    on<AuthRegisterMemberRequested>(onMemberRegister);
    on<AuthRegisterAdminRequested>(onAdminRegister);
    on<AuthResetPasswordRequested>(onResetPassword);
    on<AuthPageChanged>(onPageChanged);
    on<AuthCheckSavedEmailRequested>(onCheckSavedEmail);
    on<AuthGoogleSignInRequested>(onGoogleSignIn);
  }

  String _getFriendlyErrorMessage(dynamic error) {
    const firebaseAuthMessages = {
      'invalid-verification-code':
          'Invalid verification code. Please try again.',
      'code-expired':
          'Verification code has expired. Please request a new one.',
      'credential-already-in-use':
          'This phone number is already linked to another account.',
      'provider-already-linked':
          'This phone number is already linked to your account.',
      'too-many-requests': 'Too many attempts. Please try again later.',
      'invalid-phone-number': 'The phone number entered is invalid.',
      'operation-not-allowed':
          'Phone authentication is not enabled on this project.',
    };

    const genericErrorMessages = {
      'user-not-found':
          'No account found with this email. Please sign up first.',
      'email not registered': 'Email not registered. Please sign up first.',
      'wrong-password': 'Invalid email or password. Please try again.',
      'invalid-credential': 'Invalid email or password. Please try again.',
      'auth credential is incorrect':
          'Invalid email or password. Please try again.',
      'too-many-requests': 'Too many failed attempts. Please try again later.',
      'user-disabled':
          'This account has been disabled. Please contact support.',
      'email-already-in-use':
          'This email is already registered. Please sign in instead.',
      'weak-password': 'Password is too weak. Please use a stronger password.',
      'invalid-email': 'Invalid email address. Please check and try again.',
      'network': 'Network error. Please check your connection and try again.',
      'user profile not found': 'User not found. Please complete registration.',
    };

    if (error is FirebaseAuthException) {
      return firebaseAuthMessages[error.code] ??
          error.message ??
          'Something went wrong. Please try again.';
    }

    final errorMessage = error.toString().toLowerCase();
    for (final entry in genericErrorMessages.entries) {
      if (errorMessage.contains(entry.key)) {
        return entry.value;
      }
    }

    return 'Something went wrong. Please try again.';
  }

  void onPageChanged(AuthPageChanged event, Emitter<AuthState> emit) {
    if (state is AuthFailure ||
        state is AuthRegisterFailure ||
        state is AuthRegisterSuccess ||
        state is AuthResetPasswordFailure ||
        state is AuthResetPasswordSuccess) {
      emit(AuthInitial(currentPage: event.page));
      return;
    }

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
      final savedEmail = (state as AuthUnauthenticated).savedEmail;
      emit(
        AuthUnauthenticated(currentPage: event.page, savedEmail: savedEmail),
      );
    } else {
      emit(AuthInitial(currentPage: event.page));
    }
  }

  Future<void> onAuthCheck(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await getCurrentUser();
    final savedEmail = await getSavedEmail();

    if (result == null) {
      emit(AuthUnauthenticated(savedEmail: savedEmail));
      return;
    }

    if (result.userType == UserType.admin) {
      emit(AuthAuthenticatedAsAdmin(result.userData as Admin));
    } else {
      emit(AuthAuthenticatedAsMember(result.userData as Member));
    }
  }

  Future<void> onCheckSavedEmail(
    AuthCheckSavedEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    final savedEmail = await getSavedEmail();
    emit(
      AuthUnauthenticated(
        savedEmail: savedEmail,
        currentPage: state.currentPage,
      ),
    );
  }

  Future<void> onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await signIn(event.email, event.password);

      if (event.rememberMe) {
        await saveEmail(event.email);
      } else {
        await saveEmail('');
      }

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
      final savedEmail = await getSavedEmail();
      emit(AuthUnauthenticated(savedEmail: savedEmail));
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
      final errorMessage = _getFriendlyErrorMessage(e);
      if (errorMessage == 'Email not registered. Please sign up first.') {
        emit(AuthFailure(errorMessage, currentPage: 1));
      } else {
        emit(AuthFailure(errorMessage));
      }
    }
  }
}
