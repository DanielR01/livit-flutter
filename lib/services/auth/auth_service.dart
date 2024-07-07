import 'package:livit/services/auth/auth_provider.dart';
import 'package:livit/services/auth/auth_user.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;
  const AuthService(this.provider);

  @override
  Future<AuthUser> createUser({
    required CredentialType credentialType,
    required List<String> credentials,
  }) =>
      provider.createUser(
          credentialType: credentialType, credentials: credentials);

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<AuthUser> logIn({
    required CredentialType credentialType,
    required List<String> credentials,
  }) =>
      provider.logIn(credentialType: credentialType, credentials: credentials);

  @override
  Future<void> logOut() => provider.logOut();

  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();
}
