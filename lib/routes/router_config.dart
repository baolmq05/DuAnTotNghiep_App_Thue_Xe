import 'package:duantotnghiep_app_thue_xe/views/demo_page.dart';
import 'package:duantotnghiep_app_thue_xe/views/home_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/setting_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/message/message_list_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/message/chat_detail_view.dart';
import 'package:duantotnghiep_app_thue_xe/models/message_model.dart';
import 'package:go_router/go_router.dart';

// GoRouter configuration
final drivioRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeView()),
    GoRoute(path: '/chat', builder: (context, state) => const MessageListView()),
    GoRoute(path: '/setting', builder: (context, state) => const SettingView()),
    GoRoute(path: '/demo', builder: (context, state) => const DemoPage()),
    GoRoute(
      path: '/chat/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final conv = state.extra as Conversation?;
        return ChatDetailView(conversationId: id, conversation: conv);
      },
    ),
  ],
);
