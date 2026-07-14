import 'package:duantotnghiep_app_thue_xe/components/home_components/home_advantages.dart';
import 'package:duantotnghiep_app_thue_xe/components/home_components/home_car_list.dart';
import 'package:duantotnghiep_app_thue_xe/components/home_components/home_filter.dart';
import 'package:duantotnghiep_app_thue_xe/components/home_components/home_insurance.dart';
import 'package:duantotnghiep_app_thue_xe/components/home_components/home_promotion.dart';
import 'package:duantotnghiep_app_thue_xe/components/home_components/home_rent_out_banner.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/home_viewmodel.dart';
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
            padding: EdgeInsets.all(12),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  onPressed: () {
                    context.push('/notification');
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
