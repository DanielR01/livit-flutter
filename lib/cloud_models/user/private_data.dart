import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livit/cloud_models/ticket/ticket.dart';
import 'package:livit/constants/enums.dart';

class UserPrivateData {
  final String phoneNumber;
  final String email;
  final UserType userType;
  final bool isProfileCompleted;

  UserPrivateData({
    required this.phoneNumber,
    required this.email,
    required this.userType,
    required this.isProfileCompleted,
  });

  UserPrivateData copyWith({
    String? phoneNumber,
    String? email,
    UserType? userType,
    bool? isProfileCompleted,
  }) {
    return UserPrivateData(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      userType: userType ?? this.userType,
      isProfileCompleted: isProfileCompleted ?? this.isProfileCompleted,
    );
  }

  factory UserPrivateData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserPrivateData(
      phoneNumber: data['phoneNumber'],
      email: data['email'],
      userType: UserType.values.byName(data['userType']),
      isProfileCompleted: data['isProfileCompleted'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phoneNumber': phoneNumber,
      'email': email,
      'userType': userType.name,
      'isProfileCompleted': isProfileCompleted,
    };
  }

  @override
  String toString() {
    return 'PrivateData(phoneNumber: $phoneNumber, email: $email, userType: $userType, isProfileCompleted: $isProfileCompleted)';
  }
}

class PrivatePromoterData extends UserPrivateData {
  final List<String> defaultScanners;
  final List<Ticket> defaultTickets;

  PrivatePromoterData(
      {required super.phoneNumber,
      required super.email,
      required super.userType,
      required this.defaultScanners,
      required this.defaultTickets,
      required super.isProfileCompleted});
}
