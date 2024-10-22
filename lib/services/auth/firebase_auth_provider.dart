// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:livit/firebase_options.dart';
import 'package:livit/services/auth/auth_user.dart';
import 'package:livit/services/auth/auth_exceptions.dart';
import 'package:livit/services/auth/auth_provider.dart';

import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseAuthException, GoogleAuthProvider, PhoneAuthCredential, PhoneAuthProvider;

class FirebaseAuthProvider implements AuthProvider {
  @override
  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // try {
    //   FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    //   FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
    //   await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    // } catch (e) {
    //   // ignore: avoid_print
    //   print(e);
    // }
  }

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
        throw GenericAuthException();
      }
      await sendEmailVerification();
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
    } on GenericAuthException {
      rethrow;
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  AuthUser get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw UserNotLoggedInAuthException();
    }
    if (user.phoneNumber != null) {
      return AuthUser.fromFirebase(user);
    } else if (user.email != null) {
      if (!user.emailVerified) {
        throw NotVerifiedEmailAuthException();
      } else {
        return AuthUser.fromFirebase(user);
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
        try {
          await user.sendEmailVerification();
        } on FirebaseAuthException catch (e) {
          if (e.code == 'too-many-requests') {
            throw TooManyRequestsAuthException();
          } else {
            throw GenericAuthException();
          }
        }
      }
    } else {
      throw UserNotLoggedInAuthException();
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
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      return user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-credential':
          throw InvalidCredentialsAuthException();
        case 'network-request-failed':
          throw NetworkRequesFailed();
        case 'too-many-requests':
          throw TooManyRequestsAuthException();
        default:
          throw GenericAuthException();
      }
    } on GenericAuthException {
      rethrow;
    } on UserNotLoggedInAuthException {
      rethrow;
    } on NotVerifiedEmailAuthException {
      rethrow;
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
  Future<void> sendPasswordReset({required String email}) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'network-request-failed':
          throw NetworkRequesFailed();
        default:
          throw GenericAuthException();
      }
    } catch (e) {
      throw GenericAuthException();
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
        throw InvalidVerificationCodeAuthException();
      } else if (e.code == 'network-request-failed') {
        throw NetworkRequesFailed();
      } else {
        throw GenericAuthException();
      }
    } catch (e) {
      throw GenericAuthException();
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
