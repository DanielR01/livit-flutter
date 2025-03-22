import 'package:flutter/cupertino.dart';

class LivitPrice {
  final double amount;
  final String currency;

  LivitPrice({required this.amount, required this.currency});

  factory LivitPrice.empty() {
    return LivitPrice(amount: 0, currency: '');
  }

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

    String formatPrice() {
    final hasDecimal = amount % 1 != 0;
    final parts = amount.toString().split('.');
    final wholePart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
    return hasDecimal ? '$wholePart,${parts[1]}' : wholePart;
  }
}