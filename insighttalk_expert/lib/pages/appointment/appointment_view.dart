import 'package:flutter/material.dart';
import 'package:insighttalk_backend/apis/appointment/appointment_apis.dart';
import 'package:insighttalk_expert/pages/appointment/appointment_tab_view.dart';

class AppointmentsView extends StatefulWidget {
  const AppointmentsView({super.key});

  @override
  State<AppointmentsView> createState() => _AppointmentsViewState();
}

class _AppointmentsViewState extends State<AppointmentsView> {
  final List<String> _tabs = [
    "Past",
    "Today",
    "Upcoming",
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 1,
      child: Scaffold(
        // floatingActionButton: (homeController.getProfile()?.isVerified ?? false)
        //     ? FloatingActionButton(
        //         onPressed: () {
        //                     Navigator.of(context, rootNavigator: true)
        //               .push(MaterialPageRoute(builder: (context) => const EnrollNewPatient()));
        //         },
        //         child: Icon(Icons.add),
        //       )
        //     : SizedBox.shrink(),
        body: Column(children: [
          TabBar(
            labelColor: Colors.black,
            labelStyle: const TextStyle(fontSize: 16),
            tabs: _tabs.map((String title) => Tab(text: title)).toList(),
          ),
          const Expanded(
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              children: [
                AppointmentTabView(
                  dateTimeFilter: DateTimeFilter.past,
                ),
                AppointmentTabView(
                  dateTimeFilter: DateTimeFilter.today,
                ),
                AppointmentTabView(
                  dateTimeFilter: DateTimeFilter.future,
                ),
              ],
            ),
          )
        ]),
      ),
    );
  }
}
