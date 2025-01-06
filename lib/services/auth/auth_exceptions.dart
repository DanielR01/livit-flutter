//login exceptions
import 'package:livit/services/exceptions/base_exception.dart';

class AuthException extends LivitException {
  AuthException(
    super.message, {
    super.showToUser = true,
    super.technicalDetails,
    super.severity = ErrorSeverity.low,
  });
}

class InvalidCredentialsAuthException extends AuthException {
  InvalidCredentialsAuthException({String? details})
      : super(
          'Credenciales inválidas',
          showToUser: true,
          technicalDetails: details,
        );
}

class NotVerifiedEmailAuthException extends AuthException {
  NotVerifiedEmailAuthException({String? details})
      : super(
          'Email no verificado',
          showToUser: true,
          technicalDetails: details,
        );
}

class EmailAlreadyInUseAuthException extends AuthException {
  EmailAlreadyInUseAuthException({String? details})
      : super(
          'Este email ya está en uso',
          showToUser: true,
          technicalDetails: details,
        );
}

class InvalidEmailAuthException extends AuthException {
  InvalidEmailAuthException({String? details})
      : super(
          'Email inválido',
          showToUser: true,
          technicalDetails: details,          
        );
}

class WeakPasswordAuthException extends AuthException {
  WeakPasswordAuthException({String? details})
      : super(
          'Contraseña demasiado débil',
          showToUser: true,
          technicalDetails: details,
        );
}

class EmailAlreadyVerifiedException extends AuthException {
  EmailAlreadyVerifiedException({String? details})
      : super(
          'Email ya verificado',
          showToUser: true,
          technicalDetails: details,
        );
}

//phone number exceptions
class InvalidPhoneNumberAuthException extends AuthException {
  InvalidPhoneNumberAuthException({String? details})
      : super(
          'Número de teléfono inválido',
          showToUser: true,
          technicalDetails: details,
        );
}

class InvalidVerificationCodeAuthException extends AuthException {
  InvalidVerificationCodeAuthException({String? details})
      : super(
          'Código de verificación inválido',
          showToUser: true,
          technicalDetails: details,
        );
}

//generic exceptions
class GenericAuthException extends AuthException {
  GenericAuthException({String? details})
      : super(
          'Algo salió mal',
          showToUser: true,
          technicalDetails: details,
          severity: ErrorSeverity.normal,
        );
}

class UserNotLoggedInAuthException extends AuthException {
  UserNotLoggedInAuthException({String? details})
      : super(
          'Usuario no ha iniciado sesión',
          showToUser: false,
          technicalDetails: details,
        );
}

class TooManyRequestsAuthException extends AuthException {
  TooManyRequestsAuthException({String? details})
      : super(
          'Demasiados intentos. Intenta más tarde',
          showToUser: true,
          technicalDetails: details,
        );
}

class NetworkRequestFailedAuthException extends AuthException {
  NetworkRequestFailedAuthException({String? details})
      : super(
          'Error de conexión',
          showToUser: true,
          technicalDetails: details,
        );
}
