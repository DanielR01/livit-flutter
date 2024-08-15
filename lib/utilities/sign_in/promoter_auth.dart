import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/constants/styles/text_style.dart';
import 'package:livit/services/auth/auth_exceptions.dart';
import 'package:livit/services/auth/auth_service.dart';
import 'package:livit/services/auth/auth_user.dart';
import 'package:livit/services/auth/credential_types.dart';
import 'package:livit/services/crud/livit_db_service.dart';
import 'package:livit/utilities/bars_containers_fields/glass_container.dart';
import 'package:livit/utilities/bars_containers_fields/text_field.dart';
import 'package:livit/utilities/buttons/action_button.dart';
import 'package:livit/utilities/buttons/arrow_back_button.dart';

class PromoterAuth extends StatefulWidget {
  final VoidCallback onBack;
  const PromoterAuth({
    super.key,
    required this.onBack,
  });

  get phoneCode => null;

  get phoneNumber => null;

  @override
  State<PromoterAuth> createState() => _PromoterAuthState();
}

class _PromoterAuthState extends State<PromoterAuth> {
  PromoterViews _currentView = PromoterViews.login;

  void _onRegisterPressed() {
    setState(
      () {
        _currentView = PromoterViews.register;
      },
    );
  }

  void _onLoginPressed() {
    setState(
      () {
        _currentView = PromoterViews.login;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          child: GlassContainer(
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: LivitContainerStyle.padding([0, null, null, null]),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: LivitBarStyle.height,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            left: 0,
                            child: ArrowBackButton(
                              onPressed: widget.onBack,
                            ),
                          ),
                          const LivitText(
                            'Promocionador',
                            textType: TextType.normalTitle,
                          ),
                        ],
                      ),
                    ),
                    const LivitText(
                      'En LIVIT podras promocionar tus eventos y negocio, permitiendo que muchos mas clientes te encuentren y tengan una gran experiencia de compra.',
                    ),
                    LivitSpaces.medium16spacer,
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _onLoginPressed,
                            child: Container(
                              padding: const EdgeInsets.only(bottom: 8),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                  color: _currentView == PromoterViews.login
                                      ? LivitColors.whiteActive
                                      : Colors.transparent,
                                )),
                              ),
                              child: Center(
                                child: LivitText(
                                  'Iniciar sesión',
                                  color: _currentView == PromoterViews.login
                                      ? LivitColors.whiteActive
                                      : LivitColors.whiteInactive,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: _onRegisterPressed,
                            child: Container(
                              padding: const EdgeInsets.only(bottom: 8),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                  color: _currentView == PromoterViews.register
                                      ? LivitColors.whiteActive
                                      : Colors.transparent,
                                )),
                              ),
                              child: Center(
                                child: LivitText(
                                  'Crear cuenta',
                                  color: _currentView == PromoterViews.register
                                      ? LivitColors.whiteActive
                                      : LivitColors.whiteInactive,
                                ),
                              ),
                            ),
                          ),
                        ),
                        LivitSpaces.medium16spacer,
                      ],
                    ),
                    LivitSpaces.mediumPlus24spacer,
                    Redirector(
                      view: _currentView,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        _currentView == PromoterViews.login
            ? Column(
                children: [
                  LivitSpaces.medium16spacer,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ForgotPassword(),
                  ),
                ],
              )
            : SizedBox(
                height: 0,
              ),
      ],
    );
  }
}

enum PromoterViews {
  login,
  register,
}

class Redirector extends StatelessWidget {
  final PromoterViews view;

  const Redirector({
    super.key,
    required this.view,
  });

  @override
  Widget build(BuildContext context) {
    switch (view) {
      case PromoterViews.login:
        return const SignIn();
      case PromoterViews.register:
        return const Register();
    }
  }
}

