import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livit/models/ticket/ticket.dart';
import 'package:livit/constants/enums.dart';

class UserPrivateData {
  final String phoneNumber;
  final String email;
  final UserType userType;

  UserPrivateData({
    required this.phoneNumber,
    required this.email,
    required this.userType,
  });

  factory UserPrivateData.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    if (data['userType'] == UserType.promoter.name) {
      return PromoterPrivateData.fromDocument(doc);
    }

    return UserPrivateData(
      phoneNumber: data['phoneNumber'],
      email: data['email'],
      userType: UserType.values.byName(data['userType']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phoneNumber': phoneNumber,
      'email': email,
      'userType': userType.name,
    };
  }

  @override
  String toString() {
    return 'PrivateData(phoneNumber: $phoneNumber, email: $email, userType: $userType)';
  }
}

class PromoterPrivateData extends UserPrivateData {
  final List<String?> defaultScanners;
  final List<LivitTicket?> defaultTickets;

  PromoterPrivateData({
    required super.phoneNumber,
    required super.email,
    required super.userType,
    required this.defaultScanners,
    required this.defaultTickets,
  });

  factory PromoterPrivateData.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final List<String?> defaultScanners = (data['defaultScanners'] as List<dynamic>?)?.map((e) => e as String?).toList() ?? [];
    final List<LivitTicket?> defaultTickets = (data['defaultTickets'] as List<dynamic>?)?.map((e) => LivitTicket.fromMap(e)).toList() ?? [];

    final PromoterPrivateData privatePromoterData = PromoterPrivateData(
      phoneNumber: data['phoneNumber'],
      email: data['email'],
      userType: UserType.values.byName(data['userType']),
      defaultScanners: defaultScanners,
      defaultTickets: defaultTickets,
    );

    return privatePromoterData;
  }

  @override
  String toString() {
    return 'PrivatePromoterData(phoneNumber: $phoneNumber, email: $email, userType: $userType, defaultScanners: $defaultScanners, defaultTickets: $defaultTickets)';
  }
}
