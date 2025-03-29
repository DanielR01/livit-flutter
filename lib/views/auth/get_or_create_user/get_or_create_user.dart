import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/models/user/cloud_user.dart';
import 'package:livit/constants/enums.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/services/firestore_storage/bloc/location/location_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/location/location_event.dart';
import 'package:livit/services/firestore_storage/bloc/location/location_state.dart';
import 'package:livit/services/firestore_storage/firestore_storage/exceptions/firestore_exceptions.dart';
import 'package:livit/services/firestore_storage/bloc/user/user_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/user/user_event.dart';
import 'package:livit/services/firestore_storage/bloc/user/user_state.dart';
import 'package:livit/utilities/debug/livit_debugger.dart';
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
  final _debugger = LivitDebugger('GetOrCreateUserView');

  @override
  void initState() {
    super.initState();
    _debugger.debPrint('Initializing view...', DebugMessageType.initializing);
    BlocProvider.of<UserBloc>(context).add(GetUserWithPrivateData(context));
    //BlocProvider.of<AuthBloc>(context).add(AuthEventLogOut(context));
  }

  bool _isProfileCompleted(UserState userState, LocationState? locationState) {
    _debugger.debPrint('Checking if profile is completed', DebugMessageType.info);
    if (userState is! CurrentUser) return false;
    if (userState.user.userType == UserType.promoter && locationState is! LocationsLoaded) return false;
    if (userState.user.userType == UserType.promoter &&
        locationState is LocationsLoaded &&
        locationState.loadingStates['cloud'] == LoadingState.loaded) {
      final promoter = userState.user as CloudPromoter;
      final locations = locationState.cloudLocations;
      final bool isCompleted = promoter.description != null &&
          promoter.interests != null &&
          promoter.locations != null &&
          locations.every((location) => location.geopoint != null && location.media != null);
      _debugger.debPrint('Profile is completed: $isCompleted', DebugMessageType.info);
      return isCompleted;
    } else if (userState.user is CloudCustomer) {
      final bool isCompleted = (userState.user as CloudCustomer).interests != null;
      _debugger.debPrint('Profile is completed: $isCompleted', DebugMessageType.info);
      return isCompleted;
    }
    _debugger.debPrint('Profile is not completed', DebugMessageType.info);
    return false;
  }

  Widget _handleNoCurrentUser(NoCurrentUser noCurrentUser) {
    _debugger.debPrint('Handling NoCurrentUser state', DebugMessageType.userVerifying);
    if (!noCurrentUser.isInitialized || noCurrentUser.isLoading) {
      _debugger.debPrint('Loading state from no initialized or loading state', DebugMessageType.loading);
      return const LoadingScreen();
    }
    if (noCurrentUser.userType == null && !noCurrentUser.isLoading && noCurrentUser.isInitialized && noCurrentUser.exception == null) {
      _debugger.debPrint('Showing user type input', DebugMessageType.info);
      return const UserTypeInput();
    }
    if (noCurrentUser.exception != null) {
      return _handleNoCurrentUserWithException(noCurrentUser);
    }
    return const LoadingScreen();
  }

  Widget _handleNoCurrentUserWithException(NoCurrentUser noCurrentUser) {
    _debugger.debPrint('Handling exception: ${noCurrentUser.exception.runtimeType}', DebugMessageType.error);
    if (noCurrentUser.exception is UserNotFoundException || noCurrentUser.exception is UsernameAlreadyExistsException) {
      if (noCurrentUser.userType == null) {
        if (widget.userType != null) {
          _debugger.debPrint('Setting user type to: ${widget.userType}', DebugMessageType.userCreating);
          BlocProvider.of<UserBloc>(context).add(SetUserType(context, userType: widget.userType!));
          return const LoadingScreen();
        } else {
          _debugger.debPrint('Showing user type input', DebugMessageType.info);
          return const UserTypeInput();
        }
      } else {
        _debugger.debPrint('Showing create user view', DebugMessageType.info);
        _isFirstTime = true;
        return const CreateUserView();
      }
    } else {
      _debugger.debPrint('Unhandled exception: ${noCurrentUser.exception}', DebugMessageType.error);
      throw noCurrentUser.exception!;
    }
  }

  Widget _handleCurrentUser(CurrentUser currentUser) {
    _debugger.debPrint('Handling CurrentUser state - Type: ${currentUser.user.userType}', DebugMessageType.userVerifying);
    if (currentUser.user is CloudCustomer && (currentUser.user as CloudCustomer).isProfileCompleted ||
        currentUser.user is CloudPromoter && (currentUser.user as CloudPromoter).isProfileCompleted) {
      return _handleCurrentUserProfileCompleted(currentUser);
    } else if (currentUser.user is CloudScanner) {
      return const LoadingScreen();
    }

    return _handleCurrentUserProfileIncomplete(currentUser);
  }

  Widget _handleCurrentUserProfileIncomplete(CurrentUser currentUser) {
    _debugger.debPrint('Handling CurrentUser profile incomplete - Type: ${currentUser.user.userType}', DebugMessageType.userVerifying);
    switch (currentUser.user.userType) {
      case UserType.customer:
        if (currentUser.user is CloudCustomer && (currentUser.user as CloudCustomer).interests == null ||
            currentUser.user is CloudPromoter && (currentUser.user as CloudPromoter).interests == null) {
          _debugger.debPrint('Customer needs to set interests', DebugMessageType.info);
          _isFirstTime = true;
          return const WelcomeAndInterestsView();
        } else if (_isProfileCompleted(currentUser, null)) {
          _debugger.debPrint('Customer profile completed, showing loading screen', DebugMessageType.done);
          BlocProvider.of<UserBloc>(context).add(SetUserProfileCompleted(context));
          return const LoadingScreen();
        } else {
          _debugger.debPrint('Customer profile data is corrupted', DebugMessageType.error);
          throw UserInformationCorruptedException();
        }
      case UserType.promoter:
        _debugger.debPrint('Handling promoter profile setup', DebugMessageType.userCreating);
        if (BlocProvider.of<LocationBloc>(context).state is LocationUninitialized) {
          _debugger.debPrint('Initializing location bloc', DebugMessageType.initializing);
          BlocProvider.of<LocationBloc>(context).add(InitializeLocationBloc(context));
        }
        final promoter = currentUser.user as CloudPromoter;

        if (promoter.interests == null) {
          _debugger.debPrint('Promoter needs to set interests', DebugMessageType.info);
          _isFirstTime = true;
          return const WelcomeAndInterestsView();
        } else if (promoter.description == null) {
          _debugger.debPrint('Promoter needs to set description', DebugMessageType.info);
          _isFirstTime = true;
          return const DescriptionPrompt();
        } else {
          _isFirstTime = true;
          return BlocBuilder<LocationBloc, LocationState>(
            builder: (context, locationState) {
              _debugger.debPrint('Building location state: ${locationState.runtimeType}', DebugMessageType.building);
              switch (locationState) {
                case LocationUninitialized():
                  return const LoadingScreen();
                case LocationsLoaded():
                  _debugger.debPrint('Locations loaded: ${promoter.locations}', DebugMessageType.info);
                  _debugger.debPrint('Cloud locations: ${locationState.cloudLocations}', DebugMessageType.info);
                  if (promoter.locations == null) {
                    _debugger.debPrint('Showing address prompt', DebugMessageType.info);
                    return AddressPrompt();
                  } else if (promoter.locations!.isNotEmpty && locationState.cloudLocations.any((location) => location.geopoint == null)) {
                    _debugger.debPrint('Showing map location prompt', DebugMessageType.info);
                    return const MapLocationPrompt();
                  } else if (promoter.locations!.isNotEmpty &&
                      !locationState.cloudLocations.any((location) => location.geopoint == null) &&
                      (locationState.cloudLocations.any((location) => location.media == null))) {
                    _debugger.debPrint('Showing media prompt', DebugMessageType.info);
                    return const MediaPrompt();
                  } else {
                    if (_isProfileCompleted(currentUser, locationState)) {
                      BlocProvider.of<UserBloc>(context).add(SetUserProfileCompleted(context));
                    }
                    _debugger.debPrint('Showing loading screen', DebugMessageType.loading);
                    return const LoadingScreen();
                  }
                default:
                  return ErrorReauthScreen(exception: Exception('Unknown location state'));
              }
            },
          );
        }
      case UserType.scanner:
        return const LoadingScreen();
    }
  }

  Widget _handleCurrentUserProfileCompleted(CurrentUser currentUser) {
    _debugger.debPrint('Profile is marked as completed', DebugMessageType.done);
    if (_isFirstTime) {
      _debugger.debPrint('Showing final welcome message', DebugMessageType.info);
      return FinalWelcomeMessage(
        onPressed: () {
          _debugger.debPrint('Pressed button on final welcome message', DebugMessageType.interaction);
          setState(() {
            _isFirstTime = false;
          });
          BlocProvider.of<UserBloc>(context).add(UpdateState(context));
        },
      );
    } else {
      _debugger.debPrint('Loading screen because first time is false', DebugMessageType.loading);
      return const LoadingScreen();
    }
  }

  Widget _handleError(FirestoreException error, String context) {
    _debugger.debPrint('Handling error: $error', DebugMessageType.error);
    return ErrorReauthScreen(exception: error);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserBloc, UserState>(
      listener: (context, state) {
        if (state is CurrentUser) {
          if (state.user is CloudScanner ||
              (state.user is CloudCustomer && (state.user as CloudCustomer).isProfileCompleted ||
                      state.user is CloudPromoter && (state.user as CloudPromoter).isProfileCompleted) &&
                  !_isFirstTime) {
            _debugger.debPrint('Profile complete, navigating to main view', DebugMessageType.navigation);
            Navigator.of(context).pushNamedAndRemoveUntil(
              Routes.mainViewRoute,
              (route) => false,
              arguments: {'userType': state.user.userType},
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
          _debugger.debPrint('Building state: ${userState.runtimeType}', DebugMessageType.building);
          switch (userState) {
            case CurrentUser():
              return _handleCurrentUser(userState);
            case NoCurrentUser():
              return _handleNoCurrentUser(userState);
            default:
              _debugger.debPrint('Unknown state type', DebugMessageType.error);
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
