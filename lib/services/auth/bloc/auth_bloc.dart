import 'package:bloc/bloc.dart';
import 'package:livit/services/auth/auth_provider.dart';
import 'package:livit/services/auth/auth_user.dart';
import 'package:livit/services/auth/bloc/auth_event.dart';
import 'package:livit/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthProvider provider}) : super(const AuthStateLoading()) {
    on<AuthEventInitialize>(
      (event, emit) async {
        await provider.initialize();
        final AuthUser? user = provider.currentUser;
        if (user == null) {
          emit(const AuthStateLoggedOut());
        } else {
          if (user.isEmailVerified ?? false) {
            emit(AuthStateLoggedIn(user: user));
          } else {
            emit(const AuthStateNeedsVerification());
          }
        }
      },
    );

    on<AuthEventLogInWithEmailAndPassword>(
      (event, emit) async {
        emit(const AuthStateLoading());
        final email = event.email;
        final password = event.password;
        try {
          final user = await provider.logInWithEmailAndPassword(email: email, password: password);
          emit(AuthStateLoggedIn(user: user));
        } catch (e) {
          emit(AuthStateLoginError(exception: e as Exception));
        }
      },
    );

    on<AuthEventLogOut>(
      (event, emit) async {
        emit(const AuthStateLoading());
        try {
          await provider.logOut();
          emit(const AuthStateLoggedOut());
        } catch (e) {
          emit(AuthStateLogoutError(exception: e as Exception));
        }
      },
    );
  }
}
