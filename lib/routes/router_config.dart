import 'package:duantotnghiep_app_thue_xe/views/auth/login_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:duantotnghiep_app_thue_xe/models/conversation_model.dart';
import 'package:duantotnghiep_app_thue_xe/views/car/car_detail_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/message/chat_detail_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/message/conversations_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/auth/onboardings/slide1_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/auth/onboardings/slide2_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/auth/onboardings/slide3_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/auth/onboardings/slide4_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/order/order_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/order/order_detail_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/auth/register_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/profile/setting_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/auth/splash_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/support/policy_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/main_screen_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/home_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/profile/profile_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/notification_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/support/support_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/support/support_detail_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/profile/address_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/car/vehicle_list_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/car/favorite_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/owner/owner_profile_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/car/booking_car_view.dart';
import 'package:provider/provider.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/owner_profile_viewmodel.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/trip_viewmodel.dart';
import 'package:duantotnghiep_app_thue_xe/views/profile/change_password_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/profile/driver_license_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/support/privacy_policy_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/profile/edit_profile_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/wallet/wallet_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/owner/owner_order_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/owner/owner_tab_wrapper_view.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/owner_order_viewmodel.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/owner_order_detail_viewmodel.dart';
import 'package:duantotnghiep_app_thue_xe/views/owner/owner_order_detail_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/car/create_car_view.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/create_car_viewmodel.dart';

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
final GlobalKey<NavigatorState> _shellNavigatorOwner =
    GlobalKey<NavigatorState>(debugLabel: 'shellOwner');
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
      path: '/privacy-policy',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const PrivacyPolicyView(),
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
      path: '/driver-license',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const DriverLicenseView(),
    ),
    GoRoute(
      path: '/edit-profile',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const EditProfileView(),
    ),
    GoRoute(
      path: '/my-wallet',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const WalletView(),
    ),
    GoRoute(
      path: '/vehicles',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        return VehicleListView(queryParameters: state.uri.queryParameters);
      },
    ),
    GoRoute(
      path: '/booking-car/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final carId = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return ChangeNotifierProvider(
          create: (_) => TripViewModel(),
          child: BookingCarView(carId: carId),
        );
      },
    ),
    GoRoute(
      path: '/owner-profile/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final idStr = state.pathParameters['id']!;
        final id = int.tryParse(idStr) ?? 0;
        final extra = state.extra as Map<String, dynamic>?;
        final fromCarId = extra?['fromCarId'] as int?;
        final isOwnerStr = state.uri.queryParameters['isOwner'];
        final isOwner = isOwnerStr == null ? true : (isOwnerStr == 'true');
        return ChangeNotifierProvider(
          create: (_) => OwnerProfileViewModel(),
          child: OwnerProfileView(
            ownerId: id,
            fromCarId: fromCarId,
            isOwner: isOwner,
          ),
        );
      },
    ),
    GoRoute(
      path: '/owner-orders',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        return ChangeNotifierProvider(
          create: (_) => OwnerOrderViewModel(),
          child: const OwnerOrderView(),
        );
      },
    ),
    GoRoute(
      path: '/owner-order-detail/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final idStr = state.pathParameters['id']!;
        final id = int.tryParse(idStr) ?? 0;
        return ChangeNotifierProvider(
          create: (_) => OwnerOrderDetailViewModel(),
          child: OwnerOrderDetailView(orderId: id),
        );
      },
    ),
    GoRoute(
      path: '/register-car',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        return ChangeNotifierProvider(
          create: (_) => CreateCarViewModel(),
          child: const CreateCarView(),
        );
      },
    ),

    // StatefulShellRoute chứa 5 tab chính của ứng dụng
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
        // Tab 3: Chủ xe
        StatefulShellBranch(
          navigatorKey: _shellNavigatorOwner,
          routes: [
            GoRoute(
              path: '/owner-dashboard',
              builder: (context, state) => ChangeNotifierProvider(
                create: (_) => OwnerOrderViewModel(),
                child: const OwnerTabWrapperView(),
              ),
            ),
          ],
        ),
        // Tab 4: Cá nhân
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
