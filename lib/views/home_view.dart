import 'package:duantotnghiep_app_thue_xe/components/home_components/home_advantages.dart';
import 'package:duantotnghiep_app_thue_xe/components/home_components/home_car_list.dart';
import 'package:duantotnghiep_app_thue_xe/components/home_components/home_filter.dart';
import 'package:duantotnghiep_app_thue_xe/components/home_components/home_insurance.dart';
import 'package:duantotnghiep_app_thue_xe/components/home_components/home_promotion.dart';
import 'package:duantotnghiep_app_thue_xe/components/home_components/home_rent_out_banner.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/home_viewmodel.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/favorite_viewmodel.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/notification_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().fetchHomeData();
      context.read<FavoriteViewModel>().fetchFavorites();
      context.read<NotificationViewModel>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Drivio,',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            Row(
              spacing: 5,
              children: [
                Text(
                  'xin chào',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Icon(
                  Icons.waving_hand_sharp,
                  color: Colors.amberAccent,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Consumer<NotificationViewModel>(
              builder: (context, notificationVM, child) {
                final unreadCount = notificationVM.unreadCount;
                return Badge(
                  isLabelVisible: unreadCount > 0,
                  label: Text(
                    unreadCount > 99 ? '99+' : '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: Colors.red,
                  offset: const Offset(-4, 4),
                  child: IconButton(
                    onPressed: () {
                      context.push('/notification');
                    },
                    icon: const Icon(Icons.notifications_none_outlined),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          // Bộ lọc
          const HomeFilter(),
          const SizedBox(height: 20),
          // Ưu đãi
          const HomePromotion(),
          const SizedBox(height: 20),
          // Xe nổi bật gần bạn
          const HomeCarList(),
          const SizedBox(height: 20),
          // Bảo hiểm
          const HomeInsurance(),
          const SizedBox(height: 20),
          // Tại sao lại chọn Drivio
          const HomeAdvantages(),
          const SizedBox(height: 20),
          // Đăng ký chủ xe
          const HomeRentOutBanner(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
