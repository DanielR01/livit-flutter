import 'package:livit/services/auth/auth_user.dart';

abstract class AuthProvider {
  AuthUser get currentUser;

  Future<AuthUser> logInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<AuthUser> logInWithCredential({
    required credential,
  });

  Future<void> registerEmail({
    required String email,
    required String password,
  });

  Future<void> logOut();

  Future<void> sendEmailVerification();

  Future<void> sendOtpCode({
    required String phoneCode,
    required String phoneNumber,
    required void Function(dynamic) onVerificationCompleted,
    required void Function(dynamic) onVerificationFailed,
    required void Function(String, int?) onCodeSent,
    required void Function(String) onCodeAutoRetrievalTimeout,
  });

  Future<void> sendPasswordReset({required String email});

  Future<AuthUser> logInWithPhoneAndOtp({required String verificationId, required String otpCode}); 

  Future<void> logInWithGoogle();
}
