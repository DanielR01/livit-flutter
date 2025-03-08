import 'package:livit/services/exceptions/base_exception.dart';

class FirestoreException extends LivitException {
  FirestoreException(
    super.message, {
    super.showToUser,
    super.technicalDetails,
    super.severity,
  });
}

class GenericFirestoreException extends FirestoreException {
  GenericFirestoreException({String? details})
      : super(
          'Error desconocido',
          showToUser: true,
          technicalDetails: details,
          severity: ErrorSeverity.high,
        );
}

// User Exceptions
class CouldNotGetUserException extends FirestoreException {
  CouldNotGetUserException({String? details})
      : super(
          'No se pudo obtener el usuario',
          showToUser: true,
          technicalDetails: details,
          severity: ErrorSeverity.low,
        );
}

class UsernameAlreadyExistsException extends FirestoreException {
  UsernameAlreadyExistsException({String? details})
      : super(
          'El nombre de usuario ya existe',
          showToUser: true,
          technicalDetails: details,
          severity: ErrorSeverity.low,
        );
}

class UserNotFoundException extends FirestoreException {
  UserNotFoundException({String? details})
      : super(
          'No se pudo encontrar el usuario',
          showToUser: true,
          technicalDetails: details,
          severity: ErrorSeverity.low,
        );
}

class CouldNotUpdateUserException extends FirestoreException {
  CouldNotUpdateUserException({String? details})
      : super(
          'No se pudo actualizar el usuario',
          showToUser: true,
          technicalDetails: details,
          severity: ErrorSeverity.normal,
        );
}

class NoCurrentUserException extends FirestoreException {
  NoCurrentUserException({String? details})
      : super(
          'No hay un usuario actual',
          showToUser: false,
          technicalDetails: details,
          severity: ErrorSeverity.low,
        );
}

class UserTypeNotFoundException extends FirestoreException {
  UserTypeNotFoundException({String? details})
      : super(
          'No se pudo encontrar el tipo de usuario',
          showToUser: false,
          technicalDetails: details,
          severity: ErrorSeverity.low,
        );
}

class UserInformationCorruptedException extends FirestoreException {
  UserInformationCorruptedException({String? details})
      : super(
          'La información del usuario está corrupta',
          showToUser: true,
          technicalDetails: details,
          severity: ErrorSeverity.high,
        );
}

// Event Exceptions
class CouldNotGetEventException extends FirestoreException {
  CouldNotGetEventException({String? details})
      : super(
          'No se pudo obtener el evento',
          showToUser: true,
          technicalDetails: details,
          severity: ErrorSeverity.normal,
        );
}

class CouldNotGetEventsByIdsException extends FirestoreException {
  CouldNotGetEventsByIdsException({String? details})
      : super(
          'No se pudo obtener los eventos por ids',
          showToUser: true,
          technicalDetails: details,
          severity: ErrorSeverity.normal,
        );
}
class CouldNotGetEventsByLocationException extends FirestoreException {
  CouldNotGetEventsByLocationException({String? details})
      : super(
          'No se pudo obtener los eventos por ubicación',
          showToUser: true,
          technicalDetails: details,
          severity: ErrorSeverity.normal,
        );
}

class CouldNotGetAllEventsException extends FirestoreException {
  CouldNotGetAllEventsException({String? details})
      : super(
          'No se pudo obtener todos los eventos',
          showToUser: true,
          technicalDetails: details,
          severity: ErrorSeverity.normal,
        );
}

class CouldNotCreateEventException extends FirestoreException {
  CouldNotCreateEventException({String? details})
      : super(
          'No se pudo crear el evento',
          showToUser: true,
          technicalDetails: details,
          severity: ErrorSeverity.normal,
        );
}

class CouldNotUpdateEventException extends FirestoreException {
  CouldNotUpdateEventException({String? details})
      : super(
          'No se pudo actualizar el evento',
          showToUser: true,
          technicalDetails: details,
          severity: ErrorSeverity.normal,
        );
}

class CouldNotDeleteEventException extends FirestoreException {
  CouldNotDeleteEventException({String? details})
      : super(
          'No se pudo eliminar el evento',
          showToUser: true,
          technicalDetails: details,
          severity: ErrorSeverity.normal,
        );
}

// Ticket Exceptions
class CouldNotGetTicketException extends FirestoreException {
  CouldNotGetTicketException({String? details})
      : super(
          'No se pudo obtener el ticket',
          showToUser: true,
          technicalDetails: details,
          severity: ErrorSeverity.high,
        );
}

class CouldNotGetAllTicketsException extends FirestoreException {
  CouldNotGetAllTicketsException({String? details})
      : super(
          'No se pudo obtener todos los tickets',
          showToUser: true,
          technicalDetails: details,
          severity: ErrorSeverity.high,
        );
}

class CouldNotCreateTicketException extends FirestoreException {
  CouldNotCreateTicketException({String? details})
      : super(
          'No se pudo crear el ticket',
          showToUser: true,
          technicalDetails: details,
          severity: ErrorSeverity.normal,
        );
}

class CouldNotUpdateTicketException extends FirestoreException {
  CouldNotUpdateTicketException({String? details})
      : super(
          'No se pudo actualizar el ticket',
          showToUser: true,
          technicalDetails: details,
          severity: ErrorSeverity.normal,
        );
}

class CouldNotDeleteTicketException extends FirestoreException {
  CouldNotDeleteTicketException({String? details})
      : super(
          'No se pudo eliminar el ticket',
          showToUser: true,
          technicalDetails: details,
          severity: ErrorSeverity.normal,
        );
}

// Username Exceptions
class CouldNotCreateUsernameException extends FirestoreException {
  CouldNotCreateUsernameException({String? details})
      : super(
          'No se pudo crear el nombre de usuario',
          showToUser: true,
          technicalDetails: details,
          severity: ErrorSeverity.normal,
        );
}

class CouldNotCheckUsernameException extends FirestoreException {
  CouldNotCheckUsernameException({String? details})
      : super(
          'No se pudo verificar el nombre de usuario',
          showToUser: true,
          technicalDetails: details,
          severity: ErrorSeverity.normal,
        );
}

// Private Data Exceptions
class PrivateDataNotFoundException extends FirestoreException {
  PrivateDataNotFoundException({String? details})
      : super(
          'No se pudo encontrar la información privada',
          showToUser: true,
          technicalDetails: details,
          severity: ErrorSeverity.normal,
        );
}

class CouldNotGetPrivateDataException extends FirestoreException {
  CouldNotGetPrivateDataException({String? details})
      : super(
          'No se pudo obtener la información privada',
          showToUser: true,
          technicalDetails: details,
          severity: ErrorSeverity.normal,
        );
}

class CouldNotUpdatePrivateDataException extends FirestoreException {
  CouldNotUpdatePrivateDataException({String? details})
      : super(
          'No se pudo actualizar la información privada',
          showToUser: true,
          technicalDetails: details,
          severity: ErrorSeverity.normal,
        );
}
//TODO: check the severity of the errors

// Scanner Exceptions
class ScannerNotFoundException extends FirestoreException {
  ScannerNotFoundException({String? details})
      : super(
          'No se pudo encontrar el escáner',
          showToUser: true,
          technicalDetails: details,
          severity: ErrorSeverity.normal,
        );
}

class CouldNotGetScannersByLocationIdException extends FirestoreException {
  CouldNotGetScannersByLocationIdException({String? details})
      : super(
          'No se pudo obtener los escáneres por ubicación',
          showToUser: true,
          technicalDetails: details,
          severity: ErrorSeverity.normal,
        );
}
