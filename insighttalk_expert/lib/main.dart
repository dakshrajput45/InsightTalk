import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:insighttalk_backend/services/notification_services.dart';
import 'package:insighttalk_expert/firebase_options.dart';
import 'package:insighttalk_expert/router.dart';
import 'package:insighttalk_expert/themes/theme.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

DsdNotificationService? dsdNotificationService;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(     
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: ResponsiveSizer(builder: (context, orientation, screenType) {
      return MaterialApp.router(
        title: 'Insight Talk Expert App',
        debugShowCheckedModeBanner: false,
        theme: appTheme,
        routerConfig: routerConfig.getRouter(),
      );
    }));
  }
}
