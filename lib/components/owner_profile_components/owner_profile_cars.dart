import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:duantotnghiep_app_thue_xe/models/owner_profile_model.dart';
import 'package:duantotnghiep_app_thue_xe/models/car_model.dart';
import 'package:duantotnghiep_app_thue_xe/components/home_components/home_car_card.dart';

class OwnerProfileCars extends StatelessWidget {
  final OwnerProfile profile;
  final Function(Car) onCarTap;

  const OwnerProfileCars({
    super.key,
    required this.profile,
    required this.onCarTap,
  });

  void _showAllCarsBottomSheet(BuildContext context, List<Car> cars, String ownerName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 10),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tất cả xe của $ownerName',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4.0,
                      vertical: 8.0,
                    ),
                    itemCount: cars.length,
                    itemBuilder: (context, index) {
                      final car = cars[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 4.0,
                        ),
                        child: HomeCarCard(
                          width: double.infinity,
                          car: car,
                          onTap: () {
                            Navigator.pop(context);
                            onCarTap(car);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cars = profile.cars;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Danh sách xe (${cars.length})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              if (cars.isNotEmpty)
                TextButton(
                  onPressed: () => _showAllCarsBottomSheet(context, cars, profile.name),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(60, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Xem tất cả',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (cars.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Center(
              child: Text(
                'Chủ xe này chưa đăng ký xe nào.',
                style: TextStyle(color: context.textSecondary, fontSize: 13),
              ),
            ),
          )
        else
          SizedBox(
            height: 425,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: cars.length,
              itemBuilder: (context, index) {
                final car = cars[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: HomeCarCard(
                    width: 290,
                    car: car,
                    onTap: () {
                      onCarTap(car);
                    },
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
