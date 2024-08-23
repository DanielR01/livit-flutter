import 'package:flutter/foundation.dart';

@immutable
class LivitEvent {
  final int id;
  final String creatorId;
  final String title;
  final String location;
  const LivitEvent({
    required this.id,
    required this.creatorId,
    required this.title,
    required this.location,
  });

  LivitEvent.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        creatorId = map[creatorIdColumn] as String,
        title = map[titleColumn] as String,
        location = map[locationColumn] as String;

  static const idColumn = 'id';
  static const creatorIdColumn = 'promoter_id';
  static const titleColumn = 'title';
  static const locationColumn = 'location';

  @override
  String toString() =>
      'Event, Id = $id, creatorId = $creatorId, title = $title, location: $location';

  @override
  bool operator ==(covariant LivitEvent other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}
