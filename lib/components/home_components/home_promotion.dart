import 'package:duantotnghiep_app_thue_xe/components/home_components/promotion_tile.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';

class HomePromotion extends StatefulWidget {
  const HomePromotion({super.key});

  @override
  State<HomePromotion> createState() => _HomePromotionState();
}

class _HomePromotionState extends State<HomePromotion> {
  int _currentIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, homeVM, _) {
        final promotions = homeVM.promotions;
        final isLoading = homeVM.isPromotionsLoading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Section
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                  // TextButton(
                  //   onPressed: () {},
                  //   style: TextButton.styleFrom(
                  //     padding: EdgeInsets.zero,
                  //     minimumSize: const Size(50, 30),
                  //     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  //   ),
                  //   child: const Text(
                  //     'Xem tất cả',
                  //     style: TextStyle(
                  //       color: AppColors.primary,
                  //       fontWeight: FontWeight.w600,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),

            // Carousel Slider or Loading
            isLoading
                ? const SizedBox(
                    height: 180,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : promotions.isEmpty
                ? const SizedBox(
                    height: 100,
                    child: Center(
                      child: Text(
                        'Hôm nay không có khuyến mãi nào',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      CarouselSlider(
                        carouselController: _carouselController,
                        options: CarouselOptions(
                          height: 180.0,
                          autoPlay: true,
                          autoPlayInterval: const Duration(seconds: 4),
                          autoPlayAnimationDuration: const Duration(
                            milliseconds: 800,
                          ),
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
                          return PromotionTile(promotion: promo);
                        }).toList(),
                      ),

                      // Indicator dots
                      const SizedBox(height: 7),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: promotions.asMap().entries.map((entry) {
                          final int index = entry.key;
                          final bool isActive = _currentIndex == index;
                          return GestureDetector(
                            onTap: () =>
                                _carouselController.animateToPage(index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: isActive ? 18.0 : 6.0,
                              height: 6.0,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 3.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3.0),
                                color: isActive
                                    ? AppColors.primary
                                    : Colors.grey.shade300,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
          ],
        );
      },
    );
  }
}

