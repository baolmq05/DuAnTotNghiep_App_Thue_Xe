import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../themes/app_colors.dart';

class OrderDetailView extends StatelessWidget {
  const OrderDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // header có màu xanh đâm bên trên
          SliverAppBar(
            backgroundColor: AppColors.primary,
            pinned: true, // giữ header luôn hiển thị khi cuộn
            leading: IconButton(
              // nut back
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.go('/'),
            ),
            title: const Text(
              'Chi tiết đơn hàng',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min, // cho các nút nằm sát nhau
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.headset_mic_outlined,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      constraints:
                          const BoxConstraints(), // xóa bỏ mặc định của pd của icon
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.more_horiz, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),

          // nội dung chính của trang chi tiết đơn hàng
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildHeaderStatus(),
                Transform.translate(
                  offset: const Offset(
                    0,
                    -30,
                  ), // Kéo toàn bộ cả cụm card lên 30dp
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        // chiều cao của các card
                        _buildCarCard(),
                        const SizedBox(height: 20),
                        _buildOwnerCard(),
                        const SizedBox(height: 20),
                        _buildTimeCard(),
                        const SizedBox(height: 20),
                        _buildPriceCard(),
                        const SizedBox(height: 20),
                        _buildStatusTimeline(),
                        // const SizedBox(height: 24),
                        // _buildBottomActionButtons(),
                        // const SizedBox(height: 40),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        // padding cho nút ở dưới cùng, thêm MediaQuery.of(context).padding.bottom để tránh bị che bởi thanh điều hướng của điện thoại
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border(
            top: BorderSide(color: Colors.grey.shade200, width: 0.5),
          ),
        ),
        padding: EdgeInsets.only(
          left: 12,
          right: 12,
          top: 10,
          bottom: MediaQuery.of(context).padding.bottom + 10, // thêm khoảng cách dưới cùng để tránh bị che bởi thanh điều hướng của điện thoại
        ),
        child: _buildBottomActionButtons(),
      ),
    );
  }

  // header trạng thái đơn hàng
  Widget _buildHeaderStatus() {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(20, 5, 20, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Text(
              'Đang thuê',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment
                .spaceBetween, // chia ra để đều 2 cột trái phải
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '#RT123456',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Đặt ngày 10/06/2024 - 10:30',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    '2.000.000đ',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'Đặt cọc: 2.000.000đ',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // card thông tin xe
  Widget _buildCarCard() {
    return Card(
      margin: EdgeInsets.zero,
      color: AppColors.card,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                'https://picsum.photos/100/70',
                width: 90,
                height: 65,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Toyota Corolla Cross 2023',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                      const Text(
                        '51K-123.45 • Trắng',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: const [
                      Icon(Icons.person_outline, size: 14),
                      Text(' 5 chỗ  ', style: TextStyle(fontSize: 13)),
                      Icon(Icons.autorenew, size: 14),
                      Text(' Số tự động  ', style: TextStyle(fontSize: 13)),
                      Icon(Icons.local_gas_station_outlined, size: 14),
                      Text(' Xăng', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 15,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  // card thông tin chủ xe
  Widget _buildOwnerCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chủ xe',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage('https://picsum.photos/100'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nguyễn Minh Đức',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: AppColors.primary,
                          size: 16,
                        ),
                        const Text(
                          ' 4.9 ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '(86 đánh giá)',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // nút chat
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.chat_bubble_outline,
                        color: AppColors.primary,
                      ),
                      onPressed: () {},
                      // xóa bỏ hover, splash, highlight để tránh màu nền khi bấm
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                    ),
                  ),
                  const SizedBox(width: 10),

                  // nút gọi
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.call, color: AppColors.primary),
                      onPressed: () {},
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // card thời gian thuê
  Widget _buildTimeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thời gian thuê',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimeSubCol(
                'Nhận xe',
                'T7, 22/06/2024',
                '09:00',
                'TP. Hồ Chí Minh',
              ),
              Column(
                children: [
                  Text(
                    '2 ngày',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(width: 40, height: 1, color: AppColors.border),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              _buildTimeSubCol(
                'Trả xe',
                'T2, 24/06/2024',
                '09:00',
                'TP. Hồ Chí Minh',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // cột cho tg thuê
  Widget _buildTimeSubCol(
    String label,
    String date,
    String time,
    String location,
  ) {
    return Column(
      // căn chỉnh các cột trái phải theo label
      crossAxisAlignment: label == 'Nhận xe'
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.access_time, size: 10, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
        Text(
          date,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(
          time,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on, size: 10, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              location,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  // card chi tiết giá
  Widget _buildPriceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chi phí',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Divider(height: 24), // đươpng kẻ ngang
          _buildPriceRow('Tiền thuê xe (2 ngày x 700.000đ)', '1.400.000đ'),
          _buildPriceRow('Phí giao xe', '100.000đ'),
          _buildPriceRow('Phí vệ sinh', '100.000đ'),
          _buildPriceRow('Khuyến mãi', '-100.000đ', isDiscount: true),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng cộng',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
              Text(
                '2.000.000đ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Đã thanh toán (đặt cọc)',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              Text(
                '2.000.000đ',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // hàng chi tiết giá
  Widget _buildPriceRow(String label, String value, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4.0,
      ), // khoảng cách các hàng
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.textPrimary)),
          Text(
            value,
            style: TextStyle(
              color: isDiscount ? AppColors.success : AppColors.textPrimary,
              fontWeight: isDiscount ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // timeline trạng thái đơn hàng
  Widget _buildStatusTimeline() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trạng thái đơn ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                // mỗi bước chiếm 1 phần bằng nhau
                child: _buildTimelineStep(
                  icon: Icons.account_balance_wallet,
                  title: 'Đặt cọc',
                  time: '10/06 10:30',
                  isDone: true,
                  showLeftLine: false,
                  showRightLine: true,
                ),
              ),
              Expanded(
                child: _buildTimelineStep(
                  icon: Icons.check,
                  title: 'Chủ xe xác nhận',
                  time: '10/06 11:15',
                  isDone: true,
                  showLeftLine: true,
                  showRightLine: true,
                ),
              ),
              Expanded(
                child: _buildTimelineStep(
                  icon: Icons.directions_car,
                  title: 'Nhận xe',
                  time: '22/06 09:00',
                  isDone: true,
                  showLeftLine: true,
                  showRightLine: true,
                ),
              ),
              Expanded(
                child: _buildTimelineStep(
                  icon: Icons.car_rental,
                  title: 'Trả xe',
                  time: '--',
                  isDone: false,
                  showLeftLine: true,
                  showRightLine: true,
                ),
              ),
              Expanded(
                child: _buildTimelineStep(
                  icon: Icons.assignment_turned_in,
                  title: 'Hoàn tất',
                  time: '--',
                  isDone: false,
                  showLeftLine: true,
                  showRightLine: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // hàm tái sử  dụng cho timeline dùng để tạo từng bước trong timeline
  Widget _buildTimelineStep({
    required IconData icon,
    required String title,
    required String time,
    required bool isDone,
    required bool showLeftLine,
    required bool showRightLine,
  }) {
    final Color color = isDone ? AppColors.primary : Colors.grey.shade300;

    return Column(
      children: [
        SizedBox(
          height: 28,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 2,
                  color: showLeftLine ? color : Colors.transparent,
                ),
              ),

              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                child: Icon(icon, color: Colors.white, size: 14),
              ),

              Expanded(
                child: Container(
                  height: 2,
                  color: showRightLine ? color : Colors.transparent,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 6),
        SizedBox(
          height: 30,
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        const SizedBox(height: 2),
        Text(
          time,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  //  nút nút hỗ trợ sự cố
  Widget _buildBottomActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionItem(Icons.assignment_outlined, 'Biên bản\nnhận xe'),
        _buildActionItem(
          Icons.assignment_turned_in_outlined,
          'Biên bản\ntrả xe',
        ),
        _buildActionItem(Icons.headset_mic_outlined, 'Liên hệ\nhỗ trợ'),
        _buildActionItem(
          Icons.gpp_bad_outlined,
          'Báo cáo\nsự cố',
          isDanger: true,
        ),
      ],
    );
  }

  // hàm tái sử dụng cho các nút hành động ở dưới cùng, có thể là "Biên bản nhận xe", "Biên bản trả xe", "Liên hệ hỗ trợ", "Báo cáo sự cố"
  Widget _buildActionItem(
    IconData icon,
    String label, {
    bool isDanger = false,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDanger ? AppColors.error : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(8),
          color: AppColors.card,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isDanger ? AppColors.error : AppColors.textPrimary,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10, // Giảm nhẹ size chữ từ 11 xuống 10 để an toàn hơn
                color: isDanger ? AppColors.error : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
