import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';

class SupportGuidesCarousel extends StatefulWidget {
  final List<Map<String, dynamic>> guides;
  final Function(Map<String, dynamic> guide) onGuideTap;

  const SupportGuidesCarousel({
    super.key,
    required this.guides,
    required this.onGuideTap,
  });

  @override
  State<SupportGuidesCarousel> createState() => _SupportGuidesCarouselState();
}

class _SupportGuidesCarouselState extends State<SupportGuidesCarousel> {
  int _currentGuideIndex = 0;
  final CarouselSliderController _carouselController = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          carouselController: _carouselController,
          options: CarouselOptions(
            height: 170.0,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            enlargeFactor: 0.22,
            viewportFraction: 0.88,
            enableInfiniteScroll: true,
            onPageChanged: (index, reason) {
              setState(() {
                _currentGuideIndex = index;
              });
            },
          ),
          items: widget.guides.map((guide) {
            return Builder(
              builder: (BuildContext context) {
                return GestureDetector(
                  onTap: () => widget.onGuideTap(guide),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: guide['color'],
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    guide['category'].toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: context.primaryColor.withValues(alpha: 0.8),
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    guide['title'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: context.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    guide['description'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: context.textSecondary.withValues(alpha: 0.9),
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Xem chi tiết',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: context.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 11,
                                    color: context.primaryColor,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          right: 8,
                          bottom: -8,
                          child: Opacity(
                            opacity: 0.08,
                            child: Icon(
                              guide['title'].contains('đặt xe')
                                  ? Icons.directions_car_filled_rounded
                                  : (guide['title'].contains('chủ xe')
                                      ? Icons.home_work_rounded
                                      : Icons.gavel_rounded),
                              size: 110,
                              color: context.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.guides.asMap().entries.map((entry) {
            final int index = entry.key;
            final bool isActive = _currentGuideIndex == index;
            return GestureDetector(
              onTap: () => _carouselController.animateToPage(index),
              child: Container(
                width: isActive ? 16.0 : 6.0,
                height: 6.0,
                margin: const EdgeInsets.symmetric(horizontal: 3.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3.0),
                  color: isActive
                      ? context.primaryColor
                      : Colors.grey.shade300,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
