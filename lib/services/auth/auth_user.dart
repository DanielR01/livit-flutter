import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:livit/constants/enums.dart';

@immutable
class AuthUser {
  final String id;
  final String? email;
  final String? phoneNumber;
  final bool isEmailVerified;
  final UserType? userType;

  const AuthUser({
    required this.id,
    required this.email,
    required this.isEmailVerified,
    this.phoneNumber,
    required this.userType,
  });

  factory AuthUser.fromFirebase(User user, UserType? userType) {    
    return AuthUser(
      id: user.uid,
      email: user.email,
      isEmailVerified: user.emailVerified,
      phoneNumber: user.phoneNumber,
      userType: userType,
    );
  }

  @override
  String toString() {
    return 'AuthUser(id: $id, email: $email, phoneNumber: $phoneNumber, isEmailVerified: $isEmailVerified, userType: $userType)';
  }
}


