import 'package:go_router/go_router.dart';
import 'package:insighttalk_expert/pages/appointment/appointment_view.dart';
import 'package:insighttalk_expert/pages/auth/login_view.dart';
import 'package:insighttalk_expert/pages/auth/signup_view.dart';
import 'package:insighttalk_expert/pages/clientChat/client_chat.dart';
import 'package:insighttalk_expert/pages/expertProfile/expert_profile_view.dart';
import 'package:insighttalk_expert/pages/home.dart';
import 'package:insighttalk_expert/pages/notifications/notification_view.dart';


RouterConfig routerConfig = RouterConfig();
RouteNames routeNames = RouteNames();

int isLoggedIn = 1;
void updateLoginStatus(int loggedIn) {
  isLoggedIn = loggedIn;
  print(isLoggedIn);
}

class RouterConfig {
  GoRouter getRouter() => _router;
  final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: '/login',
        name: routeNames.login,
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: '/signup',
        name: routeNames.signup,
        builder: (context, state) => const SignUpView(),
      ),
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
    ],
    redirect: (context, state) {
      if (isLoggedIn == 1) {
        return ("/login");
      }
      return null;
    },
  );
}

class RouteNames {
  final String appointment = 'appointment';
  final String clientchat = 'clientchat';
  final String notification = 'notification';
  final String expertprofile = 'expertprofile';
  final String login = 'login';
  final String signup = 'signup';
}
