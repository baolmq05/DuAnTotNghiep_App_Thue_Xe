import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OwnerRegisterPromoView extends StatelessWidget {
  const OwnerRegisterPromoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(
          'Đăng ký Chủ xe',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: context.primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.time_to_leave_rounded,
                          size: 46,
                          color: context.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Trở thành Chủ xe Drivio',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tạo thêm nguồn thu nhập hấp dẫn từ chiếc xe nhàn rỗi của bạn với chính sách bảo vệ & bảo hiểm toàn diện từ Drivio.',
                        style: TextStyle(
                          fontSize: 13,
                          color: context.textSecondary,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),

                      _buildBenefitRow(
                        context,
                        icon: Icons.monetization_on_outlined,
                        title: 'Thu nhập thụ động cao',
                        description: 'Tối ưu hóa lợi nhuận từ chiếc xe nhàn rỗi hằng tháng.',
                      ),
                      const SizedBox(height: 14),
                      _buildBenefitRow(
                        context,
                        icon: Icons.shield_outlined,
                        title: 'An tâm tuyệt đối',
                        description: 'Xác thực danh tính khách thuê & bảo hiểm đầy đủ.',
                      ),
                      const SizedBox(height: 14),
                      _buildBenefitRow(
                        context,
                        icon: Icons.tune_outlined,
                        title: 'Chủ động 100%',
                        description: 'Dễ dàng quản lý lịch cho thuê & thiết lập giá linh hoạt.',
                      ),
                    ],
                  ),
                ),
              ),

              // Button đăng ký xe ngay
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/register-car');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Đăng ký cho thuê xe ngay',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: context.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: context.primaryColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
