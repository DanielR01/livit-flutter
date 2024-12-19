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

  factory UserPrivateData.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    if (data['userType'] == UserType.promoter.name) {
      return PromoterPrivateData.fromDocument(doc);
    }

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

class PromoterPrivateData extends UserPrivateData {
  final bool noLocations;
  final List<String?> defaultScanners;
  final List<Ticket?> defaultTickets;

  PromoterPrivateData(
      {required super.phoneNumber,
      required super.email,
      required super.userType,
      required super.isProfileCompleted,
      required this.defaultScanners,
      required this.defaultTickets,
      required this.noLocations});

  factory PromoterPrivateData.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final List<String?> defaultScanners = (data['defaultScanners'] as List<dynamic>?)?.map((e) => e as String?).toList() ?? [];
    final List<Ticket?> defaultTickets = (data['defaultTickets'] as List<dynamic>?)?.map((e) => Ticket.fromMap(e)).toList() ?? [];

    final PromoterPrivateData privatePromoterData = PromoterPrivateData(
      phoneNumber: data['phoneNumber'],
      email: data['email'],
      userType: UserType.values.byName(data['userType']),
      defaultScanners: defaultScanners,
      defaultTickets: defaultTickets,
      isProfileCompleted: data['isProfileCompleted'],
      noLocations: data['noLocations'],
    );

    return privatePromoterData;
  }

  @override
  String toString() {
    return 'PrivatePromoterData(phoneNumber: $phoneNumber, email: $email, userType: $userType, isProfileCompleted: $isProfileCompleted, defaultScanners: $defaultScanners, defaultTickets: $defaultTickets, noLocations: $noLocations)';
  }
}