class SignIn extends StatefulWidget {
  const SignIn({
    super.key,
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

  bool _resetPassword = false;

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
          bottomCaptionStyle: LivitTextStyle.regularBlackBoldText,
        ),
        LivitSpaces.medium16spacer,
        LivitTextField(
          controller: _passwordController,
          hint: 'Contraseña',
          blurInput: true,
          onChanged: _onPasswordChange,
          regExp: RegExp(r'^.{6,}$'),
          bottomCaptionText: passwordCaptionText,
          bottomCaptionStyle: LivitTextStyle.regularBlackBoldText,
        ),
        LivitSpaces.medium16spacer,
        MainActionButton(
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
              final AuthUser user = await AuthService.firebase().logIn(
                credentialType: CredentialType.emailAndPassword,
                credentials: [
                  _emailController.text,
                  _passwordController.text,
                ],
              );
              if (user.id == null) {
                emailToVerify = user.email;
                AuthService.firebase().sendEmailVerification();
              } else {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    Routes.getOrCreateUserRoute,
                    arguments: UserType.promoter,
                    (route) => false);
              }
            } on InvalidCredentialsAuthException {
              passwordCaptionText = 'Email o contraseña incorrectos';
              setState(
                () {
                  _resetPassword = true;
                },
              );
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
        if (_passwordController.text == _confirmPasswordController.text) {
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
        if (_passwordController.text == _confirmPasswordController.text) {
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
          bottomCaptionStyle: LivitTextStyle.regularWhiteActiveBoldText,
        ),
        LivitSpaces.medium16spacer,
        LivitTextField(
          controller: _passwordController,
          hint: 'Contraseña',
          blurInput: true,
          onChanged: _onPasswordChange,
          regExp: RegExp(r'^.{6,}$'),
          bottomCaptionText: passwordCaptionText,
          bottomCaptionStyle: LivitTextStyle.regularBlackBoldText,
        ),
        LivitSpaces.medium16spacer,
        LivitTextField(
          controller: _confirmPasswordController,
          hint: 'Verifica tu contraseña',
          blurInput: true,
          onChanged: _onConfirmPasswordChange,
          externalIsValid: _arePasswordsEqual,
          bottomCaptionText: confirmPasswordCaptionText,
          bottomCaptionStyle: LivitTextStyle.regularBlackBoldText,
        ),
        LivitSpaces.medium16spacer,
        MainActionButton(
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
              final AuthUser user = await AuthService.firebase().createUser(
                credentialType: CredentialType.emailAndPassword,
                credentials: [
                  _emailController.text,
                  _passwordController.text,
                ],
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
                  confirmPasswordCaptionText =
                      'Error, intentalo de nuevo mas tarde';
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
            ? SizedBox()
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
        LivitSpaces.medium16spacer,
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
                                text:
                                    ' para que termines de confirmar tu cuenta.',
                                style: LivitTextStyle.regularWhiteActiveText,
                              ),
                            ],
                          ),
                        ),
                ),
                MainActionButton(
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
                    } catch (e) {}
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
            LivitSpaces.small8spacer,
            const LivitText(
              'Digita tu correo y te enviaremos un mensaje para que reestablezcas tu contraseña.',
            ),
            LivitSpaces.medium16spacer,
            Row(
              children: [
                Expanded(
                  child: LivitTextField(
                    controller: _emailController,
                    hint: 'Email',
                    inputType: TextInputType.emailAddress,
                    regExp: RegExp(
                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'),
                    onChanged: _onEmailChange,
                    bottomCaptionText: emailCaptionText,
                  ),
                ),
                LivitSpaces.medium16spacer,
                MainActionButton(
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
                      await AuthService.firebase()
                          .sendPasswordReset(_emailController.text.trim());
                      _isEmailSent = true;
                      emailCaptionText = '¡Listo!, revisa tu correo.';
                    } on FirebaseAuthException catch (e) {
                      switch (e.code) {
                        case 'network-request-failed':
                          emailCaptionText = 'Error de conexión';
                          break;
                        default:
                      }
                    } catch (e) {
                      _isEmailSent = false;
                      emailCaptionText = 'Error, intenta mas tarde';
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
