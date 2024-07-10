import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PaymentGatewayView extends StatefulWidget {
  const PaymentGatewayView({super.key});

  @override
  State<PaymentGatewayView> createState() => _PaymentGatewayViewState();
}

class _PaymentGatewayViewState extends State<PaymentGatewayView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Payment Gateway",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
        )
      ],
    );
  }
}
