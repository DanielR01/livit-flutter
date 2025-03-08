import 'package:livit/services/exceptions/base_exception.dart';

class LocationException extends LivitException {
  final String code;

  LocationException(
    super.message, {
    required this.code,
    super.showToUser = true,
    super.technicalDetails,
    super.severity = ErrorSeverity.low,
  });

  @override
  String toString() =>
      showToUser ? message : '$runtimeType: $message (code: $code)${technicalDetails != null ? ' ($technicalDetails)' : ''}';
}

class CouldNotGetLocationException extends LocationException {
  CouldNotGetLocationException({String? details})
      : super(
          'No se pudo obtener la ubicación',
          code: 'could-not-get-location',
          showToUser: true,
          technicalDetails: details,
        );
}

class CouldNotGetLocationsByIdsException extends LocationException {
  CouldNotGetLocationsByIdsException({String? details})
      : super(
          'No se pudieron obtener las ubicaciones',
          code: 'could-not-get-locations-by-ids',
          showToUser: true,
          technicalDetails: details,
        );
}

class CouldNotUpdateLocationException extends LocationException {
  CouldNotUpdateLocationException({String? details})
      : super(
          'No se pudo actualizar la ubicación',
          code: 'could-not-update-location',
          showToUser: true,
          technicalDetails: details,
        );
}

class CouldNotDeleteLocationException extends LocationException {
  CouldNotDeleteLocationException({String? details})
      : super(
          'No se pudo eliminar la ubicación',
          code: 'could-not-delete-location',
          showToUser: true,
          technicalDetails: details,
        );
}

class CouldNotCreateLocationException extends LocationException {
  CouldNotCreateLocationException({String? details})
      : super(
          'No se pudo crear la ubicación',
          code: 'could-not-create-location',
          showToUser: true,
          technicalDetails: details,
        );
}

class CouldNotGetUserLocationsException extends LocationException {
  CouldNotGetUserLocationsException({String? details})
      : super(
          'No se pudieron obtener las ubicaciones',
          code: 'could-not-get-user-locations',
          showToUser: true,
          technicalDetails: details,
        );
}

class LocationLimitExceededException extends LocationException {
  LocationLimitExceededException({String? details})
      : super(
          'Has alcanzado el límite de ubicaciones',
          code: 'location-limit-exceeded',
          showToUser: true,
          technicalDetails: details,
        );
}

class InvalidLocationDataException extends LocationException {
  InvalidLocationDataException({String? details})
      : super(
          'Datos de ubicación inválidos',
          code: 'invalid-location-data',
          showToUser: true,
          technicalDetails: details,
        );
}

class LocationNotFoundException extends LocationException {
  LocationNotFoundException({String? details})
      : super(
          'Ubicación no encontrada',
          code: 'location-not-found',
          showToUser: true,
          technicalDetails: details,
        );
}

class LocationMediaException extends LocationException {
  LocationMediaException({String? details})
      : super(
          'Error con los archivos multimedia',
          code: 'location-media-error',
          showToUser: true,
          technicalDetails: details,
        );
}

class LocationPermissionDeniedException extends LocationException {
  LocationPermissionDeniedException({String? details})
      : super(
          'No tienes permiso para esta ubicación',
          code: 'location-permission-denied',
          showToUser: true,
          technicalDetails: details,
        );
}

class CouldNotCreateLocationFromDocumentException extends LocationException {
  CouldNotCreateLocationFromDocumentException({String? details})
      : super(
          'No se pudo crear la ubicación desde el documento',
          code: 'could-not-create-location-from-document',
          showToUser: false,
          technicalDetails: details,
          severity: ErrorSeverity.high,
        );
}

class CouldNotCreateLocationProductFromDocumentException extends LocationException {
  CouldNotCreateLocationProductFromDocumentException({String? details})
      : super(
          'No se pudo crear el producto desde el documento',
          code: 'could-not-create-location-product-from-document',
          showToUser: false,
          technicalDetails: details,
          severity: ErrorSeverity.high,
        );
}

class CouldNotCreateLocationMediaFromMapException extends LocationException {
  CouldNotCreateLocationMediaFromMapException({String? details})
      : super(
          'No se pudo crear el archivo multimedia desde el mapa',
          code: 'could-not-create-location-media-from-map',
          showToUser: true,
          technicalDetails: details,
          severity: ErrorSeverity.high,
        );
}
