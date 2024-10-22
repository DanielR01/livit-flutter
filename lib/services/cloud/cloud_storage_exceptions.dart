// User Exceptions

class CouldNotGetUserException implements Exception {
  @override
  String toString() {
    return 'No se pudo obtener el usuario';
  }
}

class UserNotFoundException implements Exception {
  @override
  String toString() {
    return 'No se pudo encontrar el usuario';
  }
}

class CouldNotUpdateUserException implements Exception {
  @override
  String toString() {
    return 'No se pudo actualizar el usuario';
  }
}

class CouldNotGetAllUsersException implements Exception {
  @override
  String toString() {
    return 'No se pudo obtener todos los usuarios';
  }
}


class NoCurrentUserException implements Exception {
  @override
  String toString() {
    return 'No hay un usuario actual';
  }
}

// Event Exceptions

class CouldNotGetEventException implements Exception {}

class CouldNotGetAllEventsException implements Exception {}

class CouldNotCreateEventException implements Exception {}

class CouldNotUpdateEventException implements Exception {}

class CouldNotDeleteEventException implements Exception {}

// Ticket Exceptions

class CouldNotGetTicketException implements Exception {}

class CouldNotGetAllTicketsException implements Exception {}

class CouldNotCreateTicketException implements Exception {}

class CouldNotUpdateTicketException implements Exception {}

class CouldNotDeleteTicketException implements Exception {}

// Username Exceptions

class CouldNotCreateUsernameException implements Exception {}

class CouldNotCheckUsernameException implements Exception {}

class UsernameAlreadyTakenException implements Exception {}

// Private Data Exceptions

class PrivateDataNotFoundException implements Exception {}

class CouldNotGetPrivateDataException implements Exception {}

class CouldNotUpdatePrivateDataException implements Exception {}
