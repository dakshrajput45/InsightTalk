import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ExpertsView extends StatefulWidget {
  const ExpertsView({super.key});

  @override
  State<ExpertsView> createState() => _ExpertsViewState();
}

class _ExpertsViewState extends State<ExpertsView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Expert",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
        )
      ],
    );
  }
}
