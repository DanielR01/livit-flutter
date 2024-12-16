import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/cloud_models/location.dart';
import 'package:livit/cloud_models/user/cloud_user.dart';
import 'package:livit/constants/enums.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/services/firestore_storage/bloc/firestore_storage/firestore_storage_exceptions.dart';
import 'package:livit/services/firestore_storage/bloc/users/user_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/users/user_event.dart';
import 'package:livit/services/firestore_storage/bloc/users/user_state.dart';
import 'package:livit/utilities/error_screens/error_reauth_screen.dart';
import 'package:livit/utilities/loading_screen.dart';
import 'package:livit/views/auth/get_or_create_user/create_user_view.dart';
import 'package:livit/views/auth/get_or_create_user/final_welcome_message.dart';
import 'package:livit/views/auth/get_or_create_user/promoter/description_prompt.dart';
import 'package:livit/views/auth/get_or_create_user/promoter/location/address_prompt.dart';
import 'package:livit/views/auth/get_or_create_user/promoter/location/map_location_prompt.dart';
import 'package:livit/views/auth/get_or_create_user/promoter/location/media_prompt.dart';
import 'package:livit/views/auth/get_or_create_user/user_type_input.dart';
import 'package:livit/views/auth/get_or_create_user/welcome_and_data_view.dart';

class GetOrCreateUserView extends StatefulWidget {
  final UserType? userType;
  const GetOrCreateUserView({super.key, this.userType});

  @override
  State<GetOrCreateUserView> createState() => _GetOrCreateUserViewState();
}

class _GetOrCreateUserViewState extends State<GetOrCreateUserView> {
  bool _isFirstTime = false;
  Locatio

  @override
  void initState() {
    super.initState();
    BlocProvider.of<UserBloc>(context).add(const GetUserWithPrivateData());
    //BlocProvider.of<AuthBloc>(context).add(const AuthEventLogOut());
  }

  bool checkIfUserIsCompleted(CloudUser user) {
    if (user.userType == UserType.customer && user.interests == null) {
      return false;
    }
    if (user.userType == UserType.promoter) {
      final promoter = user as CloudPromoter;
      if (promoter.interests == null ||
          promoter.description == null ||
          promoter.locations == null ||
          promoter.locations!.any((location) => location?.geopoint == null) == true ||
          promoter.locations!.any((location) => location?.description == null) == true) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserBloc, UserState>(
      listener: (context, state) {
        if (state is CurrentUser) {
          if (state.privateData.isProfileCompleted && !_isFirstTime && checkIfUserIsCompleted(state.user)) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              Routes.mainViewRoute,
              (route) => false,
              arguments: state.user,
            );
          }
        }
      },
      builder: (context, state) {
        if (state is NoCurrentUser && state.userType == null && !state.isLoading && state.isInitialized && state.exception == null) {
          return const UserTypeInput();
        }
        switch (state) {
          case CurrentUser():
            if (state.privateData.isProfileCompleted) {
              if (_isFirstTime) {
                if (state.user.userType == UserType.customer && state.user.interests == null) {
                  return ErrorReauthScreen(exception: UserInformationCorruptedException());
                }
                return FinalWelcomeMessage(
                  onPressed: () {
                    setState(() {
                      _isFirstTime = false;
                    });
                    BlocProvider.of<UserBloc>(context).add(const UpdateState());
                  },
                );
              } else {
                return const LoadingScreen();
              }
            }
            switch (state.user.userType) {
              case UserType.customer:
                if (state.user.interests == null) {
                  _isFirstTime = true;
                  return const WelcomeAndInterestsView();
                } else {
                  return ErrorReauthScreen(exception: UserInformationCorruptedException());
                }
              case UserType.promoter:
                final promoter = state.user as CloudPromoter;
                if (promoter.interests == null) {
                  _isFirstTime = true;
                  return const WelcomeAndInterestsView();
                } else if (promoter.description == null) {
                  _isFirstTime = true;
                  return const DescriptionPrompt();
                } else if (promoter.locations == null ||
                    promoter.locations!.any((location) => location == null) && promoter.locations!.any((location) => location != null) ||
                    promoter.locations!.any((location) => location?.description == null)) {
                  _isFirstTime = true;
                  return AddressPrompt(locations: promoter.locations);
                } else if (promoter.locations != null &&
                    promoter.locations!.any((location) => location?.geopoint == null) &&
                    !promoter.locations!.any((location) => location == null)) {
                  _isFirstTime = true;
                  return MapLocationPrompt(
                    locations: promoter.locations!.whereType<Location>().toList(),
                  );
                } else if (promoter.locations != null &&
                    promoter.locations!.any((location) => location?.media == null)) {
                  _isFirstTime = true;
                  return MediaPrompt();
                } else {
                  return const LoadingScreen();
                }
            }
          case NoCurrentUser():
            if (!state.isInitialized) {
              return const LoadingScreen();
            } else if (state.isLoading) {
              return const LoadingScreen();
            } else if (state.exception is UserNotFoundException || state.exception == null) {
              if (state.userType == null) {
                if (widget.userType != null) {
                  BlocProvider.of<UserBloc>(context).add(SetUserType(userType: widget.userType!));
                  return const LoadingScreen();
                } else {
                  return const UserTypeInput();
                }
              } else {
                _isFirstTime = true;
                return const CreateUserView();
              }
            } else if (state.exception is UsernameAlreadyTakenException) {
              return const CreateUserView();
            } else {
              return ErrorReauthScreen(exception: state.exception);
            }
          default:
            return const LoadingScreen();
        }
      },
    );
  }
}
