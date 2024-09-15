import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import 'package:livit/services/auth/auth_exceptions.dart';
import 'package:livit/services/auth/auth_provider.dart';
import 'package:livit/services/auth/auth_user.dart';
import 'package:livit/services/auth/bloc/auth_event.dart';
import 'package:livit/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthProvider provider}) : super(const AuthStateLoading()) {
    on<AuthEventInitialize>(
      (event, emit) async {
        await provider.initialize();
        try {
          final AuthUser user = provider.currentUser;
          emit(AuthStateLoggedIn(user: user));
        } catch (e) {
          emit(const AuthStateLoggedOut());
        }
      },
    );

    on<AuthEventLogInWithEmailAndPassword>(
      (event, emit) async {
        emit(const AuthStateLoading());
        final email = event.email;
        final password = event.password;
        try {
          final user = await provider.logInWithEmailAndPassword(email: email, password: password);
          emit(AuthStateLoggedIn(user: user));
        } catch (e) {
          emit(AuthStateLoggedOut(exception: e as Exception));
        }
      },
    );

    on<AuthEventLogOut>(
      (event, emit) async {
        emit(const AuthStateLoading());
        try {
          await provider.logOut();
          emit(const AuthStateLoggedOut());
        } catch (e) {
          emit(AuthStateLoggedOut(exception: e as Exception));
        }
      },
    );

    on<AuthEventSendOtpCode>(
      (event, emit) async {
        emit(const AuthStateLoading());
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
                  completer.complete(AuthStateLoggedOut(exception: InvalidPhoneNumberAuthException()));
                  break;
                default:
                  completer.complete(AuthStateLoggedOut(exception: GenericAuthException()));
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
          emit(AuthStateLoggedOut(exception: e as Exception));
        }
      },
    );

    on<AuthEventLogInWithGoogle>(
      (event, emit) async {
        emit(const AuthStateLoading());
        try {
          await provider.logInWithGoogle();
          final user = provider.currentUser;
          emit(AuthStateLoggedIn(user: user));
        } catch (e) {
          emit(AuthStateLoggedOut(exception: e as Exception));
        }
      },
    );

    on<AuthEventLogInWithPhoneAndOtp>(
      (event, emit) async {
        emit(const AuthStateLoading());
        final verificationId = event.verificationId;
        final otpCode = event.otpCode;
        try {
          final user = await provider.logInWithPhoneAndOtp(
            verificationId: verificationId,
            otpCode: otpCode,
          );
          emit(AuthStateLoggedIn(user: user));
        } catch (e) {
          emit(AuthStateLoggedOut(exception: e as Exception));
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
        emit(const AuthStateLoading());
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
        emit(const AuthStateLoading());
        final email = event.email;
        try {
          await provider.sendPasswordReset(email: email);
        } catch (e) {
          emit(AuthStateLoggedOut(exception: e as Exception));
        }
      },
    );
  }
}
