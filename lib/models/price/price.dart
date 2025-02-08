import 'package:flutter/cupertino.dart';

class LivitPrice {
  final double amount;
  final String currency;

  LivitPrice({required this.amount, required this.currency});

  factory LivitPrice.fromMap(Map<String, dynamic> map) {
    debugPrint('🛠️ [LivitPrice] fromMap: $map');
    final double amount = (map['amount'] is double) ? map['amount'] : map['amount'].toDouble();
    return LivitPrice(
      amount: amount,
      currency: map['currency'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'currency': currency,
    };
  }
}