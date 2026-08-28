import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:duantotnghiep_app_thue_xe/models/trip_model.dart';

class OrderItemCard extends StatelessWidget {
  final TripModel trip;
  final VoidCallback onTap;

  const OrderItemCard({
    super.key,
    required this.trip,
    required this.onTap,
  });

  String _formatPrice(double price) {
    String priceStr = price.toInt().toString();
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String result = priceStr.replaceAllMapped(
      reg,
      (Match match) => '${match[1]}.',
    );
    return '$resultđ';
  }

  String _formatDate(DateTime date) {
    String pad(int v) => v.toString().padLeft(2, '0');
    return '${pad(date.day)}/${pad(date.month)}/${date.year}';
  }

  String _formatDateRange(DateTime start, DateTime end) {
    return '${_formatDate(start)} - ${_formatDate(end)}';
  }

  String _getLocationText(TripModel trip) {
    if (trip.deliveryAddress != null &&
        trip.deliveryAddress!.trim().isNotEmpty) {
      return trip.deliveryAddress!.trim();
    }
    if (trip.deliveryLocation != null &&
        trip.deliveryLocation!.trim().isNotEmpty) {
      return trip.deliveryLocation!.trim();
    }
    final carLoc = trip.car?.carLocation;
    if (carLoc != null) {
      final List<String> parts = [];
      if (carLoc.address != null && carLoc.address!.trim().isNotEmpty) {
        parts.add(carLoc.address!.trim());
      }
      if (carLoc.city != null && carLoc.city!.trim().isNotEmpty) {
        if (parts.isEmpty ||
            !parts.last.toLowerCase().contains(
              carLoc.city!.trim().toLowerCase(),
            )) {
          parts.add(carLoc.city!.trim());
        }
      }
      if (parts.isNotEmpty) {
        return parts.join(', ');
      }
      if (carLoc.location != null && carLoc.location!.trim().isNotEmpty) {
        return carLoc.location!.trim();
      }
    }
    return "TP. Hồ Chí Minh";
  }

  Widget _buildCarImageWidget(String? rawUrl) {
    const double size = 120.0;
    const String fallback = "https://picsum.photos/300/200";

    if (rawUrl == null || rawUrl.trim().isEmpty) {
      return Image.network(
        fallback,
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    }

    final url = rawUrl.trim();
    if (url.startsWith('assets/') || url.startsWith('lib/assets/')) {
      return Image.asset(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Image.network(
          fallback,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }

    String fullUrl = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      final base = (!kIsWeb && Platform.isAndroid)
          ? 'http://10.0.2.2:8000'
          : 'http://127.0.0.1:8000';
      fullUrl = url.startsWith('/') ? '$base$url' : '$base/$url';
    }

    return Image.network(
      fullUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) =>
          Image.network(fallback, width: size, height: size, fit: BoxFit.cover),
    );
  }

  @override
  Widget build(BuildContext context) {
    final carName = trip.car?.name ?? 'Chưa xác định';
    final imageUrl = trip.car?.getFirstImageUrl();
    final locationText = _getLocationText(trip);

    final statusBgColor = trip.getStatusBackgroundColor(context);
    final statusTextColor = trip.getStatusTextColor(context);

    final double netTotal = (trip.cost - trip.discountAmount) < 0
        ? 0.0
        : (trip.cost - trip.discountAmount);

    double actualPaid = trip.paidAmount;
    if (actualPaid == 0 && trip.status >= 2 && trip.status != 5 && trip.status != 6) {
      actualPaid = netTotal * 0.4;
    }

    final double ratio = netTotal > 0 ? (actualPaid / netTotal) : 0.0;
    final bool isDepositPaid = trip.status >= 2 && trip.status != 5 && trip.status != 6;
    final bool isFullPaid = isDepositPaid && ratio >= 0.9;

    String payLabel;
    String payValue;
    Color payColor;

    if (trip.status == 5 || trip.status == 6) {
      payLabel = 'Trạng thái: ';
      payValue = 'Đã hủy chuyến';
      payColor = context.error;
    } else if (!isDepositPaid) {
      payLabel = 'Thanh toán: ';
      payValue = 'Chưa cọc/thanh toán';
      payColor = context.textSecondary;
    } else if (isFullPaid) {
      payLabel = 'Đã thanh toán (100%): ';
      payValue = _formatPrice(actualPaid);
      payColor = context.success;
    } else {
      payLabel = 'Đã đặt cọc (40%): ';
      payValue = _formatPrice(actualPaid);
      payColor = context.success;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: context.isDarkMode
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: _buildCarImageWidget(imageUrl),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      carName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      trip.displayCode,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        trip.getStatusDisplay(),
                        style: TextStyle(
                          color: statusTextColor,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 15,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _formatDateRange(trip.startAt, trip.endAt),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            locationText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatPrice(netTotal),
                      style: TextStyle(
                        fontSize: 20,
                        color: context.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          payLabel,
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        Expanded(
                          child: Text(
                            payValue,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: payColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 30,
                child: OutlinedButton(
                  onPressed: onTap,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.primaryColor,
                    side: BorderSide(color: context.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                  ),
                  child: const Text(
                    "Xem chi tiết",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
