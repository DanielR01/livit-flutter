// import 'package:flutter/material.dart';
// import 'package:livit/constants/user_types.dart';
// import 'package:livit/utilities/login/email_login.dart';
// import 'package:livit/utilities/login/login_methods_list.dart';
// import 'package:livit/utilities/login/phone_login.dart';

// enum View {
//   loginMethods,
//   emailLogin,
//   phoneLogin,
// }

// class LoginView extends StatefulWidget {
//   const LoginView({
//     super.key,
//   });

//   @override
//   State<LoginView> createState() => _LoginViewState();
// }

// class _LoginViewState extends State<LoginView> {
//   UserType _userType = UserType.customer;
//   View _view = View.loginMethods;

//   String phoneCode = '';
//   String phoneNumber = '';
//   String verificationId = '';

//   void _onChangeUserType() {
//     setState(
//       () {
//         _userType = _userType == UserType.customer ? UserType.promoter : UserType.customer;
//       },
//     );
//   }

//   void _onEmailLoginPressed() {
//     setState(
//       () {
//         _view = View.emailLogin;
//       },
//     );
//   }

//   void _onBackPressed() {
//     setState(
//       () {
//         _view = View.loginMethods;
//       },
//     );
//   }

//   void _onPhoneLoginPressed() {
//     setState(
//       () {
//         _view = View.phoneLogin;
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     switch (_view) {
//       case View.loginMethods:
//         return LoginMethodsList(
//           onBackPressed: _onChangeUserType,
//           onEmailLoginPressed: _onEmailLoginPressed,
//           onPhoneLoginPressed: _onPhoneLoginPressed,
//           onChangeUserType: _onChangeUserType,
//           userType: _userType,
//         );

//       case View.emailLogin:
//         return EmailLogin(
//           userType: _userType,
//           onBackPressed: _onBackPressed,
//         );
//       case View.phoneLogin:
//         return PhoneLogin(
//           userType: _userType,
//           onBackPressed: _onBackPressed,
//         );
//     }
//   }
// }
