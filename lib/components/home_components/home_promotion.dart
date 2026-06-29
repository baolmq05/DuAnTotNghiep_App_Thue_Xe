import 'package:duantotnghiep_app_thue_xe/components/home_components/promotion_tile.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomePromotion extends StatefulWidget {
  const HomePromotion({super.key});

  @override
  State<HomePromotion> createState() => _HomePromotionState();
}

class _HomePromotionState extends State<HomePromotion> {
  int _currentIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  final List<Map<String, dynamic>> promotions = [
    {
      'title': 'Ưu đãi bạn mới',
      'subtitle': 'Giảm ngay 10% tối đa 150k cho lần đầu thuê xe',
      'code': 'DRIVIONEW',
      'gradient': [AppColors.primaryDark, AppColors.primary],
      'icon': Icons.card_giftcard,
    },
    {
      'title': 'Vi vu cuối tuần',
      'subtitle': 'Đồng giá thuê xe tự lái chỉ từ 699k/ngày',
      'code': 'WEEKEND699',
      'gradient': [Color(0xFF8C5333), AppColors.secondary],
      'icon': Icons.directions_car,
    },
    {
      'title': 'Trải nghiệm xe điện',
      'subtitle': 'Giảm đến 20% khi thuê các dòng ô tô điện',
      'code': 'EVFUTURE',
      'gradient': [Color(0xFF1B3B5F), Color(0xFF3B6898)],
      'icon': Icons.electric_car,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Chương trình ưu đãi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Xem tất cả',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Carousel Slider
        CarouselSlider(
          carouselController: _carouselController,
          options: CarouselOptions(
            height: 150.0,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            enlargeFactor: 0.22,
            viewportFraction: 0.9,
            enableInfiniteScroll: true,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          items: promotions.map((promo) {
            return PromotionTile();
          }).toList(),
        ),

        // Indicator dots
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: promotions.asMap().entries.map((entry) {
            final int index = entry.key;
            final bool isActive = _currentIndex == index;
            return GestureDetector(
              onTap: () => _carouselController.animateToPage(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isActive ? 18.0 : 6.0,
                height: 6.0,
                margin: const EdgeInsets.symmetric(horizontal: 3.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3.0),
                  color: isActive ? AppColors.primary : Colors.grey.shade300,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
