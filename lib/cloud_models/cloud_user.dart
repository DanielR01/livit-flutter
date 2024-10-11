import 'package:cloud_firestore/cloud_firestore.dart';

class CloudUser {
  final String id;
  final String username;
  final String userType;
  final String name;
  
  CloudUser({
    required this.id,
    required this.username,
    required this.userType,
    required this.name,
  });

  CloudUser copyWith({
    String? id,
    String? username,
    String? userType,
    String? name,
  }) {
    return CloudUser(
      id: id ?? this.id,
      username: username ?? this.username,
      userType: userType ?? this.userType,
      name: name ?? this.name,
    );
  }

  factory CloudUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return CloudUser(
      id: data['userId'],
      username: data['username'],
      userType: data['userType'],
      name: data['name'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'userType': userType,
      'name': name,
    };
  }

  @override
  String toString() {
    return 'CloudUser(id: $id, username: $username, userType: $userType, name: $name)';
  }

}
