import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livit/cloud_models/cloud_models_exceptions.dart';
import 'package:livit/constants/enums.dart';

class CloudUser {
  final String id;
  final String username;
  final UserType userType;
  final String name;
  final DateTime createdAt;
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
    DateTime? createdAt,
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
      createdAt: (data['createdAt'] as Timestamp).toDate(),
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
    DateTime? createdAt,
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

  CloudPromoter({
    required super.id,
    required super.username,
    required super.userType,
    required super.name,
    required super.createdAt,
    required super.interests,
    required this.description,
  });

  @override
  CloudPromoter copyWith({
    String? id,
    String? username,
    UserType? userType,
    String? name,
    List<String?>? interests,
    DateTime? createdAt,
    String? description,
  }) {
    return CloudPromoter(
      id: id ?? this.id,
      username: username ?? this.username,
      userType: userType ?? this.userType,
      name: name ?? this.name,
      interests: interests ?? this.interests,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
    
    );
  }

  @override
  String toString() {
    return 'CloudPromoter(id: $id, username: $username, userType: $userType, name: $name, interests: $interests, createdAt: $createdAt, description: $description)';
  }

  factory CloudPromoter.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final id = doc.id;
    final username = data['username'] as String;
    final userType = UserType.values.firstWhere((e) => e.name == data['userType'] as String);
    final name = data['name'] as String;
    final interests = (data['interests'] as List<dynamic>?)?.cast<String>();
    final createdAt = (data['createdAt'] as Timestamp).toDate();
    final description = data['description'] as String?;
    

    return CloudPromoter(
      id: id,
      username: username,
      userType: userType,
      name: name,
      interests: interests,
      createdAt: createdAt,
      description: description,
      
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
    };
  }
}
