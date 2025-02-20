import 'package:livit/services/exceptions/base_exception.dart';

class ProductBlocException extends LivitException {
  ProductBlocException({String? message, String? details, bool? showToUser, ErrorSeverity? severity})
      : super(
          message ?? 'Error desconocido',
          showToUser: showToUser ?? false,
          technicalDetails: details,
          severity: severity ?? ErrorSeverity.high,
        );
}

class GenericProductBlocException extends ProductBlocException {
  GenericProductBlocException({super.details})
      : super(
          message: 'Error desconocido',
          showToUser: true,
          severity: ErrorSeverity.high,
        );
}