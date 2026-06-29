import 'package:duantotnghiep_app_thue_xe/views/demo_page.dart';
import 'package:duantotnghiep_app_thue_xe/views/home_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/setting_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/login_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/register_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/splash_view.dart';
import 'package:go_router/go_router.dart';

// GoRouter configuration
final drivioRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashView()),
    GoRoute(path: '/home', builder: (context, state) => const HomeView()),
    GoRoute(path: '/login', builder: (context, state) => const LoginView()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterView()),
    GoRoute(path: '/setting', builder: (context, state) => const SettingView()),
    GoRoute(path: '/demo', builder: (context, state) => const DemoPage()),
  ],
);
