import 'package:livit/services/exceptions/base_exception.dart';

class StorageBlocException extends LivitException {
  StorageBlocException(super.message, {super.showToUser, super.technicalDetails, super.severity});
}

class InvalidFileExtensionException extends StorageBlocException {
  InvalidFileExtensionException({String? details})
      : super(
          'Extensión de archivo no válida',
          showToUser: true,
          technicalDetails: details,
          severity: ErrorSeverity.normal,
        );
}

class FileSizeTooLargeException extends StorageBlocException {
  FileSizeTooLargeException({String? details})
      : super(
          'Tamaño de archivo demasiado grande',
          showToUser: true,
          technicalDetails: details,
          severity: ErrorSeverity.normal,
        );
}

class GenericStorageBlocException extends StorageBlocException {
  GenericStorageBlocException({String? details, ErrorSeverity? severity})
      : super(
          'Error desconocido',
          showToUser: true,
          technicalDetails: details,
          severity: severity ?? ErrorSeverity.normal,
        );
}

