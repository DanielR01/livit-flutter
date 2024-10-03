import 'package:flutter/foundation.dart' show immutable;
import 'package:livit/constants/enums.dart';

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
  final UserType userType;
  const AuthEventLogInWithEmailAndPassword({
    required this.email,
    required this.password,
    required this.userType,
  });
}

class AuthEventLogInWithGoogle extends AuthEvent {
  final UserType userType;
  const AuthEventLogInWithGoogle({required this.userType});
}

class AuthEventSendOtpCode extends AuthEvent {
  final String phoneCode;
  final String phoneNumber;
  final bool isResending;
  const AuthEventSendOtpCode({
    required this.phoneCode,
    required this.phoneNumber,
    required this.isResending
  });
}

class AuthEventLogInWithPhoneAndOtp extends AuthEvent {
  final String verificationId;
  final String otpCode;
  final UserType userType;
  const AuthEventLogInWithPhoneAndOtp({
    required this.verificationId,
    required this.otpCode,
    required this.userType,
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

class AuthEventSendPasswordReset extends AuthEvent {
  final String email;
  const AuthEventSendPasswordReset({required this.email});
}
