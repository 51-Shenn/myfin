part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

final class AuthCheckRequested extends AuthEvent {}

final class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

final class AuthLogoutRequested extends AuthEvent {
}

final class AuthRegisterMemberRequested extends AuthEvent {
  final String username;
  final String first_name;
  final String last_name;
  final String email;
  final String password;
  final String phone_number;
  final String address;

  const AuthRegisterMemberRequested(
    this.username,
    this.first_name,
    this.last_name,
    this.email,
    this.password,
    this.phone_number,
    this.address,
  );

  @override
  List<Object> get props => [
    username,
    first_name,
    last_name,
    email,
    password,
    phone_number,
    address,
  ];
}

final class AuthRegisterAdminRequested extends AuthEvent {
  final String username;
  final String first_name;
  final String last_name;
  final String email;
  final String password;

  const AuthRegisterAdminRequested(
    this.username,
    this.first_name,
    this.last_name,
    this.email,
    this.password,
  );

  @override
  List<Object> get props => [
    username,
    first_name,
    last_name,
    email,
    password,
  ];
}

final class AuthResetPasswordRequested extends AuthEvent {
  final String email;

  const AuthResetPasswordRequested(this.email);

  @override
  List<Object> get props => [email];
}
