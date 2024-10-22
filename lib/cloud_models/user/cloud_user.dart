import 'package:cloud_firestore/cloud_firestore.dart';

class CloudUser {
  final String id;
  final String username;
  final String userType;
  final String name;
  final Timestamp createdAt;
  final List<String?> interests;

  CloudUser({
    required this.id,
    required this.username,
    required this.userType,
    required this.name,
    required this.interests,
    required this.createdAt,
  });

  CloudUser copyWith({
    String? id,
    String? username,
    String? userType,
    String? name,
    List<String?>? interests,
    Timestamp? createdAt,
  }) {
    return CloudUser(
      id: id ?? this.id,
      username: username ?? this.username,
      userType: userType ?? this.userType,
      name: name ?? this.name,
      interests: interests ?? this.interests,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory CloudUser.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final String id = doc.id;
    final String username = data['username'] as String;
    final String userType = data['userType'] as String;
    final String name = data['name'] as String;
    final List<String?> interests = (data['interests'] as List<dynamic>?)?.map((interest) => interest.toString()).toList() ?? [];
    final Timestamp createdAt = data['createdAt'] as Timestamp? ?? Timestamp.now();

    return CloudUser(
      id: id,
      username: username,
      userType: userType,
      name: name,
      interests: interests,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'userType': userType,
      'name': name,
      'interests': interests,
      'createdAt': createdAt,
    };
  }

  @override
  String toString() {
    return 'CloudUser(id: $id, username: $username, userType: $userType, name: $name, interests: $interests, createdAt: $createdAt)';
  }
}
