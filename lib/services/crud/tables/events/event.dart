import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;
import 'package:path/path.dart' show join;

@immutable
class LivitEvent {
  final int id;
  final int promoterId;
  final String name;
  final String location;
  const LivitEvent({
    required this.id,
    required this.promoterId,
    required this.name,
    required this.location,
  });

  LivitEvent.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        promoterId = map[promoterIdColumn] as int,
        name = map[nameColumn] as String,
        location = map[locationColumn] as String;

  static const idColumn = 'id';
  static const promoterIdColumn = 'promoter_id';
  static const nameColumn = 'name';
  static const locationColumn = 'location';

  @override
  String toString() =>
      'Event, Id = $id, promoterId = $promoterId, name = $name, location: $location';

  @override
  bool operator ==(covariant LivitEvent other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}
