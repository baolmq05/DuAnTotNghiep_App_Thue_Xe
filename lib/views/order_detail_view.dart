import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../themes/app_colors.dart';
import '../models/trip_model.dart';
import '../viewmodels/order_detail_viewmodel.dart';
import 'package:provider/provider.dart';

class OrderDetailView extends StatefulWidget {
  final int orderId;
  const OrderDetailView({super.key, required this.orderId});

  @override
  State<OrderDetailView> createState() => _OrderDetailViewState();
}

class _OrderDetailViewState extends State<OrderDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderDetailViewModel>().fetchTripDetail(widget.orderId);
    });
  }

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
    const weekdays = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    String pad(int v) => v.toString().padLeft(2, '0');
    final weekdayStr = weekdays[date.weekday % 7];
    return '$weekdayStr, ${pad(date.day)}/${pad(date.month)}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    String pad(int v) => v.toString().padLeft(2, '0');
    return '${pad(date.hour)}:${pad(date.minute)}';
  }

  int _calculateDays(DateTime start, DateTime end) {
    final difference = end.difference(start).inDays;
    return difference <= 0 ? 1 : difference;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OrderDetailViewModel>();

    if (viewModel.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (viewModel.errorMessage.isNotEmpty || viewModel.trip == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go('/orders'),
          ),
          title: const Text('Lỗi', style: TextStyle(color: Colors.white)),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                viewModel.errorMessage.isNotEmpty
                    ? viewModel.errorMessage
                    : 'Không tìm thấy đơn hàng.',
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => viewModel.fetchTripDetail(widget.orderId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text(
                  'Thử lại',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final trip = viewModel.trip!;
    final car = trip.car;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.primary,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.go('/orders'),
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.headset_mic_outlined,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.more_horiz, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildHeaderStatus(trip),
                Transform.translate(
                  offset: const Offset(0, -30),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        if (car != null) _buildCarCard(car),
                        const SizedBox(height: 20),
                        if (car != null && car.owner != null)
                          _buildOwnerCard(car.owner!),
                        const SizedBox(height: 20),
                        _buildTimeCard(trip),
                        const SizedBox(height: 20),
                        _buildPriceCard(trip),
                        const SizedBox(height: 20),
                        _buildStatusTimeline(trip),
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
          bottom: MediaQuery.of(context).padding.bottom + 10,
        ),
        child: _buildBottomActionButtons(),
      ),
    );
  }

  Widget _buildHeaderStatus(TripModel trip) {
    Color statusBgColor;
    switch (trip.status) {
      case 0:
        statusBgColor = Colors.orange;
        break;
      case 1:
        statusBgColor = Colors.blue;
        break;
      case 2:
      case 3:
      case 4:
        statusBgColor = AppColors.success;
        break;
      default:
        statusBgColor = AppColors.error;
    }

    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(20, 5, 20, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              trip.getStatusDisplay(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#RT${trip.id}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Đặt ngày ${_formatDate(trip.startAt)}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatPrice(trip.cost),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'Đặt cọc: ${_formatPrice(trip.cost)}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCarCard(CarModel car) {
    final imageUrl = car.getFirstImageUrl();
    final addressText =
        car.carLocation?.address ?? car.carLocation?.city ?? 'TP. Hồ Chí Minh';

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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
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

  Widget _buildOwnerCard(OwnerModel owner) {
    final avatarUrl = owner.avatar ?? 'https://picsum.photos/100';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chủ xe',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(avatarUrl),
                onBackgroundImageError: (exception, stackTrace) {},
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      owner.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                    ),
                  ),
                  const SizedBox(width: 10),
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

  Widget _buildTimeCard(TripModel trip) {
    final startCity = trip.car?.carLocation?.city ?? 'TP. Hồ Chí Minh';
    final endCity = trip.car?.carLocation?.city ?? 'TP. Hồ Chí Minh';
    final rentalDays = _calculateDays(trip.startAt, trip.endAt);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
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
                _formatDate(trip.startAt),
                _formatDateTime(trip.startAt),
                startCity,
              ),
              Column(
                children: [
                  Text(
                    '$rentalDays ngày',
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
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(width: 40, height: 1, color: AppColors.border),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
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
                _formatDate(trip.endAt),
                _formatDateTime(trip.endAt),
                endCity,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSubCol(
    String label,
    String date,
    String time,
    String location,
  ) {
    return Column(
      crossAxisAlignment: label == 'Nhận xe'
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.access_time, size: 10, color: AppColors.primary),
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
            const Icon(Icons.location_on, size: 10, color: AppColors.primary),
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

  Widget _buildPriceCard(TripModel trip) {
    final rentalDays = _calculateDays(trip.startAt, trip.endAt);
    final subtotal = trip.cost + trip.discountAmount;
    final unitPrice = subtotal / rentalDays;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chi phí',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Divider(height: 24),
          _buildPriceRow(
            'Tiền thuê xe ($rentalDays ngày x ${_formatPrice(unitPrice)})',
            _formatPrice(subtotal),
          ),
          _buildPriceRow('Phí giao xe', _formatPrice(0)),
          _buildPriceRow('Phí vệ sinh', _formatPrice(0)),
          if (trip.discountAmount > 0)
            _buildPriceRow(
              'Khuyến mãi',
              '-${_formatPrice(trip.discountAmount)}',
              isDiscount: true,
            ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng cộng',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
              Text(
                _formatPrice(trip.cost),
                style: const TextStyle(
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
              const Text(
                'Đã thanh toán (đặt cọc)',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              Text(
                _formatPrice(trip.cost),
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textPrimary)),
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

  Widget _buildStatusTimeline(TripModel trip) {
    final isStep1 = trip.status >= 0;
    final isStep2 = trip.status >= 1;
    final isStep3 = trip.status >= 2;
    final isStep4 = trip.status >= 3;
    final isStep5 = trip.status == 4;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
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
                child: _buildTimelineStep(
                  icon: Icons.assignment_outlined,
                  title: 'Đăng ký thuê',
                  time: isStep1 ? _formatDateTime(trip.startAt) : '--',
                  isDone: isStep1,
                  showLeftLine: false,
                  showRightLine: true,
                ),
              ),
              Expanded(
                child: _buildTimelineStep(
                  icon: Icons.account_balance_wallet,
                  title: 'Đặt cọc',
                  time: isStep2 ? 'Đã cọc' : '--',
                  isDone: isStep2,
                  showLeftLine: true,
                  showRightLine: true,
                ),
              ),
              Expanded(
                child: _buildTimelineStep(
                  icon: Icons.check,
                  title: 'Xác nhận',
                  time: isStep3 ? 'Thành công' : '--',
                  isDone: isStep3,
                  showLeftLine: true,
                  showRightLine: true,
                ),
              ),
              Expanded(
                child: _buildTimelineStep(
                  icon: Icons.directions_car,
                  title: 'Nhận xe',
                  time: isStep4 ? _formatDateTime(trip.startAt) : '--',
                  isDone: isStep4,
                  showLeftLine: true,
                  showRightLine: true,
                ),
              ),
              Expanded(
                child: _buildTimelineStep(
                  icon: Icons.assignment_turned_in,
                  title: 'Hoàn tất',
                  time: isStep5 ? 'Đã xong' : '--',
                  isDone: isStep5,
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
            style: const TextStyle(
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
                fontSize: 10,
                color: isDanger ? AppColors.error : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
