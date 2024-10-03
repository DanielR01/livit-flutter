import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/constants/enums.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/services/cloud/cloud_storage_exceptions.dart';
import 'package:livit/services/cloud/bloc/users/user_bloc.dart';
import 'package:livit/services/cloud/bloc/users/user_event.dart';
import 'package:livit/services/cloud/bloc/users/user_state.dart';
import 'package:livit/utilities/error_screens/error_reauth_screen.dart';
import 'package:livit/utilities/loading_screen.dart';
import 'package:livit/views/auth/get_or_create_user/create_user_view.dart';
import 'package:livit/views/auth/get_or_create_user/user_type_input.dart';
import 'package:livit/views/auth/get_or_create_user/welcome_and_data_view.dart';

class GetOrCreateUserView extends StatefulWidget {
  final UserType? userType;
  const GetOrCreateUserView({super.key, this.userType});

  @override
  State<GetOrCreateUserView> createState() => _GetOrCreateUserViewState();
}

class _GetOrCreateUserViewState extends State<GetOrCreateUserView> {

  @override
  void initState() {
    super.initState();
    BlocProvider.of<UserBloc>(context).add(GetUser());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state is CurrentUser) {
            if (state.user.isProfileCompleted) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                Routes.mainViewRoute,
                (route) => false,
                arguments: state.user,
              );
            }
          }
        },
        builder: (context, state) {
          switch (state) {
            case CurrentUser():
              if (!state.user.isProfileCompleted) {
                return const WelcomeAndDataView();
              }
              return const LoadingScreen();
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
                  return const CreateUserView();
                }
              } else if (state.exception is UsernameAlreadyExistsException) {
                return const CreateUserView();
              } else {
                return const ErrorReauthScreen();
              }

            default:
              return const LoadingScreen();
          }
        },
      
    );
  }
}
