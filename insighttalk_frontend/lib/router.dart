import 'package:go_router/go_router.dart';
import 'package:insighttalk_backend/apis/userApis/auth_user.dart';
import 'package:insighttalk_backend/modal/modal_chat_rooms.dart';
import 'package:insighttalk_backend/modal/modal_expert.dart';
import 'package:insighttalk_frontend/pages/appointment/appointment_view.dart';
import 'package:insighttalk_frontend/pages/auth/SignUp_view.dart';
import 'package:insighttalk_frontend/pages/auth/login_view.dart';
import 'package:insighttalk_frontend/pages/chat/chat_room_view.dart';
import 'package:insighttalk_frontend/pages/chat/chat_view.dart';
import 'package:insighttalk_frontend/pages/appointment/book_appointment_view.dart';
import 'package:insighttalk_frontend/pages/expert/expert_profile_view.dart';
import 'package:insighttalk_frontend/pages/expert/experts_view.dart';
import 'package:insighttalk_frontend/pages/home.dart';
import 'package:insighttalk_frontend/pages/paymentgateway/payment_gateway.dart';
import 'package:insighttalk_frontend/pages/userProfile/editprofile_view.dart';
import 'package:insighttalk_frontend/pages/userProfile/experts_of_category_view.dart';
import 'package:insighttalk_frontend/pages/userProfile/user_profile_view.dart';

// Simulate login status
int isLoggedIn = 1;
void updateLoginStatus(int loggedIn) {
  isLoggedIn = loggedIn;
}

final ITUserAuthSDK _itUserAuthSDK = ITUserAuthSDK();
RouterConfig routerConfig = RouterConfig();
RouteNames routeNames = RouteNames();

class RouterConfig {
  GoRouter getRouter() => _router;
  final GoRouter _router = GoRouter(
    initialLocation: _itUserAuthSDK.getUser() == null ? "/login" : "/",
    routes: [
      GoRoute(
        path: '/editprofileview',
        name: routeNames.editprofileview,
        builder: (context, state) => const EditProfileView(),
      ),
      GoRoute(
        path: '/expertprofileview/:expertId',
        name: routeNames.expertprofileview,
        builder: (context, state) {
          final expertId = state.pathParameters['expertId']!;
          return ExpertProfileView(
            expertId: expertId,
          );
        },
      ),
      GoRoute(
        path: '/bookappointmentview',
        name: routeNames.bookappointmentview,
        builder: (context, state) {
          final expertData = state.extra as DsdExpert;
          return BookAppointmentView(
            expertData: expertData,
          );
        },
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
        path:
            '/expertsOfCategory/:categoryTitle', // Updated path to include categoryTitle
        name: routeNames.expertsOfCategory,
        builder: (context, state) {
          final categoryTitle = state.pathParameters['categoryTitle']!;
          return CategoryExperts(categoryTitle: categoryTitle);
        },
      ),
      GoRoute(
        path: '/chatRooms/view/:id',
        name: routeNames.chat,
        pageBuilder: (context, state) {
          final Map<String, dynamic> extras =
              state.extra as Map<String, dynamic>;
          final DsdChatRooms? room = extras['chatRoom'];

          return NoTransitionPage(
            child: ChatView(
              roomId: state.pathParameters["id"],
              room: room,
            ),
          );
        },
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
                    const NoTransitionPage(child: AppointmentsView()),
              ),
              GoRoute(
                path: '/chatRooms',
                name: routeNames.chatRooms,
                builder: (context, state) => const ChatRoomsView(),
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
  );
}

class RouteNames {
  final String experts = 'experts';
  final String appointment = 'appointment';
  final String paymentgateway = 'paymentgateway';
  final String userprofile = 'userprofile';
  final String login = 'login';
  final String signup = 'signup';
  final String chat = 'chat';
  final String chatRooms = 'chatRooms';
  final String editprofileview = 'editprofileview';
  final String expertprofileview = 'expertprofileview';
  final String expertsOfCategory = 'expertsOfCategory';
  final String bookappointmentview = 'bookappointmentview';
}
