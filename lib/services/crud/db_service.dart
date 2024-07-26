import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:livit/services/crud/crud_exceptions.dart';
import 'package:livit/services/crud/livit_db.dart';
import 'package:livit/services/crud/tables/events/event.dart';
import 'package:livit/services/crud/tables/promoters/promoter.dart';
import 'package:livit/services/crud/tables/users/user.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'package:sqflite/sqlite_api.dart';

class LivitService {
  Database? _db;

  Future<LivitPromoter> getPromoter({
    required String name,
  }) async {
    final db = _getDatabaseOrThrow();

    final results = await db.query(
      LivitDB.promotersTableName,
      where: 'name = ?',
      whereArgs: [name],
    );

    if (results.isEmpty) {
      throw CouldNotFindPromoter();
    }
    return LivitPromoter.fromRow(results.first);
  }

  Future<LivitPromoter> createPromoter({
    required String name,
    required String email,
    required String username,
  }) async {
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

    final promoterId = await db.insert(
      LivitDB.promotersTableName,
      {
        LivitPromoter.emailColumn: email,
        LivitPromoter.nameColumn: name,
        LivitPromoter.usernameColumn: username,
      },
    );
    return LivitPromoter(
      id: promoterId,
      username: username,
      email: email,
      name: name,
    );
  }

  Future<LivitEvent> getEvent({required int eventId}) async {
    final db = _getDatabaseOrThrow();

    final results = await db.query(
      LivitDB.eventsTableName,
      where: 'id = ?',
      whereArgs: [eventId],
    );

    if (results.isEmpty) {
      throw CouldNotFindEvent();
    }

    return LivitEvent.fromRow(results.first);
  }

  Future<LivitEvent> createEvent({
    required LivitPromoter promoter,
    required String name,
    required String location,
  }) async {
    final db = _getDatabaseOrThrow();

    final dbPromoter = await getPromoter(name: name);

    if (promoter != dbPromoter) {
      throw CouldNotFindPromoter();
    }
    final eventId = await db.insert(
      LivitDB.eventsTableName,
      {
        LivitEvent.promoterIdColumn: promoter.id,
        LivitEvent.locationColumn: location,
        LivitEvent.nameColumn: name,
      },
    );
    return LivitEvent(
      id: eventId,
      promoterId: promoter.id,
      name: name,
      location: location,
    );
  }

  Future<LivitEvent> updateEvent({
    required LivitEvent event,
    required String location,
  }) async {
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
      return await getEvent(eventId: event.id);
    }
  }

  Future<LivitUser> getUser({required String username}) async {
    final db = _getDatabaseOrThrow();

    final results = await db.query(
      LivitDB.usersTableName,
      limit: 1,
      where: 'username = ?',
      whereArgs: [username],
    );

    if (results.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return LivitUser.fromRow(results.first);
    }
  }

  Future<LivitUser> createUser({
    required String username,
    required String name,
  }) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      LivitDB.usersTableName,
      limit: 1,
      where: 'username = ?',
      whereArgs: [username],
    );
    if (results.isNotEmpty) {
      throw UserUsernameAlreadyInUse();
    }
    final userId = await db.insert(
      LivitDB.usersTableName,
      {
        LivitUser.usernameColumn: username,
        LivitUser.nameColumn: name,
      },
    );
    return LivitUser(
      id: userId,
      name: name,
      username: username,
    );
  }

  Future<void> deleteUser({required String username}) async {
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(
      LivitDB.usersTableName,
      where: 'username = ?',
      whereArgs: [username],
    );
    if (deleteCount != 1) {
      throw CouldNotDeleteUser();
    }
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
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
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
	"id"	INTEGER NOT NULL UNIQUE,
	"name"	TEXT NOT NULL,
	"user_name"	TEXT NOT NULL UNIQUE,
	"phone_number"	TEXT UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT)
);''';
}
