import 'dart:async';
import 'dart:convert';
import 'package:insighttalk_backend/modal/modal_checkout.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../modal/modal_order.dart';

class PaymentService {
  final Razorpay _razorpay = Razorpay();

  PaymentService() {
    _initializeService();
  }

  Future<void> _initializeService() async {
    await dotenv.load(fileName: ".env");
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    // _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Do something when payment succeeds
    print('Payment Successful: ${response.paymentId}');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
    print('Payment Failed: ${response.code} - ${response.message}');
  }

  // void _handleExternalWallet(ExternalWalletResponse response) {
  //   // Do something when an external wallet is selected
  //   print('External Wallet Selected: ${response.walletName}');
  // }

  Future<Map<String, dynamic>?> createOrder({required DsdOrder order}) async {
    final String basicAuth = "Basic" +
        base64Encode(
            utf8.encode('${dotenv.env['RAZORPAY_KEY_ID']}:${dotenv.env['RAZORPAY_SECRET']}'));

    final String _url = dotenv.env['URL'].toString();

    // Request body for creating an order

    final Map<String, dynamic> data = {
      "amount": order
          .amount, // Amount in the smallest currency unit (e.g., paise for INR, so 1000 paise = 10 INR)
      "currency": order.currency, // Currency like "INR"
      "receipt": order.receipt ?? "receipt_12345",
      "payment_capture": 1 // Auto-capture payment (1 for auto, 0 for manual)
    };

    try {
      // Sending POST request to Razorpay API to create the order
      final response = await http.post(
        Uri.parse(_url),
        headers: {
          'Authorization': basicAuth,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      // Check if the request was successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse the response body into a Map
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        print('Order created successfully: $responseBody');
        return responseBody; // Return the order details
      } else {
        // Handle failure
        print('Failed to create order: ${response.body}');
        return null;
      }
    } catch (e) {
      // Handle error
      print('Error creating Razorpay order: $e');
      return null;
    }
  }

  DsdCheckout? createCheckout(
      {required int amount, required String description, required String orderId}) {
    try {
      return DsdCheckout(
        apiKey: dotenv.env['RAZORPAY_KEY_ID'].toString(),
        amount: amount,
        currency: "INR",
        name: "Insight Talk Appointment payment",
        orderId: orderId,
        description: description,
        
      );
    } catch (err) {
      print('Error creating checkout: $err');
      return null;
    }
  }

  void open_checkout(DsdCheckout options){
    _razorpay.open(options.toJson());
  }

  void dispose() {
    _razorpay.clear(); // It's important to clear listeners when done
  }
}
