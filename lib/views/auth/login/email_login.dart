import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/enums.dart';
import 'package:livit/services/auth/auth_exceptions.dart';
import 'package:livit/services/auth/bloc/auth_bloc.dart';
import 'package:livit/services/auth/bloc/auth_event.dart';
import 'package:livit/services/auth/bloc/auth_state.dart';
import 'package:livit/utilities/bars_containers_fields/glass_container.dart';
import 'package:livit/utilities/bars_containers_fields/livit_text_field.dart';
import 'package:livit/utilities/bars_containers_fields/title_bar.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/utilities/buttons/question_mark_button.dart';
import 'package:livit/utilities/dialogs/generic_dialog.dart';

class EmailLoginView extends StatefulWidget {
  final UserType userType;
  const EmailLoginView({
    super.key,
    required this.userType,
  });

  @override
  State<EmailLoginView> createState() => _EmailLogin();
}

class _EmailLogin extends State<EmailLoginView> {
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
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  MediaQuery.of(context).viewInsets.bottom,
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
                        child: Column(
                          children: [
                            const TitleBar(
                              title: 'Continua con email y contraseña',
                              isBackEnabled: true,
                            ),
                            Padding(
                              padding: LivitContainerStyle.padding(padding: [0, null, null, null]),
                              child: Column(
                                children: [
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
                                                color: _currentView == EmailLoginViews.login ? LivitColors.whiteActive : Colors.transparent,
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
                                                color:
                                                    _currentView == EmailLoginViews.register ? LivitColors.whiteActive : Colors.transparent,
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
                          ],
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

  void _onPasswordClear() {
    setState(
      () {
        _isPasswordValid = false;
      },
    );
  }

  void _onEmailClear() {
    setState(
      () {
        _isEmailValid = false;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthStateLoggedIn) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            Routes.getOrCreateUserRoute,
            (_) => false,
            arguments: {
              'userType': state.userType,
            },
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthStateLoggedOut) {
            if (state.loginMethod == LoginMethod.emailAndPassword) {
              passwordCaptionText = null;
              emailCaptionText = null;
              _isSigningIn = true;
              emailToVerify = null;
            } else {
              if (_isSigningIn) {
                _passwordController.clear();
                _isPasswordValid = false;
              }
              _isSigningIn = false;
              if (state.exception != null) {
                switch (state.exception.runtimeType) {
                  case const (NetworkRequesFailed):
                    passwordCaptionText = 'Error de red';
                    break;
                  case const (InvalidCredentialsAuthException):
                    passwordCaptionText = 'Email no registrado o contraseña incorrecta';
                    break;
                  case const (GenericAuthException):
                    passwordCaptionText = 'Algo salio mal, intentalo de nuevo mas tarde';
                    break;
                  case const (TooManyRequestsAuthException):
                    passwordCaptionText = 'Demasiados intentos, espera unos minutos';
                    break;
                  case const (NotVerifiedEmailAuthException):
                    emailToVerify = _emailController.text;
                    context.read<AuthBloc>().add(
                          AuthEventSendEmailVerification(email: _emailController.text),
                        );
                    break;
                  case const (UserNotLoggedInAuthException):
                    break;
                  default:
                    passwordCaptionText = 'Error: ${state.exception.toString()}';
                }
              }
            }
          }
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
                onClear: _onEmailClear,
              ),
              LivitSpaces.m,
              LivitTextField(
                controller: _passwordController,
                hint: 'Contraseña',
                isPasswordField: true,
                onChanged: _onPasswordChange,
                regExp: RegExp(r'^.{6,}$'),
                bottomCaptionText: passwordCaptionText,
                onClear: _onPasswordClear,
              ),
              LivitSpaces.m,
              Button.main(
                text: _isSigningIn ? 'Iniciando sesión' : 'Iniciar sesión',
                isActive: _isEmailValid & _isPasswordValid,
                isLoading: _isSigningIn,
                onPressed: () {
                  context.read<AuthBloc>().add(
                        AuthEventLogInWithEmailAndPassword(
                          email: _emailController.text,
                          password: _passwordController.text,
                          userType: widget.userType,
                        ),
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
        },
      ),
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

  bool _isRegistering = false;
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
    _passwordController.clear();
    _confirmPasswordController.clear();
    _arePasswordsEqual = false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthStateRegisterError) {
          _isRegistering = false;
          switch (state.exception.runtimeType) {
            case const (NetworkRequesFailed):
              confirmPasswordCaptionText = 'Error de red';
              break;
            case const (EmailAlreadyInUseAuthException):
              emailCaptionText = 'Este email ya se encuentra registrado';
              break;
            case const (WeakPasswordAuthException):
              passwordCaptionText = 'Contraseña debil';
              break;
            case const (InvalidEmailAuthException):
              emailCaptionText = 'Email no valido';
              break;
            case const (GenericAuthException):
              confirmPasswordCaptionText = 'Algo salio mal, intentalo de nuevo mas tarde';
              break;
          }
        } else if (state is AuthStateRegistering) {
          _isRegistering = true;
        } else if (state is AuthStateRegistered) {
          _isRegistering = false;
          emailToVerify = _emailController.text;
          _resetFields();
        }
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
            if (_emailController.text.isNotEmpty && !_isEmailValid) ...[
              const LivitText(
                'Ingresa un email válido',
                color: LivitColors.whiteActive,
              ),
              LivitSpaces.m,
            ],
            LivitTextField(
              controller: _passwordController,
              hint: 'Contraseña',
              isPasswordField: true,
              onChanged: _onPasswordChange,
              regExp: RegExp(r'^.{6,}$'),
              bottomCaptionText: passwordCaptionText,
            ),
            LivitSpaces.m,
            if (_passwordController.text.isNotEmpty && !_isPasswordValid) ...[
              const LivitText(
                'Tu contraseña debe tener al menos 8 caracteres',
                color: LivitColors.whiteActive,
              ),
              LivitSpaces.m,
            ],
            LivitTextField(
              controller: _confirmPasswordController,
              hint: 'Verifica tu contraseña',
              isPasswordField: true,
              onChanged: _onConfirmPasswordChange,
              externalIsValid: _arePasswordsEqual,
              bottomCaptionText: confirmPasswordCaptionText,
            ),
            LivitSpaces.m,
            if (_confirmPasswordController.text.isNotEmpty && !_arePasswordsEqual) ...[
              const LivitText(
                'Las contraseñas deben coincidir',
                color: LivitColors.whiteActive,
              ),
              LivitSpaces.m,
            ],
            Button.main(
              text: _isRegistering ? 'Creando cuenta' : 'Crear cuenta',
              isActive: _isEmailValid & _isPasswordValid & _arePasswordsEqual,
              isLoading: _isRegistering,
              onPressed: () async {
                setState(
                  () {
                    emailCaptionText = null;
                    passwordCaptionText = null;
                    confirmPasswordCaptionText = null;
                    emailToVerify = null;
                  },
                );

                context.read<AuthBloc>().add(
                      AuthEventRegister(
                        email: _emailController.text,
                        password: _passwordController.text,
                      ),
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
      },
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
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthStateEmailVerificationSending) {
          _isSendingCode = true;
        } else if (state is AuthStateEmailVerificationSent) {
          _isSendingCode = false;
        } else if (state is AuthStateEmailVerificationSentError) {
          _isSendingCode = false;
        }
        return Column(
          children: [
            LivitSpaces.m,
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(
                minHeight: 54,
              ),
              decoration: LivitBarStyle.strongShadowDecoration,
              padding: LivitContainerStyle.padding(),
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
                      text: _isSendingCode ? 'Enviando' : 'Reenviar',
                      isActive: true,
                      isLoading: _isSendingCode,
                      onPressed: () async {
                        context.read<AuthBloc>().add(
                              AuthEventSendEmailVerification(email: widget.email),
                            );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
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

  Widget emailCaptionWidget = LivitSpaces.m;

  void _onEmailChange(bool isValid) {
    setState(
      () {
        _isEmailValid = isValid;
      },
    );
  }

  void _showInfoDialog() {
    showGenericDialog<void>(
      context: context,
      title: '¿No recibiste el correo de restablecimiento?',
      content: 'Si no recibes el correo, por favor verifica lo siguiente:\n\n'
          '- Revisa tu carpeta de spam o correo no deseado.\n\n'
          '- Asegúrate de que la dirección de correo sea correcta y que este registrada en LIVIT.\n\n'
          '- Espera unos minutos, a veces puede tardar en llegar.\n\n'
          '- Si aún no lo recibes, intenta enviar la solicitud nuevamente.',
      contentAlign: TextAlign.left,
      optionBuilder: () => {
        'Volver': {
          'return': null,
          'buttonType': ButtonType.main,
        },
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
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthStateSendingPasswordReset) {
          emailCaptionWidget = LivitSpaces.m;
          _isSendingEmail = true;
        } else if (state is AuthStatePasswordResetSent) {
          _isSendingEmail = false;
          _isEmailSent = true;
          emailCaptionWidget = Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: LivitText(
                  '¡Listo!, ¿no te ha llegado?',
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                width: 32.sp, // Adjust this value as needed
                height: 24.sp, // Adjust this value as needed
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: -LivitContainerStyle.horizontalPadding,
                      right: 0,
                      child: QuestionMarkButton(
                        onPressed: _showInfoDialog,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        } else if (state is AuthStatePasswordResetSentError) {
          _isSendingEmail = false;
          _isEmailSent = false;
          if (state.exception.runtimeType == NetworkRequesFailed) {
            emailCaptionWidget = Column(
              children: [
                LivitSpaces.s,
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    LivitText(
                      'Error de conexión',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                LivitSpaces.m,
              ],
            );
          } else if (state.exception.runtimeType == GenericAuthException) {
            emailCaptionWidget = Column(
              children: [
                LivitSpaces.s,
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    LivitText(
                      'Algo salio mal, intenta mas tarde',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                LivitSpaces.m,
              ],
            );
          }
        }
        return GlassContainer(
          child: Padding(
            padding: LivitContainerStyle.padding(padding: [null, null, 0, null]),
            child: Column(
              children: [
                const LivitText(
                  '¿Olvidaste tu contraseña?',
                  textType: LivitTextType.smallTitle,
                ),
                LivitSpaces.s,
                const LivitText(
                  'Digita tu correo y te enviaremos un mensaje para que reestablezcas tu contraseña.',
                ),
                LivitSpaces.m,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LivitTextField(
                            controller: _emailController,
                            hint: 'Email',
                            inputType: TextInputType.emailAddress,
                            regExp: RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'),
                            onChanged: _onEmailChange,
                          ),
                          emailCaptionWidget,
                        ],
                      ),
                    ),
                    LivitSpaces.m,
                    SizedBox(
                      height: LivitBarStyle.height,
                      child: Center(
                        child: Button.main(
                          text: _isSendingEmail
                              ? 'Enviando'
                              : _isEmailSent
                                  ? 'Enviado'
                                  : 'Enviar',
                          isActive: _isEmailValid,
                          isLoading: _isSendingEmail,
                          onPressed: () async {
                            context.read<AuthBloc>().add(
                                  AuthEventSendPasswordReset(email: _emailController.text),
                                );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
