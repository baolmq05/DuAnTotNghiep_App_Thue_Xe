import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:duantotnghiep_app_thue_xe/models/trip_model.dart';

class OrderDetailCarCard extends StatelessWidget {
  final CarModel car;

  const OrderDetailCarCard({
    super.key,
    required this.car,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = car.getFirstImageUrl();
    final addressText =
        car.carLocation?.address ?? car.carLocation?.city ?? 'TP. Hồ Chí Minh';

    return Card(
      margin: EdgeInsets.zero,
      color: context.cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: 90,
                height: 65,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Image.network(
                  'https://picsum.photos/300/200',
                  width: 90,
                  height: 65,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    car.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${car.licensePlate} • $addressText',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 14),
                      Text(
                        ' ${car.seatCount} chỗ  ',
                        style: const TextStyle(fontSize: 13),
                      ),
                      const Icon(Icons.autorenew, size: 14),
                      Text(
                        ' ${car.transmission ?? "Số tự động"}  ',
                        style: const TextStyle(fontSize: 13),
                      ),
                      const Icon(Icons.local_gas_station_outlined, size: 14),
                      Text(
                        ' ${car.fuelType ?? "Xăng"}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
