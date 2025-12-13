import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:myfin/features/authentication/domain/entities/admin.dart';
import 'package:myfin/features/authentication/domain/entities/member.dart';
import 'package:myfin/features/authentication/domain/usecases/get_current_user_usecase.dart';
import 'package:myfin/features/authentication/domain/usecases/sign_in_usecase.dart';
import 'package:myfin/features/authentication/domain/usecases/sign_out_usecase.dart';
import 'package:myfin/features/authentication/domain/usecases/sign_up_usecase.dart';
import 'package:myfin/features/authentication/domain/usecases/reset_password_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signIn;
  final SignUpUseCase signUp;
  final GetCurrentUserUseCase getCurrentUser;
  final SignOutUseCase signOut;
  final ResetPasswordUseCase resetPassword;

  AuthBloc({
    required this.signIn,
    required this.signUp,
    required this.getCurrentUser,
    required this.signOut,
    required this.resetPassword,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(onAuthCheck);
    on<AuthLoginRequested>(onLogin);
    on<AuthLogoutRequested>(onLogout);
    on<AuthRegisterMemberRequested>(onMemberRegister);
    on<AuthRegisterAdminRequested>(onAdminRegister);
    on<AuthResetPasswordRequested>(onResetPassword);
    on<AuthPageChanged>(onPageChanged);
  }

  void onPageChanged(AuthPageChanged event, Emitter<AuthState> emit) {
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
    } else if (state is AuthFailure) {
      emit(
        AuthFailure((state as AuthFailure).message, currentPage: event.page),
      );
    } else if (state is AuthRegisterSuccess) {
      emit(
        AuthRegisterSuccess(
          (state as AuthRegisterSuccess).message,
          currentPage: event.page,
        ),
      );
    } else if (state is AuthRegisterFailure) {
      emit(
        AuthRegisterFailure(
          (state as AuthRegisterFailure).message,
          currentPage: event.page,
        ),
      );
    } else {
      emit(AuthUnauthenticated(currentPage: event.page));
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
      emit(AuthFailure(e.toString()));
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
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> onMemberRegister(
    AuthRegisterMemberRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await signUp.signUpMember(
        email: event.email,
        password: event.password,
        username: event.username,
        firstName: event.first_name,
        lastName: event.last_name,
        phoneNumber: event.phone_number,
        address: event.address,
      );

      emit(AuthRegisterSuccess('Member registered successfully'));
      emit(AuthAuthenticatedAsMember(result.userData as Member));
    } catch (e) {
      emit(AuthRegisterFailure(e.toString()));
    }
  }

  Future<void> onAdminRegister(
    AuthRegisterAdminRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await signUp.signUpAdmin(
        email: event.email,
        password: event.password,
        username: event.username,
        firstName: event.first_name,
        lastName: event.last_name,
      );

      emit(AuthRegisterSuccess('Admin registered successfully'));
      emit(AuthAuthenticatedAsAdmin(result.userData as Admin));
    } catch (e) {
      emit(AuthRegisterFailure(e.toString()));
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
      emit(AuthFailure(e.toString()));
    }
  }
}
