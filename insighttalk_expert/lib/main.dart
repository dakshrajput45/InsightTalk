import 'package:flutter/material.dart';
import 'package:insighttalk_expert/router.dart';
import 'package:insighttalk_expert/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Insight Talk Expert App',
      debugShowCheckedModeBanner: false,
      theme:appTheme,
      routerConfig: routerConfig.getRouter(),
    );
  }
}
