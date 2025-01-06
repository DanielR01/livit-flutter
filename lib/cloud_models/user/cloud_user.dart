import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livit/constants/enums.dart';

class CloudUser {
  final String id;
  final String username;
  final UserType userType;
  final String name;
  final Timestamp createdAt;
  final List<String?>? interests;
  final bool isProfileCompleted;

  CloudUser({
    required this.id,
    required this.username,
    required this.userType,
    required this.name,
    required this.createdAt,
    required this.interests,
    required this.isProfileCompleted,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'userType': userType.name,
      'name': name,
      'interests': interests,
      'createdAt': createdAt,
      'isProfileCompleted': isProfileCompleted,
    };
  }

  CloudUser copyWith({
    String? id,
    String? username,
    UserType? userType,
    String? name,
    List<String?>? interests,
    Timestamp? createdAt,
    bool? isProfileCompleted,
  }) {
    return CloudUser(
      id: id ?? this.id,
      username: username ?? this.username,
      userType: userType ?? this.userType,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      interests: interests ?? this.interests,
      isProfileCompleted: isProfileCompleted ?? this.isProfileCompleted,
    );
  }
}

class CloudCustomer extends CloudUser {
  CloudCustomer({
    required super.id,
    required super.username,
    required super.userType,
    required super.name,
    required super.createdAt,
    required super.interests,
    required super.isProfileCompleted,
  });

  factory CloudCustomer.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CloudCustomer(
      id: doc.id,
      username: data['username'] as String,
      userType: UserType.values.firstWhere((e) => e.name == data['userType'] as String),
      name: data['name'] as String,
      interests: (data['interests'] as List<dynamic>?)?.cast<String>(),
      createdAt: (data['createdAt'] as Timestamp),
      isProfileCompleted: data['isProfileCompleted'] as bool,
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
      'isProfileCompleted': isProfileCompleted,
    };
  }

  @override
  CloudCustomer copyWith({
    String? id,
    String? username,
    UserType? userType,
    String? name,
    List<String?>? interests,
    Timestamp? createdAt,
    bool? isProfileCompleted,
  }) {
    return CloudCustomer(
      id: id ?? this.id,
      username: username ?? this.username,
      userType: userType ?? this.userType,
      name: name ?? this.name,
      interests: interests ?? this.interests,
      createdAt: createdAt ?? this.createdAt,
      isProfileCompleted: isProfileCompleted ?? this.isProfileCompleted,
    );
  }

  @override
  String toString() {
    return 'CloudCustomer(id: $id, username: $username, userType: $userType, name: $name, interests: $interests, createdAt: $createdAt, isProfileCompleted: $isProfileCompleted)';
  }
}

class CloudPromoter extends CloudUser {
  final String? description;
  final List<String>? locations;
  CloudPromoter({
    required super.id,
    required super.username,
    required super.userType,
    required super.name,
    required super.createdAt,
    required super.interests,
    required this.locations,
    required this.description,
    required super.isProfileCompleted,
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
