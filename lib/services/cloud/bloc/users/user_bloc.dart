import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/cloud_models/cloud_user.dart';
import 'package:livit/services/cloud/cloud_functions/cloud_functions_exceptions.dart';
import 'package:livit/services/cloud/cloud_functions/firestore_cloud_functions.dart';
import 'package:livit/services/cloud/firebase_cloud_storage.dart';
import 'package:livit/services/auth/auth_provider.dart';
import 'package:livit/services/cloud/bloc/users/user_event.dart';
import 'package:livit/services/cloud/bloc/users/user_state.dart';
import 'package:livit/services/cloud/livit_user.dart';
import 'package:livit/services/cloud/cloud_storage_exceptions.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final FirebaseCloudStorage _cloudStorage;
  final FirestoreCloudFunctions _firestoreCloudFunctions;
  final AuthProvider _authProvider;

  LivitUser? _currentUser;

  UserBloc({
    required FirebaseCloudStorage cloudStorage,
    required FirestoreCloudFunctions firestoreCloudFunctions,
    required AuthProvider authProvider,
  })  : _cloudStorage = cloudStorage,
        _firestoreCloudFunctions = firestoreCloudFunctions,
        _authProvider = authProvider,
        super(NoCurrentUser(isInitialized: false)) {
    on<GetUser>(_onGetUser);
    on<SetUserType>(_onSetUserType);
    on<CreateUser>(_onCreateUser);
    on<SetUserInterests>(_onSetUserInterests);
  }

  Future<void> _onGetUser(GetUser event, Emitter<UserState> emit) async {
    emit(NoCurrentUser(isLoading: true));
    try {
      final userId = _authProvider.currentUser.id;
      final user = await _cloudStorage.getUser(userId: userId);

      _currentUser = user;

      emit(CurrentUser(user: user));
    } on UserNotFoundException {
      emit(NoCurrentUser(exception: UserNotFoundException()));
    } catch (e) {
      emit(NoCurrentUser(exception: e as Exception));
    }
  }

  void _onSetUserType(SetUserType event, Emitter<UserState> emit) {
    emit(NoCurrentUser(userType: event.userType, isLoading: false));
  }

  Future<void> _onCreateUser(CreateUser event, Emitter<UserState> emit) async {
    emit(NoCurrentUser(userType: event.userType, isCreating: true));
    try {
      final userId = _authProvider.currentUser.id;
      final newUser = LivitUser(
        id: userId,
        name: event.name,
        username: event.username,
        userType: event.userType.name,
        email: _authProvider.currentUser.email ?? '',
        profilePicture: '',
        location: '',
        description: '',
        phoneNumber: _authProvider.currentUser.phoneNumber ?? '',
        friends: [],
        attendingEvents: [],
        likedEvents: [],
        ownedTickets: [],
        shareAttendingEvents: true,
        isProfileCompleted: false,
        interests: [],
      );
      await _firestoreCloudFunctions.createUserAndUsername(
        user: CloudUser(
          id: userId,
          username: event.username,
          userType: event.userType.name,
          name: event.name,
        ),
      );

      _currentUser = newUser;

      emit(CurrentUser(user: newUser));
    } catch (e) {
      emit(NoCurrentUser(
        userType: event.userType,
        exception: e as Exception,
        isLoading: false,
      ));
    }
  }

  Future<void> _onSetUserInterests(SetUserInterests event, Emitter<UserState> emit) async {
    if (_currentUser == null) {
      emit(NoCurrentUser(exception: NoCurrentUserException()));
      return;
    }

    emit(CurrentUser(user: _currentUser!, isLoading: true));
    try {
      final updatedUser = _currentUser!.copyWith(
        interests: event.interests,
        isProfileCompleted: true,
      );

      await _cloudStorage.updateUser(user: updatedUser);

      _currentUser = updatedUser;

      emit(CurrentUser(user: updatedUser));
    } catch (e) {
      emit(CurrentUser(user: _currentUser!, exception: e as Exception));
    }
  }

  LivitUser? getCurrentUser() {
    return _currentUser;
  }
}
