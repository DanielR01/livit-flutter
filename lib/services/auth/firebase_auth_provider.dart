import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:livit/services/auth/credential_types.dart';
import 'package:livit/firebase_options.dart';
import 'package:livit/services/auth/auth_user.dart';
import 'package:livit/services/auth/auth_exceptions.dart';
import 'package:livit/services/auth/auth_provider.dart';

import 'package:firebase_auth/firebase_auth.dart'
    show
        FirebaseAuth,
        FirebaseAuthException,
        GoogleAuthProvider,
        PhoneAuthCredential,
        PhoneAuthProvider;

class FirebaseAuthProvider implements AuthProvider {
  @override
  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

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
          sendEmailVerification();
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
    if (user == null) {
      return null;
    } else {
      if (user.email != null && !user.emailVerified) {
        return AuthUser.notVerifiedEmailFromFirebase(user);
      }
    }
    return AuthUser.fromFirebase(user);
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
  Future<void> sendOtpCode(
    String phoneCode,
    String phoneNumber,
    ValueChanged<List> onUpdate,
  ) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+$phoneCode $phoneNumber',
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
      },
      verificationFailed: (error) {
        onUpdate([false, error.code]);
      },
      codeSent: (verificationId, forceResendingToken) {
        onUpdate([
          true,
          verificationId,
        ]);
      },
      codeAutoRetrievalTimeout: (verificationId) {},
    );
  }

  @override
  Future<AuthUser> logIn({
    required CredentialType credentialType,
    List<String>? credentials,
  }) async {
    try {
      switch (credentialType) {
        case CredentialType.emailAndPassword:
          if (credentials != null) {
            await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: credentials[0],
              password: credentials[1],
            );
          }
          break;
        case CredentialType.phoneAndOtp:
          if (credentials != null) {
            String verificationId = credentials[0];
            String otpCode = credentials[1];
            await signInWithPhoneNumber(verificationId, otpCode);
          }
          break;
        case CredentialType.google:
          await signInWithGoogle();
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
        case "invalid-credential":
          throw InvalidCredentialsAuthException();
        case "too-many-requests":
          throw TooManyRequestsAuthException();
        case "invalid-verification-code":
          throw InvalidVerificationCodeAuthException();
        default:
          throw GenericAuthException();
      }
    } on UserNotLoggedInAuthException {
      throw UserNotLoggedInAuthException();
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

  @override
  Future<void> sendPasswordReset(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }
}

Future<void> signInWithGoogle() async {
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;
  if (googleUser == null) {
    return;
  }

  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  await FirebaseAuth.instance.signInWithCredential(credential);
}

Future<void> signInWithPhoneNumber(
    String verificationId, String otpCode) async {
  PhoneAuthCredential credential = PhoneAuthProvider.credential(
    verificationId: verificationId,
    smsCode: otpCode,
  );

  await FirebaseAuth.instance.signInWithCredential(credential);
}
