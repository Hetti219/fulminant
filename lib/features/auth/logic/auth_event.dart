part of 'auth_bloc.dart';

abstract class AuthEvent {}

class AuthSignUpRequested extends AuthEvent {
  final String email, password, name;
  DateTime dob;

  AuthSignUpRequested(this.email, this.password, this.name, this.dob);
}

class AuthLoginRequested extends AuthEvent {
  final String email, password;

  AuthLoginRequested(this.email, this.password);
}

class AuthLogoutRequested extends AuthEvent {}
