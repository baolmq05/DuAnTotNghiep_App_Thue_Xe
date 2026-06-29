import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:flutter/material.dart';

class DrivioAdvantageTile extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String description;

  const DrivioAdvantageTile({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side: Vertically centered image container
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              width: 70,
              height: 70,
              color: Colors.white,
              child: imageUrl.startsWith('http')
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.image_not_supported_outlined,
                        color: AppColors.textSecondary,
                        size: 30,
                      ),
                    )
                  : Image.asset(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.image_not_supported_outlined,
                        color: AppColors.textSecondary,
                        size: 30,
                      ),
                    ),
            ),
          ),

          const SizedBox(width: 16),

          // Right side: Name and Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomeAdvantages extends StatelessWidget {
  const HomeAdvantages({super.key});

  @override
  Widget build(BuildContext context) {
    // List of premium preset advantages
    final List<Map<String, String>> advantages = [
      {
        'imageUrl':
            'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?auto=format&fit=crop&q=80&w=150',
        'name': 'Hơn 100+ dòng xe đa dạng',
        'description':
            'Từ các dòng xe phổ thông tiết kiệm đến xe cao cấp sang trọng, đáp ứng mọi nhu cầu của bạn.',
      },
      {
        'imageUrl':
            'https://images.unsplash.com/photo-1508974239320-0a029497e820?auto=format&fit=crop&q=80&w=150',
        'name': 'Giao xe tận nơi nhanh chóng',
        'description':
            'Đặt xe dễ dàng và nhận xe ngay tại nhà hoặc địa điểm yêu cầu chỉ trong vài bước thao tác.',
      },
      {
        'imageUrl':
            'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?auto=format&fit=crop&q=80&w=150',
        'name': 'Thủ tục thuê đơn giản',
        'description':
            'Chỉ cần bằng lái GPLX và CCCD hợp lệ, xét duyệt hồ sơ nhanh gọn trong vòng 10 phút.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Tính năng nổi bật tại Drivio',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        // List of Advantage Tiles
        ...advantages.map(
          (adv) => DrivioAdvantageTile(
            imageUrl: adv['imageUrl']!,
            name: adv['name']!,
            description: adv['description']!,
          ),
        ),
      ],
    );
  }
}
