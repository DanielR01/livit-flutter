import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;
import 'package:path/path.dart' show join;

@immutable
class LivitPromoter {
  final int id;
  final String username;
  final String email;
  final String name;

  const LivitPromoter({
    required this.id,
    required this.username,
    required this.email,
    required this.name,
  });

  LivitPromoter.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        name = map[nameColumn] as String,
        username = map[usernameColumn] as String,
        email = map[emailColumn] as String;

  static const idColumn = 'id';
  static const emailColumn = 'email';
  static const nameColumn = 'name';
  static const usernameColumn = 'username';
  @override
  String toString() => 'Promoter, Id = $id, name = $name, email = $email';

  @override
  bool operator ==(covariant LivitPromoter other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}
