import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';

class SupportView extends StatefulWidget {
  const SupportView({super.key});

  @override
  State<SupportView> createState() => _SupportViewState();
}

class _SupportViewState extends State<SupportView> {
  int _currentGuideIndex = 0;
  final CarouselSliderController _carouselController = CarouselSliderController();

  final List<Map<String, dynamic>> _guides = [
    {
      'title': 'Hướng dẫn đặt xe',
      'category': 'Dành cho khách thuê',
      'description': 'Quy trình tìm kiếm xe phù hợp, đặt xe và giao nhận xe từ chủ xe.',
      'image': 'lib/assets/images/onboarding/slide1.png',
      'color': const Color(0xFFE2F3F0),
      'steps': [
        'Tìm xe: Chọn thời gian và địa điểm mong muốn để tìm những xe sẵn có.',
        'Đặt xe: Gửi yêu cầu đặt xe và chờ chủ xe phê duyệt (thường dưới 30 phút).',
        'Đặt cọc: Thanh toán tiền cọc 30% qua ví hoặc cổng thanh toán của Drivio.',
        'Nhận xe: Kiểm tra kỹ hiện trạng xe, chụp ảnh check-in và ký biên bản bàn giao xe.',
        'Trả xe: Trả xe đúng giờ, vệ sinh sạch sẽ và hoàn tất thủ tục bàn giao.'
      ]
    },
    {
      'title': 'Hướng dẫn dành cho chủ xe',
      'category': 'Dành cho chủ xe',
      'description': 'Đăng ký xe dễ dàng, quản lý lịch thuê và bắt đầu gia tăng thu nhập từ xe nhàn rỗi.',
      'image': 'lib/assets/images/onboarding/slide2.png',
      'color': const Color(0xFFFEE3CE),
      'steps': [
        'Đăng ký xe: Điền thông tin chi tiết về đời xe, tính năng, phụ phí và tải ảnh xe rõ nét.',
        'Quản lý lịch: Cập nhật lịch bận/rỗi của xe để tránh tình trạng trùng lịch.',
        'Duyệt yêu cầu: Phản hồi nhanh các yêu cầu thuê từ khách hàng để cải thiện tỷ lệ phản hồi.',
        'Giao xe: Kiểm tra giấy phép lái xe của khách hàng, ghi nhận mức nhiên liệu và bàn giao chìa khóa.',
        'Nhận lại xe & Đánh giá: Kiểm tra tình trạng xe khi nhận lại và gửi đánh giá khách hàng.'
      ]
    },
    {
      'title': 'Chính sách hủy chuyến & đền bù',
      'category': 'Quy định chung',
      'description': 'Thông tin chi tiết về các mốc thời gian hủy chuyến và hoàn trả tiền đặt cọc.',
      'image': 'lib/assets/images/onboarding/slide3.png',
      'color': const Color(0xFFE3EDF7),
      'steps': [
        'Hủy chuyến miễn phí: Thực hiện hủy trong vòng 1 giờ sau khi cọc (nếu cách giờ nhận xe trên 24h).',
        'Hủy trước 24h: Khách hàng được hoàn trả 100% tiền đặt cọc.',
        'Hủy dưới 24h: Khách hàng bị phạt 30% tiền đặt cọc (chuyển cho chủ xe làm phí đền bù).',
        'Sự cố phát sinh: Liên hệ hotline 1900 9217 ngay lập tức nếu gặp sự cố giao nhận xe.'
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8F6F4),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Banner Block
            Container(
              color: const Color(0xFFE8F6F4),
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  const Text(
                    'Trung tâm hỗ trợ nhanh',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Background Circle
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                        ),
                        // Support Icon
                        const Icon(
                          Icons.support_agent_rounded,
                          size: 96,
                          color: AppColors.primary,
                        ),
                        // Speech Bubble Left
                        Positioned(
                          left: -12,
                          top: 20,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                              ],
                            ),
                            child: const Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 20,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        // Question Mark Right
                        Positioned(
                          right: -12,
                          top: 30,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                              ],
                            ),
                            child: const Icon(
                              Icons.question_mark_rounded,
                              size: 20,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Quick Support Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Cần hỗ trợ nhanh, vui lòng gọi 1900 9217 (7AM - 10PM) hoặc gửi tin nhắn vào Drivio Fanpage.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đang kết nối cuộc gọi tới 1900 9217...')),
                            );
                          },
                          icon: const Icon(Icons.phone_outlined, color: AppColors.primary, size: 20),
                          label: const Text(
                            'Gọi điện',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primary, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đang mở Drivio Fanpage...')),
                            );
                          },
                          icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 20),
                          label: const Text(
                            'Gửi tin nhắn',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF52C48E),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Feedback Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF4FBF9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBFE5DF), width: 1.5),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFD0F0EA),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.thumb_up_alt_outlined,
                      color: Color(0xFF1E705F),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Góp ý cùng Drivio',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1E705F),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ý kiến của bạn sẽ giúp chúng tôi cải thiện chất lượng dịch vụ tốt hơn mỗi ngày.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Cảm ơn bạn đã phản hồi! Form góp ý đang phát triển.')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF42B883),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Bắt đầu', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Hotline Insurance Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Hotline bảo hiểm',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildInsuranceCard('MIC', '1900 558891'),
                  _buildInsuranceCard('PVI', '1900 545458'),
                  _buildInsuranceCard('DBV', '1900 6484'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Guides Section Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Hướng dẫn',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Carousel Guides
            Column(
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
                  items: _guides.map((guide) {
                    return Builder(
                      builder: (BuildContext context) {
                        return GestureDetector(
                          onTap: () {
                            context.push('/support-detail', extra: {
                              'title': guide['title'],
                              'content': guide['description'],
                              'imageUrl': guide['image'],
                              'steps': guide['steps'],
                            });
                          },
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
                                              color: AppColors.primary.withValues(alpha: 0.8),
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            guide['title'],
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            guide['description'],
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: AppColors.textSecondary.withValues(alpha: 0.9),
                                              height: 1.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Row(
                                        children: [
                                          Text(
                                            'Xem chi tiết',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            size: 11,
                                            color: AppColors.primary,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Decorative icon/illustration at bottom right
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
                                      color: AppColors.primary,
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

                // Indicator dots
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _guides.asMap().entries.map((entry) {
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
                          color: isActive ? AppColors.primary : Colors.grey.shade300,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // AI Chatbot Banner
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFEE3CE), width: 1.5),
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
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chatbot',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Giải đáp thắc mắc, hỗ trợ thông tin & hướng dẫn quy trình 24/7 cùng AI chatbot.',
                              style: TextStyle(
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
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Info Section Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Thông tin',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Grid View for Info Items
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.35,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildInfoItem(Icons.business_rounded, 'Thông tin công ty'),
                _buildInfoItem(Icons.gavel_rounded, 'Chính sách và quy định'),
                _buildInfoItem(Icons.star_outline_rounded, 'Đánh giá Drivio'),
                _buildInfoItem(Icons.facebook_rounded, 'Facebook Fanpage'),
                _buildInfoItem(Icons.help_center_rounded, 'Hỏi và trả lời'),
                _buildInfoItem(Icons.assignment_rounded, 'Quy chế hoạt động'),
                _buildInfoItem(Icons.lock_rounded, 'Bảo mật thông tin'),
                _buildInfoItem(Icons.handshake_rounded, 'Giải quyết tranh chấp'),
              ],
            ),

            const SizedBox(height: 32),

            // Footer Version Details
            const Center(
              child: Text(
                'Phiên bản 5.2.7 (707)',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInsuranceCard(String name, String phone) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 12, bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đang gọi tổng đài bảo hiểm $name ($phone)...')),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                phone,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đang mở trang: $title')),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primary, size: 28),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
