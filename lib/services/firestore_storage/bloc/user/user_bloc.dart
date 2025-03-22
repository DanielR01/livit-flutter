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

class UserBloc extends Bloc<UserEvent, UserState> {
  final FirestoreStorageService _cloudStorage;
  final FirestoreCloudFunctions _firestoreCloudFunctions;
  final AuthProvider _authProvider;
  final ErrorReporter _errorReporter;
  final BackgroundBloc _backgroundBloc;

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
    debugPrint('🚨 [UserBloc] Error${context != null ? ' ($context)' : ''}: $error');
    final exception = error is FirestoreException ? error : GenericFirestoreException(details: error.toString());

    await _errorReporter.reportError(
      exception,
      StackTrace.current,
      reason: '[UserBloc] Error${context != null ? ': $context' : ''}',
    );
  }

  Future<void> _onGetUser(GetUser event, Emitter<UserState> emit) async {
    debugPrint('👤 [UserBloc] Getting user...');
    debugPrint('🔄 [UserBloc] Emitting NoCurrentUser(isLoading: true)');
    emit(state.copyWith(isLoading: true));
    _backgroundBloc.add(BackgroundStartLoadingAnimation());

    try {
      final userId = (await _authProvider.currentUser).id;
      debugPrint('📥 [UserBloc] Fetching user data for ID: $userId');
      final user = await _cloudStorage.userService.getUser(userId: userId);
      debugPrint('👤 [UserBloc] User fetched: $user');
      emit(CurrentUser(user: user, privateData: _currentPrivateData!));
    } catch (e) {
      await _handleError(e, 'Getting user');
      debugPrint('🔄 [UserBloc] Emitting NoCurrentUser with error');
      emit(NoCurrentUser(exception: e is FirestoreException ? e : GenericFirestoreException(details: e.toString())));
    } finally {
      _backgroundBloc.add(BackgroundStopLoadingAnimation());
    }
  }

  Future<void> _onGetUserWithPrivateData(GetUserWithPrivateData event, Emitter<UserState> emit) async {
    debugPrint('👤 [UserBloc] Getting user with private data...');
    debugPrint('🔄 [UserBloc] Emitting NoCurrentUser(isLoading: true)');
    emit(NoCurrentUser(isLoading: true));
    _backgroundBloc.add(BackgroundStartLoadingAnimation());

    try {
      final userId = (await _authProvider.currentUser).id;
      debugPrint('📥 [UserBloc] Fetching user data for ID: $userId');

      final user = await _cloudStorage.userService.getUser(userId: userId);
      if (user is CloudPromoter) {
        debugPrint('👤 [UserBloc] Promoter fetched: ${user.username}');
      } else if (user is CloudCustomer) {
        debugPrint('👤 [UserBloc] Customer fetched: ${user.username}');
      }
      late final UserPrivateData privateData;

      privateData = await _cloudStorage.privateDataService.getPrivateData(userId: userId);
      debugPrint('🔒 [UserBloc] Private data fetched for user');

      if (user.userType != privateData.userType) {
        debugPrint('⚠️ [UserBloc] User type mismatch detected: ${user.userType} != ${privateData.userType}');
        final exception = UserInformationCorruptedException(details: 'User type mismatch: ${user.userType} != ${privateData.userType}');
        await _handleError(exception, 'Type mismatch during user fetch');
        debugPrint('🔄 [UserBloc] Emitting NoCurrentUser with corruption exception');
        emit(NoCurrentUser(exception: exception));
        return;
      }

      currentUser = user;
      _currentPrivateData = user is CloudScanner ? null : privateData;
      debugPrint('✅ [UserBloc] User data successfully loaded');
      debugPrint('🔄 [UserBloc] Emitting CurrentUser state');
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
        debugPrint('❌ [UserBloc] Error getting user data: $e');
        await _handleError(e, 'Getting user with private data');
        debugPrint(
            '🔄 [UserBloc] Emitting NoCurrentUser with error: ${e is FirestoreException ? e : GenericFirestoreException(details: e.toString())}');
        emit(NoCurrentUser(exception: e is FirestoreException ? e : GenericFirestoreException(details: e.toString())));
      }
    } finally {
      _backgroundBloc.add(BackgroundStopLoadingAnimation());
    }
  }

  void _onSetUserType(SetUserType event, Emitter<UserState> emit) {
    debugPrint('🔄 [UserBloc] Setting user type to: ${event.userType}');
    debugPrint('🔄 [UserBloc] Emitting NoCurrentUser with userType: ${event.userType}');
    final Exception? exception = (state is NoCurrentUser) ? (state as NoCurrentUser).exception : null;
    emit(NoCurrentUser(userType: event.userType, isLoading: false, exception: exception));
  }

  Future<void> _onCreateUser(CreateUser event, Emitter<UserState> emit) async {
    debugPrint('👤 [UserBloc] Creating new user...');
    debugPrint('📝 [UserBloc] Username: ${event.username}, Type: ${event.userType}');
    debugPrint('🔄 [UserBloc] Emitting NoCurrentUser(isCreating: true)');
    emit(NoCurrentUser(
        userType: event.userType, isCreating: true, exception: (state is NoCurrentUser) ? (state as NoCurrentUser).exception : null));
    _backgroundBloc.add(BackgroundStartLoadingAnimation());

    try {
      debugPrint('🔍 [UserBloc] Checking if username is taken...');
      final isUsernameTaken = await _cloudStorage.usernameService.isUsernameTaken(event.username);
      if (isUsernameTaken) {
        debugPrint('⚠️ [UserBloc] Username already taken: ${event.username}');
        final exception = UsernameAlreadyExistsException(details: 'Username ${event.username} is already taken');
        await _handleError(exception, 'Username check during user creation');
        debugPrint('🔄 [UserBloc] Emitting NoCurrentUser with username taken exception');
        emit(NoCurrentUser(userType: event.userType, exception: exception));
        return;
      }

      debugPrint('✅ [UserBloc] Username available, creating user...');
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
      debugPrint('🔄 [UserBloc] Emitting CurrentUser with new user data');
      debugPrint('✅ [UserBloc] User created successfully');
    } catch (e) {
      debugPrint('❌ [UserBloc] Error creating user: $e');
      await _handleError(e, 'Creating user');
      debugPrint('🔄 [UserBloc] Emitting NoCurrentUser with error');
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
      debugPrint('🔄 [UserBloc] Copying user ${currentUser!} with interests...');
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
      debugPrint('🔄 [UserBloc] Updating user with interests...');
      await _cloudStorage.userService.updateUser(user: updatedUser);
      debugPrint('🔄 [UserBloc] User updated with interests');
      currentUser = updatedUser;
      debugPrint('🔄 [UserBloc] Emitting CurrentUser with updated user');
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
    debugPrint('🔄 [UserBloc] Setting user profile completed');
    if (currentUser == null) {
      emit(NoCurrentUser(exception: NoCurrentUserException()));
      return;
    }
    debugPrint('🔄 [UserBloc] Current user: ${currentUser!}');
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
    debugPrint('🔄 [UserBloc] Updated user: $updatedUser');
    await _cloudStorage.userService.updateUser(user: updatedUser);
    currentUser = updatedUser;
    debugPrint('🔄 [UserBloc] Emitting CurrentUser with updated user');
    emit(CurrentUser(user: currentUser!, privateData: _currentPrivateData!));
  }

  void _onSetUserLocationsLocally(SetUserLocationsLocally event, Emitter<UserState> emit) {
    debugPrint('🔄 [UserBloc] Setting user locations');
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
    debugPrint('🔄 [UserBloc] Updated user: $updatedUser');
    currentUser = updatedUser;
    debugPrint('🔄 [UserBloc] Emitting CurrentUser with updated user');
    emit(CurrentUser(user: currentUser!, privateData: _currentPrivateData!));
  }

  void _onOnError(OnError event, Emitter<UserState> emit) {
    debugPrint('❌ [UserBloc] Error: ${event.exception}');
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
