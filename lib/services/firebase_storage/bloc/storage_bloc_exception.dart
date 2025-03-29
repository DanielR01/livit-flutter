import 'package:livit/services/exceptions/base_exception.dart';

class StorageBlocException extends LivitException {
  StorageBlocException(
    super.message, {
    super.showToUser = true,
    super.technicalDetails,
    super.severity = ErrorSeverity.low,
  });
}

// Location media exceptions
class LocationMediaNotVerifiedException extends StorageBlocException {
  LocationMediaNotVerifiedException({
    String? technicalDetails,
  }) : super('Location media not verified', technicalDetails: technicalDetails);
}

class UnavailableStorageBlocException extends StorageBlocException {
  UnavailableStorageBlocException({
    required String details,
    bool showToUser = true,
    String? technicalDetails,
    ErrorSeverity severity = ErrorSeverity.low,
  }) : super('Storage is unavailable', showToUser: showToUser, technicalDetails: technicalDetails ?? details, severity: severity);
}

// Event media exceptions
class EventMediaNotVerifiedException extends StorageBlocException {
  EventMediaNotVerifiedException({
    String? technicalDetails,
  }) : super('Event media not verified', technicalDetails: technicalDetails);
}

// Common exceptions
class FileDoesNotExistException extends StorageBlocException {
  FileDoesNotExistException({
    required String? details,
    bool showToUser = true,
    String? technicalDetails,
    ErrorSeverity severity = ErrorSeverity.low,
  }) : super('File does not exist', showToUser: showToUser, technicalDetails: technicalDetails ?? details, severity: severity);
}

class InvalidFileExtensionException extends StorageBlocException {
  InvalidFileExtensionException({
    required String details,
    bool showToUser = true,
    String? technicalDetails,
    ErrorSeverity severity = ErrorSeverity.low,
  }) : super('Invalid file extension', showToUser: showToUser, technicalDetails: technicalDetails ?? details, severity: severity);
}

class StorageBlocFileSizeTooLargeException extends StorageBlocException {
  StorageBlocFileSizeTooLargeException({
    required String details,
    bool showToUser = true,
    String? technicalDetails,
    ErrorSeverity severity = ErrorSeverity.low,
  }) : super('File size is too large', showToUser: showToUser, technicalDetails: technicalDetails ?? details, severity: severity);
}

class IncompleteDataException extends StorageBlocException {
  IncompleteDataException({
    required String details,
    bool showToUser = true,
    String? technicalDetails,
    ErrorSeverity severity = ErrorSeverity.low,
  }) : super('Incomplete data', showToUser: showToUser, technicalDetails: technicalDetails ?? details, severity: severity);
}

class GenericStorageBlocException extends StorageBlocException {
  GenericStorageBlocException({
    required String details,
    bool showToUser = true,
    String? technicalDetails,
    ErrorSeverity severity = ErrorSeverity.low,
  }) : super('Unknown storage error', showToUser: showToUser, technicalDetails: technicalDetails ?? details, severity: severity);
}
