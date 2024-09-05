class DsdOrder {
  int? amount;
  String? currency = "INR";
  String? receipt;

  DsdOrder({
    this.amount,
    this.currency,
    this.receipt,
  });

  // Factory constructor to create DsdOrder from JSON
  factory DsdOrder.fromJson({required Map<String, dynamic> json}) {
    try {
      return DsdOrder(
        amount: json['amount'],
        currency: json['currency'] ,
        receipt: json['receipt'],
      );
    } catch (e) {
      print('Error parsing JSON to DsdOrder: $e');
      rethrow;
    }
  }

  // Method to convert DsdOrder to JSON
  Map<String, dynamic> toJson() {
    return {
      if (amount != null) 'amount': amount,
      if (currency != null) 'currency': currency ?? "INR",
      if (receipt != null) 'receipt': receipt ?? 'receipt_12345', // Default receipt
    };
  }
}
