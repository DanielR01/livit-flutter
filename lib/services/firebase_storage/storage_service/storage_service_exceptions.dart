import 'package:livit/services/exceptions/base_exception.dart';

class StorageServiceException extends LivitException {
  StorageServiceException(
    super.message, {
    super.showToUser = true,
    super.technicalDetails,
    super.severity = ErrorSeverity.low,
  });
}

class ObjectNotFoundStorageException extends StorageServiceException {
  ObjectNotFoundStorageException(
    super.message, {
    super.showToUser = true,
    super.technicalDetails,
  });
}

class UnavailableStorageException extends StorageServiceException {
  UnavailableStorageException(
    super.message, {
    super.showToUser = true,
    super.technicalDetails,
    super.severity = ErrorSeverity.low,
  });
}
