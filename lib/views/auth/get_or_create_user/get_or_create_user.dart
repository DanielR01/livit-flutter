import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/cloud_models/user/cloud_user.dart';
import 'package:livit/constants/enums.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/services/cloud/cloud_storage_exceptions.dart';
import 'package:livit/services/cloud/bloc/users/user_bloc.dart';
import 'package:livit/services/cloud/bloc/users/user_event.dart';
import 'package:livit/services/cloud/bloc/users/user_state.dart';
import 'package:livit/utilities/error_screens/error_reauth_screen.dart';
import 'package:livit/utilities/loading_screen.dart';
import 'package:livit/views/auth/get_or_create_user/create_user_view.dart';
import 'package:livit/views/auth/get_or_create_user/final_welcome_message.dart';
import 'package:livit/views/auth/get_or_create_user/promoter/description_prompt.dart';
import 'package:livit/views/auth/get_or_create_user/promoter/location_prompt.dart';
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
    BlocProvider.of<UserBloc>(context).add(GetUserWithPrivateData());
  }

  bool checkIfProfileIsComplete(UserState state) {
    if (state is CurrentUser) {
      if (state.user is CloudPromoter) {
        final promoter = state.user as CloudPromoter;
        return promoter.description != null && promoter.interests != null && promoter.location != null;
      } else if (state.user is CloudCustomer) {
        return state.user.interests != null;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserBloc, UserState>(
      listener: (context, state) {
        if (state is CurrentUser) {
          if (!state.privateData.isFirstTime && !_isFirstTime) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              Routes.mainViewRoute,
              (route) => false,
              arguments: state.user,
            );
          }
        }
      },
      builder: (context, state) {
        if (state is NoCurrentUser && state.userType == null && !state.isLoading && state.isInitialized && state.exception == null) {
          return const UserTypeInput();
        }
        switch (state) {
          case CurrentUser():
            if (state.user.userType == UserType.customer) {
              if (!state.privateData.isFirstTime) {
                _isFirstTime = true;
                return const WelcomeAndDataView();
              } else if (_isFirstTime) {
                return FinalWelcomeMessage(
                  onPressed: () {
                    setState(
                      () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          Routes.mainViewRoute,
                          (route) => false,
                          arguments: state.user,
                        );
                      },
                    );
                  },
                );
              }
              return const LoadingScreen();
            } else if (state.user is CloudPromoter) {
              final promoter = state.user as CloudPromoter;
              if (promoter.description == null) {
                _isFirstTime = true;
                return const DescriptionPrompt();
              } else if (promoter.interests == null) {
                _isFirstTime = true;
                return const InterestsView();
              } else if (promoter.location == null) {
                _isFirstTime = true;
                return const LocationPromptView();
              } else {
                return const LoadingScreen();
              }
            } else {
              return ErrorReauthScreen(exception: UserTypeNotFoundException());
            }
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
                _isFirstTime = true;
                return const CreateUserView();
              }
            } else if (state.exception is UsernameAlreadyTakenException) {
              return const CreateUserView();
            } else {
              return ErrorReauthScreen(exception: state.exception);
            }
          default:
            return const LoadingScreen();
        }
      },
    );
  }
}
