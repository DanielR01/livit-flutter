import 'package:livit/enums/credential_types.dart';
import 'package:livit/services/auth/auth_user.dart';
import 'package:livit/services/auth/auth_exceptions.dart';
import 'package:livit/services/auth/auth_provider.dart';

import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseAuthException;

class FirebaseAuthProvider implements AuthProvider {
  @override
  Future<AuthUser> createUser({
    required CredentialType credentialType,
    required List<String> credentials,
  }) async {
    try {
      switch (credentialType) {
        case CredentialType.emailAndPassword:
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: credentials[0],
            password: credentials[1],
          );

        default:
          throw GenericAuthException();
      }
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (error) {
      switch (error.code) {
        case "weak-password":
          throw WeakPasswordAuthException();
        case "email-already-in-use":
          throw EmailAlreadyInUseAuthException();
        case "invalid-email":
          throw InvalidEmailAuthException();
        default:
          throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (user.emailVerified) {
        throw EmailAlreadyVerified();
      } else {
        await user.sendEmailVerification();
      }
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<AuthUser> logIn({
    required CredentialType credentialType,
    required List<String> credentials,
  }) async {
    try {
      switch (credentialType) {
        case CredentialType.emailAndPassword:
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: credentials[0],
            password: credentials[1],
          );
          break;
        default:
          throw GenericAuthException();
      }
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (error) {
      switch (error.code) {
        case "user-not-found":
          throw UserNotFoundAuthException();
        case "wrong-password":
          throw WrongPasswordAuthException();
        case "too-many-requests":
          throw TooManyRequestsAuthException();
        default:
          throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  Future<void> logOut() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseAuth.instance.signOut();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }
}
