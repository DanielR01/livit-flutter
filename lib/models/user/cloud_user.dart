import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:livit/constants/enums.dart';

part 'cloud_promoter/cloud_promoter.dart';
part 'cloud_customer/cloud_customer.dart';
part 'cloud_scanner/cloud_scanner.dart';

abstract class CloudUser {
  final String id;
  final Timestamp createdAt;
  final UserType userType;

  CloudUser({
    required this.id,
    required this.createdAt,
    required this.userType,
  });

  Map<String, dynamic> toMap();

  CloudUser copyWith();
}


