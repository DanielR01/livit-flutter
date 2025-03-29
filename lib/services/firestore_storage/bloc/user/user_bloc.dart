import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/models/user/cloud_user.dart';
import 'package:livit/models/user/private_data.dart';
import 'package:livit/services/background/background_events.dart';
import 'package:livit/services/cloud_functions/firestore_cloud_functions.dart';
import 'package:livit/services/firestore_storage/firestore_storage/firestore_storage.dart';
import 'package:livit/services/auth/auth_provider.dart';
import 'package:livit/services/firestore_storage/bloc/user/user_event.dart';
import 'package:livit/services/firestore_storage/bloc/user/user_state.dart';
import 'package:livit/services/firestore_storage/firestore_storage/exceptions/firestore_exceptions.dart';
import 'package:livit/services/background/background_bloc.dart';
import 'package:livit/services/error_reporting/error_reporter.dart';
import 'package:livit/utilities/debug/livit_debugger.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final FirestoreStorageService _cloudStorage;
  final FirestoreCloudFunctions _firestoreCloudFunctions;
  final AuthProvider _authProvider;
  final ErrorReporter _errorReporter;
  final BackgroundBloc _backgroundBloc;
  final LivitDebugger _debugger = const LivitDebugger('UserBloc');

  CloudUser? currentUser;
  UserPrivateData? _currentPrivateData;

  UserBloc({
    required FirestoreStorageService cloudStorage,
    required FirestoreCloudFunctions firestoreCloudFunctions,
    required AuthProvider authProvider,
    required BackgroundBloc backgroundBloc,
  })  : _cloudStorage = cloudStorage,
        _firestoreCloudFunctions = firestoreCloudFunctions,
        _authProvider = authProvider,
        _errorReporter = ErrorReporter(viewName: 'UserBloc'),
        _backgroundBloc = backgroundBloc,
        super(NoCurrentUser(isInitialized: false)) {
    on<GetUser>(_onGetUser);
    on<GetUserWithPrivateData>(_onGetUserWithPrivateData);
    on<SetUserType>(_onSetUserType);
    on<CreateUser>(_onCreateUser);
    on<SetUserInterests>(_onSetUserInterests);
    on<SetPromoterUserDescription>(_onSetPromoterUserDescription);
    on<SetPromoterUserNoLocations>(_onSetPromoterUserNoLocations);
    on<UpdateState>(_onUpdateState);
    on<SetUserProfileCompleted>(_onSetUserProfileCompleted);
    on<OnError>(_onOnError);
    on<SetUserLocationsLocally>(_onSetUserLocationsLocally);
  }

  Future<void> _handleError(dynamic error, [String? context]) async {
    _debugger.debPrint('Error${context != null ? ' ($context)' : ''}: $error', DebugMessageType.error);
    final exception = error is FirestoreException ? error : GenericFirestoreException(details: error.toString());

    await _errorReporter.reportError(
      exception,
      StackTrace.current,
      reason: '[UserBloc] Error${context != null ? ': $context' : ''}',
    );
  }

  Future<void> _onGetUser(GetUser event, Emitter<UserState> emit) async {
    _debugger.debPrint('Getting user...', DebugMessageType.methodCalling);
    _debugger.debPrint('Emitting NoCurrentUser(isLoading: true)', DebugMessageType.methodEntering);
    emit(state.copyWith(isLoading: true));
    _backgroundBloc.add(BackgroundStartLoadingAnimation());

    try {
      final userId = (await _authProvider.currentUser).id;
      _debugger.debPrint('Fetching user data for ID: $userId', DebugMessageType.reading);
      final user = await _cloudStorage.userService.getUser(userId: userId);
      _debugger.debPrint('User fetched: $user', DebugMessageType.info);
      emit(CurrentUser(user: user, privateData: _currentPrivateData!));
    } catch (e) {
      await _handleError(e, 'Getting user');
      _debugger.debPrint('Emitting NoCurrentUser with error', DebugMessageType.methodExiting);
      emit(NoCurrentUser(exception: e is FirestoreException ? e : GenericFirestoreException(details: e.toString())));
    } finally {
      _backgroundBloc.add(BackgroundStopLoadingAnimation());
    }
  }

  Future<void> _onGetUserWithPrivateData(GetUserWithPrivateData event, Emitter<UserState> emit) async {
    _debugger.debPrint('Getting user with private data...', DebugMessageType.methodCalling);
    _debugger.debPrint('Emitting NoCurrentUser(isLoading: true)', DebugMessageType.methodEntering);
    emit(NoCurrentUser(isLoading: true));
    _backgroundBloc.add(BackgroundStartLoadingAnimation());

    try {
      final userId = (await _authProvider.currentUser).id;
      _debugger.debPrint('Fetching user data for ID: $userId', DebugMessageType.reading);

      final user = await _cloudStorage.userService.getUser(userId: userId);
      if (user is CloudPromoter) {
        _debugger.debPrint('Promoter fetched: ${user.username}', DebugMessageType.info);
      } else if (user is CloudCustomer) {
        _debugger.debPrint('Customer fetched: ${user.username}', DebugMessageType.info);
      }
      late final UserPrivateData privateData;

      privateData = await _cloudStorage.privateDataService.getPrivateData(userId: userId);
      _debugger.debPrint('Private data fetched for user', DebugMessageType.info);

      if (user.userType != privateData.userType) {
        _debugger.debPrint('User type mismatch detected: ${user.userType} != ${privateData.userType}', DebugMessageType.warning);
        final exception = UserInformationCorruptedException(details: 'User type mismatch: ${user.userType} != ${privateData.userType}');
        await _handleError(exception, 'Type mismatch during user fetch');
        _debugger.debPrint('Emitting NoCurrentUser with corruption exception', DebugMessageType.methodExiting);
        emit(NoCurrentUser(exception: exception));
        return;
      }

      currentUser = user;
      _currentPrivateData = user is CloudScanner ? null : privateData;
      _debugger.debPrint('User data successfully loaded', DebugMessageType.done);
      _debugger.debPrint('Emitting CurrentUser state', DebugMessageType.methodExiting);
      emit(CurrentUser(user: user, privateData: privateData));
    } catch (e) {
      if (e is UserNotFoundException) {
        try {
          final scanner = await _cloudStorage.scannerService.getScannerById((await _authProvider.currentUser).id);
          currentUser = scanner;
          _currentPrivateData = null;
          emit(CurrentUser(user: scanner, privateData: null));
        } catch (e) {
          await _handleError(e, 'Getting user with private data');
          emit(NoCurrentUser(exception: e is FirestoreException ? e : GenericFirestoreException(details: e.toString())));
        }
      } else {
        _debugger.debPrint('Error getting user data: $e', DebugMessageType.error);
        await _handleError(e, 'Getting user with private data');
        _debugger.debPrint(
            'Emitting NoCurrentUser with error: ${e is FirestoreException ? e : GenericFirestoreException(details: e.toString())}',
            DebugMessageType.methodExiting);
        emit(NoCurrentUser(exception: e is FirestoreException ? e : GenericFirestoreException(details: e.toString())));
      }
    } finally {
      _backgroundBloc.add(BackgroundStopLoadingAnimation());
    }
  }

  void _onSetUserType(SetUserType event, Emitter<UserState> emit) {
    _debugger.debPrint('Setting user type to: ${event.userType}', DebugMessageType.methodCalling);
    _debugger.debPrint('Emitting NoCurrentUser with userType: ${event.userType}', DebugMessageType.methodExiting);
    final Exception? exception = (state is NoCurrentUser) ? (state as NoCurrentUser).exception : null;
    emit(NoCurrentUser(userType: event.userType, isLoading: false, exception: exception));
  }

  Future<void> _onCreateUser(CreateUser event, Emitter<UserState> emit) async {
    _debugger.debPrint('Creating new user...', DebugMessageType.methodCalling);
    _debugger.debPrint('Username: ${event.username}, Type: ${event.userType}', DebugMessageType.creating);
    _debugger.debPrint('Emitting NoCurrentUser(isCreating: true)', DebugMessageType.methodEntering);
    emit(NoCurrentUser(
        userType: event.userType, isCreating: true, exception: (state is NoCurrentUser) ? (state as NoCurrentUser).exception : null));
    _backgroundBloc.add(BackgroundStartLoadingAnimation());

    try {
      _debugger.debPrint('Checking if username is taken...', DebugMessageType.verifying);
      final isUsernameTaken = await _cloudStorage.usernameService.isUsernameTaken(event.username);
      if (isUsernameTaken) {
        _debugger.debPrint('Username already taken: ${event.username}', DebugMessageType.warning);
        final exception = UsernameAlreadyExistsException(details: 'Username ${event.username} is already taken');
        await _handleError(exception, 'Username check during user creation');
        _debugger.debPrint('Emitting NoCurrentUser with username taken exception', DebugMessageType.methodExiting);
        emit(NoCurrentUser(userType: event.userType, exception: exception));
        return;
      }

      _debugger.debPrint('Username available, creating user...', DebugMessageType.done);
      final userId = (await _authProvider.currentUser).id;
      await _firestoreCloudFunctions.createUserAndUsername(
        userId: userId,
        username: event.username,
        userType: event.userType.name,
        name: event.name,
        phoneNumber: (await _authProvider.currentUser).phoneNumber ?? '',
        email: (await _authProvider.currentUser).email ?? '',
      );
      currentUser = await _cloudStorage.userService.getUser(userId: userId);
      _currentPrivateData = await _cloudStorage.privateDataService.getPrivateData(userId: userId);
      emit(CurrentUser(user: currentUser!, privateData: _currentPrivateData!));
      _debugger.debPrint('Emitting CurrentUser with new user data', DebugMessageType.methodExiting);
      _debugger.debPrint('User created successfully', DebugMessageType.done);
    } catch (e) {
      _debugger.debPrint('Error creating user: $e', DebugMessageType.error);
      await _handleError(e, 'Creating user');
      _debugger.debPrint('Emitting NoCurrentUser with error', DebugMessageType.methodExiting);
      emit(NoCurrentUser(
        userType: event.userType,
        exception: e is FirestoreException ? e : GenericFirestoreException(details: e.toString()),
        isLoading: false,
      ));
    } finally {
      _backgroundBloc.add(BackgroundStopLoadingAnimation());
    }
  }

  Future<void> _onSetUserInterests(SetUserInterests event, Emitter<UserState> emit) async {
    if (currentUser == null) {
      final exception = NoCurrentUserException(details: 'Attempting to set interests with no current user');
      await _handleError(exception, 'Setting user interests');
      emit(NoCurrentUser(exception: exception));
      return;
    }

    emit(CurrentUser(user: currentUser!, privateData: _currentPrivateData!, isLoading: true));
    _backgroundBloc.add(BackgroundStartLoadingAnimation());

    try {
      _debugger.debPrint('Copying user ${currentUser!} with interests...', DebugMessageType.methodCalling);
      late final CloudUser updatedUser;
      if (currentUser is CloudCustomer) {
        updatedUser = (currentUser as CloudCustomer).copyWith(
          interests: event.interests,
        );
      } else if (currentUser is CloudPromoter) {
        updatedUser = (currentUser as CloudPromoter).copyWith(
          interests: event.interests,
        );
      } else if (currentUser is CloudScanner) {
        final exception =
            UserInformationCorruptedException(details: 'User type mismatch: ${currentUser!.userType} != CloudCustomer or CloudPromoter');
        await _handleError(exception, 'Setting user interests');
        emit(NoCurrentUser(exception: exception));
        return;
      }
      _debugger.debPrint('Updating user with interests...', DebugMessageType.methodCalling);
      await _cloudStorage.userService.updateUser(user: updatedUser);
      _debugger.debPrint('User updated with interests', DebugMessageType.done);
      currentUser = updatedUser;
      _debugger.debPrint('Emitting CurrentUser with updated user', DebugMessageType.methodExiting);
      emit(CurrentUser(user: currentUser!, privateData: _currentPrivateData!));
    } catch (e) {
      await _handleError(e, 'Setting user interests');
      emit(CurrentUser(
          user: currentUser!,
          privateData: _currentPrivateData!,
          exception: e is FirestoreException ? e : GenericFirestoreException(details: e.toString())));
    } finally {
      _backgroundBloc.add(BackgroundStopLoadingAnimation());
    }
  }

  Future<void> _onSetPromoterUserDescription(SetPromoterUserDescription event, Emitter<UserState> emit) async {
    if (currentUser == null) {
      emit(NoCurrentUser(exception: NoCurrentUserException()));
      return;
    }
    if (currentUser is! CloudPromoter) {
      final exception = UserInformationCorruptedException(details: 'User type mismatch: ${currentUser!.userType} != CloudPromoter');
      await _handleError(exception, 'Setting promoter user description');
      emit(NoCurrentUser(exception: exception));
      return;
    }

    emit(CurrentUser(user: currentUser!, privateData: _currentPrivateData!, isLoading: true));
    _backgroundBloc.add(BackgroundStartLoadingAnimation());

    try {
      final updatedUser = (currentUser as CloudPromoter).copyWith(
        description: event.description,
      );

      await _cloudStorage.userService.updateUser(user: updatedUser);
      currentUser = updatedUser;

      emit(CurrentUser(user: updatedUser, privateData: _currentPrivateData!));
    } catch (e) {
      await _handleError(e, 'Setting promoter user description');
      emit(CurrentUser(user: currentUser!, privateData: _currentPrivateData!, exception: e as Exception));
    } finally {
      _backgroundBloc.add(BackgroundStopLoadingAnimation());
    }
  }

  Future<void> _onSetPromoterUserNoLocations(SetPromoterUserNoLocations event, Emitter<UserState> emit) async {
    if (currentUser == null) {
      emit(NoCurrentUser(exception: NoCurrentUserException()));
      return;
    }
    if (currentUser is! CloudPromoter) {
      final exception = UserInformationCorruptedException(details: 'User type mismatch: ${currentUser!.userType} != CloudPromoter');
      await _handleError(exception, 'Setting promoter user no locations');
      emit(NoCurrentUser(exception: exception));
      return;
    }

    emit(CurrentUser(user: currentUser!, privateData: _currentPrivateData!, isLoading: true));
    _backgroundBloc.add(BackgroundStartLoadingAnimation());

    try {
      await _firestoreCloudFunctions.updatePromoterUserNoLocations(userId: currentUser!.id);
      final user = await _cloudStorage.userService.getUser(userId: currentUser!.id);
      currentUser = user;
      emit(CurrentUser(user: currentUser!, privateData: _currentPrivateData!));
    } catch (e) {
      await _handleError(e, 'Setting promoter user no locations');
      emit(CurrentUser(user: currentUser!, privateData: _currentPrivateData!, exception: e as Exception));
    } finally {
      _backgroundBloc.add(BackgroundStopLoadingAnimation());
    }
  }

  Future<void> _onSetUserProfileCompleted(SetUserProfileCompleted event, Emitter<UserState> emit) async {
    _debugger.debPrint('Setting user profile completed', DebugMessageType.methodCalling);
    if (currentUser == null) {
      emit(NoCurrentUser(exception: NoCurrentUserException()));
      return;
    }
    _debugger.debPrint('Current user: ${currentUser!}', DebugMessageType.info);
    late final CloudUser updatedUser;
    if (currentUser is CloudCustomer) {
      updatedUser = (currentUser as CloudCustomer).copyWith(
        isProfileCompleted: true,
      );
    } else if (currentUser is CloudPromoter) {
      updatedUser = (currentUser as CloudPromoter).copyWith(
        isProfileCompleted: true,
      );
    } else if (currentUser is CloudScanner) {
      final exception =
          UserInformationCorruptedException(details: 'User type mismatch: ${currentUser!.userType} != CloudCustomer or CloudPromoter');
      await _handleError(exception, 'Setting user profile completed');
      emit(NoCurrentUser(exception: exception));
      return;
    }
    _debugger.debPrint('Updated user: $updatedUser', DebugMessageType.info);
    await _cloudStorage.userService.updateUser(user: updatedUser);
    currentUser = updatedUser;
    _debugger.debPrint('Emitting CurrentUser with updated user', DebugMessageType.methodExiting);
    emit(CurrentUser(user: currentUser!, privateData: _currentPrivateData!));
  }

  void _onSetUserLocationsLocally(SetUserLocationsLocally event, Emitter<UserState> emit) {
    _debugger.debPrint('Setting user locations', DebugMessageType.methodCalling);
    if (currentUser == null) {
      emit(NoCurrentUser(exception: NoCurrentUserException()));
      return;
    }
    if (currentUser is! CloudPromoter) {
      emit(NoCurrentUser(
          exception: UserInformationCorruptedException(details: 'User type mismatch: ${currentUser!.userType} != CloudPromoter')));
      return;
    }
    final updatedUser = (currentUser as CloudPromoter).copyWith(
      locations: event.locations.map((location) => location.id).toList(),
    );
    _debugger.debPrint('Updated user: $updatedUser', DebugMessageType.info);
    currentUser = updatedUser;
    _debugger.debPrint('Emitting CurrentUser with updated user', DebugMessageType.methodExiting);
    emit(CurrentUser(user: currentUser!, privateData: _currentPrivateData!));
  }

  void _onOnError(OnError event, Emitter<UserState> emit) {
    _debugger.debPrint('Error: ${event.exception}', DebugMessageType.error);
    emit(NoCurrentUser(exception: event.exception));
  }

  void _onUpdateState(UpdateState event, Emitter<UserState> emit) {
    if (state is CurrentUser) {
      emit(CurrentUser(
        user: (state as CurrentUser).user,
        privateData: (state as CurrentUser).privateData,
      ));
    } else {
      emit(NoCurrentUser());
    }
  }

  CloudUser? getCurrentUser() {
    return currentUser;
  }
}
