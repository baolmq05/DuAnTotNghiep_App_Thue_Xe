import 'package:duantotnghiep_app_thue_xe/views/home_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/setting_view.dart';
import 'package:go_router/go_router.dart';

// GoRouter configuration
final drivioRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeView()),
    GoRoute(path: '/setting', builder: (context, state) => const SettingView()),
  ],
);
