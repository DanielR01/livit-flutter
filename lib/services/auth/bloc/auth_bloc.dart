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
import 'package:livit/utilities/debug/livit_debugger.dart';


class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthProvider _provider;
  final ErrorReporter _errorReporter;

  final _debugger = LivitDebugger('auth_bloc', isDebugEnabled: false);

  // Add getter for login state
  bool get isLoggedIn => state is AuthStateLoggedIn;

  AuthBloc({
    required AuthProvider provider,
    ErrorReporter? errorReporter,
  })  : _provider = provider,
        _errorReporter = errorReporter ?? ErrorReporter(viewName: 'AuthBloc'),
        super(const AuthStateUninitialized()) {
    _debugger.debPrint('Initializing AuthBloc', DebugMessageType.initializing);

    on<AuthEventInitialize>((event, emit) async {
      _debugger.debPrint('Initializing Auth...', DebugMessageType.initializing);
      try {
        final AuthUser user = await _provider.currentUser;
        _debugger.debPrint('Auth initialized with user: ${user.id}', DebugMessageType.done);
        emit(AuthStateLoggedIn(user: user));
      } catch (e) {
        _debugger.debPrint('Auth initialization failed: $e', DebugMessageType.error);
        await _handleError(e);
        emit(const AuthStateLoggedOut());
      }
    });

    on<AuthEventLogInWithEmailAndPassword>(
      (event, emit) async {
        _debugger.debPrint('Attempting email login: ${event.email}', DebugMessageType.loginIn);
        final context = event.context;

        BlocProvider.of<BackgroundBloc>(context, listen: false).add(BackgroundStartLoadingAnimation());

        emit(const AuthStateLoggedOut(
          loginMethod: LoginMethod.emailAndPassword,
        ));

        final email = event.email;
        final password = event.password;
        try {
          final user = await _provider.logInWithEmailAndPassword(email: email, password: password);

          _debugger.debPrint('Email login successful: ${user.id}', DebugMessageType.done);
          emit(AuthStateLoggedIn(user: user, userType: event.userType));
        } catch (e) {
          _debugger.debPrint('Email login failed: $e', DebugMessageType.error);
          final authException = _mapFirebaseToAuthException(e as Exception);
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
        _debugger.debPrint('Logging out...', DebugMessageType.loginOut);
        final context = event.context;
        BlocProvider.of<BackgroundBloc>(context, listen: false).add(BackgroundStartLoadingAnimation());
        emit(const AuthStateLoggingOut());
        try {
          await _provider.logOut();
          _debugger.debPrint('Logout successful', DebugMessageType.done);
          emit(const AuthStateLoggedOut());
        } catch (e) {
          _debugger.debPrint('Logout failed: $e', DebugMessageType.error);
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
        _debugger.debPrint('Sending OTP to: +${event.phoneCode} ${event.phoneNumber}', DebugMessageType.sending);
        final context = event.context;
        BlocProvider.of<BackgroundBloc>(context, listen: false).add(BackgroundStartLoadingAnimation());
        emit(AuthStateSendingCode(isResending: event.isResending));
        final phoneCode = event.phoneCode;
        final phoneNumber = event.phoneNumber;
        try {
          final completer = Completer<AuthState>();
          await _provider.sendOtpCode(
            onVerificationCompleted: (credential) {
              _debugger.debPrint('Phone verification completed automatically', DebugMessageType.done);
              completer.complete(const AuthStateLoggedOut());
            },
            onVerificationFailed: (error) async {
              _debugger.debPrint('Phone verification failed: ${error.code}', DebugMessageType.error);
              final authException = _mapFirebaseToAuthException(error);
              await _handleError(authException);
              completer.complete(AuthStateCodeSentError(
                exception: authException,
              ));
            },
            onCodeSent: (String verificationId, int? forceResendingToken) {
              _debugger.debPrint('OTP code sent successfully', DebugMessageType.done);
              completer.complete(AuthStateCodeSent(verificationId: verificationId));
            },
            phoneCode: phoneCode,
            phoneNumber: phoneNumber,
            onCodeAutoRetrievalTimeout: (verificationId) {
              _debugger.debPrint('OTP code auto-retrieval timeout', DebugMessageType.waiting);
              if (!completer.isCompleted) {
                completer.complete(const AuthStateLoggedOut());
              }
            },
          );
          final result = await completer.future;
          emit(result);
        } catch (e) {
          _debugger.debPrint('Error sending OTP: $e', DebugMessageType.error);
          final authException = _mapFirebaseToAuthException(e as Exception);
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
      _debugger.debPrint('Starting Google login...', DebugMessageType.loginIn);
      final context = event.context;
      BlocProvider.of<BackgroundBloc>(context, listen: false).add(BackgroundStartLoadingAnimation());

      emit(const AuthStateLoggedOut(loginMethod: LoginMethod.google));

      try {
        await _provider.logInWithGoogle();
        final user = await _provider.currentUser;
        _debugger.debPrint('Google login successful: ${user.id}', DebugMessageType.done);
        emit(AuthStateLoggedIn(user: user, userType: event.userType));
      } catch (e) {
        _debugger.debPrint('Google login failed: $e', DebugMessageType.error);
        _emitError(emit, e as Exception);
      } finally {
        if (context.mounted) {
          BlocProvider.of<BackgroundBloc>(context, listen: false).add(BackgroundStopLoadingAnimation());
        }
      }
    });

    on<AuthEventLogInWithPhoneAndOtp>((event, emit) async {
      _debugger.debPrint('Verifying OTP code...', DebugMessageType.loginIn);
      final context = event.context;
      BlocProvider.of<BackgroundBloc>(context, listen: false).add(BackgroundStartLoadingAnimation());

      emit(const AuthStateLoggedOut(loginMethod: LoginMethod.phoneAndOtp));

      final verificationId = event.verificationId;
      final otpCode = event.otpCode;
      try {
        _debugger.debPrint('Attempting phone login with OTP...', DebugMessageType.loginIn);
        final user = await _provider.logInWithPhoneAndOtp(
          verificationId: verificationId,
          otpCode: otpCode,
        );
        _debugger.debPrint('Phone login successful: ${user.id}', DebugMessageType.done);
        emit(AuthStateLoggedIn(user: user, userType: event.userType));
      } catch (e) {
        _debugger.debPrint('Phone login failed: $e', DebugMessageType.error);
        _emitError(emit, e as Exception);
      } finally {
        if (context.mounted) {
          BlocProvider.of<BackgroundBloc>(context, listen: false).add(BackgroundStopLoadingAnimation());
        }
      }
    });

    on<AuthEventSendEmailVerification>((event, emit) async {
      _debugger.debPrint('Sending email verification...', DebugMessageType.sending);
      final context = event.context;
      BlocProvider.of<BackgroundBloc>(context, listen: false).add(BackgroundStartLoadingAnimation());

      emit(const AuthStateEmailVerificationSending());
      try {
        await _provider.sendEmailVerification();
        _debugger.debPrint('Email verification sent successfully', DebugMessageType.done);
        emit(const AuthStateEmailVerificationSent());
      } catch (e) {
        _debugger.debPrint('Failed to send email verification: $e', DebugMessageType.error);
        final authException = _mapFirebaseToAuthException(e as Exception);
        await _handleError(authException);
        emit(AuthStateEmailVerificationSentError(exception: authException));
      } finally {
        if (context.mounted) {
          BlocProvider.of<BackgroundBloc>(context, listen: false).add(BackgroundStopLoadingAnimation());
        }
      }
    });

    on<AuthEventRegister>((event, emit) async {
      _debugger.debPrint('Starting registration: ${event.email}', DebugMessageType.userCreating);
      final context = event.context;
      BlocProvider.of<BackgroundBloc>(context, listen: false).add(BackgroundStartLoadingAnimation());

      emit(const AuthStateRegistering());
      final email = event.email;
      final password = event.password;
      try {
        await _provider.registerEmail(email: email, password: password);
        _debugger.debPrint('Registration successful', DebugMessageType.done);
        emit(const AuthStateRegistered());
      } catch (e) {
        _debugger.debPrint('Registration failed: $e', DebugMessageType.error);
        final authException = _mapFirebaseToAuthException(e as Exception);
        await _handleError(authException);
        emit(AuthStateRegisterError(exception: authException));
      } finally {
        if (context.mounted) {
          BlocProvider.of<BackgroundBloc>(context, listen: false).add(BackgroundStopLoadingAnimation());
        }
      }
    });

    on<AuthEventSendPasswordReset>((event, emit) async {
      _debugger.debPrint('Sending password reset: ${event.email}', DebugMessageType.auth);
      final context = event.context;
      BlocProvider.of<BackgroundBloc>(context, listen: false).add(BackgroundStartLoadingAnimation());

      emit(const AuthStateSendingPasswordReset());
      try {
        await _provider.sendPasswordReset(email: event.email);
        _debugger.debPrint('Password reset email sent', DebugMessageType.done);
        emit(const AuthStatePasswordResetSent());
      } catch (e) {
        _debugger.debPrint('Failed to send password reset: $e', DebugMessageType.error);
        final authException = _mapFirebaseToAuthException(e as Exception);
        await _handleError(authException);
        emit(AuthStatePasswordResetSentError(exception: authException));
      } finally {
        if (context.mounted) {
          BlocProvider.of<BackgroundBloc>(context, listen: false).add(BackgroundStopLoadingAnimation());
        }
      }
    });
  }

  AuthException _mapFirebaseToAuthException(Exception error) {
    if (error is AuthException) {
      return error;
    }
    if (error is! FirebaseAuthException) {
      _debugger.debPrint('Unknown error type: ${error.runtimeType}', DebugMessageType.error);
      return GenericAuthException(details: error.toString());
    }
    _debugger.debPrint('Mapping Firebase error: ${error.code}', DebugMessageType.error);
    final exception = _createAuthException(error);
    _debugger.debPrint('Mapped to: ${exception.runtimeType}', DebugMessageType.error);
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
        _debugger.debPrint('Unhandled Firebase error code: ${error.code}', DebugMessageType.error);
        return GenericAuthException(details: '${error.code}: ${error.message}');
    }
  }

  Future<void> _handleError(dynamic error) async {
    _debugger.debPrint('Handling error: $error', DebugMessageType.error);
    final exception = error is AuthException ? error : _mapFirebaseToAuthException(error);

    await _errorReporter.reportError(
      exception,
      StackTrace.current,
      reason: '[AuthBloc] Error: ${exception.runtimeType}',
    );
  }

  void _emitError(Emitter<AuthState> emit, Exception e) {
    _debugger.debPrint('Emitting error state: $e', DebugMessageType.error);
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
