import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livit/cloud_models/cloud_models_exceptions.dart';
import 'package:livit/cloud_models/location.dart';
import 'package:livit/constants/enums.dart';

class CloudUser {
  final String id;
  final String username;
  final UserType userType;
  final String name;
  final Timestamp createdAt;
  final List<String?>? interests;

  CloudUser({
    required this.id,
    required this.username,
    required this.userType,
    required this.name,
    required this.createdAt,
    required this.interests,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'userType': userType.name,
      'name': name,
      'interests': interests,
      'createdAt': createdAt,
    };
  }

  CloudUser copyWith({
    String? id,
    String? username,
    UserType? userType,
    String? name,
    List<String?>? interests,
    Timestamp? createdAt,
  }) {
    return CloudUser(
      id: id ?? this.id,
      username: username ?? this.username,
      userType: userType ?? this.userType,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      interests: interests ?? this.interests,
    );
  }

  factory CloudUser.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    if (data['userType'] == UserType.customer.name) {
      return CloudCustomer.fromDocument(doc);
    } else if (data['userType'] == UserType.promoter.name) {
      return CloudPromoter.fromDocument(doc);
    }

    throw InvalidUserTypeException();
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
  });

  factory CloudCustomer.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CloudCustomer(
      id: doc.id,
      username: data['username'] as String,
      userType: UserType.values.firstWhere((e) => e.name == data['userType'] as String),
      name: data['name'] as String,
      interests: (data['interests'] as List<dynamic>?)?.cast<String>(),
      createdAt: data['createdAt'] as Timestamp,
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
  }) {
    return CloudCustomer(
      id: id ?? this.id,
      username: username ?? this.username,
      userType: userType ?? this.userType,
      name: name ?? this.name,
      interests: interests ?? this.interests,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'CloudCustomer(id: $id, username: $username, userType: $userType, name: $name, interests: $interests, createdAt: $createdAt)';
  }
}

class CloudPromoter extends CloudUser {
  final String? description;
  final Location? location;

  CloudPromoter({
    required super.id,
    required super.username,
    required super.userType,
    required super.name,
    required super.createdAt,
    required super.interests,
    required this.description,
    required this.location,
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
    Location? location,
  }) {
    return CloudPromoter(
      id: id ?? this.id,
      username: username ?? this.username,
      userType: userType ?? this.userType,
      name: name ?? this.name,
      interests: interests ?? this.interests,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      location: location ?? this.location,
    );
  }

  @override
  String toString() {
    return 'CloudPromoter(id: $id, username: $username, userType: $userType, name: $name, interests: $interests, createdAt: $createdAt, description: $description, location: $location)';
  }

  factory CloudPromoter.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return CloudPromoter(
      id: doc.id,
      username: data['username'] as String,
      userType: UserType.values.firstWhere((e) => e.name == data['userType'] as String),
      name: data['name'] as String,
      interests: (data['interests'] as List<dynamic>?)?.cast<String>(),
      createdAt: data['createdAt'] as Timestamp,
      description: data['description'] as String?,
      location: data['location'] as Location?,
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
      'location': location,
    };
  }
}
