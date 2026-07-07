import 'package:duantotnghiep_app_thue_xe/components/home_components/feature_car.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:flutter/material.dart';
import '../../models/car_model.dart';

class CarFeature {
  final IconData icon;
  final String text;

  const CarFeature({required this.icon, required this.text});
}

class HomeCarCard extends StatelessWidget {
  final double? width;
  final Car car;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onTap;

  const HomeCarCard({
    super.key,
    this.width,
    required this.car,
    this.isFavorite = false,
    this.onFavoriteTap,
    this.onTap,
  });

  String get imageUrl {
    if (car.images.isEmpty) {
      return "https://via.placeholder.com/600x300";
    }
    final thumbnailImage = car.images.firstWhere(
      (img) => img.isThumbnail,
      orElse: () => car.images.first,
    );
    return thumbnailImage.imageUrl;
  }

  String? get discountText {
    if (car.unitPrice > 0 && car.discountValue > 0) {
      final pct = ((car.discountValue / car.unitPrice) * 100).round();
      return "Giảm $pct%";
    }
    return null;
  }

  String get location => car.carLocation?.address ?? 'Chưa xác định';

  double get rating => car.reviewsAvgRating;

  int get ridesCount => car.tripsCount;

  List<CarFeature> get features {
    final bool isAuto =
        car.transmission.toLowerCase().contains("tự động") ||
        car.transmission.toLowerCase().contains("auto");
    return [
      CarFeature(
        icon: Icons.airline_seat_recline_normal,
        text: "${car.seatCount} chỗ",
      ),
      CarFeature(
        icon: isAuto ? Icons.autorenew_outlined : Icons.settings,
        text: isAuto ? "Số tự động" : "Số sàn",
      ),
      CarFeature(icon: Icons.local_gas_station_outlined, text: car.fuelType),
    ];
  }

  String formatPrice(num price) {
    final value = price.toInt();
    final formatted = value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
    return '$formattedđ';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        margin: const EdgeInsets.only(top: 12, bottom: 12, left: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(context),
            _buildDetailsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    final discount = discountText;
    return Stack(
      children: [
        // Car Image with Error Placeholder
        Padding(
          padding: const EdgeInsets.all(10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              imageUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey.shade200,
                child: const Icon(
                  Icons.broken_image,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ),

        // Favorite Button
        Positioned(
          top: 18,
          right: 18,
          child: GestureDetector(
            onTap: onFavoriteTap,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border_outlined,
                size: 16,
                color: isFavorite ? Colors.red : Colors.black,
              ),
            ),
          ),
        ),

        // Discount Tag
        if (discount != null && discount.isNotEmpty)
          Positioned(
            top: 18,
            left: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: AppColors.primary,
              ),
              child: Text(
                discount,
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          // Title / Car Name
          Text(
            car.name.toUpperCase(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          // Features List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: features
                .map(
                  (feature) =>
                      FeatureCar(icon: feature.icon, text: feature.text),
                )
                .toList(),
          ),

          // Location Section
          Row(
            spacing: 4,
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: AppColors.textSecondary,
                size: 16,
              ),
              Expanded(
                child: Text(
                  location,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          Divider(height: 1, color: Theme.of(context).colorScheme.outline),

          // Rating, Rides and Pricing Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRatingAndRides(context),
              _buildPriceSection(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingAndRides(BuildContext context) {
    return Row(
      spacing: 12,
      children: [
        // Rating Stars
        Row(
          spacing: 4,
          children: [
            Icon(Icons.star, color: Colors.yellow.shade700, size: 16),
            Text(
              rating.toStringAsFixed(1),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),

        // Rides Count
        Row(
          spacing: 4,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            Text(
              '$ridesCount+ chuyến',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceSection(BuildContext context) {
    final originalPriceVal = car.unitPrice;
    final currentPriceVal = car.unitPrice - car.discountValue;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: 6,
      children: [
        // Original Price (Line-through)
        if (car.discountValue > 0)
          Text(
            formatPrice(originalPriceVal),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.lineThrough,
              color: Colors.grey,
            ),
          ),

        // Current Rent Price
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              formatPrice(currentPriceVal),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),

            // Unit
            const Text(
              '/ngày',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }
}
