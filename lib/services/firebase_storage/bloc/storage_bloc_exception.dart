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

class StorageBlocFileSizeTooLargeException extends StorageBlocException {
  StorageBlocFileSizeTooLargeException({String? details})
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

class FileDoesNotExistException extends StorageBlocException {
  FileDoesNotExistException({String? details})
      : super(
          'Archivo no encontrado',
          showToUser: true,
          technicalDetails: details,
          severity: ErrorSeverity.normal,
        );
}

class IncompleteDataException extends StorageBlocException {
  IncompleteDataException({String? details})
      : super(
          'Datos incompletos o no válidos',
          showToUser: true,
          technicalDetails: details,
          severity: ErrorSeverity.normal,
        );
}

class LocationMediaNotVerifiedException extends StorageBlocException {
  LocationMediaNotVerifiedException({String? details})
      : super(
          'Media de la locación no verificada',
          showToUser: true,
          technicalDetails: details,
          severity: ErrorSeverity.normal,
        );
}

class UnavailableStorageBlocException extends StorageBlocException {
  UnavailableStorageBlocException({String? details})
      : super(
          'Problema de red',
          showToUser: true,
          technicalDetails: details,
          severity: ErrorSeverity.low,
        );
}
