import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/services/auth/auth_service.dart';
import 'package:livit/services/auth/bloc/auth_bloc.dart';
import 'package:livit/services/auth/bloc/auth_event.dart';
import 'package:livit/services/auth/bloc/auth_state.dart';
import 'package:livit/views/auth/login/welcome.dart';
import 'package:livit/views/main_pages/mainmenu.dart';

class CheckInitialAuth extends StatefulWidget {
  const CheckInitialAuth({super.key});

  @override
  State<CheckInitialAuth> createState() => _CheckInitialAuthState();
}

class _CheckInitialAuthState extends State<CheckInitialAuth> {
  // late bool isAuth;
  // late bool isLoggedIn;

  // @override
  // void initState() {
  //   isAuth = _checkIfLoggedIn();
  //   super.initState();
  //   SchedulerBinding.instance.addPostFrameCallback((_) {
  //     _routeUser();
  //   });
  // }

  // void _routeUser() {
  //   if (isAuth) {
  //     Navigator.of(context).pushNamedAndRemoveUntil(Routes.mainviewRoute, (route) => false);
  //   } else {
  //     Navigator.of(context).pushNamedAndRemoveUntil(Routes.welcomeRoute, (route) => false);
  //   }
  // }

  // bool _checkIfLoggedIn() {
  //   final user = AuthService.firebase().currentUser;
  //   if (user?.id == null) {
  //     return false;
  //   }
  //   return true;
  // }

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      if (state is AuthStateLoggedIn) {
        return const MainMenu();
      }
      return const WelcomeView();
    });
  }
}
