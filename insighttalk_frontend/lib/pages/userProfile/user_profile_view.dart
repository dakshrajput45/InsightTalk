import 'package:flutter/material.dart';
import 'package:insighttalk_backend/api_functions/auth/auth_user.dart';

class UserProfileView extends StatefulWidget {
  const UserProfileView({super.key});

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  final ITUserAuthSDK _itUserAuthSDK = ITUserAuthSDK();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "User Profile",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            _itUserAuthSDK.signOut();
            Navigator.pushNamed(context, '/login');
            // const ProfileScreen();
          },
          child: const Text("Log Out"),
        ),
      ],
    );
  }
}
