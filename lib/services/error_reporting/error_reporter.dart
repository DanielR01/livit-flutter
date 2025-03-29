import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:livit/services/exceptions/base_exception.dart';
import 'package:livit/services/auth/auth_exceptions.dart';
import 'package:livit/services/firestore_storage/firestore_storage/exceptions/firestore_exceptions.dart';
import 'package:livit/services/firestore_storage/firestore_storage/exceptions/locations_exceptions.dart';
import 'package:livit/services/firestore_storage/bloc/location/location_bloc_exception.dart';
import 'package:livit/services/cloud_functions/cloud_functions_exceptions.dart';
import 'package:livit/utilities/debug/livit_debugger.dart';

class ErrorReporter {
  final FirebaseCrashlytics _crashlytics;
  final String? _viewName;

  final LivitDebugger _debugger = const LivitDebugger('ErrorReporter', isDebugEnabled: true);

  ErrorReporter({FirebaseCrashlytics? crashlytics, String? viewName})
      : _crashlytics = crashlytics ?? FirebaseCrashlytics.instance,
        _viewName = viewName;

  Future<void> reportError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
  }) async {
    // Handle different exception types
    _debugger.debPrint('Reporting error: $error, viewName: $_viewName', DebugMessageType.reporting);

    // Set view information if provided
    if (_viewName != null) {
      await _crashlytics.setCustomKey('error_view', _viewName);
      _debugger.debPrint('Error occurred in view: $_viewName', DebugMessageType.info);
    }

    if (error is LivitException) {
      await _handleLivitException(error, stackTrace, reason: reason);
    } else {
      // Handle unknown errors as high severity
      await _reportHighSeverityError(
        error,
        stackTrace,
        reason: reason ?? 'Unknown Error',
        errorType: 'UnknownError',
      );
    }
  }

  Future<void> _handleLivitException(
    LivitException error,
    StackTrace? stackTrace, {
    String? reason,
  }) async {
    // Log all errors to console
    _debugger.debPrint('${error.runtimeType}: ${error.toString()}', DebugMessageType.info);

    // Determine exception category for analytics
    final String category = _getExceptionCategory(error);

    switch (error.severity) {
      case ErrorSeverity.high:
        await _reportHighSeverityError(
          error,
          stackTrace,
          reason: reason,
          errorType: category,
        );
        break;

      case ErrorSeverity.normal:
        await _reportNormalSeverityError(
          error,
          stackTrace,
          reason: reason,
          errorType: category,
        );
        break;

      case ErrorSeverity.low:
        _logLowSeverityError(error);
        break;
    }
  }

  String _getExceptionCategory(LivitException error) {
    if (error is AuthException) return 'Auth';
    if (error is FirestoreException) return 'Firestore';
    if (error is LocationException) return 'Location';
    if (error is LocationBlocException) return 'LocationBloc';
    if (error is CloudFunctionException) return 'CloudFunction';
    return 'Other';
  }

  Future<void> _reportHighSeverityError(
    dynamic error,
    StackTrace? stackTrace, {
    required String errorType,
    String? reason,
  }) async {
    _debugger.debPrint('Reporting high severity error to Crashlytics...', DebugMessageType.reporting);
    await _setErrorKeys(error, errorType);

    await _crashlytics.recordError(
      error,
      stackTrace,
      reason: reason ?? 'High Severity Error',
      fatal: true,
    );
    _debugger.debPrint('Error reported to Crashlytics successfully', DebugMessageType.done);

    // Additional actions for high severity errors
    await _crashlytics.setCustomKey('requires_immediate_attention', true);
  }

  Future<void> _reportNormalSeverityError(
    dynamic error,
    StackTrace? stackTrace, {
    required String errorType,
    String? reason,
  }) async {
    _debugger.debPrint('Reporting normal severity error to Crashlytics...', DebugMessageType.reporting);
    await _setErrorKeys(error, errorType);

    await _crashlytics.recordError(
      error,
      stackTrace,
      reason: reason ?? 'Normal Severity Error',
      fatal: false,
    );
    _debugger.debPrint('Error reported to Crashlytics successfully', DebugMessageType.done);
  }

  void _logLowSeverityError(LivitException error) {
    // Only log to console for debugging
    _debugger.debPrint('Low Severity Error - ${error.runtimeType}: ${error.toString()}', DebugMessageType.info);
  }

  Future<void> _setErrorKeys(dynamic error, String errorType) async {
    await _crashlytics.setCustomKey('error_type', errorType);

    if (error is LivitException) {
      await _crashlytics.setCustomKey('severity', error.severity.toString());
      await _crashlytics.setCustomKey('show_to_user', error.showToUser);
      await _crashlytics.setCustomKey('technical_details', error.technicalDetails ?? 'none');

      if (error is LocationException) {
        await _crashlytics.setCustomKey('location_error_code', error.code);
      }
    }
  }
}
