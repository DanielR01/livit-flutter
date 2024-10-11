import 'package:cloud_firestore/cloud_firestore.dart';

class PublicCloudUser {
  final String id;
  final String username;
  final String? name;
  final String? email;
  final String? phoneNumber;
  final String userType;
  final Map<String, List<String>> media;
  final String? location;
  final String? description;

  // Constructor
  PublicCloudUser({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.userType,
    required this.media,
    required this.location,
    required this.description,
  });

  PublicCloudUser copyWith({
    String? id,
    String? name,
    String? username,
    String? userType,
    String? email,
    String? phoneNumber,
    Map<String, List<String>>? media,
    String? location,
    String? description,
  }) {
    return PublicCloudUser(
      id: this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      userType: userType ?? this.userType,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      media: media ?? this.media,
      location: location ?? this.location,
      description: description ?? this.description,
    );
  }

  // Factory method to create a User from Firestore document snapshot
  factory PublicCloudUser.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    if (data['userType'] == 'customer') {
      return PublicCloudCustomer.fromFirestore(doc);
    } else if (data['userType'] == 'promoter') {
      return PublicCloudPromoter.fromFirestore(doc);
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
    };
  }

  @override
  String toString() {
    return 'CloudUser(id: $id, username: $username, name: $name, email: $email, userType: $userType, media: $media, location: $location, description: $description, phoneNumber: $phoneNumber)';
  }
}

class PublicCloudCustomer extends PublicCloudUser {
  final List<String>? interests;

  PublicCloudCustomer({
    required super.id,
    required super.username,
    required super.name,
    required super.email,
    required super.phoneNumber,
    required super.media,
    required super.location,
    required super.description,
    required this.interests,
  }) : super(userType: 'customer');

  factory PublicCloudCustomer.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return PublicCloudCustomer(
      id: data['userId'],
      username: data['username'],
      name: data['name'],
      email: data['email'],
      phoneNumber: data['phoneNumber'],
      media: data['media'],
      location: data['location'],
      description: data['description'],
      interests: List<String>.from(data['interests'] ?? []),
    );
  }
}

class PublicCloudPromoter extends PublicCloudUser {
  final List<String> managedEvents;
  final List<String> tagsOfInterest;
  PublicCloudPromoter({
    required super.id,
    required super.username,
    required super.name,
    required super.email,
    required super.phoneNumber,
    required super.media,
    required super.location,
    required super.description,
    required this.managedEvents,
    required this.tagsOfInterest,
  }) : super(userType: 'promoter');

  factory PublicCloudPromoter.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return PublicCloudPromoter(
      id: data['userId'],
      username: data['username'],
      name: data['name'],
      email: data['email'],
      phoneNumber: data['phoneNumber'],
      media: data['media'],
      location: data['location'],
      description: data['description'],
      managedEvents: List<String>.from(data['managedEvents'] ?? []),
      tagsOfInterest: List<String>.from(data['tagsOfInterest'] ?? []),
    );
  }
}
