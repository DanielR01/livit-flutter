import 'package:cloud_firestore/cloud_firestore.dart';

class LivitUser {
  final String id;
  final String username;
  final String name;
  final String email;
  final String userType;
  final String profilePicture;
  final String location;
  final String description;
  final String phoneNumber;
  final List<String> friends;
  final List<String> attendingEvents;
  final List<String> likedEvents;
  final List<String> ownedTickets;
  final bool shareAttendingEvents;
  final bool isProfileCompleted;
  final List<String> interests;

  // Constructor
  LivitUser({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.userType,
    required this.profilePicture,
    required this.location,
    required this.description,
    required this.phoneNumber,
    required this.friends,
    required this.attendingEvents,
    required this.likedEvents,
    required this.ownedTickets,
    required this.shareAttendingEvents,
    required this.isProfileCompleted,
    required this.interests,
  });

    LivitUser copyWith({
    String? id,
    String? name,
    String? username,
    String? userType,
    String? email,
    String? profilePicture,
    String? location,
    String? description,
    String? phoneNumber,
    List<String>? friends,
    List<String>? attendingEvents,
    List<String>? likedEvents,
    List<String>? ownedTickets,
    bool? shareAttendingEvents,
    bool? isProfileCompleted,
    List<String>? interests,
  }) {
    return LivitUser(
      id: this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      userType: userType ?? this.userType,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
      location: location ?? this.location,
      description: description ?? this.description,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      friends: friends ?? this.friends,
      attendingEvents: attendingEvents ?? this.attendingEvents,
      likedEvents: likedEvents ?? this.likedEvents,
      ownedTickets: ownedTickets ?? this.ownedTickets,
      shareAttendingEvents: shareAttendingEvents ?? this.shareAttendingEvents,
      isProfileCompleted: isProfileCompleted ?? this.isProfileCompleted,
      interests: interests ?? this.interests,
    );
  }

  // Factory method to create a User from Firestore document snapshot
  factory LivitUser.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return LivitUser(
      id: data['userId'],
      username: data['username'],
      name: data['name'],
      email: data['email'],
      userType: data['userType'],
      profilePicture: data['profilePicture'] ?? '',
      location: data['location'] ?? '',
      description: data['description'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      friends: List<String>.from(data['friends'] ?? []),
      attendingEvents: List<String>.from(data['attendingEvents'] ?? []),
      likedEvents: List<String>.from(data['likedEvents'] ?? []),
      ownedTickets: List<String>.from(data['ownedTickets'] ?? []),
      shareAttendingEvents: data['privacySettings']['shareAttendingEvents'] ?? false,
      isProfileCompleted: data['isProfileCompleted'] ?? false,
      interests: List<String>.from(data['interests'] ?? []),
    );
  }

  // Method to convert the User object to a Firestore-compatible map (for updates)
  Map<String, Object?> toMap() {
    return {
      'userId': id,
      'username': username,
      'name': name,
      'email': email,
      'userType': userType,
      'profilePicture': profilePicture,
      'location': location,
      'description': description,
      'phoneNumber': phoneNumber,
      'friends': friends,
      'attendingEvents': attendingEvents,
      'likedEvents': likedEvents,
      'ownedTickets': ownedTickets,
      'privacySettings': {
        'shareAttendingEvents': shareAttendingEvents,
      },
      'isProfileCompleted': isProfileCompleted,
      'interests': interests,
    };
  }

  @override
  String toString() {
    return 'LivitUser(id: $id, username: $username, name: $name, email: $email, userType: $userType, profilePicture: $profilePicture, location: $location, description: $description, phoneNumber: $phoneNumber, friends: $friends, attendingEvents: $attendingEvents, likedEvents: $likedEvents, ownedTickets: $ownedTickets, shareAttendingEvents: $shareAttendingEvents, isProfileCompleted: $isProfileCompleted, interests: $interests)';
  }
}
