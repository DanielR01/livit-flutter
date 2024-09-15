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

class AuthStateLoggedOut extends AuthState {
  final Exception? exception;
  const AuthStateLoggedOut({this.exception});
}

class AuthStateRegistered extends AuthState {
  const AuthStateRegistered();
}

class AuthStateRegisterError extends AuthState {
  final Exception exception;
  const AuthStateRegisterError({required this.exception});
}

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification();
}

class AuthStateCodeSent extends AuthState {
  final String verificationId;
  final int? forceResendingToken;
  const AuthStateCodeSent({required this.verificationId, this.forceResendingToken});
}

class AuthStateEmailVerificationSending extends AuthState {
  const AuthStateEmailVerificationSending();
}

class AuthStateEmailVerificationSent extends AuthState {
  const AuthStateEmailVerificationSent();
}

class AuthStateEmailVerificationSentError extends AuthState {
  final Exception exception;
  const AuthStateEmailVerificationSentError({required this.exception});
}
