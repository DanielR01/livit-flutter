import 'package:livit/services/exceptions/base_exception.dart';

class TicketBlocException extends LivitException {
  TicketBlocException(
    super.message, {
    super.showToUser,
    super.technicalDetails,
    super.severity,
  });
}

class TicketBlocUserNotPromoterException extends TicketBlocException {
  TicketBlocUserNotPromoterException()
      : super('User is not a promoter', showToUser: false, severity: ErrorSeverity.high);
}

class TicketBlocGenericException extends TicketBlocException {
  TicketBlocGenericException({String? details})
      : super('Algo salió mal', showToUser: true, severity: ErrorSeverity.normal, technicalDetails: details);
}

class TicketBlocNoLocationException extends TicketBlocException {
  TicketBlocNoLocationException()
      : super('No location set', showToUser: true, severity: ErrorSeverity.high);
}
