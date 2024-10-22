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

