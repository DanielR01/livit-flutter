import 'package:livit/constants/enums.dart';

abstract class UserEvent {}

class GetUser extends UserEvent {}

class SetUserType extends UserEvent {
  final UserType userType;
  SetUserType({required this.userType});
}

class CreateUser extends UserEvent {
  final String name;
  final String username;
  final UserType userType;
  CreateUser({required this.name, required this.username, required this.userType});
}

class SetUserInterests extends UserEvent {
  final List<String> interests;

  SetUserInterests({required this.interests});
}