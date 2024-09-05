class DsdCheckout {
  String apiKey; // API Key ID (mandatory)
  int amount; // Amount in smallest currency sub-unit (mandatory)
  String currency = "INR"; // Currency (mandatory)
  String name; // Business/Enterprise name (mandatory)
  String description; // Description of the purchase item (mandatory)
  String orderId; // Order ID generated via Orders API (mandatory)
  bool send_sms_hash = true;

  DsdCheckout({
    required this.apiKey,
    required this.amount,
    required this.currency,
    required this.name,
    required this.orderId,
    required this.description,
  });

  // Factory constructor to create DsdCheckout from JSON
  factory DsdCheckout.fromJson({required Map<String, dynamic> json}) {
    try {
      return DsdCheckout(
        apiKey: json['apiKey'],
        amount: json['amount'],
        currency: json['currency'],
        name: json['name'],
        orderId: json['order_id'],
        description: json['description'],
      );
    } catch (e) {
      print('Error parsing JSON to DsdCheckout: $e');
      rethrow;
    }
  }

  // Method to convert DsdCheckout to JSON
  Map<String, dynamic> toJson() {
    return {
      'apiKey': apiKey,
      'amount': amount,
      'currency': currency,
      'name': name,
      'order_id': orderId,
      'description': description,
      'send_sms_hash': true,
    };
  }
}
