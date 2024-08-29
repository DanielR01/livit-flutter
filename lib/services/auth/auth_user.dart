import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';

@immutable
class AuthUser {
  final String id;
  final String? email;
  final String? phoneNumber;

  const AuthUser(
    this.id,
    this.email,
    this.phoneNumber,
  );

  factory AuthUser.fromFirebase(User user) =>
      AuthUser(user.uid, user.email, user.phoneNumber);

}
