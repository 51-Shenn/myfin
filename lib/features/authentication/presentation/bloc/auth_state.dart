part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthAuthenticatedAsMember extends AuthState {
  final Member member;
  const AuthAuthenticatedAsMember(this.member);
  @override
  List<Object> get props => [member];
}

final class AuthAuthenticatedAsAdmin extends AuthState {
  final Admin admin;
  const AuthAuthenticatedAsAdmin(this.admin);
  @override
  List<Object> get props => [admin];
}

final class AuthUnauthenticated extends AuthState {}

final class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object> get props => [message];
}

final class AuthRegisterSuccess extends AuthState {
  final String message;

  const AuthRegisterSuccess(this.message);

  @override
  List<Object> get props => [message];
}

final class AuthRegisterFailure extends AuthState {
  final String message;

  const AuthRegisterFailure(this.message);

  @override
  List<Object> get props => [message];
}

final class AuthResetPasswordSuccess extends AuthState {
  final String message;

  const AuthResetPasswordSuccess(this.message);

  @override
  List<Object> get props => [message];
}

final class AuthResetPasswordFailure extends AuthState {
  final String message;

  const AuthResetPasswordFailure(this.message);

  @override
  List<Object> get props => [message];
}

