import 'package:go_router/go_router.dart';
import 'package:insighttalk_expert/pages/appointment/appointment_view.dart';
import 'package:insighttalk_expert/pages/clientChat/client_chat.dart';
import 'package:insighttalk_expert/pages/expertProfile/expert_profile_view.dart';
import 'package:insighttalk_expert/pages/home.dart';
import 'package:insighttalk_expert/pages/notifications/notification_view.dart';
import './main.dart';

RouterConfig routerConfig = RouterConfig();
RouteNames routeNames = RouteNames();

class RouterConfig {
  GoRouter goRouter() => _router;
  final GoRouter _router = GoRouter(routes: [
    // GoRoute(
    //     path: '/sign_in',
    //     name: routeNames.signIn,
    //     builder: (context, state) => const SignInView(),
    //   ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => HomeView(
        navigationShell: navigationShell,
        title: 'Insight Talk',
      ),
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              name: routeNames.appointment,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: AppointmentView()),
            ),
            GoRoute(
              path: '/clientchat',
              name: routeNames.clientchat,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: ClientChatView()),
            ),
            GoRoute(
              path: '/notification',
              name: routeNames.notification,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: NotificationView()),
            ),
            GoRoute(
              path: '/expertprofile',
              name: routeNames.expertprofile,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: ExpertProfileView()),
            ),
          ],
        ),
      ],
    )
  ]);
}

class RouteNames {
  final String appointment = 'appointment';
  final String clientchat = 'clientchat';
  final String notification = 'notification';
  final String expertprofile = 'expertprofile';
}
