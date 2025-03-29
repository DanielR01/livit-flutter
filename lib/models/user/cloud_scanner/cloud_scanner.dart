part of '../cloud_user.dart';

final _debugger = LivitDebugger('cloud_scanner', isDebugEnabled: false);

class CloudScanner extends CloudUser {
  final bool credentialsSent;
  final Timestamp? credentialsSentAt;
  final List<String?>? eventIds;
  final List<String?>? locationIds;
  final String promoterId;
  final String email;
  final String name;

  CloudScanner({
    required super.id,
    required super.userType,
    required super.createdAt,
    required this.credentialsSent,
    required this.credentialsSentAt,
    required this.eventIds,
    required this.locationIds,
    required this.promoterId,
    required this.email,
    required this.name,
  });

  factory CloudScanner.fromDocument(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>;
      _debugger.debPrint('Raw Data: $data', DebugMessageType.reading);

      // Extract and debug print each field
      final id = doc.id;
      _debugger.debPrint('id: $id', DebugMessageType.info);

      final email = data['email'] as String;
      _debugger.debPrint('email: $email', DebugMessageType.info);

      final createdAt = data['createdAt'] as Timestamp;
      _debugger.debPrint('createdAt: $createdAt', DebugMessageType.info);

      final credentialsSent = data['credentialsSent'] as bool;
      _debugger.debPrint('credentialsSent: $credentialsSent', DebugMessageType.info);

      final credentialsSentAt = data['credentialsSentAt'] as Timestamp?;
      _debugger.debPrint('credentialsSentAt: $credentialsSentAt', DebugMessageType.info);

      final eventIdsRaw = data['eventIds'] as List<dynamic>?;
      _debugger.debPrint('raw eventIds: $eventIdsRaw', DebugMessageType.info);
      final eventIds = eventIdsRaw?.cast<String?>();
      _debugger.debPrint('parsed eventIds: $eventIds', DebugMessageType.info);

      final locationIdsRaw = data['locationIds'] as List<dynamic>?;
      _debugger.debPrint('raw locationIds: $locationIdsRaw', DebugMessageType.info);
      final locationIds = locationIdsRaw?.cast<String?>();
      _debugger.debPrint('parsed locationIds: $locationIds', DebugMessageType.info);

      final promoterId = data['promoterId'] as String;
      _debugger.debPrint('promoterId: $promoterId', DebugMessageType.info);

      final name = data['name'] as String;
      _debugger.debPrint('name: $name', DebugMessageType.info);

      _debugger.debPrint('All fields extracted successfully', DebugMessageType.done);

      return CloudScanner(
        id: id,
        email: email,
        userType: UserType.scanner,
        createdAt: createdAt,
        credentialsSent: credentialsSent,
        credentialsSentAt: credentialsSentAt,
        eventIds: eventIds,
        locationIds: locationIds,
        promoterId: promoterId,
        name: name,
      );
    } catch (e, stackTrace) {
      _debugger.debPrint('Error creating CloudScanner: $e', DebugMessageType.error);
      ErrorReporter(viewName: 'CloudScanner.fromDocument').reportError(e, stackTrace);
      rethrow;
    }
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'credentialsSent': credentialsSent,
      'credentialsSentAt': credentialsSentAt,
      'eventIds': eventIds,
      'locationIds': locationIds,
      'promoterId': promoterId,
      'userType': userType.name,
      'createdAt': createdAt,
      'name': name,
    };
  }

  @override
  CloudScanner copyWith({
    String? id,
    String? email,
    UserType? userType,
    Timestamp? createdAt,
    bool? credentialsSent,
    Timestamp? credentialsSentAt,
    List<String?>? eventIds,
    List<String?>? locationIds,
    String? promoterId,
    String? name,
  }) {
    return CloudScanner(
      id: id ?? this.id,
      email: email ?? this.email,
      userType: userType ?? this.userType,
      createdAt: createdAt ?? this.createdAt,
      credentialsSent: credentialsSent ?? this.credentialsSent,
      credentialsSentAt: credentialsSentAt ?? this.credentialsSentAt,
      eventIds: eventIds ?? this.eventIds,
      locationIds: locationIds ?? this.locationIds,
      promoterId: promoterId ?? this.promoterId,
      name: name ?? this.name,
    );
  }

  @override
  String toString() {
    return 'CloudScanner(id: $id, name: $name, email: $email, userType: $userType, createdAt: $createdAt, credentialsSent: $credentialsSent, credentialsSentAt: $credentialsSentAt, eventIds: $eventIds, locationIds: $locationIds, promoterId: $promoterId)';
  }
}
