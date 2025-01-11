enum ErrorSeverity {
  low, // Minor issues that don't affect core functionality
  normal, // Standard errors that should be handled
  high, // Critical errors that need immediate attention
}

abstract class LivitException implements Exception {
  final String message;
  final bool showToUser;
  final String? technicalDetails;
  final ErrorSeverity severity;

  LivitException(
    this.message, {
    this.showToUser = false,
    this.technicalDetails,
    this.severity = ErrorSeverity.normal,
  });

  @override
  String toString() => showToUser ? message : '$runtimeType: $message${technicalDetails != null ? ' ($technicalDetails)' : ''}';
}

class BadStateException extends LivitException {
  BadStateException(super.message, {super.showToUser = true, super.severity = ErrorSeverity.high});
}
