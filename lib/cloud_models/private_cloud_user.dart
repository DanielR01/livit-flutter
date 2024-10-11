import 'package:cloud_firestore/cloud_firestore.dart';

class PrivateCloudUser {
  final String id;
  final String username;
  final String name;
  final String email;
  final String phoneNumber;
  final String userType;
  final Map<String, List<String>> media;
  final String location;
  final String description;
  final bool isProfileCompleted;
  final Timestamp createdAt;

  // Constructor
  PrivateCloudUser({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.userType,
    required this.media,
    required this.location,
    required this.description,
    required this.isProfileCompleted,
    required this.createdAt,
  });

  PrivateCloudUser copyWith({
    String? id,
    String? name,
    String? username,
    String? userType,
    String? email,
    String? phoneNumber,
    Map<String, List<String>>? media,
    String? location,
    String? description,
    bool? isProfileCompleted,
    Timestamp? createdAt,
  }) {
    return PrivateCloudUser(
      id: this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      userType: userType ?? this.userType,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      media: media ?? this.media,
      location: location ?? this.location,
      description: description ?? this.description,
      isProfileCompleted: isProfileCompleted ?? this.isProfileCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Factory method to create a User from Firestore document snapshot
  factory PrivateCloudUser.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    if (data['userType'] == 'customer') {
      return PrivateCloudCustomer.fromFirestore(doc);
    } else if (data['userType'] == 'promoter') {
      return PrivateCloudPromoter.fromFirestore(doc);
    } else {
      throw Exception('Invalid user type');
    }
  }

  // Method to convert the User object to a Firestore-compatible map (for updates)
  Map<String, Object?> toMap() {
    return {
      'userId': id,
      'username': username,
      'name': name,
      'email': email,
      'userType': userType,
      'media': media,
      'location': location,
      'description': description,
      'phoneNumber': phoneNumber,
      'isProfileCompleted': isProfileCompleted,
      'createdAt': createdAt,
    };
  }

  @override
  String toString() {
    return 'CloudUser(id: $id, username: $username, name: $name, email: $email, userType: $userType, media: $media, location: $location, description: $description, phoneNumber: $phoneNumber, isProfileCompleted: $isProfileCompleted, createdAt: $createdAt)';
  }
}

class PrivateCloudCustomer extends PrivateCloudUser {
  final List<String> interests;
  final Map<String, bool> privacySettings;

  PrivateCloudCustomer({
    required super.id,
    required super.username,
    required super.name,
    required super.email,
    required super.phoneNumber,
    required super.media,
    required super.location,
    required super.description,
    required super.isProfileCompleted,
    required super.createdAt,
    required this.interests,
    required this.privacySettings,
  }) : super(userType: 'customer');

  factory PrivateCloudCustomer.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return PrivateCloudCustomer(
      id: data['userId'],
      username: data['username'],
      name: data['name'],
      email: data['email'],
      phoneNumber: data['phoneNumber'],
      media: data['media'],
      location: data['location'],
      description: data['description'],
      isProfileCompleted: data['isProfileCompleted'],
      createdAt: data['createdAt'],
      interests: List<String>.from(data['interests'] ?? []),
      privacySettings: Map<String, bool>.from(data['privacySettings'] ?? {}),
    );
  }
}

class PrivateCloudPromoter extends PrivateCloudUser {
  final List<String> managedEvents;
  final List<String> tagsOfInterest;

  PrivateCloudPromoter({
    required super.id,
    required super.username,
    required super.name,
    required super.email,
    required super.phoneNumber,
    required super.media,
    required super.location,
    required super.description,
    required super.isProfileCompleted,
    required super.createdAt,
    required this.managedEvents,
    required this.tagsOfInterest,
  }) : super(userType: 'promoter');

  factory PrivateCloudPromoter.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return PrivateCloudPromoter(
      id: data['userId'],
      username: data['username'],
      name: data['name'],
      email: data['email'],
      phoneNumber: data['phoneNumber'],
      media: data['media'],
      location: data['location'],
      description: data['description'],
      isProfileCompleted: data['isProfileCompleted'],
      createdAt: data['createdAt'],
      managedEvents: List<String>.from(data['managedEvents'] ?? []),
      tagsOfInterest: List<String>.from(data['tagsOfInterest'] ?? []),
    );
  }
}
