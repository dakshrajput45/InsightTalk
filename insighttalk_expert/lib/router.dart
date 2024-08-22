import 'package:go_router/go_router.dart';
import 'package:insighttalk_backend/modal/modal_chat_rooms.dart';
import 'package:insighttalk_expert/pages/appointment/appointment_view.dart';
import 'package:insighttalk_expert/pages/auth/login_view.dart';
import 'package:insighttalk_expert/pages/auth/signup_view.dart';
import 'package:insighttalk_expert/pages/clientChat/client_chat.dart';
import 'package:insighttalk_expert/pages/clientChat/client_chat_room.dart';
import 'package:insighttalk_expert/pages/expertProfile/expert_profile_view.dart';
import 'package:insighttalk_expert/pages/expertProfile/edit_profile_view.dart';
import 'package:insighttalk_expert/pages/home.dart';
import 'package:insighttalk_expert/pages/notifications/notification_view.dart';

RouterConfig routerConfig = RouterConfig();
RouteNames routeNames = RouteNames();

int isLoggedIn = 1;
void updateLoginStatus(int loggedIn) {
  isLoggedIn = loggedIn;
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
      GoRoute(
        path: '/editprofile',
        name: routeNames.editprofile,
        builder: (context, state) => const EditProfileView(),
      ),
      GoRoute(
        path: '/chatRooms/view/:id',
        name: routeNames.chat,
        pageBuilder: (context, state) {
          final Map<String, dynamic> extras =
              state.extra as Map<String, dynamic>;
          final String? userName = extras['userName'];
          final DsdChatRooms? room = extras['chatRoom'];

          return NoTransitionPage(
            child: ClientChatView(
              roomId: state.pathParameters["id"],
              room: room,
              userName: userName,
            ),
          );
        },
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
                path: '/chatRooms',
                name: routeNames.chatRooms,
                builder: (context, state) => const CleintChatRoomView(),
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
  final String notification = 'notification';
  final String expertprofile = 'expertprofile';
  final String login = 'login';
  final String signup = 'signup';
  final String editprofile = 'editprofile';
  final String chat = 'chat';
  final String chatRooms = 'chatRooms';
}
