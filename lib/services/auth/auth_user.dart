import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';

@immutable
class AuthUser {
  final String id;
  final String? email;
  final String? phoneNumber;
  final bool isEmailVerified;

  const AuthUser({
    required this.id,
    required this.email,
    required this.isEmailVerified,
    this.phoneNumber,
  });

  factory AuthUser.fromFirebase(User user) {
    return AuthUser(
      id: user.uid,
      email: user.email,
      isEmailVerified: user.emailVerified,
      phoneNumber: user.phoneNumber,
    );
  }
}


