import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/constants/enums.dart';
import 'package:livit/services/auth/auth_exceptions.dart';
import 'package:livit/services/auth/auth_provider.dart';
import 'package:livit/services/auth/auth_user.dart';
import 'package:livit/services/auth/bloc/auth_event.dart';
import 'package:livit/services/auth/bloc/auth_state.dart';
import 'package:livit/services/background/background_bloc.dart';
import 'package:livit/services/background/background_events.dart';
import 'package:livit/services/error_reporting/error_reporter.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthProvider _provider;
  final ErrorReporter _errorReporter;

  // Add getter for login state
  bool get isLoggedIn => state is AuthStateLoggedIn;

  AuthBloc({
    required AuthProvider provider,
    ErrorReporter? errorReporter,
  })  : _provider = provider,
        _errorReporter = errorReporter ?? ErrorReporter(),
        super(const AuthStateUninitialized()) {
    debugPrint('🔄 [AuthBloc] Initializing AuthBloc');

    on<AuthEventInitialize>((event, emit) async {
      debugPrint('🔄 [AuthBloc] Initializing Auth...');
      try {
        final AuthUser user = _provider.currentUser;
        debugPrint('✅ [AuthBloc] Auth initialized with user: ${user.id}');
        emit(AuthStateLoggedIn(user: user));
      } catch (e) {
        debugPrint('❌ [AuthBloc] Auth initialization failed: $e');
        await _handleError(e);
        emit(const AuthStateLoggedOut());
      }
    });

    on<AuthEventLogInWithEmailAndPassword>(
      (event, emit) async {
        debugPrint('🔑 Attempting email login: ${event.email}');
        final context = event.context;

        BlocProvider.of<BackgroundBloc>(context, listen: false).add(BackgroundStartLoadingAnimation());

        emit(const AuthStateLoggedOut(
          loginMethod: LoginMethod.emailAndPassword,
        ));

        final email = event.email;
        final password = event.password;
        try {
          final user = await _provider.logInWithEmailAndPassword(email: email, password: password);

          debugPrint('✅ Email login successful: ${user.id}');
          emit(AuthStateLoggedIn(user: user, userType: event.userType));
        } catch (e) {
          debugPrint('❌ Email login failed: $e');
          final authException = _mapFirebaseToAuthException(e);
          await _handleError(authException);
          emit(AuthStateLoggedOut(exception: authException));
        } finally {
          if (context.mounted) {
            BlocProvider.of<BackgroundBloc>(context, listen: false).add(BackgroundStopLoadingAnimation());
          }
        }
      },
    );

    on<AuthEventLogOut>(
      (event, emit) async {
        debugPrint('🚪 Logging out...');
        final context = event.context;
        BlocProvider.of<BackgroundBloc>(context, listen: false).add(BackgroundStartLoadingAnimation());
        emit(const AuthStateLoggingOut());
        try {
          await _provider.logOut();
          debugPrint('✅ Logout successful');
          emit(const AuthStateLoggedOut());
        } catch (e) {
          debugPrint('❌ Logout failed: $e');
          _emitError(emit, e as Exception);
        } finally {
          if (context.mounted) {
            BlocProvider.of<BackgroundBloc>(context, listen: false).add(BackgroundStopLoadingAnimation());
          }
        }
      },
    );

    on<AuthEventSendOtpCode>(
      (event, emit) async {
        debugPrint('📱 Sending OTP to: +${event.phoneCode} ${event.phoneNumber}');
        final context = event.context;
        BlocProvider.of<BackgroundBloc>(context, listen: false).add(BackgroundStartLoadingAnimation());
        emit(AuthStateSendingCode(isResending: event.isResending));
        final phoneCode = event.phoneCode;
        final phoneNumber = event.phoneNumber;
        try {
          final completer = Completer<AuthState>();
          await _provider.sendOtpCode(
            onVerificationCompleted: (credential) {
              debugPrint('✅ Phone verification completed automatically');
              completer.complete(const AuthStateLoggedOut());
            },
            onVerificationFailed: (error) async {
              debugPrint('❌ Phone verification failed: ${error.code}');
              final authException = _mapFirebaseToAuthException(error);
              await _handleError(authException);
              completer.complete(AuthStateCodeSentError(
                exception: authException,
              ));
            },
            onCodeSent: (String verificationId, int? forceResendingToken) {
              debugPrint('📤 OTP code sent successfully');
              completer.complete(AuthStateCodeSent(verificationId: verificationId));
            },
            phoneCode: phoneCode,
            phoneNumber: phoneNumber,
            onCodeAutoRetrievalTimeout: (verificationId) {
              debugPrint('⏰ OTP code auto-retrieval timeout');
              if (!completer.isCompleted) {
                completer.complete(const AuthStateLoggedOut());
              }
            },
          );
          final result = await completer.future;
          emit(result);
        } catch (e) {
          debugPrint('❌ Error sending OTP: $e');
          final authException = _mapFirebaseToAuthException(e);
          await _handleError(authException);
          emit(AuthStateLoggedOut(exception: authException));
        } finally {
          if (context.mounted) {
            BlocProvider.of<BackgroundBloc>(context, listen: false).add(BackgroundStopLoadingAnimation());
          }
        }
      },
    );

    on<AuthEventLogInWithGoogle>((event, emit) async {
      debugPrint('🔄 [AuthBloc] Starting Google login...');
      final context = event.context;
      BlocProvider.of<BackgroundBloc>(context, listen: false).add(BackgroundStartLoadingAnimation());

      emit(const AuthStateLoggedOut(loginMethod: LoginMethod.google));

      try {
        await _provider.logInWithGoogle();
        final user = _provider.currentUser;
        debugPrint('✅ [AuthBloc] Google login successful: ${user.id}');
        emit(AuthStateLoggedIn(user: user, userType: event.userType));
      } catch (e) {
        debugPrint('❌ [AuthBloc] Google login failed: $e');
        _emitError(emit, e as Exception);
      } finally {
        if (context.mounted) {
          BlocProvider.of<BackgroundBloc>(context, listen: false).add(BackgroundStopLoadingAnimation());
        }
      }
    });

    on<AuthEventLogInWithPhoneAndOtp>((event, emit) async {
      debugPrint('📱 [AuthBloc] Verifying OTP code...');
      final context = event.context;
      BlocProvider.of<BackgroundBloc>(context, listen: false).add(BackgroundStartLoadingAnimation());

      emit(const AuthStateLoggedOut(loginMethod: LoginMethod.phoneAndOtp));

      final verificationId = event.verificationId;
      final otpCode = event.otpCode;
      try {
        debugPrint('🔄 [AuthBloc] Attempting phone login with OTP...');
        final user = await _provider.logInWithPhoneAndOtp(
          verificationId: verificationId,
          otpCode: otpCode,
        );
        debugPrint('✅ [AuthBloc] Phone login successful: ${user.id}');
        emit(AuthStateLoggedIn(user: user, userType: event.userType));
      } catch (e) {
        debugPrint('❌ [AuthBloc] Phone login failed: $e');
        _emitError(emit, e as Exception);
      } finally {
        if (context.mounted) {
          BlocProvider.of<BackgroundBloc>(context, listen: false).add(BackgroundStopLoadingAnimation());
        }
      }
    });

    on<AuthEventSendEmailVerification>((event, emit) async {
      debugPrint('📧 [AuthBloc] Sending email verification...');
      final context = event.context;
      BlocProvider.of<BackgroundBloc>(context, listen: false).add(BackgroundStartLoadingAnimation());

      emit(const AuthStateEmailVerificationSending());
      try {
        await _provider.sendEmailVerification();
        debugPrint('✅ [AuthBloc] Email verification sent successfully');
        emit(const AuthStateEmailVerificationSent());
      } catch (e) {
        debugPrint('❌ [AuthBloc] Failed to send email verification: $e');
        final authException = _mapFirebaseToAuthException(e);
        await _handleError(authException);
        emit(AuthStateEmailVerificationSentError(exception: authException));
      } finally {
        if (context.mounted) {
          BlocProvider.of<BackgroundBloc>(context, listen: false).add(BackgroundStopLoadingAnimation());
        }
      }
    });

    on<AuthEventRegister>((event, emit) async {
      debugPrint('📝 [AuthBloc] Starting registration: ${event.email}');
      final context = event.context;
      BlocProvider.of<BackgroundBloc>(context, listen: false).add(BackgroundStartLoadingAnimation());

      emit(const AuthStateRegistering());
      final email = event.email;
      final password = event.password;
      try {
        await _provider.registerEmail(email: email, password: password);
        debugPrint('✅ [AuthBloc] Registration successful');
        emit(const AuthStateRegistered());
      } catch (e) {
        debugPrint('❌ [AuthBloc] Registration failed: $e');
        final authException = _mapFirebaseToAuthException(e);
        await _handleError(authException);
        emit(AuthStateRegisterError(exception: authException));
      } finally {
        if (context.mounted) {
          BlocProvider.of<BackgroundBloc>(context, listen: false).add(BackgroundStopLoadingAnimation());
        }
      }
    });

    on<AuthEventSendPasswordReset>((event, emit) async {
      debugPrint('🔑 [AuthBloc] Sending password reset: ${event.email}');
      final context = event.context;
      BlocProvider.of<BackgroundBloc>(context, listen: false).add(BackgroundStartLoadingAnimation());

      emit(const AuthStateSendingPasswordReset());
      try {
        await _provider.sendPasswordReset(email: event.email);
        debugPrint('✅ [AuthBloc] Password reset email sent');
        emit(const AuthStatePasswordResetSent());
      } catch (e) {
        debugPrint('❌ [AuthBloc] Failed to send password reset: $e');
        final authException = _mapFirebaseToAuthException(e);
        await _handleError(authException);
        emit(AuthStatePasswordResetSentError(exception: authException));
      } finally {
        if (context.mounted) {
          BlocProvider.of<BackgroundBloc>(context, listen: false).add(BackgroundStopLoadingAnimation());
        }
      }
    });
  }

  AuthException _mapFirebaseToAuthException(dynamic error) {
    debugPrint('🔄 [AuthBloc] Mapping Firebase error: ${error.code}');
    if (error is! FirebaseAuthException) {
      debugPrint('⚠️ [AuthBloc] Unknown error type: ${error.runtimeType}');
      return GenericAuthException(details: error.toString());
    }

    final exception = _createAuthException(error);
    debugPrint('📝 [AuthBloc] Mapped to: ${exception.runtimeType}');
    return exception;
  }

  AuthException _createAuthException(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return InvalidEmailAuthException(details: error.message);
      case 'user-disabled':
        return InvalidCredentialsAuthException(details: error.message);
      case 'user-not-found':
        return InvalidCredentialsAuthException(details: error.message);
      case 'wrong-password':
        return InvalidCredentialsAuthException(details: error.message);
      case 'email-already-in-use':
        return EmailAlreadyInUseAuthException(details: error.message);
      case 'operation-not-allowed':
        return GenericAuthException(details: error.message);
      case 'weak-password':
        return WeakPasswordAuthException(details: error.message);
      case 'invalid-verification-code':
        return InvalidVerificationCodeAuthException(details: error.message);
      case 'invalid-verification-id':
        return InvalidVerificationCodeAuthException(details: error.message);
      case 'invalid-phone-number':
        return InvalidPhoneNumberAuthException(details: error.message);
      case 'too-many-requests':
        return TooManyRequestsAuthException(details: error.message);
      case 'network-request-failed':
        return NetworkRequestFailedAuthException(details: error.message);
      default:
        debugPrint('⚠️ [AuthBloc] Unhandled Firebase error code: ${error.code}');
        return GenericAuthException(details: '${error.code}: ${error.message}');
    }
  }

  Future<void> _handleError(dynamic error) async {
    debugPrint('🚨 [AuthBloc] Handling error: $error');
    final exception = error is AuthException ? error : _mapFirebaseToAuthException(error);

    await _errorReporter.reportError(
      exception,
      StackTrace.current,
      reason: '[AuthBloc] Error: ${exception.runtimeType}',
    );
  }

  void _emitError(Emitter<AuthState> emit, Exception e) {
    debugPrint('🚨 [AuthBloc] Emitting error state: $e');
    final authException = e is AuthException ? e : _mapFirebaseToAuthException(e);
    _handleError(authException);
    emit(AuthStateLoggedOut(exception: authException));
  }

  // Optional: Add more helpful getters
  AuthUser? get currentUser => state is AuthStateLoggedIn ? (state as AuthStateLoggedIn).user : null;

  UserType? get userType => state is AuthStateLoggedIn ? (state as AuthStateLoggedIn).userType : null;

  bool get isInitialized => state is! AuthStateUninitialized;

  bool get isLoggingOut => state is AuthStateLoggingOut;
}
