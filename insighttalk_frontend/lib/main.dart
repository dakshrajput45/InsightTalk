import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:insighttalk_backend/services/notification_services.dart';
import 'package:insighttalk_frontend/themes/theme.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'firebase_options.dart';
import 'package:insighttalk_frontend/router.dart';

DsdNotificationService? dsdNotificationService;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
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
    return SafeArea(
      child: ResponsiveSizer(
        builder: (context, orientation, screenType) {
          return MaterialApp.router(
            title: 'Insight Talk User App',
            debugShowCheckedModeBanner: false,
            theme: appTheme,
            routerConfig: routerConfig.getRouter(),
          );
        },
      ),
    );
  }
}
