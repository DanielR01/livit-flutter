part of '../cloud_user.dart';

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
      debugPrint('🔄 [CloudScanner.fromDocument] Raw Data: $data');

      // Extract and debug print each field
      final id = doc.id;
      debugPrint('📄 [CloudScanner.fromDocument] id: $id');

      final email = "${doc.id}@scanners.thelivitapp.com";
      debugPrint('📄 [CloudScanner.fromDocument] email: $email');

      final createdAt = data['createdAt'] as Timestamp;
      debugPrint('📄 [CloudScanner.fromDocument] createdAt: $createdAt');

      final credentialsSent = data['credentialsSent'] as bool;
      debugPrint('📄 [CloudScanner.fromDocument] credentialsSent: $credentialsSent');

      final credentialsSentAt = data['credentialsSentAt'] as Timestamp?;
      debugPrint('📄 [CloudScanner.fromDocument] credentialsSentAt: $credentialsSentAt');

      final eventIdsRaw = data['eventIds'] as List<dynamic>?;
      debugPrint('📄 [CloudScanner.fromDocument] raw eventIds: $eventIdsRaw');
      final eventIds = eventIdsRaw?.cast<String?>();
      debugPrint('📄 [CloudScanner.fromDocument] parsed eventIds: $eventIds');

      final locationIdsRaw = data['locationIds'] as List<dynamic>?;
      debugPrint('📄 [CloudScanner.fromDocument] raw locationIds: $locationIdsRaw');
      final locationIds = locationIdsRaw?.cast<String?>();
      debugPrint('📄 [CloudScanner.fromDocument] parsed locationIds: $locationIds');

      final promoterId = data['promoterId'] as String;
      debugPrint('📄 [CloudScanner.fromDocument] promoterId: $promoterId');

      final name = data['name'] as String;
      debugPrint('📄 [CloudScanner.fromDocument] name: $name');

      debugPrint('✅ [CloudScanner.fromDocument] All fields extracted successfully');

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
      debugPrint('❌ [CloudScanner.fromDocument] Error creating CloudScanner: $e');
      debugPrint('Stack trace: $stackTrace');
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
