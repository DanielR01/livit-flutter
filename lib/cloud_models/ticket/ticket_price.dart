class TicketPrice {
  final double amount;
  final String currency;

  TicketPrice({required this.amount, required this.currency});

  factory TicketPrice.fromMap(Map<String, dynamic> map) {
    return TicketPrice(
      amount: map['amount'],
      currency: map['currency'],
    );
  }
}
