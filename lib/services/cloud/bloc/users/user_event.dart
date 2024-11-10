import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livit/constants/enums.dart';

abstract class UserEvent {}

class GetUserWithPrivateData extends UserEvent {}

class SetUserType extends UserEvent {
  final UserType userType;
  SetUserType({required this.userType});
}

class CreateUser extends UserEvent {
  final String name;
  final String username;
  final UserType userType;
  final String? phoneNumber;
  final String? email;
  CreateUser({required this.name, required this.username, required this.userType, this.phoneNumber, this.email});
}

class SetUserInterests extends UserEvent {
  final List<String> interests;

  SetUserInterests({required this.interests});
}

class SetPromoterUserDescription extends UserEvent {
  final String description;

  SetPromoterUserDescription({required this.description});
}

class SetPromoterUserLocation extends UserEvent {
  final String name;
  final GeoPoint? geopoint;

  SetPromoterUserLocation({required this.name, required this.geopoint});
}
