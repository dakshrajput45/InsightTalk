import 'package:go_router/go_router.dart';
import 'package:insighttalk_backend/modal/modal_chat_rooms.dart';
import 'package:insighttalk_frontend/pages/appointment/appointment_view.dart';
import 'package:insighttalk_frontend/pages/auth/SignUp_view.dart';
import 'package:insighttalk_frontend/pages/auth/login_view.dart';
import 'package:insighttalk_frontend/pages/chat/chat_room_view.dart';
import 'package:insighttalk_frontend/pages/chat/chat_view.dart';
import 'package:insighttalk_frontend/pages/expert/book_appointment_view.dart';
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
        path: '/bookappointmentview/:expertId',
        name: routeNames.bookappointmentview,
        builder: (context, state) {
          final expertId = state.pathParameters['expertId']!;
          return BookAppointmentView(
            expertId: expertId,
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
        path: '/chatRooms',
        name: routeNames.chatRooms,
        builder: (context, state) => const ChatRoomsView(),
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
          final String? userName = extras['userName'];
          final DsdChatRooms? room = extras['chatRoom'];

          return NoTransitionPage(
            child: ChatView(
              roomId: state.pathParameters["id"],
              room: room,
              userName: userName,
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
                    const NoTransitionPage(child: AppointmentView()),
              ),
              GoRoute(
                path: '/paymentgateway',
                name: routeNames.paymentgateway,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: PaymentGatewayView()),
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
