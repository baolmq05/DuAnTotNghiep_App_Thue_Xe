import 'package:duantotnghiep_app_thue_xe/views/login_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:duantotnghiep_app_thue_xe/models/conversation.dart';
import 'package:duantotnghiep_app_thue_xe/views/car_detail.dart';
import 'package:duantotnghiep_app_thue_xe/views/message/chat_detail_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/message/conversations_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/onboardings/slide1_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/onboardings/slide2_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/onboardings/slide3_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/onboardings/slide4_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/order_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/order_detail.dart';
import 'package:duantotnghiep_app_thue_xe/views/register_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/setting_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/splash_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/main_screen.dart';
import 'package:duantotnghiep_app_thue_xe/views/home_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/profile.dart';

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
      path: '/setting',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SettingView(),
    ),
    GoRoute(
      path: '/order-detail',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const OrderDetailView(),
    ),
    GoRoute(
      path: '/car_detail',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CarDetailPage(),
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
