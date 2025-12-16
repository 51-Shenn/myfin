part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  final int currentPage;
  const AuthState({this.currentPage = 0});

  @override
  List<Object> get props => [currentPage];
}

final class AuthInitial extends AuthState {
  const AuthInitial({super.currentPage = 0});
}

final class AuthLoading extends AuthState {
  const AuthLoading({super.currentPage});
}

final class AuthAuthenticatedAsMember extends AuthState {
  final Member member;
  const AuthAuthenticatedAsMember(this.member, {super.currentPage});
  @override
  List<Object> get props => [member, currentPage];
}

final class AuthAuthenticatedAsAdmin extends AuthState {
  final Admin admin;
  const AuthAuthenticatedAsAdmin(this.admin, {super.currentPage});
  @override
  List<Object> get props => [admin, currentPage];
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated({super.currentPage = 0});
}

final class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message, {super.currentPage});
  @override
  List<Object> get props => [message, currentPage];
}

final class AuthRegisterSuccess extends AuthState {
  final String message;
  const AuthRegisterSuccess(this.message, {super.currentPage});
  @override
  List<Object> get props => [message, currentPage];
}

final class AuthRegisterFailure extends AuthState {
  final String message;
  const AuthRegisterFailure(this.message, {super.currentPage});
  @override
  List<Object> get props => [message, currentPage];
}

final class AuthResetPasswordSuccess extends AuthState {
  final String message;
  const AuthResetPasswordSuccess(this.message, {super.currentPage});
  @override
  List<Object> get props => [message, currentPage];
}

final class AuthResetPasswordFailure extends AuthState {
  final String message;
  const AuthResetPasswordFailure(this.message, {super.currentPage});
  @override
  List<Object> get props => [message, currentPage];
}

// Phone authentication state
final class AuthPhoneCodeSent extends AuthState {
  final String verificationId;
  final String phoneNumber;
  const AuthPhoneCodeSent(
    this.verificationId,
    this.phoneNumber, {
    super.currentPage,
  });
  @override
  List<Object> get props => [verificationId, phoneNumber, currentPage];
}

void showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
}
