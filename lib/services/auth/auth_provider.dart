import 'package:livit/services/auth/auth_user.dart';

enum CredentialType {
  emailAndPassword,
  otp,
  google,
  apple,
}

abstract class AuthProvider {
  AuthUser? get currentUser;
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
}
