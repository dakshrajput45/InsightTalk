import 'package:go_router/go_router.dart';
import 'package:insighttalk_frontend/pages/appointment/appointment_view.dart';
import 'package:insighttalk_frontend/pages/expert/experts_view.dart';
import 'package:insighttalk_frontend/pages/home.dart';
import 'package:insighttalk_frontend/pages/notifications/notfication_view.dart';
import 'package:insighttalk_frontend/pages/paymentgateway/payment_gateway.dart';
import 'package:insighttalk_frontend/pages/userProfile/user_profile_view.dart';


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
  ]);
}

class RouteNames {
  final String experts = 'experts';
  final String appointment = 'appointment';
  final String paymentgateway = 'paymentgateway';
  final String notification = 'notification';
  final String userprofile = 'userprofile';
}
