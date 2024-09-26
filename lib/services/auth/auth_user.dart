import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';

@immutable
class AuthUser {
  final String id;
  final String? email;
  final bool isEmailVerified;
  final String? phoneNumber;

  const AuthUser({
    required this.id,
    this.email,
    this.phoneNumber,
    required this.isEmailVerified,
  });

  factory AuthUser.fromFirebase(User user) => AuthUser(
        id: user.uid,
        email: user.email,
        phoneNumber: user.phoneNumber,
        isEmailVerified: user.emailVerified,
      );

  @override
  String toString() {
    return 'User -> id: $id, email: $email, isEmailVerified: $isEmailVerified, phoneNumber: $phoneNumber';
  }
}
