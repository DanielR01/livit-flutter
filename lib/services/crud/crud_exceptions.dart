class DatabaseAlreadyOpenException implements Exception {}

class UnableToGetDocumentsDirectory implements Exception {}

class DatabaseIsNotOpen implements Exception {}

// Users exceptions

class CouldNotDeleteUser implements Exception {}

class UserAlreadyExists implements Exception {}

class UserNotFound implements Exception {}

// Promoters exceptions

class CouldNotFindPromoter implements Exception {}

class PromoterUsernameAlreadyInUse implements Exception {}

class PromoterEmailAlreadyInUse implements Exception {}

// Events exceptions

class CouldNotFindEvent implements Exception {}

class CouldNotUpdateEvent implements Exception {}

class CouldNotDeleteEvent implements Exception {}
