import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/enums/credential_types.dart';
import 'package:livit/services/auth/auth_exceptions.dart';
import 'package:livit/services/auth/auth_service.dart';
import 'package:livit/utilities/buttons/main_action_button.dart';
import 'package:livit/utilities/error_dialogs/show_error_dialog_2t_1b.dart';
import 'package:livit/utilities/error_dialogs/show_error_dialog_2t_2b.dart';

class RegisterEmailView extends StatefulWidget {
  const RegisterEmailView({super.key});

  @override
  State<RegisterEmailView> createState() => _RegisterEmailViewState();
}

class _RegisterEmailViewState extends State<RegisterEmailView> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isEmailValid = false;
  bool _isPasswordValid = false;

  late final TextEditingController _emailFieldController;
  late final TextEditingController _passwordFieldController;

  @override
  void initState() {
    _emailFieldController = TextEditingController();
    _passwordFieldController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailFieldController.dispose();
    _passwordFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 35),
            child: Column(
              children: [
                const Text(
                  'Register',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: LivitColors.whiteActive,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text('Register with an email and password'),
                const SizedBox(
                  height: 40,
                ),
                TextFormField(
                  cursorColor: LivitColors.whiteInactive,
                  controller: _emailFieldController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    setState(
                      () {
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(_emailFieldController.text)) {
                          _isEmailValid = false;
                        } else {
                          _isEmailValid = true;
                        }
                      },
                    );
                  },
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: const TextStyle(
                      color: LivitColors.inactiveGray,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: LivitColors.inactiveGray,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: LivitColors.whiteActive),
                    ),
                    suffixIcon: _isEmailValid
                        ? const Icon(
                            Icons.done,
                            color: Color.fromARGB(255, 255, 255, 255),
                            size: 18,
                          )
                        : null,
                  ),
                  style: const TextStyle(
                    color: LivitColors.whiteActive,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  cursorColor: LivitColors.whiteInactive,
                  controller: _passwordFieldController,
                  onChanged: (value) {
                    setState(
                      () {
                        if (_passwordFieldController.text.length < 8 ||
                            _passwordFieldController.text.length > 20) {
                          _isPasswordValid = false;
                        } else {
                          _isPasswordValid = true;
                        }
                      },
                    );
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    hintStyle: const TextStyle(
                      color: LivitColors.inactiveGray,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: LivitColors.inactiveGray,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: LivitColors.whiteActive),
                    ),
                    suffixIcon: _isPasswordValid
                        ? const Icon(
                            Icons.done,
                            color: Color.fromARGB(255, 255, 255, 255),
                            size: 18,
                          )
                        : null,
                  ),
                  style: const TextStyle(
                    color: LivitColors.whiteActive,
                  ),
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'Password must have at least 8 characters (20 max)',
                  style: TextStyle(
                    color: LivitColors.inactiveGray,
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                MainActionButton(
                  isActive: (_isEmailValid && _isPasswordValid) ? true : false,
                  onPressed: () async {
                    final email = _emailFieldController.text;
                    final password = _passwordFieldController.text;
                    registerWithEmailAndPassword(
                      context,
                      scaffoldKey,
                      email,
                      password,
                    );
                  },
                  text: 'Register',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void registerWithEmailAndPassword(
    BuildContext context,
    GlobalKey key,
    String email,
    String password,
  ) async {
    try {
      await AuthService.firebase().createUser(
        credentialType: CredentialType.emailAndPassword,
        credentials: [
          email,
          password,
        ],
      );
      await AuthService.firebase().sendEmailVerification();
      if (context.mounted) {
        await Navigator.of(context).pushNamed(Routes.verifyEmailRoute);
      }
    } on InvalidEmailAuthException {
      await showErrorDialog(
        key,
        'Invalid email',
        'The email provided is not a valid one',
      );
    } on WeakPasswordAuthException {
      await showErrorDialog(
        key,
        'Weak password',
        'The password must have at least 8 characters',
      );
    } on EmailAlreadyInUseAuthException {
      await showErrorDialog2b(
        [key, null],
        'Email already in use',
        'This email is already in use by an account',
        [
          'Log in with email',
          () {
            Navigator.of(context).pushNamed(Routes.loginEmailRoute);
          },
        ],
        [
          'Try Again',
          () {
            Navigator.of(context).pop(false);
          },
        ],
      );
    } on GenericAuthException {
      await showErrorDialog(
        key,
        'Something went wrong',
        'Try again in a few minutes',
      );
    }
  }
}
