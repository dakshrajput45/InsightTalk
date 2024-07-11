import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ExpertProfileView extends StatefulWidget {
  const ExpertProfileView({super.key});

  @override
  State<ExpertProfileView> createState() => _ExpertProfileViewState();
}

class _ExpertProfileViewState extends State<ExpertProfileView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Expert Profile",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
        )
      ],
    );
  }
}
