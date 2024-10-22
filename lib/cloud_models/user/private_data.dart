import 'package:cloud_firestore/cloud_firestore.dart';

class PrivateData {
  final String phoneNumber;
  final String email;
  final bool isProfileCompleted;

  PrivateData({
    required this.phoneNumber,
    required this.email,
    required this.isProfileCompleted,
  });

  PrivateData copyWith({
    String? phoneNumber,
    String? email,
    bool? isProfileCompleted,
  }) {
    return PrivateData(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      isProfileCompleted: isProfileCompleted ?? this.isProfileCompleted,
    );
  }

  factory PrivateData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return PrivateData(
      phoneNumber: data['phoneNumber'],
      email: data['email'],
      isProfileCompleted: data['isProfileCompleted'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phoneNumber': phoneNumber,
      'email': email,
      'isProfileCompleted': isProfileCompleted,
    };
  }

  @override
  String toString() {
    return 'PrivateData(phoneNumber: $phoneNumber, email: $email, isProfileCompleted: $isProfileCompleted)';
  }
}
