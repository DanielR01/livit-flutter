import 'package:flutter/foundation.dart';
import 'package:livit/services/crud/livit_db_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;
import 'package:path/path.dart' show join;

@immutable
class LivitUser {
  final String id;
  final String username;

  const LivitUser({
    required this.id,
    required this.username,
  });

  static const idColumn = 'id';
  static const usernameColumn = 'username';
  static const userTypeColumn = "usertype";

  LivitUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as String,
        username = map[usernameColumn] as String;

  @override
  String toString() => 'User, Id = $id, username = $username';

  @override
  bool operator ==(covariant LivitUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}
