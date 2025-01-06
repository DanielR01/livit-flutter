import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/cloud_models/user/cloud_user.dart';
import 'package:livit/cloud_models/user/private_data.dart';
import 'package:livit/constants/enums.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/services/auth/bloc/auth_bloc.dart';
import 'package:livit/services/auth/bloc/auth_event.dart';
import 'package:livit/services/error_reporting/error_reporter.dart';
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
    debugPrint('🔄 [GetOrCreateUserView] Initializing view...');
    BlocProvider.of<UserBloc>(context).add(GetUserWithPrivateData(context));
    // BlocProvider.of<AuthBloc>(context).add(AuthEventLogOut(context));
  }

  Widget _handleNoCurrentUser(NoCurrentUser noCurrentUser) {
    debugPrint('👤 [GetOrCreateUserView] Handling NoCurrentUser state');
    if (!noCurrentUser.isInitialized || noCurrentUser.isLoading) {
      debugPrint('⏳ [GetOrCreateUserView] Loading state from no initialized or loading state');
      return const LoadingScreen();
    }
    if (noCurrentUser.userType == null && !noCurrentUser.isLoading && noCurrentUser.isInitialized && noCurrentUser.exception == null) {
      debugPrint('📝 [GetOrCreateUserView] Showing user type input');
      return const UserTypeInput();
    }
    if (noCurrentUser.exception != null) {
      return _handleNoCurrentUserWithException(noCurrentUser);
    }
    return const LoadingScreen();
  }

  Widget _handleNoCurrentUserWithException(NoCurrentUser noCurrentUser) {
    debugPrint('⚠️ [GetOrCreateUserView] Handling exception: ${noCurrentUser.exception.runtimeType}');
    if (noCurrentUser.exception is UserNotFoundException || noCurrentUser.exception is UsernameAlreadyExistsException) {
      if (noCurrentUser.userType == null) {
        if (widget.userType != null) {
          debugPrint('🔄 [GetOrCreateUserView] Setting user type to: ${widget.userType}');
          BlocProvider.of<UserBloc>(context).add(SetUserType(context, userType: widget.userType!));
          return const LoadingScreen();
        } else {
          debugPrint('📝 [GetOrCreateUserView] Showing user type input');
          return const UserTypeInput();
        }
      } else {
        debugPrint('📝 [GetOrCreateUserView] Showing create user view');
        _isFirstTime = true;
        return const CreateUserView();
      }
    } else {
      debugPrint('🚨 [GetOrCreateUserView] Unhandled exception: ${noCurrentUser.exception}');
      throw noCurrentUser.exception!;
    }
  }

  Widget _handleCurrentUser(CurrentUser currentUser) {
    debugPrint('👤 [GetOrCreateUserView] Handling CurrentUser state - Type: ${currentUser.user.userType}');
    if (currentUser.user.isProfileCompleted) {
      return _handleCurrentUserProfileCompleted(currentUser);
    }

    return _handleCurrentUserProfileIncomplete(currentUser);
  }

  Widget _handleCurrentUserProfileIncomplete(CurrentUser currentUser) {
    debugPrint('👤 [GetOrCreateUserView] Handling CurrentUser profile incomplete - Type: ${currentUser.user.userType}');
    switch (currentUser.user.userType) {
      case UserType.customer:
        if (currentUser.user.interests == null) {
          debugPrint('📝 [GetOrCreateUserView] Customer needs to set interests');
          _isFirstTime = true;
          return const WelcomeAndInterestsView();
        } else {
          debugPrint('❌ [GetOrCreateUserView] Customer profile corrupted');
          throw UserInformationCorruptedException();
        }
      case UserType.promoter:
        debugPrint('🏢 [GetOrCreateUserView] Handling promoter profile setup');
        if (BlocProvider.of<LocationBloc>(context).state is LocationUninitialized) {
          debugPrint('🔄 [GetOrCreateUserView] Initializing location bloc');
          BlocProvider.of<LocationBloc>(context).add(InitializeLocationBloc(context, userId: currentUser.user.id));
        }
        final promoter = currentUser.user as CloudPromoter;

        if (promoter.interests == null) {
          debugPrint('📝 [GetOrCreateUserView] Promoter needs to set interests');
          _isFirstTime = true;
          return const WelcomeAndInterestsView();
        } else if (promoter.description == null) {
          debugPrint('📝 [GetOrCreateUserView] Promoter needs to set description');
          _isFirstTime = true;
          return const DescriptionPrompt();
        } else {
          _isFirstTime = true;
          return BlocBuilder<LocationBloc, LocationState>(
            builder: (context, locationState) {
              debugPrint('📍 [GetOrCreateUserView] Building location state: ${locationState.runtimeType}');
              switch (locationState) {
                case LocationUninitialized():
                  return const LoadingScreen();
                case LocationsLoaded():
                  debugPrint('📍 [GetOrCreateUserView] Locations loaded: ${promoter.locations}');
                  debugPrint('📍 [GetOrCreateUserView] Cloud locations: ${locationState.cloudLocations}');
                  if (promoter.locations == null) {
                    debugPrint('📝 [GetOrCreateUserView] Showing address prompt');
                    return AddressPrompt();
                  } else if (promoter.locations!.isNotEmpty && locationState.cloudLocations.any((location) => location.geopoint == null)) {
                    debugPrint('📝 [GetOrCreateUserView] Showing map location prompt');
                    return const MapLocationPrompt();
                  } else if (promoter.locations!.isNotEmpty &&
                      !locationState.cloudLocations.any((location) => location.geopoint == null) &&
                      (locationState.cloudLocations.any((location) => location.media == null))) {
                    debugPrint('📝 [GetOrCreateUserView] Showing media prompt');
                    return const MediaPrompt();
                  } else {
                    return const LoadingScreen();
                  }
                default:
                  return ErrorReauthScreen(exception: Exception('Unknown location state'));
              }
            },
          );
        }
    }
  }

  Widget _handleCurrentUserProfileCompleted(CurrentUser currentUser) {
    debugPrint('✅ [GetOrCreateUserView] Profile is marked as completed');
    if (_isFirstTime) {
      debugPrint('👋 [GetOrCreateUserView] Showing final welcome message');
      return FinalWelcomeMessage(
        onPressed: () {
          debugPrint('👋 [GetOrCreateUserView] Pressed button on final welcome message');
          setState(() {
            _isFirstTime = false;
          });
          BlocProvider.of<UserBloc>(context).add(UpdateState(context));
        },
      );
    } else {
      debugPrint('🔄 [GetOrCreateUserView] Loading screen because first time is false');
      return const LoadingScreen();
    }
  }

  Widget _handleError(FirestoreException error, String context) {
    debugPrint('🚨 [GetOrCreateUserView] Handling error: $error');
    return ErrorReauthScreen(exception: error);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserBloc, UserState>(
      listener: (context, state) {
        if (state is CurrentUser) {
          if (state.user.isProfileCompleted && !_isFirstTime) {
            debugPrint('✅ [GetOrCreateUserView] Profile complete, navigating to main view');
            Navigator.of(context).pushNamedAndRemoveUntil(
              Routes.mainViewRoute,
              (route) => false,
              arguments: state.user,
            );
          }
        }
      },
      builder: (context, userState) {
        if (userState is CurrentUser && userState.exception != null) {
          if (userState.exception is UserInformationCorruptedException) {
            return _handleError(userState.exception as FirestoreException, 'Building GetOrCreateUserView');
          } else if (userState.exception.toString() == 'Unknown location state') {
            return _handleError(GenericFirestoreException(details: 'Unknown location state'), 'Building GetOrCreateUserView');
          }
        }
        try {
          debugPrint('🔄 [GetOrCreateUserView] Building state: ${userState.runtimeType}');
          switch (userState) {
            case CurrentUser():
              return _handleCurrentUser(userState);
            case NoCurrentUser():
              return _handleNoCurrentUser(userState);
            default:
              debugPrint('❌ [GetOrCreateUserView] Unknown state type');
              throw GenericFirestoreException(details: 'Unknown state type');
          }
        } catch (e) {
          return _handleError(
              e is FirestoreException ? e : GenericFirestoreException(details: e.toString()), 'Building GetOrCreateUserView');
        }
      },
    );
  }
}
