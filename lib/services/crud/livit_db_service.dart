import 'dart:async';
import 'package:livit/services/crud/crud_exceptions.dart';
import 'package:livit/services/crud/livit_db.dart';
import 'package:livit/services/crud/tables/events/event.dart';
import 'package:livit/services/crud/tables/users/user.dart';
import 'package:livit/utilities/list/filter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

enum UserType {
  consumer,
  promoter,
}

class LivitDBService {
  Database? _db;

  List<LivitEvent> _events = [];

  LivitUser? _user;

  LivitDBService._sharedInstance() {
    _eventsStreamController = StreamController<List<LivitEvent>>.broadcast(
      onListen: () {
        _eventsStreamController.sink.add(_events);
      },
    );
  }

  static final LivitDBService _shared = LivitDBService._sharedInstance();
  factory LivitDBService() => _shared;

  late final StreamController<List<LivitEvent>> _eventsStreamController;

  Stream<List<LivitEvent>> get allEvents =>
      _eventsStreamController.stream.filter(
        (event) {
          if (_user == null) {
            throw UserShouldBeSetBeforeReadingAllNotes();
          }
          return event.creatorId == _user!.id;
        },
      );

  Future<void> _cacheEvents() async {
    final allEvents = await getAllEvents();
    _events = allEvents.toList();
    _eventsStreamController.add(_events);
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
    required LivitUser userCreator,
    required String title,
    required String location,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final dbUserCreator = await getUserWithId(id: userCreator.id);

    if (userCreator != dbUserCreator) {
      throw UserNotFound();
    }
    final eventId = await db.insert(
      LivitDB.eventsTableName,
      {
        LivitEvent.creatorIdColumn: userCreator.id,
        LivitEvent.locationColumn: location,
        LivitEvent.titleColumn: title,
      },
    );
    final LivitEvent event = LivitEvent(
      id: eventId,
      creatorId: userCreator.id,
      title: title,
      location: location,
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
    // TODO this update function needs to be modified so that it doesnt update everything
    required LivitEvent event,
    required String location,
    required String title,
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
        LivitEvent.titleColumn: title,
        LivitEvent.locationColumn: location,
      },
      where: 'id = ?',
      whereArgs: [event.id],
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

  Future<LivitUser> getUserWithId({
    required String id,
  }) async {
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

  // Future<LivitUser> createUser({
  //   required String userId,
  // }) async {
  //   await _ensureDbIsOpen();
  //   final db = _getDatabaseOrThrow();
  //   final results = await db.query(
  //     LivitDB.usersTableName,
  //     limit: 1,
  //     where: 'id = ?',
  //     whereArgs: [userId],
  //   );
  //   if (results.isNotEmpty) {
  //     throw UserAlreadyExists();
  //   }
  //   await db.insert(
  //     LivitDB.usersTableName,
  //     {
  //       LivitUser.idColumn: userId,
  //     },
  //   );
  //   return LivitUser(
  //     id: userId,
  //   );
  // }

  // Future<LivitUser> getOrCreateUser({
  //   required String userId,
  //   required UserType? userType,
  // }) async {
  //   try {
  //     final user = await getUserWithId(id: userId);
  //     return user;
  //   } on UserNotFound {
  //     final user = await createUser(userId: userId);
  //     return user;
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // Future<void> deleteUser({required String username}) async {
  //   await _ensureDbIsOpen();
  //   final db = _getDatabaseOrThrow();
  //   final deleteCount = await db.delete(
  //     LivitDB.usersTableName,
  //     where: 'username = ?',
  //     whereArgs: [username],
  //   );
  //   if (deleteCount != 1) {
  //     throw CouldNotDeleteUser();
  //   } else {}
  // }

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
    try {
      await db.insert(
        LivitDB.usersTableName,
        {
          LivitUser.idColumn: userId,
          LivitUser.usernameColumn: "$userId-livitUser",
        },
      );
      return LivitUser(
        id: userId,
        username: userId,
      );
    } catch (e) {
      throw CouldNotCreateUser();
    }
  }

  Future<LivitUser> getOrCreateUser({
    required String userId,
    bool setAsCurrentUser = true,
  }) async {
    try {
      final user = await getUserWithId(id: userId);
      if (setAsCurrentUser) {
        _user = user;
      }
      return user;
    } on UserNotFound {
      try {
        final user = await createUser(
          userId: userId,
        );
        if (setAsCurrentUser) {
          _user = user;
        }
        return user;
      } on CouldNotCreateUser {
        throw CouldNotCreateNorGetUser();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUser({required String id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(
      LivitDB.usersTableName,
      where: 'id = ?',
      whereArgs: [id],
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

      //databaseFactory.deleteDatabase(dbPath);

      final db = await openDatabase(dbPath);
      _db = db;

      await db.execute(createUsersTable);

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
      //print('database already open');
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
	"promoter_id"	TEXT NOT NULL,
	"title"	TEXT NOT NULL,
	"location"	TEXT NOT NULL,
	"is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("promoter_id") REFERENCES "events"("id")
);''';

  static const createUsersTable =
      '''CREATE TABLE IF NOT EXISTS "users" ("id"	TEXT NOT NULL UNIQUE,	"username"	TEXT NOT NULL UNIQUE,	PRIMARY KEY("id"))''';
}
