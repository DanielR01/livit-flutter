import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livit/cloud_models/ticket/ticket.dart';
import 'package:livit/constants/enums.dart';

class UserPrivateData {
  final String phoneNumber;
  final String email;
  final UserType userType;
  final bool isFirstTime; 

  UserPrivateData({
    required this.phoneNumber,
    required this.email,
    required this.userType,
    required this.isFirstTime,
  });

  UserPrivateData copyWith({
    String? phoneNumber,
    String? email,
    UserType? userType,
    bool? isFirstTime,
  }) {
    return UserPrivateData(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      userType: userType ?? this.userType,
      isFirstTime: isFirstTime ?? this.isFirstTime,
    );
  }

  factory UserPrivateData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserPrivateData(
      phoneNumber: data['phoneNumber'],
      email: data['email'],
      userType: UserType.values.byName(data['userType']),
      isFirstTime: data['isFirstTime'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phoneNumber': phoneNumber,
      'email': email,
      'userType': userType.name,
      'isFirstTime': isFirstTime,
    };
  }

  @override
  String toString() {
    return 'PrivateData(phoneNumber: $phoneNumber, email: $email, userType: $userType, isFirstTime: $isFirstTime)';
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
      required super.isFirstTime});
}
