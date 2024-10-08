import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:insighttalk_backend/apis/userApis/auth_user.dart';
import 'package:insighttalk_backend/services/notification_services.dart';
import 'package:insighttalk_backend/apis/availablity/availablity_sdk.dart';
import 'package:insighttalk_expert/main.dart';
import 'package:insighttalk_expert/router.dart';

class HomeView extends StatefulWidget {
  const HomeView({
    super.key,
    required this.title,
    required this.navigationShell,
  });

  final String title;
  final StatefulNavigationShell navigationShell;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;
  final ITUserAuthSDK _itUserAuthSDK = ITUserAuthSDK();
  final DsdAvailablitySDK _dsdAvailablitySDK = DsdAvailablitySDK();

  @override
  void initState() {
    String? id = _itUserAuthSDK.getUser()?.uid;
    if (id != null) {
      _dsdAvailablitySDK.removeOldAvailability(id);
      dsdNotificationService = DsdNotificationService(
        uid: id,
        context: context,
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Insight Talk Experts',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: widget.navigationShell, // Display the current page
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (page) {
          setState(() {
            _selectedIndex = page;
            switch (page) {
              case 0:
                context.goNamed(routeNames.appointment);
                break;
              case 1:
                context.goNamed(routeNames.chatRooms);
                break;
              case 2:
                context.goNamed(routeNames.availability);
                break;
              case 3:
                context.goNamed(routeNames.expertprofile);
                break;
              default:
                break;
            }
          });
        },
        items: const [
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.home_filled),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            activeIcon: Icon(Icons.chat),
            label: 'Client Chat',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.event_available_rounded),
            icon: Icon(Icons.event_available_rounded),
            label: 'Availability',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.person),
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
