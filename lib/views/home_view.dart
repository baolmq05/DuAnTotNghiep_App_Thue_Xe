import 'package:duantotnghiep_app_thue_xe/components/home_components/home_advantages.dart';
import 'package:duantotnghiep_app_thue_xe/components/home_components/home_car_list.dart';
import 'package:duantotnghiep_app_thue_xe/components/home_components/home_filter.dart';
import 'package:duantotnghiep_app_thue_xe/components/home_components/home_insurance.dart';
import 'package:duantotnghiep_app_thue_xe/components/home_components/home_promotion.dart';
import 'package:duantotnghiep_app_thue_xe/components/home_components/home_rent_out_banner.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Xin chào,', style: TextStyle(fontSize: 13)),
            Row(
              spacing: 5,
              children: [
                Text(
                  'Quốc Bảo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            padding: EdgeInsets.all(12),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  onPressed: () {
                    context.go('/notification');
                  },
                  icon: const Icon(Icons.notifications_none_outlined),
                ),

                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    constraints: const BoxConstraints(
                      minWidth: 15,
                      minHeight: 15,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        "3",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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
          HomeCarList(),
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
