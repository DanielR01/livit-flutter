import 'package:livit/services/exceptions/base_exception.dart';

class StorageServiceExceptions extends LivitException {
  StorageServiceExceptions(
    super.message, {
    super.showToUser = true,
    super.technicalDetails,
    super.severity = ErrorSeverity.low,
  });
}

class ObjectNotFoundStorageException extends StorageServiceExceptions {
  ObjectNotFoundStorageException(
    super.message, {
    super.showToUser = true,
    super.technicalDetails,
  });
}
