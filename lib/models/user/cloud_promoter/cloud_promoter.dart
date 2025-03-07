part of '../cloud_user.dart';

class CloudPromoter extends CloudUser {
  final String? description;
  final List<String>? locations;
  final List<String?>? interests;
  final bool isProfileCompleted;
  final String username;
  final String name;

  CloudPromoter({
    required super.id,
    required this.username,
    required super.userType,
    required this.name,
    required super.createdAt,
    required this.interests,
    required this.locations,
    required this.description,
    required this.isProfileCompleted,
  });

  @override
  CloudPromoter copyWith({
    String? id,
    String? username,
    UserType? userType,
    String? name,
    List<String?>? interests,
    Timestamp? createdAt,
    String? description,
    List<String>? locations,
    bool? isProfileCompleted,
  }) {
    return CloudPromoter(
      id: id ?? this.id,
      username: username ?? this.username,
      userType: userType ?? this.userType,
      name: name ?? this.name,
      interests: interests ?? this.interests,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      locations: locations ?? this.locations,
      isProfileCompleted: isProfileCompleted ?? this.isProfileCompleted,
    );
  }

  @override
  String toString() {
    return 'CloudPromoter(id: $id, username: $username, userType: $userType, name: $name, interests: $interests, createdAt: $createdAt, description: $description, locations: $locations, isProfileCompleted: $isProfileCompleted)';
  }

  factory CloudPromoter.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final id = doc.id;
    final username = data['username'] as String;
    final userType = UserType.values.firstWhere((e) => e.name == data['userType'] as String);
    final name = data['name'] as String;
    final interests = (data['interests'] as List<dynamic>?)?.cast<String>();
    final createdAt = (data['createdAt'] as Timestamp);
    final description = data['description'] as String?;
    final locations = (data['locations'] as List<dynamic>?)?.cast<String>();
    final isProfileCompleted = data['isProfileCompleted'] as bool;
    return CloudPromoter(
      id: id,
      username: username,
      userType: userType,
      name: name,
      interests: interests,
      createdAt: createdAt,
      description: description,
      locations: locations,
      isProfileCompleted: isProfileCompleted,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'userType': userType.name,
      'name': name,
      'interests': interests,
      'createdAt': createdAt,
      'description': description,
      'locations': locations,
      'isProfileCompleted': isProfileCompleted,
    };
  }
}
