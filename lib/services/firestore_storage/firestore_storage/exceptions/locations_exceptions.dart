class LocationException implements Exception {
  final String? message;

  final String code;
  const LocationException({this.message, String? code}) : this.code = code ?? 'unknown';

  @override
  String toString() {
    return 'LocationException: $message, code: $code';
  }
}

class CouldNotGetLocationException extends LocationException {
  const CouldNotGetLocationException({super.message}) : super(code: 'could-not-get-location');
}

class CouldNotUpdateLocationException extends LocationException {
  const CouldNotUpdateLocationException({super.message}) : super(code: 'could-not-update-location');
}

class CouldNotDeleteLocationException extends LocationException {
  const CouldNotDeleteLocationException({super.message}) : super(code: 'could-not-delete-location');
}

class CouldNotCreateLocationException extends LocationException {
  const CouldNotCreateLocationException({super.message}) : super(code: 'could-not-create-location');
}

class CouldNotGetUserLocationsException extends LocationException {
  const CouldNotGetUserLocationsException({super.message}) : super(code: 'could-not-get-user-locations');
}
