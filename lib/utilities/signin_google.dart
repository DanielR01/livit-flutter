import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/utilities/show_error_dialog_2t_1b.dart';

void signInWithGoogle(BuildContext context, GlobalKey contextKey) async {
  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;
    if (googleUser == null) {
      return null;
    }

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);

    if (context.mounted) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(feedRoute, (route) => false);
    }
  } on FirebaseAuthException catch (error) {
    showErrorDialog(
      contextKey,
      'Something went wrong',
      error.toString(),
    );
  }
}
