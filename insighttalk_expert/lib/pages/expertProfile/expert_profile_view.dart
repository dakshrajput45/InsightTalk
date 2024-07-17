import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:insighttalk_backend/apis/userApis/auth_user.dart';
import 'package:insighttalk_expert/router.dart';
import 'dart:math';

class ExpertProfileView extends StatefulWidget {
  const ExpertProfileView({super.key});

  @override
  State<ExpertProfileView> createState() => _ExpertProfileViewState();
}

class _ExpertProfileViewState extends State<ExpertProfileView> {
  final ITUserAuthSDK _itUserAuthSDK = ITUserAuthSDK();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: CustomPaint(
        painter: PolkaDotPainter(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Expert Profile",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () {
                  _itUserAuthSDK.signOut();
                  context.goNamed(routeNames.login);
                },
                child: const Text("Sign Out"))
          ],
        ),
      ),
    );
  }
}

class PolkaDotPainter extends CustomPainter {
  final Random _random = Random();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.shade400
      ..style = PaintingStyle.fill;

    const double minDotRadius = 20.0;
    const double maxDotRadius = 150.0;
    const double minSpacing = 100.0;
    const double maxSpacing = 250.0;

    double y = 0;
    while (y < size.height) {
      double x = 0;
      while (x < size.width) {
        final double dotRadius =
            minDotRadius + _random.nextDouble() * (maxDotRadius - minDotRadius);
        canvas.drawCircle(Offset(x, y), dotRadius, paint);

        // Calculate the next x position
        x += dotRadius * 2 +
            minSpacing +
            _random.nextDouble() * (maxSpacing - minSpacing);
      }

      // Calculate the next y position
      y += minDotRadius * 2 +
          minSpacing +
          _random.nextDouble() * (maxSpacing - minSpacing);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
