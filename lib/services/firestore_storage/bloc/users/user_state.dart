import 'package:livit/cloud_models/user/cloud_user.dart';
import 'package:livit/cloud_models/user/private_data.dart';
import 'package:livit/constants/enums.dart';

abstract class UserState {}

class NoCurrentUser extends UserState {
  final Exception? exception;
  final UserType? userType;
  final bool isLoading;
  final bool isCreating;
  final bool isInitialized;
  NoCurrentUser({this.exception, this.userType, this.isLoading = false, this.isCreating = false, this.isInitialized = true});

  @override
  String toString() {
    return 'Exception: $exception, usertype: $userType, isLoading: $isLoading, isCreating: $isCreating, isInitialized: $isInitialized';
  }
}

class CurrentUser extends UserState {
  final Exception? exception;
  final CloudUser user;
  final UserPrivateData privateData;
  final bool isLoading;

  CurrentUser({required this.user, required this.privateData, this.exception, this.isLoading = false});
}
