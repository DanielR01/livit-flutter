import 'package:livit/utilities/debug/livit_debugger.dart';

final _debugger = LivitDebugger('livit_price', isDebugEnabled: false);

class LivitPrice {
  final double? amount;
  final String? currency;

  LivitPrice({required this.amount, required this.currency});

  factory LivitPrice.empty({double? amount, String? currency}) {
    return LivitPrice(amount: amount, currency: currency);
  }

  factory LivitPrice.fromMap(Map<String, dynamic> map) {
    _debugger.debPrint('fromMap: $map', DebugMessageType.reading);
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
    final hasDecimal = amount != null && amount! % 1 != 0;
    final parts = amount.toString().split('.');
    final wholePart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
    return hasDecimal ? '$wholePart,${parts[1]}' : wholePart;
  }

  @override
  String toString() {
    return 'LivitPrice(amount: $amount, currency: $currency)';
  }
}
