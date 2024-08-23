import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/services/auth/auth_service.dart';
import 'package:livit/services/crud/crud_exceptions.dart';
import 'package:livit/services/crud/livit_db_service.dart';
import 'package:livit/services/crud/tables/users/user.dart';
import 'package:livit/utilities/error_screens/error_reauth_screen.dart';
import 'package:livit/utilities/loading_screen.dart';
import 'package:livit/views/main_pages/mainmenu.dart';

class GetOrCreateUserView extends StatefulWidget {
  final UserType? userType;
  const GetOrCreateUserView({
    super.key,
    this.userType,
  });

  @override
  State<GetOrCreateUserView> createState() => _GetOrCreateUserViewState();
}

class _GetOrCreateUserViewState extends State<GetOrCreateUserView> {
  late final LivitDBService _livitDBService;
  String get userId => AuthService.firebase().currentUser!.id!;

  @override
  void initState() {
    _livitDBService = LivitDBService();
    _livitDBService.open();
    super.initState();
  }

  @override
  void dispose() {
    _livitDBService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _livitDBService.getOrCreateUser(
        userId: userId,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          if (snapshot.error is CouldNotCreateNorGetUser) {
            return const ErrorReauthScreen();
          }
        }
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            if (snapshot.data == null) {
              return const ErrorReauthScreen();
            }
            return RedirectorLoadingScreen(user: snapshot.data!);
          default:
            return const LoadingScreen();
        }
      },
    );
  }
}

class RedirectorLoadingScreen extends StatefulWidget {
  final LivitUser user;
  const RedirectorLoadingScreen({
    super.key,
    required this.user,
  });

  @override
  State<RedirectorLoadingScreen> createState() =>
      _RedirectorLoadingScreenState();
}

class _RedirectorLoadingScreenState extends State<RedirectorLoadingScreen> {
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _routeUser();
    });
    super.initState();
  }

  void _routeUser() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      Routes.mainviewRoute,
      (route) => false,
      arguments: widget.user,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoadingScreen();
  }
}
