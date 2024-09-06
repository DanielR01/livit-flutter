import 'package:flutter/foundation.dart' show immutable;
import 'package:livit/services/auth/auth_user.dart';

@immutable
abstract class AuthState {
  const AuthState();
}

class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

class AuthStateLoggedIn extends AuthState {
  final AuthUser user;
  const AuthStateLoggedIn({required this.user});
}

class AuthStateError extends AuthState {
  final Exception exception;
  const AuthStateError({required this.exception});
}

class AuthStateLoggedOut extends AuthState {
  const AuthStateLoggedOut();
}

class AuthStateLogoutError extends AuthState {
  final Exception exception;
  const AuthStateLogoutError({required this.exception});
}

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification();
}

class AuthStateCodeSent extends AuthState {
  final String verificationId;
  final int? forceResendingToken;
  const AuthStateCodeSent({required this.verificationId, this.forceResendingToken});
}
