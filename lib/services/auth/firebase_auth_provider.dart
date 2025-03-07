// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:livit/constants/enums.dart';
import 'package:livit/services/auth/auth_user.dart';
import 'package:livit/services/auth/auth_exceptions.dart';
import 'package:livit/services/auth/auth_provider.dart';

import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseAuthException, GoogleAuthProvider, PhoneAuthCredential, PhoneAuthProvider;

class FirebaseAuthProvider implements AuthProvider {
  @override
  Future<void> registerEmail({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw GenericAuthException(details: 'User is null after registration');
      }
      await sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "weak-password":
          throw WeakPasswordAuthException(details: e.message);
        case "email-already-in-use":
          throw EmailAlreadyInUseAuthException(details: e.message);
        case "invalid-email":
          throw InvalidEmailAuthException(details: e.message);
        default:
          throw GenericAuthException(details: '${e.code}: ${e.message}');
      }
    } catch (e) {
      throw GenericAuthException(details: e.toString());
    }
  }

  @override
  Future<AuthUser> get currentUser async {
    final user = FirebaseAuth.instance.currentUser;
    final idTokenResult = await user?.getIdTokenResult();
    final String? userTypeString = idTokenResult?.claims?['userType'] as String?;
    final UserType? userType = userTypeString != null ? UserType.values.byName(userTypeString) : null;

    if (user == null) {
      throw UserNotLoggedInAuthException(details: 'No current user found');
    }
    if (user.phoneNumber != null) {
      return AuthUser.fromFirebase(user, userType);
    } else if (user.email != null) {
      if (!user.emailVerified) {
        throw NotVerifiedEmailAuthException(details: 'Email ${user.email} not verified');
      }
      return AuthUser.fromFirebase(user, userType);
    }
    return AuthUser.fromFirebase(user, userType);
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw UserNotLoggedInAuthException(details: 'Cannot send verification to null user');
    }
    if (user.emailVerified) {
      throw EmailAlreadyVerifiedException(details: 'Email ${user.email} already verified');
    }

    try {
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'too-many-requests') {
        throw TooManyRequestsAuthException(details: e.message);
      }
      throw GenericAuthException(details: '${e.code}: ${e.message}');
    }
  }

  @override
  Future<void> sendOtpCode({
    required String phoneCode,
    required String phoneNumber,
    required void Function(PhoneAuthCredential) onVerificationCompleted,
    required void Function(FirebaseAuthException) onVerificationFailed,
    required void Function(String, int?) onCodeSent,
    required void Function(String) onCodeAutoRetrievalTimeout,
  }) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+$phoneCode $phoneNumber',
      verificationCompleted: onVerificationCompleted,
      verificationFailed: onVerificationFailed,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
    );
  }

  @override
  Future<AuthUser> logInWithCredential({
    required dynamic credential,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithCredential(credential as PhoneAuthCredential);
      final user = currentUser;
      return user;
    } on UserNotLoggedInAuthException {
      rethrow;
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  Future<AuthUser> logInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔑 [FirebaseAuthProvider] Logging in with email and password: $email, $password');
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('✅ [FirebaseAuthProvider] Login successful, current user: ${(await currentUser).id}');
      return await currentUser;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ [FirebaseAuthProvider] Login failed: ${e.code}');
      switch (e.code) {
        case 'invalid-credential':
          throw InvalidCredentialsAuthException(details: e.message);
        case 'network-request-failed':
          throw NetworkRequestFailedAuthException(details: e.message);
        case 'too-many-requests':
          throw TooManyRequestsAuthException(details: e.message);
        default:
          throw GenericAuthException(details: '${e.code}: ${e.message}');
      }
    } on AuthException {
      rethrow;
    } catch (e) {
      throw GenericAuthException(details: e.toString());
    }
  }

  @override
  Future<void> logOut() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw UserNotLoggedInAuthException(details: 'Cannot logout null user');
    }
    await FirebaseAuth.instance.signOut();
  }

  @override
  Future<void> sendPasswordReset({required String email}) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'network-request-failed':
          throw NetworkRequestFailedAuthException(details: e.message);
        default:
          throw GenericAuthException(details: '${e.code}: ${e.message}');
      }
    } catch (e) {
      throw GenericAuthException(details: e.toString());
    }
  }

  @override
  Future<AuthUser> logInWithPhoneAndOtp({required String verificationId, required String otpCode}) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpCode,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      final user = currentUser;
      return user;
    } on UserNotLoggedInAuthException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        throw InvalidVerificationCodeAuthException(details: e.message);
      } else if (e.code == 'network-request-failed') {
        throw NetworkRequestFailedAuthException(details: e.message);
      } else {
        throw GenericAuthException(details: '${e.code}: ${e.message}');
      }
    } catch (e) {
      throw GenericAuthException(details: e.toString());
    }
  }

  @override
  Future<void> logInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    if (googleUser == null) {
      return;
    }

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
