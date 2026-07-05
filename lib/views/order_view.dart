import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import 'package:go_router/go_router.dart';
import '../models/trip_model.dart';
import '../services/trip_service.dart';

class OrderView extends StatefulWidget {
  const OrderView({super.key});

  @override
  State<OrderView> createState() => _OrderViewState();
}

class _OrderViewState extends State<OrderView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TripService _tripService = TripService();
  List<TripModel> _allTrips = [];
  List<TripModel> _filteredTrips = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _fetchTrips();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) return;
    _filterTrips();
  }

  void _fetchTrips() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final trips = await _tripService.getMyTrips();
      setState(() {
        _allTrips = trips;
        _isLoading = false;
      });
      _filterTrips();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Không thể tải danh sách đơn hàng. Vui lòng thử lại!';
      });
    }
  }

  void _filterTrips() {
    int index = _tabController.index;
    setState(() {
      if (index == 0) {
        _filteredTrips = _allTrips;
      } else {
        int targetStatus = 0;
        bool isMultiStatus = false;
        List<int> statuses = [];
        switch (index) {
          case 1: // Chờ duyệt
            targetStatus = 0; // Pending
            break;
          case 2: // Chờ thanh toán
            targetStatus = 1; // WaitingPayment
            break;
          case 3: // Đang di chuyển / Đang thuê
            isMultiStatus = true;
            statuses = [2, 3]; // Confirmed, Ongoing
            break;
          case 4: // Hoàn tất
            targetStatus = 4; // Complete
            break;
          case 5: // Chủ xe hủy
            targetStatus = 6; // OwnerCancel
            break;
          case 6: // Người thuê hủy
            targetStatus = 5; // UserCancel
            break;
        }
        if (isMultiStatus) {
          _filteredTrips = _allTrips.where((trip) => statuses.contains(trip.status)).toList();
        } else {
          _filteredTrips = _allTrips.where((trip) => trip.status == targetStatus).toList();
        }
      }
    });
  }

  String _formatPrice(double price) {
    String priceStr = price.toInt().toString();
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String result = priceStr.replaceAllMapped(reg, (Match match) => '${match[1]}.');
    return '$resultđ';
  }

  String _formatDate(DateTime date) {
    String pad(int v) => v.toString().padLeft(2, '0');
    return '${pad(date.day)}/${pad(date.month)}/${date.year}';
  }

  String _formatDateRange(DateTime start, DateTime end) {
    return '${_formatDate(start)} - ${_formatDate(end)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: false,
        title: const Text(
          'Đơn hàng của bạn',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_errorMessage, style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _fetchTrips,
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                              child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      )
                    : _filteredTrips.isEmpty
                        ? const Center(
                            child: Text(
                              'Không tìm thấy đơn hàng nào.',
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async => _fetchTrips(),
                            color: AppColors.primary,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredTrips.length,
                              itemBuilder: (context, index) {
                                return _buildOrderItem(_filteredTrips[index]);
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
    final imageUrl = trip.car?.getFirstImageUrl() ?? "https://picsum.photos/300/200";
    final locationText = trip.car?.carLocation?.address ?? trip.car?.carLocation?.city ?? "TP. Hồ Chí Minh";
    
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
                child: Image.network(
                  imageUrl,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.network(
                    "https://picsum.photos/300/200",
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
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
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
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
