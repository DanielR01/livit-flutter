import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/material.dart';
import 'package:livit/constants/enums.dart';

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}

class AuthEventLogInWithEmailAndPassword extends AuthEvent {
  final BuildContext context;
  final String email;
  final String password;
  final UserType userType;
  const AuthEventLogInWithEmailAndPassword(
    this.context, {
    required this.email,
    required this.password,
    required this.userType,
  });
}

class AuthEventLogInWithGoogle extends AuthEvent {
  final BuildContext context;
  final UserType userType;
  const AuthEventLogInWithGoogle(this.context, {required this.userType});
}

class AuthEventSendOtpCode extends AuthEvent {
  final BuildContext context;
  final String phoneCode;
  final String phoneNumber;
  final bool isResending;
  const AuthEventSendOtpCode(this.context, {required this.phoneCode, required this.phoneNumber, required this.isResending});
}

class AuthEventLogInWithPhoneAndOtp extends AuthEvent {
  final BuildContext context;
  final String verificationId;
  final String otpCode;
  final UserType userType;
  const AuthEventLogInWithPhoneAndOtp(this.context, {
    required this.verificationId,
    required this.otpCode,
    required this.userType,
  });
}

class AuthEventLogOut extends AuthEvent {
  final BuildContext context;
  const AuthEventLogOut(this.context);
}

class AuthEventSendEmailVerification extends AuthEvent {
  final BuildContext context;
  final String email;
  const AuthEventSendEmailVerification(this.context, {required this.email});
}

class AuthEventRegister extends AuthEvent {
  final BuildContext context;
  final String email;
  final String password;
  const AuthEventRegister(this.context, {required this.email, required this.password});
}

class AuthEventSendPasswordReset extends AuthEvent {
  final BuildContext context;
  final String email;
  const AuthEventSendPasswordReset(this.context, {required this.email});
}
