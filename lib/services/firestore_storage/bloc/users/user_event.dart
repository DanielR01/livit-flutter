import 'package:flutter/material.dart';
import 'package:livit/constants/enums.dart';

abstract class UserEvent {
  final BuildContext context;
  UserEvent(this.context);
}

class GetUser extends UserEvent {
  GetUser(super.context);
}

class GetUserWithPrivateData extends UserEvent {
  GetUserWithPrivateData(super.context);

  @override
  String toString() => 'GetUserWithPrivateData';
}

class SetUserType extends UserEvent {
  final UserType userType;
  SetUserType(super.context, {required this.userType});
}

class CreateUser extends UserEvent {
  final String username;
  final String name;
  final UserType userType;

  CreateUser(
    super.context, {
    required this.username,
    required this.name,
    required this.userType,
  });
}

class SetUserInterests extends UserEvent {
  final List<String> interests;
  SetUserInterests(super.context, {required this.interests});
}

class SetPromoterUserDescription extends UserEvent {
  final String description;
  SetPromoterUserDescription(super.context, {required this.description});
}

class SetPromoterUserNoLocations extends UserEvent {
  SetPromoterUserNoLocations(super.context);
}

class UpdateState extends UserEvent {
  UpdateState(super.context);
}

class OnError extends UserEvent {
  final Exception exception;
  OnError(super.context, {required this.exception});
}

class SetUserProfileCompleted extends UserEvent {
  SetUserProfileCompleted(super.context);
}
