import 'package:duantotnghiep_app_thue_xe/views/login_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:duantotnghiep_app_thue_xe/models/conversation_model.dart';
import 'package:duantotnghiep_app_thue_xe/views/car_detail_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/message/chat_detail_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/message/conversations_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/onboardings/slide1_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/onboardings/slide2_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/onboardings/slide3_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/onboardings/slide4_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/order_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/order_detail_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/register_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/setting_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/splash_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/policy_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/main_screen_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/home_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/profile_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/notification_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/support_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/support_detail_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/address_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/favorite_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/owner_profile_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/change_password_view.dart';

// Khởi tạo các Global Navigator Keys
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _shellNavigatorHome = GlobalKey<NavigatorState>(
  debugLabel: 'shellHome',
);
final GlobalKey<NavigatorState> _shellNavigatorOrders =
    GlobalKey<NavigatorState>(debugLabel: 'shellOrders');
final GlobalKey<NavigatorState> _shellNavigatorMessages =
    GlobalKey<NavigatorState>(debugLabel: 'shellMessages');
final GlobalKey<NavigatorState> _shellNavigatorProfile =
    GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

final drivioRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // Các màn hình không chứa Bottom Navigation Bar (mở Full Screen)
    GoRoute(
      path: '/',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SplashView(),
    ),
    GoRoute(
      path: '/policy',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final showAcceptance = extra?['showAcceptance'] as bool? ?? false;
        final onAccept = extra?['onAccept'] as VoidCallback?;
        return PolicyView(showAcceptance: showAcceptance, onAccept: onAccept);
      },
    ),
    GoRoute(
      path: '/register',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const RegisterView(),
    ),
    GoRoute(
      path: '/login',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const LoginView(),
    ),
    GoRoute(
      path: '/change-password',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ChangePasswordView(),
    ),
    GoRoute(
      path: '/setting',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SettingView(),
    ),
    GoRoute(
      path: '/order-detail/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final idStr = state.pathParameters['id']!;
        final id = int.tryParse(idStr) ?? 0;
        return OrderDetailView(orderId: id);
      },
    ),
    GoRoute(
      path: '/car_detail/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final idStr = state.pathParameters['id']!;
        final id = int.tryParse(idStr) ?? 0;
        return CarDetailPage(carId: id);
      },
    ),
    GoRoute(
      path: '/slide1',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const Slide1View(),
    ),
    GoRoute(
      path: '/slide2',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const Slide2View(),
    ),
    GoRoute(
      path: '/slide3',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const Slide3View(),
    ),
    GoRoute(
      path: '/slide4',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const Slide4View(),
    ),
    GoRoute(
      path: '/chat/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final conv = state.extra as Conversation?;
        return ChatDetailView(conversationId: id, conversation: conv);
      },
    ),
    GoRoute(
      path: '/notification',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const NotificationView(),
    ),
    GoRoute(
      path: '/support',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SupportView(),
    ),
    GoRoute(
      path: '/address',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AddressView(),
    ),
    GoRoute(
      path: '/support-detail',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return SupportDetailView(
          title: extra['title'] as String,
          content: extra['content'] as String,
          imageUrl: extra['imageUrl'] as String?,
          steps: extra['steps'] as List<String>?,
        );
      },
    ),
    GoRoute(
      path: '/favorite',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const FavoriteView(),
    ),
    GoRoute(
      path: '/owner-profile/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final idStr = state.pathParameters['id']!;
        final id = int.tryParse(idStr) ?? 0;
        final extra = state.extra as Map<String, dynamic>?;
        final fromCarId = extra?['fromCarId'] as int?;
        return OwnerProfileView(ownerId: id, fromCarId: fromCarId);
      },
    ),

    // StatefulShellRoute chứa 4 tab chính của ứng dụng
    StatefulShellRoute.indexedStack(
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state, navigationShell) {
        // Trả về MainScreen và truyền navigationShell vào
        return MainScreen(navigationShell: navigationShell);
      },
      branches: [
        // Tab 0: Trang chủ
        StatefulShellBranch(
          navigatorKey: _shellNavigatorHome,
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeView(),
            ),
          ],
        ),
        // Tab 1: Đơn thuê
        StatefulShellBranch(
          navigatorKey: _shellNavigatorOrders,
          routes: [
            GoRoute(
              path: '/orders',
              builder: (context, state) => const OrderView(),
            ),
          ],
        ),
        // Tab 2: Tin nhắn
        StatefulShellBranch(
          navigatorKey: _shellNavigatorMessages,
          routes: [
            GoRoute(
              path: '/messages',
              builder: (context, state) => const ConversationsView(),
            ),
          ],
        ),
        // Tab 3: Cá nhân
        StatefulShellBranch(
          navigatorKey: _shellNavigatorProfile,
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileView(),
            ),
          ],
        ),
      ],
    ),
  ],
);
