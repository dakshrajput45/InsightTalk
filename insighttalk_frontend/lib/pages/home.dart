import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:insighttalk_frontend/router.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Insight Talk',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                context.pushNamed(routeNames.chat);
              },
              icon: const Icon(Icons.chat_outlined))
        ],
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
                context.goNamed(routeNames.experts);
                break;
              case 1:
                context.goNamed(routeNames.appointment);
                break;
              case 2:
                context.goNamed(routeNames.paymentgateway);
                break;
              case 3:
                context.goNamed(routeNames.notification);
                break;
              case 4:
                context.goNamed(routeNames.userprofile);
                break;
              default:
                break;
            }
          });
        },
        items: const [
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            activeIcon: Icon(Icons.dock_rounded),
            label: 'Appointment',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.payment),
            label: 'Payment Gateway',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.notifications),
            icon: Icon(Icons.notifications_outlined),
            label: 'Notifications',
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
