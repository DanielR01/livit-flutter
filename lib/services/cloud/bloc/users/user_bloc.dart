import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/cloud_models/cloud_models_exceptions.dart';
import 'package:livit/cloud_models/location.dart';
import 'package:livit/cloud_models/user/cloud_user.dart';
import 'package:livit/cloud_models/user/private_data.dart';
import 'package:livit/constants/enums.dart';
import 'package:livit/services/cloud/cloud_functions/firestore_cloud_functions.dart';
import 'package:livit/services/cloud/firebase_cloud_storage.dart';
import 'package:livit/services/auth/auth_provider.dart';
import 'package:livit/services/cloud/bloc/users/user_event.dart';
import 'package:livit/services/cloud/bloc/users/user_state.dart';
import 'package:livit/services/cloud/cloud_storage_exceptions.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final FirebaseCloudStorage _cloudStorage;
  final FirestoreCloudFunctions _firestoreCloudFunctions;
  final AuthProvider _authProvider;

  CloudUser? _currentUser;
  UserPrivateData? _currentPrivateData;

  UserBloc({
    required FirebaseCloudStorage cloudStorage,
    required FirestoreCloudFunctions firestoreCloudFunctions,
    required AuthProvider authProvider,
  })  : _cloudStorage = cloudStorage,
        _firestoreCloudFunctions = firestoreCloudFunctions,
        _authProvider = authProvider,
        super(NoCurrentUser(isInitialized: false)) {
    on<GetUserWithPrivateData>(_onGetUserWithPrivateData);
    on<SetUserType>(_onSetUserType);
    on<CreateUser>(_onCreateUser);
    on<SetUserInterests>(_onSetUserInterests);
    on<SetPromoterUserDescription>(_onSetPromoterUserDescription);
    on<SetPromoterUserLocation>(_onSetPromoterUserLocation);
  }

  Future<void> _onGetUserWithPrivateData(GetUserWithPrivateData event, Emitter<UserState> emit) async {
    emit(NoCurrentUser(isLoading: true));
    try {
      final userId = _authProvider.currentUser.id;

      final user = await _cloudStorage.getUser(userId: userId);

      final privateData = await _cloudStorage.getPrivateData(userId: userId);

      if (user.userType != privateData.userType) {
        emit(NoCurrentUser(exception: UserTypeMismatchException()));
        return;
      }

      _currentUser = user; // This will be either CloudCustomer or CloudPromoter
      _currentPrivateData = privateData;

      emit(CurrentUser(user: user, privateData: privateData));
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
      final isUsernameTaken = await _cloudStorage.isUsernameTaken(event.username);
      if (isUsernameTaken) {
        emit(NoCurrentUser(userType: event.userType, exception: UsernameAlreadyTakenException()));
        return;
      }
      final userId = _authProvider.currentUser.id;
      final newUser = event.userType == UserType.promoter
          ? CloudPromoter(
              id: userId,
              username: event.username,
              userType: event.userType,
              name: event.name,
              interests: [""],
              createdAt: Timestamp.now(),
              description: null,
              location: null,
            )
          : CloudCustomer(
              id: userId,
              username: event.username,
              userType: event.userType,
              name: event.name,
              interests: [""],
              createdAt: Timestamp.now(),
            );
      final newPrivateData = UserPrivateData(
        phoneNumber: _authProvider.currentUser.phoneNumber ?? '',
        email: _authProvider.currentUser.email ?? '',
        userType: event.userType,
        isFirstTime: true,
      );

      final createdAt = await _firestoreCloudFunctions.createUserAndUsername(
        user: newUser,
        privateData: newPrivateData,
      );
      _currentUser = newUser.copyWith(createdAt: createdAt);
      _currentPrivateData = newPrivateData;

      emit(CurrentUser(user: _currentUser!, privateData: _currentPrivateData!));
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

    emit(CurrentUser(user: _currentUser!, privateData: _currentPrivateData!, isLoading: true));
    try {
      final updatedUser = _currentUser!.copyWith(
        interests: event.interests,
      );

      await _cloudStorage.updateUser(user: updatedUser);

      _currentUser = updatedUser;

      emit(CurrentUser(user: updatedUser, privateData: _currentPrivateData!));
    } catch (e) {
      emit(CurrentUser(user: _currentUser!, privateData: _currentPrivateData!, exception: e as Exception));
    }
  }

  Future<void> _onSetPromoterUserDescription(SetPromoterUserDescription event, Emitter<UserState> emit) async {
    if (_currentUser == null) {
      emit(NoCurrentUser(exception: NoCurrentUserException()));
      return;
    }
    if (_currentUser is! CloudPromoter) {
      emit(NoCurrentUser(exception: InvalidUserTypeException()));
      return;
    }

    emit(CurrentUser(user: _currentUser!, privateData: _currentPrivateData!, isLoading: true));
    try {
      final updatedUser = (_currentUser as CloudPromoter).copyWith(
        description: event.description,
      );

      await _cloudStorage.updateUser(user: updatedUser);
      _currentUser = updatedUser;

      emit(CurrentUser(user: updatedUser, privateData: _currentPrivateData!));
    } catch (e) {
      emit(CurrentUser(user: _currentUser!, privateData: _currentPrivateData!, exception: e as Exception));
    }
  }


  Future<void> _onSetPromoterUserLocation(SetPromoterUserLocation event, Emitter<UserState> emit) async {
    if (_currentUser == null) {
      emit(NoCurrentUser(exception: NoCurrentUserException()));
      return;
    }
    if (_currentUser is! CloudPromoter) {
      emit(NoCurrentUser(exception: InvalidUserTypeException()));
      return;
    }

    emit(CurrentUser(user: _currentUser!, privateData: _currentPrivateData!, isLoading: true));
    try {
      final location = Location(name: event.name, geopoint: event.geopoint);
      final updatedUser = (_currentUser as CloudPromoter).copyWith(
        location: location,
      );

      await _cloudStorage.updateUser(user: updatedUser);
      _currentUser = updatedUser;

      emit(CurrentUser(user: updatedUser, privateData: _currentPrivateData!));
    } catch (e) {
      emit(CurrentUser(user: _currentUser!, privateData: _currentPrivateData!, exception: e as Exception));
    }
  } 

  CloudUser? getCurrentUser() {
    return _currentUser;
  }
}
