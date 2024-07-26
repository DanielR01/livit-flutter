import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;
import 'package:path/path.dart' show join;

@immutable
class LivitUser {
  final int id;
  final String name;
  final String? phoneNumber;
  final String username;

  const LivitUser({
    required this.id,
    this.phoneNumber,
    required this.name,
    required this.username,
  });

  static const idColumn = 'id';
  static const phoneNumberColumn = 'phone_number';
  static const usernameColumn = 'username';
  static const nameColumn = 'name';

  LivitUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        phoneNumber = map[phoneNumberColumn] as String,
        name = map[nameColumn] as String,
        username = map[usernameColumn] as String;

  @override
  String toString() =>
      'User, Id = $id, phone number = $phoneNumber, name = $name, username = $username';

  @override
  bool operator ==(covariant LivitUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}
