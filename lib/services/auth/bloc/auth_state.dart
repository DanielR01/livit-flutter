import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
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
  const AuthStateLoggedIn({required this.user});
}

class AuthStateLoggingOut extends AuthState {
  const AuthStateLoggingOut();
}

class AuthStateLoggedOut extends AuthState with EquatableMixin {
  final Exception? exception;
  final bool isLoggingInWithEmailAndPassword;
  final bool isLoggingInWithGoogle;
  final bool isLoggingIngWithPhoneAndOtp;
  const AuthStateLoggedOut(
      {this.exception,
      required this.isLoggingInWithEmailAndPassword,
      required this.isLoggingInWithGoogle,
      required this.isLoggingIngWithPhoneAndOtp});

  @override
  List<Object?> get props => [exception, isLoggingInWithEmailAndPassword, isLoggingInWithGoogle, isLoggingIngWithPhoneAndOtp];
}

class AuthStateRegistering extends AuthState {
  const AuthStateRegistering();
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

class AuthStateSendingCode extends AuthState {
  const AuthStateSendingCode();
}

class AuthStateCodeSent extends AuthState {
  final String verificationId;
  final int? forceResendingToken;
  const AuthStateCodeSent({required this.verificationId, this.forceResendingToken});
}

class AuthStateCodeSentError extends AuthState {
  final Exception exception;
  const AuthStateCodeSentError({required this.exception});
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

class AuthStateSendingPasswordReset extends AuthState {
  const AuthStateSendingPasswordReset();
}

class AuthStatePasswordResetSent extends AuthState {
  const AuthStatePasswordResetSent();
}

class AuthStatePasswordResetSentError extends AuthState {
  final Exception exception;
  const AuthStatePasswordResetSentError({required this.exception});
}
