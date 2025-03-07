part of '../cloud_user.dart';

class CloudCustomer extends CloudUser {
  final String username;
  final String name;
  final List<String?>? interests;
  final bool isProfileCompleted;

  CloudCustomer({
    required super.id,
    required this.username,
    required super.userType,
    required this.name,
    required super.createdAt,
    required this.interests,
    required this.isProfileCompleted,
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
