import 'package:livit/constants/enums.dart';
import 'package:livit/services/cloud/livit_user.dart';

abstract class UserState {}

class NoCurrentUser extends UserState {
  final Exception? exception;
  final UserType? userType;
  final bool isLoading;
  final bool isCreating;
  final bool isInitialized;
  NoCurrentUser({this.exception, this.userType, this.isLoading = false, this.isCreating = false, this.isInitialized = true});
}

class CurrentUser extends UserState {
  final Exception? exception;
  final LivitUser user;
  final bool isLoading;

  CurrentUser({required this.user, this.exception, this.isLoading = false});
}
