import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/cloud_models/user/cloud_user.dart';
import 'package:livit/cloud_models/user/private_data.dart';
import 'package:livit/constants/enums.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/services/firestore_storage/bloc/locations/location_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/locations/location_event.dart';
import 'package:livit/services/firestore_storage/bloc/locations/location_state.dart';
import 'package:livit/services/firestore_storage/firestore_storage/exceptions/firestore_exceptions.dart';
import 'package:livit/services/firestore_storage/bloc/users/user_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/users/user_event.dart';
import 'package:livit/services/firestore_storage/bloc/users/user_state.dart';
import 'package:livit/utilities/error_screens/error_reauth_screen.dart';
import 'package:livit/utilities/loading_screen.dart';
import 'package:livit/views/auth/get_or_create_user/create_user_view.dart';
import 'package:livit/views/auth/get_or_create_user/final_welcome_message.dart';
import 'package:livit/views/auth/get_or_create_user/promoter/description_prompt.dart';
import 'package:livit/views/auth/get_or_create_user/promoter/location/address_prompt/address_prompt.dart';
import 'package:livit/views/auth/get_or_create_user/promoter/location/map_location_prompt.dart';
import 'package:livit/views/auth/get_or_create_user/promoter/location/media_prompt/media_prompt.dart';
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

  @override
  void initState() {
    super.initState();
    BlocProvider.of<UserBloc>(context).add(const GetUserWithPrivateData());
  }

  bool checkIfUserIsCompleted(CloudUser user) {
    if (user.userType == UserType.customer && user.interests == null) {
      return false;
    }
    if (user.userType == UserType.promoter) {
      final promoter = user as CloudPromoter;
      if (promoter.interests == null || promoter.description == null) {
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
      builder: (context, userState) {
        switch (userState) {
          case CurrentUser():
            if (userState.privateData.isProfileCompleted) {
              if (_isFirstTime) {
                if (userState.user.userType == UserType.customer && userState.user.interests == null) {
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
            switch (userState.user.userType) {
              case UserType.customer:
                if (userState.user.interests == null) {
                  _isFirstTime = true;
                  return const WelcomeAndInterestsView();
                } else {
                  return ErrorReauthScreen(exception: UserInformationCorruptedException());
                }
              case UserType.promoter:
                if (BlocProvider.of<LocationBloc>(context).state is LocationUninitialized) {
                  BlocProvider.of<LocationBloc>(context).add(InitializeLocationBloc(userId: userState.user.id));
                }
                final promoter = userState.user as CloudPromoter;
                final privateData = userState.privateData as PromoterPrivateData;
                if (promoter.interests == null) {
                  _isFirstTime = true;
                  return const WelcomeAndInterestsView();
                } else if (promoter.description == null) {
                  _isFirstTime = true;
                  return const DescriptionPrompt();
                } else {
                  _isFirstTime = true;
                  return BlocBuilder<LocationBloc, LocationState>(
                    builder: (context, locationState) {
                      switch (locationState) {
                        case LocationUninitialized():
                          return const LoadingScreen();
                        case LocationsLoaded():
                          final cloudLocations = locationState.cloudLocations;

                          if (cloudLocations.isEmpty && !privateData.noLocations) {
                            return AddressPrompt();
                          } else if (cloudLocations.any((location) => location.geopoint == null)) {
                            return const MapLocationPrompt();
                          } else if (cloudLocations.isNotEmpty &&
                              !privateData.noLocations &&
                              !cloudLocations.any((location) => location.geopoint == null) &&
                              (cloudLocations.any((location) => location.media == null))) {
                            return const MediaPrompt();
                          } else {
                            return ErrorReauthScreen(exception: UserInformationCorruptedException());
                          }
                        default:
                          return const LoadingScreen();
                      }
                    },
                  );
                }
            }
          case NoCurrentUser():
            if (userState.userType == null && !userState.isLoading && userState.isInitialized && userState.exception == null) {
              return const UserTypeInput();
            }
            if (!userState.isInitialized) {
              return const LoadingScreen();
            } else if (userState.isLoading) {
              return const LoadingScreen();
            } else if (userState.exception is UserNotFoundException || userState.exception == null) {
              if (userState.userType == null) {
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
            } else if (userState.exception is UsernameAlreadyTakenException) {
              return const CreateUserView();
            } else {
              return ErrorReauthScreen(exception: userState.exception);
            }
          default:
            return const LoadingScreen();
        }
      },
    );
  }
}
