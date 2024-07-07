import 'package:livit/enums/credential_types.dart';
import 'package:livit/services/auth/auth_user.dart';

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
