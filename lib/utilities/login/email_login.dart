import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/services/auth/auth_exceptions.dart';
import 'package:livit/services/auth/auth_service.dart';
import 'package:livit/services/auth/credential_types.dart';
import 'package:livit/services/cloud/firebase_cloud_storage.dart';
import 'package:livit/utilities/background/main_background.dart';
import 'package:livit/utilities/bars_containers_fields/glass_container.dart';
import 'package:livit/utilities/bars_containers_fields/text_field.dart';
import 'package:livit/utilities/bars_containers_fields/title_bar.dart';
import 'package:livit/utilities/buttons/button.dart';

class EmailLogin extends StatefulWidget {
  final UserType userType;
  const EmailLogin({
    super.key,
    required this.userType,
  });

  @override
  State<EmailLogin> createState() => _EmailSignIn();
}

class _EmailSignIn extends State<EmailLogin> {
  EmailLoginViews _currentView = EmailLoginViews.login;

  void _onRegisterPressed() {
    setState(
      () {
        _currentView = EmailLoginViews.register;
      },
    );
  }

  void _onLoginPressed() {
    setState(
      () {
        _currentView = EmailLoginViews.login;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const MainBackground(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: LivitContainerStyle.paddingFromScreen,
                          child: GlassContainer(
                            child: SizedBox(
                              width: double.infinity,
                              child: Padding(
                                padding: LivitContainerStyle.padding([0, null, null, null]),
                                child: Column(
                                  children: [
                                    const TitleBar(
                                      title: 'Continua con email y contraseña',
                                      isBackEnabled: true,
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: _onLoginPressed,
                                            child: Container(
                                              padding: EdgeInsets.only(bottom: 8.sp),
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                border: Border(
                                                    bottom: BorderSide(
                                                  color:
                                                      _currentView == EmailLoginViews.login ? LivitColors.whiteActive : Colors.transparent,
                                                )),
                                              ),
                                              child: Center(
                                                child: LivitText(
                                                  'Iniciar sesión',
                                                  color: _currentView == EmailLoginViews.login
                                                      ? LivitColors.whiteActive
                                                      : LivitColors.whiteInactive,
                                                  fontWeight: _currentView == EmailLoginViews.login ? FontWeight.bold : null,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: _onRegisterPressed,
                                            child: Container(
                                              padding: EdgeInsets.only(bottom: 8.sp),
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                border: Border(
                                                    bottom: BorderSide(
                                                  color: _currentView == EmailLoginViews.register
                                                      ? LivitColors.whiteActive
                                                      : Colors.transparent,
                                                )),
                                              ),
                                              child: Center(
                                                child: LivitText(
                                                  'Crear cuenta',
                                                  color: _currentView == EmailLoginViews.register
                                                      ? LivitColors.whiteActive
                                                      : LivitColors.whiteInactive,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        LivitSpaces.m,
                                      ],
                                    ),
                                    LivitSpaces.l,
                                    Redirector(
                                      userType: widget.userType,
                                      view: _currentView,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        LivitSpaces.m,
                        Padding(
                          padding: LivitContainerStyle.paddingFromScreen,
                          child: const ForgotPassword(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum EmailLoginViews {
  login,
  register,
}

class Redirector extends StatelessWidget {
  final EmailLoginViews view;
  final UserType userType;

  const Redirector({
    super.key,
    required this.view,
    required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    switch (view) {
      case EmailLoginViews.login:
        return SignIn(userType: userType);
      case EmailLoginViews.register:
        return const Register();
    }
  }
}

class SignIn extends StatefulWidget {
  final UserType userType;
  const SignIn({
    super.key,
    required this.userType,
  });

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  bool _isSigningIn = false;
  bool _isEmailValid = false;
  bool _isPasswordValid = false;

  String? emailCaptionText;
  String? passwordCaptionText;

  String? emailToVerify;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onEmailChange(bool isValid) {
    setState(
      () {
        _isEmailValid = isValid;
      },
    );
  }

  void _onPasswordChange(bool isValid) {
    setState(
      () {
        _isPasswordValid = isValid;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        LivitTextField(
          controller: _emailController,
          hint: 'Email',
          inputType: TextInputType.emailAddress,
          regExp: RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'),
          onChanged: _onEmailChange,
          bottomCaptionText: emailCaptionText,
        ),
        LivitSpaces.m,
        LivitTextField(
          controller: _passwordController,
          hint: 'Contraseña',
          blurInput: true,
          onChanged: _onPasswordChange,
          regExp: RegExp(r'^.{6,}$'),
          bottomCaptionText: passwordCaptionText,
        ),
        LivitSpaces.m,
        Button.main(
          text: _isSigningIn ? 'Iniciando sesión' : 'Iniciar sesión',
          isActive: _isEmailValid & _isPasswordValid,
          onPressed: () async {
            setState(
              () {
                passwordCaptionText = null;
                emailCaptionText = null;
                _isSigningIn = true;
                emailToVerify = null;
              },
            );
            try {
              await AuthService.firebase().logIn(
                credentialType: CredentialType.emailAndPassword,
                credentials: [
                  _emailController.text,
                  _passwordController.text,
                ],
              );
              Navigator.of(context).pushNamedAndRemoveUntil(Routes.mainviewRoute, arguments: widget.userType, (route) => false);
            } on NetworkRequesFailed {
              passwordCaptionText = 'Error de red';
            } on UserNotLoggedInAuthException {
              emailToVerify = _emailController.text;
              AuthService.firebase().sendEmailVerification();
            } on InvalidCredentialsAuthException {
              passwordCaptionText = 'Email o contraseña incorrectos';
            } on TooManyRequestsAuthException {
              passwordCaptionText = 'Demasiados intentos, espera unos minutos';
            } on GenericAuthException {
              passwordCaptionText = 'Error, intenta de nuevo en unos minutos';
            }
            setState(
              () {
                _isSigningIn = false;
              },
            );
          },
        ),
        emailToVerify == null
            ? const SizedBox()
            : VerifyEmail(
                email: emailToVerify!,
                isLoginVariant: true,
              ),
      ],
    );
  }
}

class Register extends StatefulWidget {
  const Register({
    super.key,
  });

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  bool _isSigningIn = false;
  bool _isEmailValid = false;
  bool _isPasswordValid = false;
  bool _arePasswordsEqual = false;

  String? emailCaptionText;
  String? passwordCaptionText;
  String? confirmPasswordCaptionText;

  String? emailToVerify;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onEmailChange(bool isValid) {
    setState(
      () {
        _isEmailValid = isValid;
      },
    );
  }

  void _onPasswordChange(bool isValid) {
    setState(
      () {
        _isPasswordValid = isValid;
        if ((_passwordController.text == _confirmPasswordController.text) && (_passwordController.text.isNotEmpty)) {
          _arePasswordsEqual = true;
        } else {
          _arePasswordsEqual = false;
        }
      },
    );
  }

  void _onConfirmPasswordChange(bool isValid) {
    setState(
      () {
        if ((_passwordController.text == _confirmPasswordController.text) && (_passwordController.text.isNotEmpty)) {
          _arePasswordsEqual = true;
        } else {
          _arePasswordsEqual = false;
        }
      },
    );
  }

  void _resetFields() {
    setState(
      () {
        _passwordController.clear();
        _confirmPasswordController.clear();
        _arePasswordsEqual = false;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        LivitTextField(
          controller: _emailController,
          hint: 'Email',
          inputType: TextInputType.emailAddress,
          regExp: RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'),
          onChanged: _onEmailChange,
          bottomCaptionText: emailCaptionText,
        ),
        LivitSpaces.s,
        if (_emailController.text.isNotEmpty)
          LivitText(
            'Ingresa un email válido',
            color: _isEmailValid ? LivitColors.whiteInactive : LivitColors.whiteActive,
            isLineThrough: _isEmailValid,
          ),
        LivitSpaces.m,
        LivitTextField(
          controller: _passwordController,
          hint: 'Contraseña',
          blurInput: true,
          onChanged: _onPasswordChange,
          regExp: RegExp(r'^.{6,}$'),
          bottomCaptionText: passwordCaptionText,
        ),
        LivitSpaces.s,
        if (_passwordController.text.isNotEmpty)
          LivitText(
            'Tu contraseña debe tener al menos 8 caracteres',
            color: _isPasswordValid ? LivitColors.whiteInactive : LivitColors.whiteActive,
            isLineThrough: _isPasswordValid,
          ),
        LivitSpaces.m,
        LivitTextField(
          controller: _confirmPasswordController,
          hint: 'Verifica tu contraseña',
          blurInput: true,
          onChanged: _onConfirmPasswordChange,
          externalIsValid: _arePasswordsEqual,
          bottomCaptionText: confirmPasswordCaptionText,
        ),
        LivitSpaces.s,
        if (_confirmPasswordController.text.isNotEmpty)
          LivitText(
            'Las contraseñas deben coincidir',
            color: _arePasswordsEqual ? LivitColors.whiteInactive : LivitColors.whiteActive,
            isLineThrough: _arePasswordsEqual,
          ),
        LivitSpaces.m,
        Button.main(
          text: _isSigningIn ? 'Creando cuenta' : 'Crear cuenta',
          isActive: _isEmailValid & _isPasswordValid & _arePasswordsEqual,
          onPressed: () async {
            setState(
              () {
                emailCaptionText = null;
                passwordCaptionText = null;
                confirmPasswordCaptionText = null;
                _isSigningIn = true;
                emailToVerify = null;
              },
            );
            try {
              await AuthService.firebase().registerEmail(
                credentials: {
                  'email': _emailController.text.trim(),
                  'password': _passwordController.text.trim(),
                },
              );
              setState(
                () {
                  emailToVerify = _emailController.text;
                  _resetFields();
                },
              );
            } on EmailAlreadyInUseAuthException {
              setState(
                () {
                  emailCaptionText = 'Este email ya se encuentra registrado';
                },
              );
            } on WeakPasswordAuthException {
              setState(
                () {
                  passwordCaptionText = 'Contraseña debil';
                },
              );
            } on InvalidEmailAuthException {
              setState(
                () {
                  emailCaptionText = 'Email no valido';
                },
              );
            } on GenericAuthException {
              setState(
                () {
                  confirmPasswordCaptionText = 'Algo salio mal, intentalo de nuevo mas tarde';
                },
              );
            }
            setState(
              () {
                _isSigningIn = false;
              },
            );
          },
        ),
        emailToVerify == null
            ? const SizedBox()
            : VerifyEmail(
                email: _emailController.text,
              ),
      ],
    );
  }
}

class VerifyEmail extends StatefulWidget {
  final String email;
  final bool isLoginVariant;

  const VerifyEmail({
    super.key,
    required this.email,
    this.isLoginVariant = false,
  });

  @override
  State<VerifyEmail> createState() => _VerifyEmail();
}

class _VerifyEmail extends State<VerifyEmail> {
  bool _isSendingCode = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LivitSpaces.m,
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            minHeight: 54,
          ),
          decoration: LivitBarStyle.strongShadowDecoration,
          padding: LivitContainerStyle.padding(null),
          child: Center(
            child: Row(
              children: [
                Expanded(
                  child: widget.isLoginVariant
                      ? const LivitText(
                          'Termina de confirmar tu cuenta con el email que te hemos enviado.',
                          textAlign: TextAlign.start,
                        )
                      : RichText(
                          text: TextSpan(
                            text: 'Hemos enviado un email a ',
                            style: LivitTextStyle.regularWhiteActiveText,
                            children: <TextSpan>[
                              TextSpan(
                                text: widget.email,
                                style: LivitTextStyle.regularWhiteActiveText,
                              ),
                              TextSpan(
                                text: ' para que termines de confirmar tu cuenta.',
                                style: LivitTextStyle.regularWhiteActiveText,
                              ),
                            ],
                          ),
                        ),
                ),
                Button.main(
                  text: _isSendingCode ? 'Reenviando' : 'Reenviar',
                  isActive: true,
                  onPressed: () async {
                    setState(
                      () {
                        _isSendingCode = true;
                      },
                    );
                    try {
                      await AuthService.firebase().sendEmailVerification();
                    } on EmailAlreadyVerified {
                    } on UserNotLoggedInAuthException {}
                    setState(
                      () {
                        _isSendingCode = false;
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ForgotPassword extends StatefulWidget {
  final String? email;

  const ForgotPassword({
    super.key,
    this.email,
  });

  @override
  State<ForgotPassword> createState() => _ForgotPassword();
}

class _ForgotPassword extends State<ForgotPassword> {
  late TextEditingController _emailController;

  bool _isSendingEmail = false;
  bool _isEmailSent = false;

  bool _isEmailValid = false;

  String? emailCaptionText;

  void _onEmailChange(bool isValid) {
    setState(
      () {
        _isEmailValid = isValid;
      },
    );
  }

  @override
  void initState() {
    _emailController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      child: Padding(
        padding: LivitContainerStyle.padding(null),
        child: Column(
          children: [
            const LivitText(
              '¿Olvidaste tu contraseña?',
              textType: TextType.smallTitle,
            ),
            LivitSpaces.s,
            const LivitText(
              'Digita tu correo y te enviaremos un mensaje para que reestablezcas tu contraseña.',
            ),
            LivitSpaces.m,
            Row(
              children: [
                Expanded(
                  child: LivitTextField(
                    controller: _emailController,
                    hint: 'Email',
                    inputType: TextInputType.emailAddress,
                    regExp: RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'),
                    onChanged: _onEmailChange,
                    bottomCaptionText: emailCaptionText,
                  ),
                ),
                LivitSpaces.m,
                Button.main(
                  text: _isSendingEmail
                      ? 'Enviando'
                      : _isEmailSent
                          ? 'Enviado'
                          : 'Enviar',
                  isActive: _isEmailValid,
                  onPressed: () async {
                    setState(
                      () {
                        _isSendingEmail = true;
                      },
                    );
                    try {
                      await AuthService.firebase().sendPasswordReset(_emailController.text.trim());
                      _isEmailSent = true;
                      emailCaptionText = '¡Listo!, revisa tu correo.';
                    } on NetworkRequesFailed {
                      emailCaptionText = 'Error de conexión';
                      _isEmailSent = false;
                    } on GenericAuthException {
                      emailCaptionText = 'Algo salio mal, intenta mas tarde';
                      _isEmailSent = false;
                    }
                    setState(
                      () {
                        _isSendingEmail = false;
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
