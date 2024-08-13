import 'package:flutter/material.dart';
import 'package:livit/services/auth/credential_types.dart';
import 'package:livit/services/auth/auth_user.dart';

abstract class AuthProvider {
  AuthUser? get currentUser;

  Future<void> initialize();

  Future<AuthUser> logIn({
    required CredentialType credentialType,
    required List<String> credentials,
  });

  Future<AuthUser> createUser({
    required CredentialType credentialType,
    required List<String> credentials,
  });

  Future<void> logOut();

  Future<void> sendEmailVerification();

  Future<void> sendOtpCode(
      String phoneCode, String phoneNumber, ValueChanged<List> onUpdate);

  Future<void> sendPasswordReset(String email);
}
