import 'dart:async';
import 'package:livit/services/crud/crud_exceptions.dart';
import 'package:livit/services/crud/livit_db.dart';
import 'package:livit/services/crud/tables/events/event.dart';
import 'package:livit/services/crud/tables/promoters/promoter.dart';
import 'package:livit/services/crud/tables/users/user.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

class LivitDBService {
  Database? _db;

  List<LivitEvent> _events = [];

  LivitDBService._sharedInstance();
  static final LivitDBService _shared = LivitDBService._sharedInstance();
  factory LivitDBService() => _shared;

  final _eventsStreamController =
      StreamController<List<LivitEvent>>.broadcast();

  Stream<List<LivitEvent>> get allEvents => _eventsStreamController.stream;

  Future<void> _cacheEvents() async {
    final allEvents = await getAllEvents();
    _events = allEvents.toList();
    _eventsStreamController.add(_events);
  }

  Future<LivitPromoter> getPromoterWithId({
    required String id,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final results = await db.query(
      LivitDB.promotersTableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isEmpty) {
      throw CouldNotFindPromoter();
    }
    return LivitPromoter.fromRow(results.first);
  }

  Future<LivitPromoter> getPromoterWithUsername({
    required String username,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final results = await db.query(
      LivitDB.promotersTableName,
      where: 'username = ?',
      whereArgs: [username],
    );

    if (results.isEmpty) {
      throw CouldNotFindPromoter();
    }
    return LivitPromoter.fromRow(results.first);
  }

  Future<LivitPromoter> createPromoter({
    required String id,
    required String name,
    required String email,
    required String username,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final usernameResults = await db.query(
      LivitDB.promotersTableName,
      limit: 1,
      where: 'username = ?',
      whereArgs: [username],
    );

    final emailResults = await db.query(
      LivitDB.promotersTableName,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email],
    );

    if (usernameResults.isNotEmpty) {
      throw PromoterUsernameAlreadyInUse();
    }
    if (emailResults.isNotEmpty) {
      throw PromoterEmailAlreadyInUse();
    }

    await db.insert(
      LivitDB.promotersTableName,
      {
        LivitPromoter.idColumn: id,
        LivitPromoter.emailColumn: email,
        LivitPromoter.nameColumn: name,
        LivitPromoter.usernameColumn: username,
      },
    );
    return LivitPromoter(
      id: id,
      username: username,
      email: email,
      name: name,
    );
  }

  Future<LivitEvent> getEvent({required int eventId}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final results = await db.query(
      LivitDB.eventsTableName,
      where: 'id = ?',
      whereArgs: [eventId],
    );

    if (results.isEmpty) {
      throw CouldNotFindEvent();
    }

    final event = LivitEvent.fromRow(results.first);
    _events.removeWhere((event) => event.id == eventId);
    _events.add(event);
    _eventsStreamController.add(_events);
    return event;
  }

  Future<Iterable<LivitEvent>> getAllEvents() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final results = await db.query(
      LivitDB.eventsTableName,
      limit: 10,
    );

    return results.map((row) => LivitEvent.fromRow(row));
  }

  Future<LivitEvent> createEvent({
    //required LivitPromoter promoter,
    required String title,
    required String date,
    required String description,
    required String location,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // final dbPromoter = await getPromoterWithId(id: promoter.id);

    // if (promoter != dbPromoter) {
    //   throw CouldNotFindPromoter();
    // }
    final eventId = await db.insert(
      LivitDB.eventsTableName,
      {
        // LivitEvent.promoterIdColumn: promoter.id,
        LivitEvent.locationColumn: location,
        LivitEvent.titleColumn: title,
        LivitEvent.dateColumn: date,
        LivitEvent.descriptionColumn: description,
      },
    );
    final LivitEvent event = LivitEvent(
      id: eventId,
      // promoterId: promoter.id,
      title: title,
      location: location,
      date: date,
      description: description,
    );
    _events.add(event);
    _eventsStreamController.add(_events);

    return event;
  }

  Future<void> deleteEvent({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      LivitDB.eventsTableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteEvent();
    } else {
      final count = _events.length;
      _events.removeWhere((event) => event.id == id);
      if (_events.length != count) {
        _eventsStreamController.add(_events);
      }
    }
  }

  Future<LivitEvent> updateEvent({
    required LivitEvent event,
    required String location,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final dbEvent = await getEvent(eventId: event.id);

    if (dbEvent != event) {
      throw CouldNotFindEvent();
    }

    final updatesCount = await db.update(
      LivitDB.eventsTableName,
      {
        LivitEvent.locationColumn: location,
      },
    );

    if (updatesCount == 0) {
      throw CouldNotUpdateEvent();
    } else {
      final updatedEvent = await getEvent(eventId: event.id);
      _events.removeWhere((e) => e.id == event.id);
      _events.add(updatedEvent);
      _eventsStreamController.add(_events);
      return updatedEvent;
    }
  }

  Future<LivitUser> getUserWithUsername({required String username}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final results = await db.query(
      LivitDB.usersTableName,
      limit: 1,
      where: 'username = ?',
      whereArgs: [username],
    );

    if (results.isEmpty) {
      throw UserNotFound();
    } else {
      return LivitUser.fromRow(results.first);
    }
  }

  Future<LivitUser> getUserWithId({required String id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final results = await db.query(
      LivitDB.usersTableName,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isEmpty) {
      throw UserNotFound();
    } else {
      return LivitUser.fromRow(results.first);
    }
  }

  Future<LivitUser> createUser({
    required String userId,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      LivitDB.usersTableName,
      limit: 1,
      where: 'id = ?',
      whereArgs: [userId],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }
    await db.insert(
      LivitDB.usersTableName,
      {
        LivitUser.idColumn: userId,
      },
    );
    return LivitUser(
      id: userId,
    );
  }

  Future<LivitUser> getOrCreateUser({
    required String userId,
  }) async {
    try {
      final user = await getUserWithId(id: userId);
      return user;
    } on UserNotFound {
      final user = await createUser(userId: userId);
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUser({required String username}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(
      LivitDB.usersTableName,
      where: 'username = ?',
      whereArgs: [username],
    );
    if (deleteCount != 1) {
      throw CouldNotDeleteUser();
    } else {}
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(
        docsPath.path,
        LivitDB.dbName,
      );
      final db = await openDatabase(dbPath);
      _db = db;

      await db.execute(createUsersTable);

      await db.execute(createPromotersTable);

      await db.execute(createEventsTable);

      await _cacheEvents();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      //
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }

  static const createEventsTable = '''CREATE TABLE IF NOT EXISTS "events" (
	"id"	INTEGER NOT NULL UNIQUE,
	"promoter_id"	INTEGER NOT NULL,
	"name"	TEXT NOT NULL,
	"location"	TEXT NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("promoter_id") REFERENCES "promoters"("id")
);''';

  static const createPromotersTable =
      '''CREATE TABLE IF NOT EXISTS "promoters" (
	"id"	INTEGER NOT NULL UNIQUE,
	"name"	TEXT NOT NULL,
	"email"	TEXT NOT NULL UNIQUE,
	"description"	TEXT,
	"username"	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT)
);''';

  static const createUsersTable = '''CREATE TABLE IF NOT EXISTS "users" (
	"id"	TEXT NOT NULL UNIQUE,
	"name"	TEXT NOT NULL,
	"user_name"	TEXT NOT NULL UNIQUE,
	"phone_number"	TEXT UNIQUE,
	PRIMARY KEY("id")
);''';
}
