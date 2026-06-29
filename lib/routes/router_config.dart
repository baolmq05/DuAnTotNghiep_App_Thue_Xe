import 'package:duantotnghiep_app_thue_xe/views/demo_page.dart';
import 'package:duantotnghiep_app_thue_xe/views/home_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/setting_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/order_detail.dart';
import 'package:duantotnghiep_app_thue_xe/views/car_detail.dart';
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
  ],
);
