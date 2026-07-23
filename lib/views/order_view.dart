import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import 'package:go_router/go_router.dart';
import '../models/trip_model.dart';
import '../viewmodels/order_viewmodel.dart';
import 'package:provider/provider.dart';

class OrderView extends StatefulWidget {
  const OrderView({super.key});

  @override
  State<OrderView> createState() => _OrderViewState();
}

class _OrderViewState extends State<OrderView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _tabController.addListener(_handleTabSelection);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderViewModel>().fetchTrips();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) return;
    context.read<OrderViewModel>().filterTrips(_tabController.index);
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
        errorBuilder: (_, __, ___) => Image.network(
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
      errorBuilder: (_, __, ___) =>
          Image.network(fallback, width: size, height: size, fit: BoxFit.cover),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OrderViewModel>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: false,
        title: const Text(
          'Đơn hàng của bạn',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(30),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
                tabAlignment: TabAlignment.start,
                tabs: const [
                  Tab(text: "Tất cả"),
                  Tab(text: "Chờ duyệt"),
                  Tab(text: "Chờ thanh toán"),
                  Tab(text: "Đang di chuyển"),
                  Tab(text: "Hoàn tất"),
                  Tab(text: "Chủ xe hủy"),
                  Tab(text: "Người thuê hủy"),
                ],
              ),
            ),
          ),
          Expanded(
            child: viewModel.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : viewModel.errorMessage.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          viewModel.errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => viewModel.fetchTrips(),
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
                  )
                : viewModel.filteredTrips.isEmpty
                ? const Center(
                    child: Text(
                      'Không tìm thấy đơn hàng nào.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async => viewModel.fetchTrips(),
                    color: AppColors.primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: viewModel.filteredTrips.length,
                      itemBuilder: (context, index) {
                        return _buildOrderItem(viewModel.filteredTrips[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(TripModel trip) {
    final carName = trip.car?.name ?? 'Chưa xác định';
    final imageUrl = trip.car?.getFirstImageUrl();
    final locationText = _getLocationText(trip);

    // Xử lý màu sắc cho trạng thái
    Color statusBgColor;
    Color statusTextColor;
    switch (trip.status) {
      case 0: // Chờ duyệt
        statusBgColor = const Color(0xffFFF3E0);
        statusTextColor = const Color(0xffF57C00);
        break;
      case 1: // Chờ thanh toán
        statusBgColor = const Color(0xffE3F2FD);
        statusTextColor = const Color(0xff1976D2);
        break;
      case 2: // Đã xác nhận / Chưa bắt đầu
      case 3: // Đang di chuyển
        statusBgColor = const Color(0xffE8F5E9);
        statusTextColor = const Color(0xff388E3C);
        break;
      case 4: // Hoàn tất
        statusBgColor = const Color(0xffE8F5E9);
        statusTextColor = const Color(0xff388E3C);
        break;
      case 5: // Người thuê hủy
      case 6: // Chủ xe hủy
        statusBgColor = const Color(0xffFFEBEE);
        statusTextColor = const Color(0xffD32F2F);
        break;
      default:
        statusBgColor = Colors.grey.shade200;
        statusTextColor = Colors.grey.shade800;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
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
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          "#RT${trip.id}",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusBgColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            trip.getStatusDisplay(),
                            style: TextStyle(
                              color: statusTextColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
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
                      _formatPrice(trip.cost),
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        const Text(
                          "Đặt cọc: ",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        Text(
                          _formatPrice(trip.cost),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
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
                  onPressed: () {
                    context.go('/order-detail/${trip.id}');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
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
