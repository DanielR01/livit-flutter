import 'package:flutter/material.dart';
import 'package:livit/services/auth/credential_types.dart';
import 'package:livit/services/auth/auth_provider.dart';
import 'package:livit/services/auth/auth_user.dart';
import 'package:livit/services/auth/firebase_auth_provider.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;
  const AuthService(this.provider);

  factory AuthService.firebase() => AuthService(
        FirebaseAuthProvider(),
      );

  @override
  Future<void> initialize() => provider.initialize();

  @override
  Future<void> registerEmail({
    required Map<String, String> credentials,
  }) =>
      provider.registerEmail(
          credentials: credentials);

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<AuthUser> logIn({
    required CredentialType credentialType,
    required List<String> credentials,
  }) =>
      provider.logIn(credentialType: credentialType, credentials: credentials);

  @override
  Future<AuthUser> logInWithEmailAndPassword({
    required String email,
    required String password,
  }) =>
      provider.logInWithEmailAndPassword(email: email, password: password);

  @override
  Future<void> logOut() => provider.logOut();

  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();

  @override
  Future<void> sendOtpCode(
          String phoneCode, String phoneNumber, ValueChanged<Map<String, dynamic>> onUpdate) =>
      provider.sendOtpCode(phoneCode, phoneNumber, onUpdate);

  @override
  Future<void> sendPasswordReset(String email) =>
      provider.sendPasswordReset(email);
}
