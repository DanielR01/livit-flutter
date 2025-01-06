import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:livit/constants/enums.dart';
import 'package:livit/services/auth/auth_exceptions.dart';
import 'package:livit/services/auth/auth_user.dart';

@immutable
abstract class AuthState {
  const AuthState();
}

class AuthStateUninitialized extends AuthState {
  const AuthStateUninitialized();
}

class AuthStateLoggedIn extends AuthState {
  final AuthUser user;
  final UserType? userType;
  const AuthStateLoggedIn({required this.user, this.userType});
}

class AuthStateLoggingOut extends AuthState {
  const AuthStateLoggingOut();
}

class AuthStateLoggedOut extends AuthState with EquatableMixin {
  final AuthException? exception;
  final LoginMethod? loginMethod;
  const AuthStateLoggedOut({this.exception, this.loginMethod});

  @override
  List<Object?> get props => [exception, loginMethod];
}

class AuthStateRegistering extends AuthState {
  const AuthStateRegistering();
}

class AuthStateRegistered extends AuthState {
  const AuthStateRegistered();
}

class AuthStateRegisterError extends AuthState {
  final AuthException exception;
  const AuthStateRegisterError({required this.exception});
}

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification();
}

class AuthStateSendingCode extends AuthState {
  final bool isResending;
  const AuthStateSendingCode({required this.isResending});
}

class AuthStateCodeSent extends AuthState {
  final String verificationId;
  final int? forceResendingToken;
  const AuthStateCodeSent({required this.verificationId, this.forceResendingToken});
}

class AuthStateCodeSentError extends AuthState {
  final AuthException exception;
  const AuthStateCodeSentError({required this.exception});
}

class AuthStateEmailVerificationSending extends AuthState {
  const AuthStateEmailVerificationSending();
}

class AuthStateEmailVerificationSent extends AuthState {
  const AuthStateEmailVerificationSent();
}

class AuthStateEmailVerificationSentError extends AuthState {
  final AuthException exception;
  const AuthStateEmailVerificationSentError({required this.exception});
}

class AuthStateSendingPasswordReset extends AuthState {
  const AuthStateSendingPasswordReset();
}

class AuthStatePasswordResetSent extends AuthState {
  const AuthStatePasswordResetSent();
}

class AuthStatePasswordResetSentError extends AuthState {
  final AuthException exception;
  const AuthStatePasswordResetSentError({required this.exception});
}
