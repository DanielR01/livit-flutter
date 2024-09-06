import 'package:flutter/foundation.dart' show immutable;

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}

class AuthEventLogInWithEmailAndPassword extends AuthEvent {
  final String email;
  final String password;
  const AuthEventLogInWithEmailAndPassword({required this.email, required this.password});
}

class AuthEventLogInWithGoogle extends AuthEvent {
  const AuthEventLogInWithGoogle();
}

class AuthEventLogInWithPhoneNumber extends AuthEvent {
  final String verificationId;
  final String smsCode;
  const AuthEventLogInWithPhoneNumber({
    required this.verificationId,
    required this.smsCode,
  });
}

class AuthEventLogOut extends AuthEvent {
  const AuthEventLogOut();
}

class AuthEventSendEmailVerification extends AuthEvent {
  final String email;
  const AuthEventSendEmailVerification({required this.email});
}

class AuthEventRegister extends AuthEvent {
  final String email;
  final String password;
  const AuthEventRegister({required this.email, required this.password});
} 