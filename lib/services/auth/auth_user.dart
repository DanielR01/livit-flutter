import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';

@immutable
class AuthUser {
  final bool isEmailVerified;
  final bool hasPhoneNumber;

  const AuthUser(
    this.isEmailVerified,
    this.hasPhoneNumber,
  );

  factory AuthUser.fromFirebase(User user) => AuthUser(
        user.emailVerified,
        user.phoneNumber != null,
      );
}
