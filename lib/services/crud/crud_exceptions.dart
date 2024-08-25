class DatabaseAlreadyOpenException implements Exception {}

class UnableToGetDocumentsDirectory implements Exception {}

class DatabaseIsNotOpen implements Exception {}

// Users exceptions

class CouldNotDeleteUser implements Exception {}

class UserAlreadyExists implements Exception {}

class UserNotFound implements Exception {}

class CouldNotCreateUser implements Exception {}

class CouldNotCreateNorGetUser implements Exception {}

// Events exceptions

class CouldNotFindEvent implements Exception {}

class CouldNotUpdateEvent implements Exception {}

class CouldNotDeleteEvent implements Exception {}

class UserShouldBeSetBeforeReadingAllNotes implements Exception {}
