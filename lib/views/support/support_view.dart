import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:duantotnghiep_app_thue_xe/widgets/app_toast.dart';

class SupportView extends StatefulWidget {
  const SupportView({super.key});

  @override
  State<SupportView> createState() => _SupportViewState();
}

class _SupportViewState extends State<SupportView> {
  final List<Map<String, dynamic>> _guides = [
    {
      'title': 'Hướng dẫn dành cho khách thuê xe',
      'category': 'Khách thuê xe',
      'icon': Icons.car_rental_rounded,
      'description':
          'Quy trình 5 bước từ tìm kiếm xe, đặt cọc đến nhận và hoàn trả xe an toàn.',
      'image': 'lib/assets/images/onboarding/slide1.png',
      'steps': [
        '1. Tìm kiếm xe: Nhập địa điểm, thời gian thuê và lọc xe theo tiêu chí (giá, loại xe, số chỗ).',
        '2. Gửi yêu cầu: Chọn chiếc xe phù hợp và gửi yêu cầu đặt xe tới chủ xe.',
        '3. Đặt cọc chuyến đi: Thanh toán tiền cọc 30% qua ZaloPay hoặc ví Drivio khi chủ xe duyệt đơn.',
        '4. Nhận xe & Check-in: Kiểm tra giấy tờ, tình trạng xe thực tế, chụp ảnh check-in và ký biên bản bàn giao.',
        '5. Trả xe & Đánh giá: Trả xe đúng giờ, vệ sinh sạch sẽ, thanh toán chi phí phát sinh (nếu có) và đánh giá chuyến đi.',
      ],
    },
    {
      'title': 'Hướng dẫn dành cho chủ xe cho thuê',
      'category': 'Chủ xe',
      'icon': Icons.drive_eta_rounded,
      'description':
          'Đăng ký xe nhàn rỗi, quản lý lịch thuê và tối ưu hóa doanh thu cùng nền tảng Drivio.',
      'image': 'lib/assets/images/onboarding/slide2.png',
      'steps': [
        '1. Đăng ký xe: Điền thông tin chi tiết (biển số, đời xe, giá thuê, phụ phí) và tải ảnh xe rõ nét.',
        '2. Chờ phê duyệt: Quản trị viên Drivio sẽ duyệt thông tin và giấy tờ xe trong vòng 24h làm việc.',
        '3. Tiếp nhận yêu cầu: Phản hồi nhanh chóng các yêu cầu đặt xe từ khách hàng để tăng uy tín.',
        '4. Giao nhận xe: Kiểm tra bằng lái xe của khách, ghi nhận số km & mức nhiên liệu khi bàn giao.',
        '5. Hoàn tất chuyến: Nhận lại xe, kiểm tra tình trạng và nhận tiền thanh toán chuyển thẳng vào ví Drivio.',
      ],
    },
    {
      'title': 'Chính sách đặt cọc, hủy chuyến & đền bù',
      'category': 'Quy định chung',
      'icon': Icons.shield_outlined,
      'description':
          'Quy định về thời hạn giữ cọc, hoàn tiền khi hủy chuyến và đảm bảo quyền lợi đôi bên.',
      'image': 'lib/assets/images/onboarding/slide3.png',
      'steps': [
        '1. Hủy trong vòng 1 giờ sau khi cọc: Được hoàn trả 100% tiền đặt cọc (nếu cách giờ nhận xe trên 24h).',
        '2. Hủy trước 24 giờ nhận xe: Hoàn trả 100% tiền cọc về ví tài khoản khách thuê.',
        '3. Hủy dưới 24 giờ trước nhận xe: Phí hủy là 30% tiền cọc (chuyển cho chủ xe để bù đắp chi phí giữ xe).',
        '4. Chủ xe hủy đơn: Chủ xe bị trừ điểm uy tín và chịu phạt theo quy chế hoạt động của nền tảng.',
        '5. Sự cố phát sinh: Liên hệ ngay hotline 1900 9217 để được nhân viên Drivio hỗ trợ xử lý kịp thời.',
      ],
    },
  ];

  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(' ', '');
    final Uri launchUri = Uri(scheme: 'tel', path: cleanNumber);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        if (mounted) {
          AppToast.show(
            context,
            message: 'Không thể mở trình gọi điện. Hotline: $phoneNumber',
            type: ToastType.info,
          );
        }
      }
    } catch (_) {
      if (mounted) {
        AppToast.show(
          context,
          message: 'Hotline hỗ trợ: $phoneNumber',
          type: ToastType.info,
        );
      }
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(scheme: 'mailto', path: email);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        if (mounted) {
          AppToast.show(
            context,
            message: 'Email hỗ trợ: $email',
            type: ToastType.info,
          );
        }
      }
    } catch (_) {
      if (mounted) {
        AppToast.show(
          context,
          message: 'Email hỗ trợ: $email',
          type: ToastType.info,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.textPrimary, size: 20),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profile');
            }
          },
        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HERO CONTACT CARD (Thanh lịch, tối giản)
            _buildHeroContactCard(context),
            const SizedBox(height: 20),

            // 2. KÊNH HỖ TRỢ TRỰC TIẾP
            _buildSectionTitle(context, 'Kênh hỗ trợ trực tiếp'),
            const SizedBox(height: 10),
            _buildDirectContactList(context),
            const SizedBox(height: 24),

            // 3. HƯỚNG DẪN & CẨM NANG SỬ DỤNG
            _buildSectionTitle(context, 'Hướng dẫn & Quy trình'),
            const SizedBox(height: 10),
            _buildGuidesList(context),
            const SizedBox(height: 24),

            // 4. ĐIỀU KHOẢN & PHÁP LÝ (Có trang thật trong app)
            _buildSectionTitle(context, 'Điều khoản & Pháp lý'),
            const SizedBox(height: 10),
            _buildLegalSection(context),
            const SizedBox(height: 24),

            // 5. THÔNG TIN DOANH NGHIỆP (Static text, không có nút bấm giả)
            _buildCompanyInfoCard(context),
            const SizedBox(height: 24),

            // Footer Version
            Center(
              child: Text(
                'Drivio Mobile Application • Phiên bản 1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: context.textSecondary.withValues(alpha: 0.7),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15.5,
        fontWeight: FontWeight.bold,
        color: context.textPrimary,
      ),
    );
  }

  // 1. HERO CONTACT CARD
  Widget _buildHeroContactCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.headset_mic_rounded,
                  color: context.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Drivio Customer Care',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Đội ngũ hỗ trợ luôn sẵn sàng đồng hành cùng bạn',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _makePhoneCall('1900 9217'),
                  icon: const Icon(Icons.phone_rounded, color: Colors.white, size: 18),
                  label: const Text(
                    'Gọi 1900 9217',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/chat/chatbot'),
                  icon: Icon(Icons.smart_toy_outlined, color: context.primaryColor, size: 18),
                  label: Text(
                    'Trợ lý AI 24/7',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: context.primaryColor,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: context.primaryColor, width: 1.2),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. KÊNH LIÊN HỆ TRỰC TIẾP
  Widget _buildDirectContactList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.border, width: 0.8),
      ),
      child: Column(
        children: [
          _buildContactTile(
            context,
            icon: Icons.phone_in_talk_outlined,
            title: 'Tổng đài chăm sóc khách hàng',
            subtitle: '1900 9217 (08:00 - 22:00 hàng ngày)',
            actionText: 'Gọi ngay',
            onTap: () => _makePhoneCall('1900 9217'),
            showDivider: true,
          ),
          _buildContactTile(
            context,
            icon: Icons.email_outlined,
            title: 'Hộp thư điện tử hỗ trợ',
            subtitle: 'support@drivio.vn (Phản hồi trong 24h)',
            actionText: 'Gửi thư',
            onTap: () => _sendEmail('support@drivio.vn'),
            showDivider: true,
          ),
          _buildContactTile(
            context,
            icon: Icons.forum_outlined,
            title: 'Trò chuyện cùng AI Assistant',
            subtitle: 'Tư vấn giải đáp thủ tục & bảng giá 24/7',
            actionText: 'Mở chat',
            onTap: () => context.push('/chat/chatbot'),
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onTap,
    required bool showDivider,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Icon(icon, color: context.primaryColor, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: context.primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    actionText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: context.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(height: 1, thickness: 0.8, color: context.border, indent: 48),
      ],
    );
  }

  // 3. HƯỚNG DẪN & CẨM NANG
  Widget _buildGuidesList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.border, width: 0.8),
      ),
      child: Column(
        children: _guides.asMap().entries.map((entry) {
          final index = entry.key;
          final guide = entry.value;
          final isLast = index == _guides.length - 1;

          return Column(
            children: [
              InkWell(
                onTap: () {
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
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: context.primaryColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          guide['icon'] as IconData,
                          color: context.primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              guide['title'] as String,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: context.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              guide['description'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: context.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: context.textSecondary.withValues(alpha: 0.6),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                Divider(height: 1, thickness: 0.8, color: context.border, indent: 48),
            ],
          );
        }).toList(),
      ),
    );
  }

  // 5. ĐIỀU KHOẢN & PHÁP LÝ (Có trang thật trong app)
  Widget _buildLegalSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.border, width: 0.8),
      ),
      child: Column(
        children: [
          _buildNavTile(
            context,
            icon: Icons.gavel_rounded,
            title: 'Quy chế hoạt động & Điều khoản dịch vụ',
            subtitle: 'Quy định quyền và trách nhiệm của khách hàng & chủ xe',
            onTap: () => context.push('/policy'),
            showDivider: true,
          ),
          _buildNavTile(
            context,
            icon: Icons.security_rounded,
            title: 'Chính sách bảo mật quyền riêng tư',
            subtitle: 'Bảo mật thông tin thanh toán và dữ liệu cá nhân',
            onTap: () => context.push('/privacy-policy'),
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool showDivider,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Icon(icon, color: context.primaryColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right_rounded,
                  color: context.textSecondary.withValues(alpha: 0.6),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(height: 1, thickness: 0.8, color: context.border, indent: 44),
      ],
    );
  }

  // 6. THÔNG TIN DOANH NGHIỆP (Static text thanh lịch, không có nút bấm giả)
  Widget _buildCompanyInfoCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.isDarkMode
            ? context.cardColor
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.business_rounded, color: context.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Thông tin đơn vị vận hành',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(context, 'Đơn vị', 'Công ty Cổ phần Công nghệ Drivio Việt Nam'),
          const SizedBox(height: 6),
          _buildInfoRow(context, 'Giấy phép ĐKKD', '0317892176 do Sở KH&ĐT TP.HCM cấp'),
          const SizedBox(height: 6),
          _buildInfoRow(context, 'Trụ sở', 'Công viên Phần mềm Quang Trung, Q.12, TP.HCM'),
          const SizedBox(height: 6),
          _buildInfoRow(context, 'Giờ làm việc', '08:00 - 22:00 (Thứ 2 - Chủ Nhật)'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: context.textSecondary,
            ),
          ),
        ),
        const Text(': ', style: TextStyle(fontSize: 12, color: Colors.grey)),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: context.textPrimary,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
