import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/cloud_models/user/cloud_user.dart';
import 'package:livit/cloud_models/user/private_data.dart';
import 'package:livit/services/background/background_events.dart';
import 'package:livit/services/firestore_storage/cloud_functions/firestore_cloud_functions.dart';
import 'package:livit/services/firestore_storage/firestore_storage/firestore_storage.dart';
import 'package:livit/services/auth/auth_provider.dart';
import 'package:livit/services/firestore_storage/bloc/users/user_event.dart';
import 'package:livit/services/firestore_storage/bloc/users/user_state.dart';
import 'package:livit/services/firestore_storage/firestore_storage/exceptions/firestore_exceptions.dart';
import 'package:livit/services/background/background_bloc.dart';
import 'package:livit/services/error_reporting/error_reporter.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final FirestoreStorage _cloudStorage;
  final FirestoreCloudFunctions _firestoreCloudFunctions;
  final AuthProvider _authProvider;
  final ErrorReporter _errorReporter;
  final BackgroundBloc _backgroundBloc;

  CloudUser? _currentUser;
  UserPrivateData? _currentPrivateData;

  UserBloc({
    required FirestoreStorage cloudStorage,
    required FirestoreCloudFunctions firestoreCloudFunctions,
    required AuthProvider authProvider,
    ErrorReporter? errorReporter,
    required BackgroundBloc backgroundBloc,
  })  : _cloudStorage = cloudStorage,
        _firestoreCloudFunctions = firestoreCloudFunctions,
        _authProvider = authProvider,
        _errorReporter = errorReporter ?? ErrorReporter(),
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
      final userId = _authProvider.currentUser.id;
      debugPrint('📥 [UserBloc] Fetching user data for ID: $userId');
      final user = await _cloudStorage.userMethods.getUser(userId: userId);
      debugPrint('👤 [UserBloc] User fetched: ${user.username}');
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
      final userId = _authProvider.currentUser.id;
      debugPrint('📥 [UserBloc] Fetching user data for ID: $userId');

      final user = await _cloudStorage.userMethods.getUser(userId: userId);
      debugPrint('👤 [UserBloc] User fetched: ${user.username}');

      final privateData = await _cloudStorage.privateDataMethods.getPrivateData(userId: userId);
      debugPrint('🔒 [UserBloc] Private data fetched for user');

      if (user.userType != privateData.userType) {
        debugPrint('⚠️ [UserBloc] User type mismatch detected: ${user.userType} != ${privateData.userType}');
        final exception = UserInformationCorruptedException(details: 'User type mismatch: ${user.userType} != ${privateData.userType}');
        await _handleError(exception, 'Type mismatch during user fetch');
        debugPrint('🔄 [UserBloc] Emitting NoCurrentUser with corruption exception');
        emit(NoCurrentUser(exception: exception));
        return;
      }

      _currentUser = user;
      _currentPrivateData = privateData;
      debugPrint('✅ [UserBloc] User data successfully loaded');
      debugPrint('🔄 [UserBloc] Emitting CurrentUser state');
      emit(CurrentUser(user: user, privateData: privateData));
    } catch (e) {
      debugPrint('❌ [UserBloc] Error getting user data: $e');
      await _handleError(e, 'Getting user with private data');
      debugPrint(
          '🔄 [UserBloc] Emitting NoCurrentUser with error: ${e is FirestoreException ? e : GenericFirestoreException(details: e.toString())}');
      emit(NoCurrentUser(exception: e is FirestoreException ? e : GenericFirestoreException(details: e.toString())));
    } finally {
      if (event.context.mounted) {
        _backgroundBloc.add(BackgroundStopLoadingAnimation());
      }
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
      final isUsernameTaken = await _cloudStorage.usernameMethods.isUsernameTaken(event.username);
      if (isUsernameTaken) {
        debugPrint('⚠️ [UserBloc] Username already taken: ${event.username}');
        final exception = UsernameAlreadyExistsException(details: 'Username ${event.username} is already taken');
        await _handleError(exception, 'Username check during user creation');
        debugPrint('🔄 [UserBloc] Emitting NoCurrentUser with username taken exception');
        emit(NoCurrentUser(userType: event.userType, exception: exception));
        return;
      }

      debugPrint('✅ [UserBloc] Username available, creating user...');
      final userId = _authProvider.currentUser.id;
      await _firestoreCloudFunctions.createUserAndUsername(
        userId: userId,
        username: event.username,
        userType: event.userType.name,
        name: event.name,
        phoneNumber: _authProvider.currentUser.phoneNumber ?? '',
        email: _authProvider.currentUser.email ?? '',
      );
      _currentUser = await _cloudStorage.userMethods.getUser(userId: userId);
      _currentPrivateData = await _cloudStorage.privateDataMethods.getPrivateData(userId: userId);
      emit(CurrentUser(user: _currentUser!, privateData: _currentPrivateData!));
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
    if (_currentUser == null) {
      final exception = NoCurrentUserException(details: 'Attempting to set interests with no current user');
      await _handleError(exception, 'Setting user interests');
      emit(NoCurrentUser(exception: exception));
      return;
    }

    emit(CurrentUser(user: _currentUser!, privateData: _currentPrivateData!, isLoading: true));
    _backgroundBloc.add(BackgroundStartLoadingAnimation());

    try {
      debugPrint('🔄 [UserBloc] Copying user ${_currentUser!} with interests...');
      final updatedUser = _currentUser!.copyWith(
        interests: event.interests,
      );
      debugPrint('🔄 [UserBloc] Updating user with interests...');
      await _cloudStorage.userMethods.updateUser(user: updatedUser);
      debugPrint('🔄 [UserBloc] User updated with interests');
      _currentUser = updatedUser;
      debugPrint('🔄 [UserBloc] Emitting CurrentUser with updated user');
      emit(CurrentUser(user: _currentUser!, privateData: _currentPrivateData!));
    } catch (e) {
      await _handleError(e, 'Setting user interests');
      emit(CurrentUser(
          user: _currentUser!,
          privateData: _currentPrivateData!,
          exception: e is FirestoreException ? e : GenericFirestoreException(details: e.toString())));
    } finally {
      _backgroundBloc.add(BackgroundStopLoadingAnimation());
    }
  }

  Future<void> _onSetPromoterUserDescription(SetPromoterUserDescription event, Emitter<UserState> emit) async {
    if (_currentUser == null) {
      emit(NoCurrentUser(exception: NoCurrentUserException()));
      return;
    }
    if (_currentUser is! CloudPromoter) {
      final exception = UserInformationCorruptedException(details: 'User type mismatch: ${_currentUser!.userType} != CloudPromoter');
      await _handleError(exception, 'Setting promoter user description');
      emit(NoCurrentUser(exception: exception));
      return;
    }

    emit(CurrentUser(user: _currentUser!, privateData: _currentPrivateData!, isLoading: true));
    _backgroundBloc.add(BackgroundStartLoadingAnimation());

    try {
      final updatedUser = (_currentUser as CloudPromoter).copyWith(
        description: event.description,
      );

      await _cloudStorage.userMethods.updateUser(user: updatedUser);
      _currentUser = updatedUser;

      emit(CurrentUser(user: updatedUser, privateData: _currentPrivateData!));
    } catch (e) {
      await _handleError(e, 'Setting promoter user description');
      emit(CurrentUser(user: _currentUser!, privateData: _currentPrivateData!, exception: e as Exception));
    } finally {
      _backgroundBloc.add(BackgroundStopLoadingAnimation());
    }
  }

  Future<void> _onSetPromoterUserNoLocations(SetPromoterUserNoLocations event, Emitter<UserState> emit) async {
    if (_currentUser == null) {
      emit(NoCurrentUser(exception: NoCurrentUserException()));
      return;
    }
    if (_currentUser is! CloudPromoter) {
      final exception = UserInformationCorruptedException(details: 'User type mismatch: ${_currentUser!.userType} != CloudPromoter');
      await _handleError(exception, 'Setting promoter user no locations');
      emit(NoCurrentUser(exception: exception));
      return;
    }

    emit(CurrentUser(user: _currentUser!, privateData: _currentPrivateData!, isLoading: true));
    _backgroundBloc.add(BackgroundStartLoadingAnimation());

    try {
      await _firestoreCloudFunctions.updatePromoterUserNoLocations(userId: _currentUser!.id);
      final user = await _cloudStorage.userMethods.getUser(userId: _currentUser!.id);
      _currentUser = user;
      emit(CurrentUser(user: _currentUser!, privateData: _currentPrivateData!));
    } catch (e) {
      await _handleError(e, 'Setting promoter user no locations');
      emit(CurrentUser(user: _currentUser!, privateData: _currentPrivateData!, exception: e as Exception));
    } finally {
      _backgroundBloc.add(BackgroundStopLoadingAnimation());
    }
  }

  Future<void> _onSetUserProfileCompleted(SetUserProfileCompleted event, Emitter<UserState> emit) async {
    debugPrint('🔄 [UserBloc] Setting user profile completed');
    if (_currentUser == null) {
      emit(NoCurrentUser(exception: NoCurrentUserException()));
      return;
    }
    debugPrint('🔄 [UserBloc] Current user: ${_currentUser!}');
    final updatedUser = _currentUser!.copyWith(
      isProfileCompleted: true,
    );
    debugPrint('🔄 [UserBloc] Updated user: ${updatedUser}');
    await _cloudStorage.userMethods.updateUser(user: updatedUser);
    _currentUser = updatedUser;
    debugPrint('🔄 [UserBloc] Emitting CurrentUser with updated user');
    emit(CurrentUser(user: _currentUser!, privateData: _currentPrivateData!));
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
    return _currentUser;
  }
}
