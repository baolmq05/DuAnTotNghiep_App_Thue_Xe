import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';

// Components
import 'package:duantotnghiep_app_thue_xe/components/support_components/support_quick_card.dart';
import 'package:duantotnghiep_app_thue_xe/components/support_components/support_feedback_card.dart';
import 'package:duantotnghiep_app_thue_xe/components/support_components/support_insurance_row.dart';
import 'package:duantotnghiep_app_thue_xe/components/support_components/support_guides_carousel.dart';
import 'package:duantotnghiep_app_thue_xe/components/support_components/support_info_grid.dart';

class SupportView extends StatefulWidget {
  const SupportView({super.key});

  @override
  State<SupportView> createState() => _SupportViewState();
}

class _SupportViewState extends State<SupportView> {
  final List<Map<String, dynamic>> _guides = [
    {
      'title': 'Hướng dẫn đặt xe',
      'category': 'Dành cho khách thuê',
      'description':
          'Quy trình tìm kiếm xe phù hợp, đặt xe và giao nhận xe từ chủ xe.',
      'image': 'lib/assets/images/onboarding/slide1.png',
      'color': const Color(0xFFE2F3F0),
      'steps': [
        'Tìm xe: Chọn thời gian và địa điểm mong muốn để tìm những xe sẵn có.',
        'Đặt xe: Gửi yêu cầu đặt xe và chờ chủ xe phê duyệt (thường dưới 30 phút).',
        'Đặt cọc: Thanh toán tiền cọc 30% qua ví hoặc cổng thanh toán của Drivio.',
        'Nhận xe: Kiểm tra kỹ hiện trạng xe, chụp ảnh check-in và ký biên bản bàn giao xe.',
        'Trả xe: Trả xe đúng giờ, vệ sinh sạch sẽ và hoàn tất thủ tục bàn giao.',
      ],
    },
    {
      'title': 'Hướng dẫn dành cho chủ xe',
      'category': 'Dành cho chủ xe',
      'description':
          'Đăng ký xe dễ dàng, quản lý lịch thuê và bắt đầu gia tăng thu nhập từ xe nhàn rỗi.',
      'image': 'lib/assets/images/onboarding/slide2.png',
      'color': const Color(0xFFFEE3CE),
      'steps': [
        'Đăng ký xe: Điền thông tin chi tiết về đời xe, tính năng, phụ phí và tải ảnh xe rõ nét.',
        'Quản lý lịch: Cập nhật lịch bận/rỗi của xe để tránh tình trạng trùng lịch.',
        'Duyệt yêu cầu: Phản hồi nhanh các yêu cầu thuê từ khách hàng để cải thiện tỷ lệ phản hồi.',
        'Giao xe: Kiểm tra giấy phép lái xe của khách hàng, ghi nhận mức nhiên liệu và bàn giao chìa khóa.',
        'Nhận lại xe & Đánh giá: Kiểm tra tình trạng xe khi nhận lại và gửi đánh giá khách hàng.',
      ],
    },
    {
      'title': 'Chính sách hủy chuyến & đền bù',
      'category': 'Quy định chung',
      'description':
          'Thông tin chi tiết về các mốc thời gian hủy chuyến và hoàn trả tiền đặt cọc.',
      'image': 'lib/assets/images/onboarding/slide3.png',
      'color': const Color(0xFFE3EDF7),
      'steps': [
        'Hủy chuyến miễn phí: Thực hiện hủy trong vòng 1 giờ sau khi cọc (nếu cách giờ nhận xe trên 24h).',
        'Hủy trước 24h: Khách hàng được hoàn trả 100% tiền đặt cọc.',
        'Hủy dưới 24h: Khách hàng bị phạt 30% tiền đặt cọc (chuyển cho chủ xe làm phí đền bù).',
        'Sự cố phát sinh: Liên hệ hotline 1900 9217 ngay lập tức nếu gặp sự cố giao nhận xe.',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Trung tâm hỗ trợ',
          style: TextStyle(
            color: context.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            SupportQuickCard(
              onCall: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đang kết nối cuộc gọi tới 1900 9217...'),
                  ),
                );
              },
              onMessage: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đang mở Drivio Fanpage...'),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            SupportFeedbackCard(
              onStartFeedback: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cảm ơn bạn đã phản hồi! Form góp ý đang phát triển.'),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Hotline bảo hiểm',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SupportInsuranceRow(
              onCallInsurance: (name, phone) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đang gọi tổng đài bảo hiểm $name ($phone)...'),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Hướng dẫn',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SupportGuidesCarousel(
              guides: _guides,
              onGuideTap: (guide) {
                context.push(
                  '/support-detail',
                  extra: {
                    'title': guide['title'],
                    'content': guide['description'],
                    'imageUrl': guide['image'],
                    'steps': guide['steps'],
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: context.isDarkMode
                      ? context.border
                      : const Color(0xFFFEE3CE),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () {
                  context.push('/chat/chatbot');
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: AppColors.accentSurface,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.smart_toy_rounded,
                          color: AppColors.secondary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chatbot',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: context.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Giải đáp thắc mắc, hỗ trợ thông tin & hướng dẫn quy trình 24/7 cùng AI chatbot.',
                              style: TextStyle(
                                fontSize: 12,
                                color: context.textSecondary,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Thông tin',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SupportInfoGrid(
              onInfoItemTap: (title) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đang mở trang: $title')),
                );
              },
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                'Phiên bản 5.2.7 (707)',
                style: TextStyle(fontSize: 12, color: context.textSecondary),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
