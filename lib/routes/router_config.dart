import 'package:duantotnghiep_app_thue_xe/views/demo_page.dart';
import 'package:duantotnghiep_app_thue_xe/views/home_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/setting_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/order_detail.dart';
import 'package:duantotnghiep_app_thue_xe/views/car_detail.dart';
import 'package:duantotnghiep_app_thue_xe/views/profile.dart';
import 'package:duantotnghiep_app_thue_xe/views/onboardings/slide1_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/onboardings/slide2_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/onboardings/slide3_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/onboardings/slide4_view.dart';

import 'package:go_router/go_router.dart';

// GoRouter configuration
final drivioRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeView()),
    GoRoute(path: '/setting', builder: (context, state) => const SettingView()),
    GoRoute(path: '/demo', builder: (context, state) => const DemoPage()),
    GoRoute(
      path: '/order-detail',
      builder: (context, state) => const OrderDetailView(),
    ),
    GoRoute(
      path: '/car_detail',
      builder: (context, state) => const CarDetailPage(),
    ),
    GoRoute(
      path: '/car_detail',
      builder: (context, state) => const CarDetailPage(),
    ),
    GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
    GoRoute(
      path: '/order-detail',
      builder: (context, state) => const OrderDetailView(),
    ),
    GoRoute(path: '/slide1', builder: (context, state) => const Slide1View()),
    GoRoute(path: '/slide2', builder: (context, state) => const Slide2View()),
    GoRoute(path: '/slide3', builder: (context, state) => const Slide3View()),
    GoRoute(path: '/slide4', builder: (context, state) => const Slide4View()),
  ],
);
