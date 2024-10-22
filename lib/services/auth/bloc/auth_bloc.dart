import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import 'package:livit/constants/enums.dart';
import 'package:livit/services/auth/auth_exceptions.dart';
import 'package:livit/services/auth/auth_provider.dart';
import 'package:livit/services/auth/auth_user.dart';
import 'package:livit/services/auth/bloc/auth_event.dart';
import 'package:livit/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required AuthProvider provider,
  }) : super(const AuthStateUninitialized()) {
    on<AuthEventInitialize>(
      (event, emit) async {
        await provider.initialize();
        try {
          final AuthUser user = provider.currentUser;

          emit(AuthStateLoggedIn(user: user));
        } catch (e) {
          emit(
            const AuthStateLoggedOut(),
          );
        }
      },
    );

    on<AuthEventLogInWithEmailAndPassword>(
      (event, emit) async {
        emit(const AuthStateLoggedOut(
          loginMethod: LoginMethod.emailAndPassword,
        ));

        final email = event.email;
        final password = event.password;
        try {
          final user = await provider.logInWithEmailAndPassword(email: email, password: password);

          emit(AuthStateLoggedIn(user: user, userType: event.userType));
        } catch (e) {
          _emitError(emit, e as Exception);
        }
      },
    );

    on<AuthEventLogOut>(
      (event, emit) async {
        emit(const AuthStateLoggingOut());
        try {
          await provider.logOut();

          emit(const AuthStateLoggedOut());
        } catch (e) {
          _emitError(emit, e as Exception);
        }
      },
    );

    on<AuthEventSendOtpCode>(
      (event, emit) async {
        emit(AuthStateSendingCode(isResending: event.isResending));
        final phoneCode = event.phoneCode;
        final phoneNumber = event.phoneNumber;
        try {
          final completer = Completer<AuthState>();
          await provider.sendOtpCode(
            onVerificationCompleted: (credential) {
              print('onVerificationCompleted but not implemented');

              completer.complete(const AuthStateLoggedOut());
            },
            onVerificationFailed: (error) {
              final errorM = error as FirebaseAuthException;
              switch (errorM.code) {
                case 'invalid-phone-number':
                  completer.complete(AuthStateCodeSentError(
                    exception: InvalidPhoneNumberAuthException(),
                  ));
                  break;
                default:
                  print(error);
                  completer.complete(AuthStateCodeSentError(
                    exception: GenericAuthException(),
                  ));
                  break;
              }
            },
            onCodeSent: (String verificationId, int? forceResendingToken) {
              completer.complete(AuthStateCodeSent(verificationId: verificationId));
            },
            phoneCode: phoneCode,
            phoneNumber: phoneNumber,
            onCodeAutoRetrievalTimeout: (verificationId) {
              print('onCodeAutoRetrievalTimeout but not implemented');
              if (!completer.isCompleted) {
                completer.complete(const AuthStateLoggedOut());
              }
            },
          );
          final result = await completer.future;
          emit(result);
        } catch (e) {
          _emitError(emit, e as Exception);
        }
      },
    );

    on<AuthEventLogInWithGoogle>(
      (event, emit) async {
        emit(const AuthStateLoggedOut(
          loginMethod: LoginMethod.google,
        ));
        try {
          await provider.logInWithGoogle();
          final user = provider.currentUser;

          emit(AuthStateLoggedIn(user: user, userType: event.userType));
        } catch (e) {
          _emitError(emit, e as Exception);
        }
      },
    );

    on<AuthEventLogInWithPhoneAndOtp>(
      (event, emit) async {
        emit(const AuthStateLoggedOut(
          loginMethod: LoginMethod.phoneAndOtp,
        ));
        await Future.delayed(const Duration(seconds: 5));
        final verificationId = event.verificationId;
        final otpCode = event.otpCode;
        try {
          final user = await provider.logInWithPhoneAndOtp(
            verificationId: verificationId,
            otpCode: otpCode,
          );

          emit(AuthStateLoggedIn(user: user, userType: event.userType));
        } catch (e) {
          _emitError(emit, e as Exception);
        }
      },
    );

    on<AuthEventSendEmailVerification>(
      (event, emit) async {
        emit(const AuthStateEmailVerificationSending());
        try {
          await provider.sendEmailVerification();
          emit(const AuthStateEmailVerificationSent());
        } catch (e) {
          emit(AuthStateEmailVerificationSentError(exception: e as Exception));
        }
      },
    );

    on<AuthEventRegister>(
      (event, emit) async {
        emit(const AuthStateRegistering());
        final email = event.email;
        final password = event.password;
        try {
          await provider.registerEmail(email: email, password: password);
          emit(const AuthStateRegistered());
        } catch (e) {
          emit(AuthStateRegisterError(exception: e as Exception));
        }
      },
    );

    on<AuthEventSendPasswordReset>(
      (event, emit) async {
        emit(const AuthStateSendingPasswordReset());
        final email = event.email;
        try {
          await provider.sendPasswordReset(email: email);
          emit(const AuthStatePasswordResetSent());
        } catch (e) {
          emit(AuthStatePasswordResetSentError(exception: e as Exception));
        }
      },
    );
  }

  void _emitError(emit, Exception e) {
    emit(AuthStateLoggedOut(
      exception: e,
    ));
  }
}
