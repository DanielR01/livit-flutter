import 'package:livit/services/exceptions/base_exception.dart';
import 'package:livit/services/firebase_storage/firebase_storage_constants.dart';

class LocationBlocException extends LivitException {
  LocationBlocException(
    super.message, {
    super.showToUser,
    super.technicalDetails,
    super.severity,
  });
}

class FileWithNoPathException extends LocationBlocException {
  FileWithNoPathException({super.showToUser, super.technicalDetails, super.severity}) : super('Archivo corrupto');
}

class LocationWithMoreThanMaxFilesException extends LocationBlocException {
  LocationWithMoreThanMaxFilesException({super.showToUser, super.technicalDetails, super.severity}) : super('Ubicación con más de ${FirebaseStorageConstants.maxFiles} archivos');
}

class FileSizeExceededException extends LocationBlocException {
  FileSizeExceededException({super.showToUser, super.technicalDetails, super.severity}) : super('Archivo demasiado grande');
}

class GenericLocationBlocException extends LocationBlocException {
  GenericLocationBlocException({super.showToUser, super.technicalDetails, super.severity}) : super('Error desconocido');
}
