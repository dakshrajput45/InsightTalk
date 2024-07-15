import 'package:go_router/go_router.dart';
import 'package:insighttalk_frontend/pages/appointment/appointment_view.dart';
import 'package:insighttalk_frontend/pages/auth/SignUp_view.dart';
import 'package:insighttalk_frontend/pages/auth/login_view.dart';
import 'package:insighttalk_frontend/pages/chat/chat_view.dart';
import 'package:insighttalk_frontend/pages/expert/experts_view.dart';
import 'package:insighttalk_frontend/pages/home.dart';
import 'package:insighttalk_frontend/pages/notifications/notfication_view.dart';
import 'package:insighttalk_frontend/pages/paymentgateway/payment_gateway.dart';
import 'package:insighttalk_frontend/pages/userProfile/editprofile_view.dart';
import 'package:insighttalk_frontend/pages/userProfile/user_profile_view.dart';

// Simulate login status
int isLoggedIn = 1;
void updateLoginStatus(int loggedIn) {
  isLoggedIn = loggedIn;
  print(isLoggedIn);
}

RouterConfig routerConfig = RouterConfig();
RouteNames routeNames = RouteNames();

class RouterConfig {
  GoRouter getRouter() => _router;
  final GoRouter _router = GoRouter(
    // Define routes
    routes: [
      GoRoute(
        path: '/editprofileview',
        name: routeNames.editprofileview,
        builder: (context, state) => const EditProfileView(),
      ),
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
      GoRoute(
        path: '/chat',
        name: routeNames.chat,
        builder: (context, state) => const ChatView(),
      ),
      // StatefulShellRoute for authenticated routes
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return HomeView(
            navigationShell: navigationShell,
            title: 'Insight Talk',
          );
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: routeNames.experts,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ExpertsView()),
              ),
              GoRoute(
                path: '/appointment',
                name: routeNames.appointment,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: AppointmentView()),
              ),
              GoRoute(
                path: '/paymentgateway',
                name: routeNames.paymentgateway,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: PaymentGatewayView()),
              ),
              GoRoute(
                path: '/notification',
                name: routeNames.notification,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: NotificationView()),
              ),
              GoRoute(
                path: '/userprofile',
                name: routeNames.userprofile,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: UserProfileView()),
              ),
            ],
          ),
        ],
      )
    ],
    // Redirect function if route not found or for other global redirection needs
    redirect: (context, state) {
      if (isLoggedIn == 1) {
        return ("/login");
      }
      return null;
    },
  );
}

class RouteNames {
  final String experts = 'experts';
  final String appointment = 'appointment';
  final String paymentgateway = 'paymentgateway';
  final String notification = 'notification';
  final String userprofile = 'userprofile';
  final String login = 'login';
  final String signup = 'signup';
  final String chat = 'chat';
  final String editprofileview = 'editprofileview';
}
