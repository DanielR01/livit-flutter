import 'package:livit/services/exceptions/base_exception.dart';

class LocationBlocException extends LivitException {
  LocationBlocException(
    super.message, {
    super.showToUser,
    super.technicalDetails,
    super.severity,
  });
}
