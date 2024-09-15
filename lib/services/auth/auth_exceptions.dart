//login exceptions
class InvalidCredentialsAuthException implements Exception {}

class NotVerifiedEmailAuthException implements Exception {}

//register exceptions
class EmailAlreadyInUseAuthException implements Exception {}

class InvalidEmailAuthException implements Exception {}

class WeakPasswordAuthException implements Exception {}

class EmailAlreadyVerified implements Exception {}

//phone number exceptions
class InvalidPhoneNumberAuthException implements Exception {}

class InvalidVerificationCodeAuthException implements Exception {}

//generic exceptions
class GenericAuthException implements Exception {
  @override
  String toString() {
    return 'Algo salió mal';
  }
}

class UserNotLoggedInAuthException implements Exception {}

class TooManyRequestsAuthException implements Exception {}

class NetworkRequesFailed implements Exception {}
