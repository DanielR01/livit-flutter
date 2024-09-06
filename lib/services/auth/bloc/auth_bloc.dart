import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' show PhoneAuthCredential;
import 'package:livit/services/auth/auth_provider.dart';
import 'package:livit/services/auth/auth_user.dart';
import 'package:livit/services/auth/bloc/auth_event.dart';
import 'package:livit/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthProvider provider}) : super(const AuthStateLoading()) {
    on<AuthEventInitialize>(
      (event, emit) async {
        await provider.initialize();
        final AuthUser? user = provider.currentUser;
        if (user == null) {
          emit(const AuthStateLoggedOut());
        } else {
          if (user.isEmailVerified ?? false) {
            emit(AuthStateLoggedIn(user: user));
          } else {
            emit(const AuthStateNeedsVerification());
          }
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
          emit(AuthStateError(exception: e as Exception));
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
          emit(AuthStateLogoutError(exception: e as Exception));
        }
      },
    );

    on<AuthEventSendOtpCode>(
      (event, emit) async {
        emit(const AuthStateLoading());
        final phoneCode = event.phoneCode;
        final phoneNumber = event.phoneNumber;
        try {
          await provider.sendOtpCode(
            phoneCode: phoneCode,
            phoneNumber: phoneNumber,
            onVerificationCompleted: (dynamic credential) async {
              try {
                final credentialId = credential as PhoneAuthCredential;
                final user = await provider.logInWithCredential(credential: credentialId);
                emit(AuthStateLoggedIn(user: user));
              } catch (e) {
                emit(AuthStateError(exception: e as Exception));
              }
            },
            onVerificationFailed: (error) {
              emit(AuthStateError(exception: error as Exception));
            },
            onCodeSent: (verificationId, forceResendingToken) {
              emit(
                AuthStateCodeSent(
                  verificationId: verificationId,
                  forceResendingToken: forceResendingToken,
                ),
              );
            },
            onCodeAutoRetrievalTimeout: (verificationId) {},
          );
        } catch (e) {
          emit(AuthStateError(exception: e as Exception));
        }
      },
    );

    on<AuthEventLogInWithPhoneAndOtp>(
      (event, emit) async {
        emit(const AuthStateLoading());
        final verificationId = event.verificationId;
        final otpCode = event.otpCode;
        try {
          final user = await provider.logInWithPhoneAndOtp(verificationId: verificationId, otpCode: otpCode);
          emit(AuthStateLoggedIn(user: user));
        } catch (e) {
          emit(AuthStateError(exception: e as Exception));
        }
      },
    );

    on<AuthEventSendEmailVerification>(
      (event, emit) async {
        emit(const AuthStateLoading());
        try {
          await provider.sendEmailVerification();
        } catch (e) {
          emit(AuthStateError(exception: e as Exception));
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
        } catch (e) {
          emit(AuthStateError(exception: e as Exception));
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
          emit(AuthStateError(exception: e as Exception));
        }
      },
    );
  }
  
}
