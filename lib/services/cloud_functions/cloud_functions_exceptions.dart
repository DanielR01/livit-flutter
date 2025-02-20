import 'package:livit/services/exceptions/base_exception.dart';

class CloudFunctionException extends LivitException {
  CloudFunctionException(
    super.message, {
    super.showToUser = true,
    super.technicalDetails,
    super.severity,
  });
}

class UserAlreadyExistsException extends CloudFunctionException {
  UserAlreadyExistsException({String? details})
      : super(
          'El usuario ya existe',
          showToUser: false,
          technicalDetails: details,
          severity: ErrorSeverity.normal,
        );
}

class UsernameAlreadyTakenException extends CloudFunctionException {
  UsernameAlreadyTakenException({String? details})
      : super(
          'El nombre de usuario ya está tomado',
          showToUser: true,
          technicalDetails: details,
          severity: ErrorSeverity.low,
        );
}

class GenericCloudFunctionException extends CloudFunctionException {
  GenericCloudFunctionException({String? details})
      : super(
          'Ocurrió un error, lo hemos notificado',
          showToUser: true,
          technicalDetails: details,
          severity: ErrorSeverity.high,
        );
}

class LocationMediaFileSizeExceedsLimitException extends CloudFunctionException {
  LocationMediaFileSizeExceedsLimitException({String? details})
      : super(
          'El tamaño del archivo excede el límite',
          showToUser: true,
          technicalDetails: details,
          severity: ErrorSeverity.low,
        );
}

class LocationMediaExceedsMaxFilesLimitException extends CloudFunctionException {
  LocationMediaExceedsMaxFilesLimitException({String? details})
      : super(
          'Puedes subir un máximo de 7 archivos por ubicación',
          showToUser: true,
          technicalDetails: details,
          severity: ErrorSeverity.low,
        );
}

class UserDoesNotHavePermissionToUploadMediaToLocationException extends CloudFunctionException {
  UserDoesNotHavePermissionToUploadMediaToLocationException({String? details})
      : super(
          'El usuario no tiene permisos para subir archivos a esta ubicación',
          showToUser: false,
          technicalDetails: details,
          severity: ErrorSeverity.high,
        );
}

class LocationFilesNotMatchException extends CloudFunctionException {
  LocationFilesNotMatchException({String? details})
      : super(
          'Los archivos o la información no coinciden',
          showToUser: false,
          technicalDetails: details,
          severity: ErrorSeverity.high,
        );
}

class MissingParametersException extends CloudFunctionException {
  MissingParametersException({String? details})
      : super(
          'Faltan parámetros',
          showToUser: false,
          technicalDetails: details,
          severity: ErrorSeverity.normal,
        );
}

class LocationNotFoundException extends CloudFunctionException {
  LocationNotFoundException({String? details})
      : super(
          'La ubicación no existe',
          showToUser: false,
          technicalDetails: details,
          severity: ErrorSeverity.normal,
        );
}
