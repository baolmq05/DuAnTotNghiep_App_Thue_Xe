import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/promotion_model.dart';
import '../../themes/app_colors.dart';
import 'promotion_tile.dart';

class PromotionDetailDialog extends StatelessWidget {
  final Promotion promotion;

  const PromotionDetailDialog({super.key, required this.promotion});

  static Future<void> show(BuildContext context, Promotion promotion) {
    return showDialog(
      context: context,
      builder: (context) => PromotionDetailDialog(promotion: promotion),
    );
  }

  String get discountText {
    if (promotion.discountType == "0") {
      return "Giảm ${promotion.discountValue.toInt()}%";
    }

    final money = promotion.discountValue.toInt().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );

    return "Giảm $moneyđ";
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: promotion.code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Đã sao chép mã "${promotion.code}" vào bộ nhớ tạm'),
            ),
          ],
        ),
        backgroundColor: context.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = promotion.images.isNotEmpty
        ? promotion.images.first.imageUrl
        : "https://via.placeholder.com/600x300";

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Banner Image & Close Button
              Stack(
                children: [
                  Image.network(
                    imageUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 160,
                      color: Colors.grey.shade300,
                      child: Icon(
                        Icons.local_offer,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withValues(alpha: 0.5),
                      radius: 16,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                ],
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Discount Tag & Code Badge
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: context.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: context.primaryColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            discountText,
                            style: TextStyle(
                              color: context.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentSurface,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Mã: ${promotion.code}',
                            style: TextStyle(
                              color: context.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Title
                    Text(
                      promotion.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Description
                    Text(
                      promotion.description.isNotEmpty
                          ? promotion.description
                          : 'Không có mô tả chi tiết.',
                      style: TextStyle(
                        fontSize: 14,
                        color: context.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 12),

                    // Details: Validity & Limits
                    if (promotion.startDate.isNotEmpty ||
                        promotion.endDate.isNotEmpty)
                      _buildDetailRow(
                        context,
                        icon: Icons.calendar_today_outlined,
                        label: 'Thời gian:',
                        value: '${promotion.startDate} - ${promotion.endDate}',
                      ),
                    if (promotion.usageLimit > 0) ...[
                      const SizedBox(height: 6),
                      _buildDetailRow(
                        context,
                        icon: Icons.confirmation_number_outlined,
                        label: 'Lượt dùng còn lại:',
                        value: '${promotion.usageLimit} lượt',
                      ),
                    ],
                    if (promotion.perUserLimit > 0) ...[
                      const SizedBox(height: 6),
                      _buildDetailRow(
                        context,
                        icon: Icons.person_outline,
                        label: 'Lượt dùng/khách:',
                        value: '${promotion.perUserLimit} lần',
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _copyToClipboard(context),
                            icon: Icon(Icons.copy, size: 18),
                            label: Text('Sao chép mã'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: context.primaryColor,
                              side: BorderSide(color: context.primaryColor),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text('Đóng'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: context.textSecondary),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 13, color: context.textSecondary),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class PromotionsListDialog extends StatelessWidget {
  final List<Promotion> promotions;

  const PromotionsListDialog({super.key, required this.promotions});

  static Future<void> show(BuildContext context, List<Promotion> promotions) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PromotionsListDialog(promotions: promotions),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Chương trình ưu đãi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // List
          Expanded(
            child: promotions.isEmpty
                ? Center(
                    child: Text(
                      'Không có khuyến mãi nào',
                      style: TextStyle(color: context.textSecondary),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: promotions.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final promo = promotions[index];
                      return PromotionTile(
                        promotion: promo,
                        onTap: () {
                          Navigator.of(context).pop();
                          PromotionDetailDialog.show(context, promo);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
