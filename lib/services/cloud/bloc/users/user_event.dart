import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livit/cloud_models/location.dart';
import 'package:livit/constants/enums.dart';

abstract class UserEvent {
  const UserEvent();
}

class GetUserWithPrivateData extends UserEvent {
  const GetUserWithPrivateData();
}

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

class SetPromoterUserLocationWithoutGeopoint extends UserEvent {
  final Location location;

  SetPromoterUserLocationWithoutGeopoint({required this.location});
}

class UpdateState extends UserEvent {
  const UpdateState();
}

class SetPromoterUserLocation extends UserEvent {
  final Location location;
  SetPromoterUserLocation({required this.location});
}
