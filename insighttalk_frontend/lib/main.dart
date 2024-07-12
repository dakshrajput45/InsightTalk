import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:insighttalk_frontend/theme.dart';
import 'firebase_options.dart';
import 'package:insighttalk_frontend/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Insight Talk User App',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      routerConfig: routerConfig.getRouter(),
    );
  }
}
