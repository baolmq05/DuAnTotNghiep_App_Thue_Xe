import 'package:duantotnghiep_app_thue_xe/components/home_components/home_car_card.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/home_viewmodel.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/favorite_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_toast.dart';

class HomeCarList extends StatefulWidget {
  const HomeCarList({super.key});

  @override
  State<HomeCarList> createState() => _HomeCarListState();
}

class _HomeCarListState extends State<HomeCarList> {
  int _currentIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    final favoriteVM = context.watch<FavoriteViewModel>();
    return Consumer<HomeViewModel>(
      builder: (context, homeVM, _) {
        final cars = homeVM.cars;
        final isLoading = homeVM.isCarsLoading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Section
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Xe nổi bật',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Carousel Slider or Loading
            isLoading
                ? const SizedBox(
                    height: 380,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : cars.isEmpty
                ? const SizedBox(
                    height: 150,
                    child: Center(
                      child: Text(
                        'Không có xe nào khả dụng gần bạn',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      CarouselSlider(
                        carouselController: _carouselController,
                        options: CarouselOptions(
                          height: 440.0,
                          autoPlay: true,
                          autoPlayInterval: const Duration(seconds: 5),
                          autoPlayAnimationDuration: const Duration(
                            milliseconds: 800,
                          ),
                          autoPlayCurve: Curves.fastOutSlowIn,
                          enlargeCenterPage: true,
                          enlargeFactor: 0.18,
                          viewportFraction: 0.88,
                          enableInfiniteScroll: false,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _currentIndex = index;
                            });
                          },
                        ),
                        items: cars.asMap().entries.map((entry) {
                          final int index = entry.key;
                          final car = entry.value;
                          final isFav = favoriteVM.isFavorite(car.id);
                          final double translationOffset = cars.length > 1
                              ? -0.06818 * (1.0 - index / (cars.length - 1))
                              : -0.06818;
                          return FractionalTranslation(
                            translation: Offset(translationOffset, 0),
                            child: HomeCarCard(
                              width: double.infinity,
                              car: car,
                              isFavorite: isFav,
                              onFavoriteTap: () {
                                context
                                    .read<FavoriteViewModel>()
                                    .toggleFavorite(carId: car.id, car: car);
                                if (isFav) {
                                  AppToast.show(
                                    context,
                                    message:
                                        "Đã xóa xe khỏi danh sách yêu thích",
                                    type: ToastType.info,
                                  );
                                } else {
                                  AppToast.show(
                                    context,
                                    message:
                                        "Đã thêm xe vào danh sách yêu thích thành công!",
                                    type: ToastType.success,
                                  );
                                }
                              },
                              onTap: () {
                                context.push('/car_detail/${car.id}');
                              },
                            ),
                          );
                        }).toList(),
                      ),

                      // Indicator dots
                      const SizedBox(height: 7),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: cars.asMap().entries.map((entry) {
                          final int index = entry.key;
                          final bool isActive = _currentIndex == index;
                          return GestureDetector(
                            onTap: () =>
                                _carouselController.animateToPage(index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: isActive ? 18.0 : 6.0,
                              height: 6.0,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 3.0,
                              ),
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
