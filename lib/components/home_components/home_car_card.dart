import 'package:duantotnghiep_app_thue_xe/components/home_components/feature_car.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:flutter/material.dart';

class CarFeature {
  final IconData icon;
  final String text;

  const CarFeature({required this.icon, required this.text});
}

class HomeCarCard extends StatelessWidget {
  final double? width;
  final String name;
  final String imageUrl;
  final String? discountText;
  final String location;
  final double rating;
  final int ridesCount;
  final int pricePerDay;
  final int? originalPricePerDay;
  final bool isFavorite;
  final List<CarFeature> features;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onTap;

  const HomeCarCard({
    super.key,
    this.width,
    this.name = "SUZUKI XL7 2022",
    this.imageUrl =
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRwq-iHhpwhX--WirOBKIQr24jifaWPe2yFlqLiLqmCMGr4pdaVwD8YGiU&s=10",
    this.discountText = "Giảm 10%",
    this.location = "Phường 5, Đà Lạt",
    this.rating = 4.5,
    this.ridesCount = 100,
    this.pricePerDay = 933,
    this.originalPricePerDay = 1033,
    this.isFavorite = false,
    this.features = const [
      CarFeature(icon: Icons.ac_unit, text: "Số tự động"),
      CarFeature(icon: Icons.ac_unit, text: "Số tự động"),
      CarFeature(icon: Icons.ac_unit, text: "Số tự động"),
    ],
    this.onFavoriteTap,
    this.onTap,
  });

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
        if (discountText != null && discountText!.isNotEmpty)
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
                discountText!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
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
            name.toUpperCase(),
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
    return Row(
      spacing: 6,
      children: [
        // Original Price (Line-through)
        if (originalPricePerDay != null)
          Text(
            '${originalPricePerDay}K',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.lineThrough,
              color: Colors.grey,
            ),
          ),

        // Current Rent Price
        Text(
          '${pricePerDay}K',
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
    );
  }
}
