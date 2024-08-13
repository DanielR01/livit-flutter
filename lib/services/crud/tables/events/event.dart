import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;
import 'package:path/path.dart' show join;

@immutable
class LivitEvent {
  final int id;
  // final String promoterId;
  final String title;
  final String description;
  final String location;
  final String date;
  const LivitEvent({
    required this.id,
    // required this.promoterId,
    required this.title,
    this.description = '',
    required this.date,
    required this.location,
  });

  LivitEvent.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        // promoterId = map[promoterIdColumn] as String,
        title = map[titleColumn] as String,
        location = map[locationColumn] as String,
        description = map[descriptionColumn] as String,
        date = map[dateColumn] as String;

  static const idColumn = 'id';
  static const promoterIdColumn = 'promoter_id';
  static const titleColumn = 'title';
  static const locationColumn = 'location';
  static const descriptionColumn = 'description';
  static const dateColumn = 'date';

  @override
  String toString() =>
      'Event, Id = $id, promoterId = promoterId, title = $title, location: $location, description: $description, date: $date';

  @override
  bool operator ==(covariant LivitEvent other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}
