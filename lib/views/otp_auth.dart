import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/utilities/buttons/main_action_button.dart';
import 'package:livit/utilities/error_dialogs/show_error_dialog_2t_1b.dart';
import 'package:pinput/pinput.dart';

class OtpAuthView extends StatefulWidget {
  final String verificationId;

  const OtpAuthView({
    super.key,
    required this.verificationId,
  });

  @override
  State<OtpAuthView> createState() => _OtpAuthViewState();
}

class _OtpAuthViewState extends State<OtpAuthView> {
  String? otpCode;
  bool valid = false;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

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
                  'Enter the code',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: LivitColors.whiteActive,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Enter the 6-digit SMS code that you will receive',
                  style: TextStyle(
                    fontSize: 14,
                    color: LivitColors.whiteActive,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 40,
                ),
                Pinput(
                  length: 6,
                  closeKeyboardWhenCompleted: false,
                  defaultPinTheme: PinTheme(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: LivitColors.inactiveGray),
                    ),
                    textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: LivitColors.whiteActive),
                  ),
                  onChanged: (value) {
                    setState(() {
                      otpCode = value;
                      if (otpCode?.length != 6 ||
                          !RegExp(r'^[0-9]+$').hasMatch(otpCode ?? '')) {
                        valid = false;
                      } else {
                        valid = true;
                      }
                    });
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                MainActionButton(
                  isActive: valid,
                  text: 'Next',
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    PhoneAuthCredential credential =
                        PhoneAuthProvider.credential(
                      verificationId: widget.verificationId,
                      smsCode: otpCode ?? '',
                    );
                    try {
                      await FirebaseAuth.instance
                          .signInWithCredential(credential);
                      User? userCredential = FirebaseAuth.instance.currentUser;
                      if (userCredential != null) {
                        if (context.mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              Routes.mainviewRoute, (route) => false);
                        }
                      }
                    } on FirebaseAuthException catch (error) {
                      switch (error.code) {
                        case 'invalid-verification-code':
                          showErrorDialog(scaffoldKey, 'Invalid code',
                              'Check if the phone and code entered are correct');
                          break;
                        default:
                          showErrorDialog(
                            scaffoldKey,
                            'Something went wrong',
                            'Error code: ${error.code}, Try again in a few minutes',
                          );
                          break;
                      }
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
