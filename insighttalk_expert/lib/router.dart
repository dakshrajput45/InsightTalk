import 'package:go_router/go_router.dart';
import 'package:insighttalk_backend/apis/userApis/auth_user.dart';
import 'package:insighttalk_backend/modal/modal_chat_rooms.dart';
import 'package:insighttalk_expert/pages/appointment/appointment_view.dart';
import 'package:insighttalk_expert/pages/auth/login_view.dart';
import 'package:insighttalk_expert/pages/auth/signup_view.dart';
import 'package:insighttalk_expert/pages/clientChat/client_chat.dart';
import 'package:insighttalk_expert/pages/clientChat/client_chat_room.dart';
import 'package:insighttalk_expert/pages/expertProfile/expert_profile_view.dart';
import 'package:insighttalk_expert/pages/expertProfile/edit_profile_view.dart';
import 'package:insighttalk_expert/pages/home.dart';
import 'package:insighttalk_expert/pages/availability/availability_view.dart';

RouterConfig routerConfig = RouterConfig();
RouteNames routeNames = RouteNames();
final ITUserAuthSDK _itUserAuthSDK = ITUserAuthSDK();
int isLoggedIn = 1;
void updateLoginStatus(int loggedIn) {
  isLoggedIn = loggedIn;
}

class RouterConfig {
  GoRouter getRouter() => _router;
  final GoRouter _router = GoRouter(
    initialLocation: _itUserAuthSDK.getUser() == null ? "/login" : "/",
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
                    const NoTransitionPage(child: AppointmentsView()),
              ),
              GoRoute(
                path: '/chatRooms',
                name: routeNames.chatRooms,
                builder: (context, state) => const CleintChatRoomView(),
              ),
              GoRoute(
                path: '/availability',
                name: routeNames.availability,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: AvailabilityView()),
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
  );
}

class RouteNames {
  final String appointment = 'appointment';
  final String availability = 'availability';
  final String expertprofile = 'expertprofile';
  final String login = 'login';
  final String signup = 'signup';
  final String editprofile = 'editprofile';
  final String chat = 'chat';
  final String chatRooms = 'chatRooms';
}
