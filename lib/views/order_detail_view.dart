import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../themes/app_colors.dart';
import '../models/trip_model.dart';
import '../viewmodels/order_detail_viewmodel.dart';
import '../services/conversation_service.dart';
import '../services/trip_service.dart';
import '../models/conversation_model.dart';
import '../widgets/app_toast.dart';
import 'package:provider/provider.dart';
import '../components/payment/zalopay_checkout_sheet.dart';
import '../components/extension/extension_request_sheet.dart';
import '../components/extension/extension_payment_sheet.dart';

class OrderDetailView extends StatefulWidget {
  final int orderId;
  const OrderDetailView({super.key, required this.orderId});

  @override
  State<OrderDetailView> createState() => _OrderDetailViewState();
}

class _OrderDetailViewState extends State<OrderDetailView> {
  bool _isCreatingChat = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderDetailViewModel>().fetchTripDetail(widget.orderId);
    });
  }

  void _showZaloPayCheckoutSheet(TripModel trip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => ZaloPayCheckoutSheet(
        trip: trip,
        onPaymentSuccess: () {
          setState(() {
            trip.status = 2; // Đã xác nhận / Đã cọc
            trip.statusText = 'Đã cọc';
          });
          context.read<OrderDetailViewModel>().fetchTripDetail(widget.orderId);
        },
      ),
    );
  }

  void _showExtensionRequestSheet(TripModel trip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => ExtensionRequestSheet(
        trip: trip,
        onExtensionSuccess: () {
          context.read<OrderDetailViewModel>().fetchTripDetail(widget.orderId);
        },
      ),
    );
  }

  void _showExtensionPaymentSheet(TripModel trip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => ExtensionPaymentSheet(
        trip: trip,
        onPaymentSuccess: () {
          context.read<OrderDetailViewModel>().fetchTripDetail(widget.orderId);
        },
      ),
    );
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
    final diffMinutes = end.difference(start).inMinutes;
    final days = (diffMinutes / 1440).ceil();
    return days <= 0 ? 1 : days;
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
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go('/orders'),
          ),
          title: Text('Lỗi', style: TextStyle(color: Colors.white)),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                viewModel.errorMessage.isNotEmpty
                    ? viewModel.errorMessage
                    : 'Không tìm thấy đơn hàng.',
                style: TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => viewModel.fetchTripDetail(widget.orderId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: Text('Thử lại', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    final trip = viewModel.trip!;
    final car = trip.car;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.primary,
            pinned: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/orders');
                }
              },
            ),
            title: Text(
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
                      icon: Icon(
                        Icons.headset_mic_outlined,
                        color: Colors.white,
                      ),
                      onPressed: () => context.push('/support'),
                    ),
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.more_horiz, color: Colors.white),
                      onPressed: () => _showOptionBottomSheet(context, trip),
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
                        if (trip.latestExtension != null) ...[
                          const SizedBox(height: 20),
                          _buildExtensionBanner(trip),
                        ],
                        const SizedBox(height: 20),
                        if (car != null && car.owner != null)
                          _buildOwnerCard(trip, car.owner!),
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
          color: context.cardColor,
          border: Border(top: BorderSide(color: context.border, width: 0.5)),
        ),
        padding: EdgeInsets.only(
          left: 12,
          right: 12,
          top: 10,
          bottom: MediaQuery.of(context).padding.bottom + 10,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (trip.status == 1) ...[
              ElevatedButton.icon(
                onPressed: () => _showZaloPayCheckoutSheet(trip),
                icon: const Icon(Icons.payment, color: Colors.white),
                label: const Text(
                  'Thanh toán đặt cọc qua ZaloPay',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
              const SizedBox(height: 10),
            ],
            if (trip.status == 3 || trip.status == 7) ...[
              Row(
                children: [
                  Expanded(
                    child: trip.latestExtension?.status == 2
                        ? ElevatedButton.icon(
                            onPressed: () => _showExtensionPaymentSheet(trip),
                            icon: const Icon(Icons.credit_card, color: Colors.white, size: 16),
                            label: const Text(
                              'Thanh toán gia hạn',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade700,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          )
                        : (trip.latestExtension == null ||
                                trip.latestExtension!.status == 0)
                            ? ElevatedButton.icon(
                                onPressed: () => _showExtensionRequestSheet(trip),
                                icon: const Icon(Icons.more_time, color: Colors.white, size: 16),
                                label: const Text(
                                  'Gia hạn chuyến đi',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                              )
                            : const SizedBox.shrink(),
                  ),
                  if (trip.latestExtension?.status == 2 ||
                      trip.latestExtension == null ||
                      trip.latestExtension!.status == 0)
                    const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showReturnConfirmDialog(trip),
                      icon: const Icon(Icons.keyboard_return, color: Colors.white, size: 16),
                      label: const Text(
                        'Trả xe',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            _buildBottomActionButtons(trip),
          ],
        ),
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
      case 8: // Chờ trả xe
        statusBgColor = AppColors.success;
        break;
      case 7: // Chờ gia hạn
        statusBgColor = Colors.indigo;
        break;
      default:
        statusBgColor = AppColors.error;
    }

    final double netTotal = (trip.cost - trip.discountAmount) < 0
        ? 0.0
        : (trip.cost - trip.discountAmount);

    double actualPaid = trip.paidAmount;
    if (actualPaid == 0 &&
        trip.status >= 2 &&
        trip.status != 5 &&
        trip.status != 6) {
      actualPaid = netTotal * 0.4;
    }

    final double ratio = netTotal > 0 ? (actualPaid / netTotal) : 0.0;
    final bool isDepositPaid =
        trip.status >= 2 && trip.status != 5 && trip.status != 6;
    final bool isFullPaid = isDepositPaid && ratio >= 0.9;

    String depositStatusText;
    if (trip.status == 5 || trip.status == 6) {
      depositStatusText = 'Chuyến đi đã hủy';
    } else if (trip.status == 7) {
      depositStatusText = 'Đang chờ duyệt gia hạn';
    } else if (trip.status == 8) {
      depositStatusText = 'Chờ chủ xe nhận xe';
    } else if (!isDepositPaid) {
      depositStatusText = trip.status == 0
          ? 'Chờ chủ xe duyệt'
          : 'Chờ thanh toán cọc';
    } else if (isFullPaid) {
      depositStatusText = 'Đã thanh toán 100% (${_formatPrice(actualPaid)})';
    } else {
      depositStatusText = 'Đã đặt cọc 40% (${_formatPrice(actualPaid)})';
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
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#RT${trip.id}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Đặt ngày ${_formatDate(trip.startAt)}',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        _formatPrice(netTotal),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      depositStatusText,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
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
                      Expanded(
                        child: Text(
                          '${car.licensePlate} • $addressText',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: 14),
                      Text(
                        ' ${car.seatCount} chỗ  ',
                        style: TextStyle(fontSize: 13),
                      ),
                      Icon(Icons.autorenew, size: 14),
                      Text(
                        ' ${car.transmission ?? "Số tự động"}  ',
                        style: TextStyle(fontSize: 13),
                      ),
                      Icon(Icons.local_gas_station_outlined, size: 14),
                      Text(
                        ' ${car.fuelType ?? "Xăng"}',
                        style: TextStyle(fontSize: 13),
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

  Widget _buildOwnerCard(TripModel trip, OwnerModel owner) {
    String? avatarUrl = owner.avatar;
    if (avatarUrl != null &&
        avatarUrl.isNotEmpty &&
        !avatarUrl.startsWith('http')) {
      avatarUrl = 'http://10.0.2.2:8000/storage/$avatarUrl';
    }

    final bool isPaid = trip.status >= 2 && trip.status <= 4;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chủ xe',
            style: TextStyle(
              color: context.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              GestureDetector(
                onTap: () =>
                    context.push('/owner-profile/${owner.id}?isOwner=true'),
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                      ? NetworkImage(avatarUrl)
                      : null,
                  onBackgroundImageError:
                      (avatarUrl != null && avatarUrl.isNotEmpty)
                      ? (exception, stackTrace) {}
                      : null,
                  child: (avatarUrl == null || avatarUrl.isEmpty)
                      ? Icon(
                          Icons.person,
                          color: context.textSecondary,
                          size: 28,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      context.push('/owner-profile/${owner.id}?isOwner=true'),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        owner.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.star, color: AppColors.primary, size: 16),
                          Text(
                            ' 4.9 ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '(86 đánh giá)',
                            style: TextStyle(
                              color: context.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isPaid) ...[
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: IconButton(
                        icon: _isCreatingChat
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              )
                            : Icon(
                                Icons.chat_bubble_outline,
                                color: AppColors.primary,
                                size: 20,
                              ),
                        onPressed: _isCreatingChat
                            ? null
                            : () => _handleStartChat(trip, owner),
                        hoverColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.call,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      onPressed: () => _showPhoneDialog(owner),
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
    final startCity =
        (trip.deliveryAddress != null &&
            trip.deliveryAddress!.trim().isNotEmpty)
        ? trip.deliveryAddress!
        : (trip.car?.carLocation?.address ??
              trip.car?.carLocation?.city ??
              'TP. Hồ Chí Minh');
    final endCity =
        (trip.car?.carLocation?.address ??
        trip.car?.carLocation?.city ??
        'TP. Hồ Chí Minh');
    final rentalDays = _calculateDays(trip.startAt, trip.endAt);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thời gian & Địa điểm',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildTimeSubCol(
                  'Nhận xe',
                  _formatDate(trip.startAt),
                  _formatDateTime(trip.startAt),
                  startCity,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  const SizedBox(height: 12),
                  Text(
                    '$rentalDays ngày',
                    style: TextStyle(
                      color: context.textSecondary,
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
                      Container(width: 30, height: 1, color: AppColors.border),
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
              const SizedBox(width: 8),
              Expanded(
                child: _buildTimeSubCol(
                  'Trả xe',
                  _formatDate(trip.endAt),
                  _formatDateTime(trip.endAt),
                  endCity,
                ),
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
    final bool isStart = label == 'Nhận xe';
    return Column(
      crossAxisAlignment: isStart
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
              style: TextStyle(color: context.textSecondary, fontSize: 13),
            ),
          ],
        ),
        Text(date, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        Text(time, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Icon(
                Icons.location_on,
                size: 10,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                location,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: isStart ? TextAlign.left : TextAlign.right,
                style: TextStyle(color: context.textSecondary, fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceCard(TripModel trip) {
    final rentalDays = _calculateDays(trip.startAt, trip.endAt);
    final double unitPrice = (trip.car != null && trip.car!.unitPrice > 0)
        ? trip.car!.unitPrice
        : ((trip.cost - trip.deliveryFee) > 0
              ? (trip.cost - trip.deliveryFee) / rentalDays
              : trip.cost / rentalDays);
    final double rentalFee = unitPrice * rentalDays;
    final double netTotal = (trip.cost - trip.discountAmount) < 0
        ? 0.0
        : (trip.cost - trip.discountAmount);

    double actualPaid = trip.paidAmount;
    if (actualPaid == 0 &&
        trip.status >= 2 &&
        trip.status != 5 &&
        trip.status != 6) {
      actualPaid = netTotal * 0.4;
    }

    final double ratio = netTotal > 0 ? (actualPaid / netTotal) : 0.0;
    final bool isDepositPaid =
        trip.status >= 2 && trip.status != 5 && trip.status != 6;
    final bool isFullPaid = isDepositPaid && ratio >= 0.9;

    String paymentStatusText;
    if (trip.status == 5 || trip.status == 6) {
      paymentStatusText = 'Đã hủy chuyến';
    } else if (!isDepositPaid) {
      paymentStatusText = 'Chưa cọc/thanh toán';
    } else if (isFullPaid) {
      paymentStatusText = 'Đã thanh toán (100%) - ${_formatPrice(actualPaid)}';
    } else {
      paymentStatusText = 'Đã đặt cọc (40%) - ${_formatPrice(actualPaid)}';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin thanh toán',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          Divider(height: 24),
          _buildPriceRow(
            'Đơn giá thuê xe',
            '${_formatPrice(unitPrice)} / ${trip.tripType == 0 ? "ngày" : "km"}',
          ),
          _buildPriceRow('Số ngày thuê', '$rentalDays ngày'),
          _buildPriceRow('Tổng chi phí ban đầu', _formatPrice(rentalFee)),
          if (trip.deliveryFee > 0)
            _buildPriceRow('Phí giao xe', _formatPrice(trip.deliveryFee)),
          if (trip.discountAmount > 0)
            _buildPriceRow(
              'Số tiền được giảm giá',
              '-${_formatPrice(trip.discountAmount)}',
              isDiscount: true,
            ),
          if (trip.latestExtension != null &&
              trip.latestExtension!.status == 3) ...[
            _buildPriceRow(
              'Phí gia hạn xe (${trip.latestExtension!.extendedDays} ngày)',
              _formatPrice(trip.latestExtension!.extensionAmount),
            ),
          ],
          Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Thành tiền',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    _formatPrice(netTotal),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Trạng thái thanh toán',
                  style: TextStyle(color: context.textSecondary, fontSize: 13),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    paymentStatusText,
                    style: TextStyle(
                      color: isDepositPaid
                          ? AppColors.success
                          : context.textSecondary,
                      fontSize: 13,
                      fontWeight: isDepositPaid
                          ? FontWeight.bold
                          : FontWeight.normal,
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

  Widget _buildPriceRow(String label, String value, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label, style: TextStyle(color: context.textPrimary)),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                value,
                style: TextStyle(
                  color: isDiscount ? AppColors.success : context.textPrimary,
                  fontWeight: isDiscount ? FontWeight.bold : FontWeight.normal,
                ),
              ),
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

    final bool canCancel = trip.status >= 0 && trip.status < 3;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trạng thái đơn',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
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
          if (canCancel) ...[
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showCancelConfirmDialog(trip),
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(
                  Icons.cancel_outlined,
                  size: 18,
                  color: Colors.white,
                ),
                label: const Text(
                  'Hủy chuyến đi',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
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
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
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

  Widget _buildBottomActionButtons(TripModel trip) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionItem(
          Icons.assignment_outlined,
          'Biên bản\nnhận xe',
          onTap: () => _showPickupReportDialog(trip),
        ),
        _buildActionItem(
          Icons.assignment_turned_in_outlined,
          'Biên bản\ntrả xe',
          onTap: () => _showReturnReportDialog(trip),
        ),
        _buildActionItem(
          Icons.headset_mic_outlined,
          'Liên hệ\nhỗ trợ',
          onTap: () => context.push('/support'),
        ),
      ],
    );
  }

  Widget _buildActionItem(
    IconData icon,
    String label, {
    bool isDanger = false,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            border: Border.all(
              color: isDanger ? AppColors.error : AppColors.border,
            ),
            borderRadius: BorderRadius.circular(8),
            color: context.cardColor,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isDanger ? AppColors.error : context.textPrimary,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDanger ? AppColors.error : context.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleStartChat(TripModel trip, OwnerModel owner) async {
    if (_isCreatingChat) return;
    setState(() => _isCreatingChat = true);

    try {
      final conversationService = ConversationService();
      var conv = await conversationService.createConversation(
        receiverId: owner.id,
        tripId: trip.id,
        carId: trip.carId,
      );

      // Nếu API trả về otherUser có tên mặc định/trống hoặc ID = 0, đồng bộ lại từ thông tin của owner (chủ xe)
      if (conv.otherUser.id == 0 ||
          conv.otherUser.name == 'Người dùng' ||
          conv.otherUser.name.isEmpty) {
        conv = Conversation.raw(
          id: conv.id,
          status: conv.status,
          tripId: conv.tripId,
          createdAt: conv.createdAt,
          updatedAt: conv.updatedAt,
          otherUser: OtherUser(
            id: owner.id,
            name: owner.name,
            avatar: owner.avatar,
          ),
          car: conv.car,
          lastMessageObj: conv.lastMessageObj,
          unreadCount: conv.unreadCount,
        );
      }

      if (!mounted) return;
      context.push('/chat/${conv.id}', extra: conv);
    } catch (e) {
      if (!mounted) return;
      AppToast.show(
        context,
        message: 'Không thể tạo đoạn chat: $e',
        type: ToastType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isCreatingChat = false);
      }
    }
  }

  void _showPhoneDialog(OwnerModel owner) {
    final phone = (owner.phone != null && owner.phone!.isNotEmpty)
        ? owner.phone!
        : 'Chưa cập nhật số điện thoại';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.call, color: AppColors.primary),
            SizedBox(width: 8),
            Text(
              'Số điện thoại chủ xe',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chủ xe: ${owner.name}',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.phone_android, color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SelectableText(
                      phone,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Đóng', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showCancelConfirmDialog(TripModel trip) {
    bool isCancelling = false;

    final bookingTime = trip.createdAt ?? DateTime.now();
    final startTime = trip.startAt;
    final now = DateTime.now();

    final tripValue = (trip.cost - trip.discountAmount) < 0
        ? 0.0
        : (trip.cost - trip.discountAmount);

    double totalPaid = trip.paidAmount;
    if (totalPaid == 0 &&
        trip.status >= 2 &&
        trip.status != 5 &&
        trip.status != 6) {
      totalPaid = tripValue * 0.4;
    }

    double feePercent = 0.0;
    String policyDesc = 'Miễn phí hủy chuyến (Trong vòng 1h sau khi đặt xe)';

    final diffInMinutes = now.difference(bookingTime).inMinutes.abs();
    if (diffInMinutes > 60) {
      final diffInDays = startTime.difference(now).inHours / 24.0;
      if (diffInDays >= 7) {
        feePercent = 0.10;
        policyDesc =
            'Phí hủy 10% giá trị chuyến đi (Trước chuyến đi >= 7 ngày và sau 1h khi đặt)';
      } else {
        feePercent = 0.40;
        policyDesc =
            'Phí hủy 40% giá trị chuyến đi (Trong vòng 7 ngày trước chuyến đi và sau 1h khi đặt)';
      }
    }

    final double cancelFeeAmount = tripValue * feePercent;
    final double actualCompensation = totalPaid < cancelFeeAmount
        ? totalPaid
        : cancelFeeAmount;
    final double actualRefund = (totalPaid - actualCompensation) < 0
        ? 0.0
        : (totalPaid - actualCompensation);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: AppColors.error),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Xác nhận hủy chuyến đi',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bạn có chắc chắn muốn hủy chuyến đi #RT${trip.id} này không? Quyết định này không thể hoàn tác.',
                  style: TextStyle(fontSize: 13, color: context.textSecondary),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    children: [
                      _buildCancelPolicyRow(
                        'Chính sách áp dụng:',
                        policyDesc,
                        isBoldValue: true,
                      ),
                      const SizedBox(height: 6),
                      _buildCancelPolicyRow(
                        'Giá trị chuyến đi:',
                        _formatPrice(tripValue),
                      ),
                      const SizedBox(height: 6),
                      _buildCancelPolicyRow(
                        'Số tiền đã thanh toán:',
                        _formatPrice(totalPaid),
                      ),
                      const SizedBox(height: 6),
                      _buildCancelPolicyRow(
                        'Phí hủy chuyến:',
                        _formatPrice(cancelFeeAmount),
                        isDanger: true,
                      ),
                      const Divider(height: 16),
                      _buildCancelPolicyRow(
                        'Tiền hoàn khách thuê:',
                        _formatPrice(actualRefund),
                        isSuccess: true,
                      ),
                      if (actualCompensation > 0) ...[
                        const SizedBox(height: 6),
                        _buildCancelPolicyRow(
                          'Bồi thường chủ xe:',
                          _formatPrice(actualCompensation),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '* Tiền hoàn sẽ được chuyển trực tiếp vào ví điện tử ngay sau khi xác nhận hủy.',
                  style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isCancelling ? null : () => Navigator.pop(context),
              child: Text(
                'Quay lại',
                style: TextStyle(color: context.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: isCancelling
                  ? null
                  : () async {
                      final currentContext = context;
                      final nav = Navigator.of(currentContext);
                      final viewModel = currentContext
                          .read<OrderDetailViewModel>();

                      setDialogState(() => isCancelling = true);
                      final result = await TripService().cancelTrip(trip.id);
                      if (!mounted) return;
                      nav.pop();

                      if (currentContext.mounted) {
                        if (result['success'] == true) {
                          AppToast.show(
                            currentContext,
                            message:
                                result['message'] ??
                                'Đã hủy chuyến đi thành công!',
                            type: ToastType.success,
                          );
                          viewModel.fetchTripDetail(trip.id);
                        } else {
                          AppToast.show(
                            currentContext,
                            message:
                                result['message'] ?? 'Không thể hủy chuyến!',
                            type: ToastType.error,
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isCancelling
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Xác nhận hủy',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelPolicyRow(
    String label,
    String value, {
    bool isBoldValue = false,
    bool isDanger = false,
    bool isSuccess = false,
  }) {
    Color valColor = AppColors.primary;
    if (isDanger) valColor = AppColors.error;
    if (isSuccess) valColor = AppColors.success;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12,
              fontWeight: (isBoldValue || isSuccess || isDanger)
                  ? FontWeight.bold
                  : FontWeight.w500,
              color: (isSuccess || isDanger) ? valColor : Colors.grey.shade900,
            ),
          ),
        ),
      ],
    );
  }

  void _showOptionBottomSheet(BuildContext context, TripModel trip) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.headset_mic_outlined,
                color: AppColors.primary,
              ),
              title: Text('Liên hệ trung tâm hỗ trợ'),
              onTap: () {
                Navigator.pop(context);
                context.push('/support');
              },
            ),
            ListTile(
              leading: Icon(Icons.article_outlined, color: AppColors.primary),
              title: Text('Chính sách & Quy định thuê xe'),
              onTap: () {
                Navigator.pop(context);
                context.push('/policy');
              },
            ),
            if (trip.car?.owner != null)
              ListTile(
                leading: Icon(Icons.person_outline, color: AppColors.primary),
                title: Text('Xem hồ sơ chủ xe'),
                onTap: () {
                  Navigator.pop(context);
                  context.push(
                    '/owner-profile/${trip.car!.owner!.id}?isOwner=true',
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showPickupReportDialog(TripModel trip) {
    final car = trip.car;
    final addressText =
        car?.carLocation?.address ??
        car?.carLocation?.city ??
        'Điểm hẹn giao xe';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).padding.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Biên bản nhận xe',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Divider(height: 20),
            _buildReportDetailRow('Mã đơn hàng:', '#RT${trip.id}'),
            _buildReportDetailRow('Tên xe:', car?.name ?? 'Xe tự lái'),
            _buildReportDetailRow('Biển số xe:', car?.licensePlate ?? 'N/A'),
            _buildReportDetailRow(
              'Thời gian nhận:',
              '${_formatDate(trip.startAt)} ${_formatDateTime(trip.startAt)}',
            ),
            _buildReportDetailRow('Địa điểm nhận:', addressText),
            _buildReportDetailRow(
              'Tình trạng xe:',
              'Xe đã vệ sinh sạch sẻ, đầy đủ giấy tờ',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Quý khách vui lòng quay video/chụp ảnh ngoại thất xe khi làm thủ tục nhận xe.',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Đã hiểu',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReturnReportDialog(TripModel trip) {
    final car = trip.car;
    final addressText =
        car?.carLocation?.address ??
        car?.carLocation?.city ??
        'Điểm hẹn trả xe';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).padding.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Biên bản trả xe',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Divider(height: 20),
            _buildReportDetailRow('Mã đơn hàng:', '#RT${trip.id}'),
            _buildReportDetailRow('Tên xe:', car?.name ?? 'Xe tự lái'),
            _buildReportDetailRow('Biển số xe:', car?.licensePlate ?? 'N/A'),
            _buildReportDetailRow(
              'Thời gian trả:',
              '${_formatDate(trip.endAt)} ${_formatDateTime(trip.endAt)}',
            ),
            _buildReportDetailRow('Địa điểm trả:', addressText),
            _buildReportDetailRow(
              'Hạng mục bàn giao:',
              'Chìa khóa xe, Đăng ký xe, Bảo hiểm',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: const [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.amber,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Vui lòng dọn dẹp hành lý cá nhân và kiểm tra bình nhiên liệu trước khi bàn giao lại chìa khóa.',
                      style: TextStyle(fontSize: 12, color: Colors.brown),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Đã hiểu',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(color: context.textSecondary, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExtensionBanner(TripModel trip) {
    final ext = trip.latestExtension;
    if (ext == null) return const SizedBox.shrink();

    final isDark = context.isDarkMode;

    if (ext.status == 1 || trip.status == 7) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2538) : const Color(0xFFEEF2F6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.indigo.shade800 : Colors.indigo.shade100,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              color: isDark ? Colors.indigo.shade300 : Colors.indigo.shade700,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Đang chờ chủ xe duyệt gia hạn',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Yêu cầu gia hạn thêm ngày đang chờ chủ xe phê duyệt.',
                    style: TextStyle(
                      fontSize: 11,
                      color: context.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'HẠN TRẢ MỚI',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: context.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              ext.endDate != null
                                  ? _formatDate(
                                      DateTime.tryParse(ext.endDate!) ??
                                          DateTime.now(),
                                    )
                                  : '--',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: context.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PHÍ GIA HẠN DỰ KIẾN',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: context.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatPrice(ext.extensionAmount),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (ext.status == 2) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF332517) : const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.amber.shade900 : Colors.amber.shade200,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info,
              color: isDark ? Colors.amber.shade400 : Colors.amber.shade600,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Yêu cầu gia hạn đã được phê duyệt',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Chủ xe đã đồng ý yêu cầu gia hạn của bạn. Vui lòng nhấn nút thanh toán phía dưới cùng để hoàn tất.',
                    style: TextStyle(
                      fontSize: 11,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (ext.status == 3) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1B5E20) : const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.green.shade800 : Colors.green.shade200,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: isDark ? Colors.green.shade300 : Colors.green.shade600,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Đã gia hạn thành công đến ${_formatDate(DateTime.tryParse(ext.endDate ?? '') ?? trip.endAt)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.green.shade100 : Colors.green.shade800,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (ext.status == 4) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF3B1E1E) : const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.red.shade800 : Colors.red.shade200,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.cancel,
              color: isDark ? Colors.red.shade400 : Colors.red.shade600,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Yêu cầu gia hạn trước đó đã bị từ chối/hủy',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.red.shade200 : Colors.red.shade800,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _showReturnConfirmDialog(TripModel trip) {
    bool isSubmitting = false;
    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 8),
              Text('Trả xe sớm'),
            ],
          ),
          content: const Text(
            'Bạn có chắc chắn muốn gửi yêu cầu trả xe sớm không?\n\nYêu cầu này sẽ cần được chủ xe phê duyệt để hoàn thành chuyến đi.',
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(dialogCtx),
              child: Text(
                'Hủy',
                style: TextStyle(color: context.textSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final currentContext = this.context;
                      final nav = Navigator.of(dialogCtx);
                      final viewModel = currentContext.read<OrderDetailViewModel>();

                      setDialogState(() => isSubmitting = true);
                      final result = await TripService().requestReturn(trip.id);
                      nav.pop(); // Close dialog

                      if (!mounted) return;
                      if (currentContext.mounted) {
                        if (result['success'] == true) {
                          AppToast.show(
                            currentContext,
                            message: 'Gửi yêu cầu trả xe thành công!',
                            type: ToastType.success,
                          );
                          viewModel.fetchTripDetail(trip.id);
                        } else {
                          AppToast.show(
                            currentContext,
                            message: result['message'] ?? 'Gửi yêu cầu trả xe thất bại.',
                            type: ToastType.error,
                          );
                        }
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Đồng ý trả xe',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
