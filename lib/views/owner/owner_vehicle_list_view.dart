import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:duantotnghiep_app_thue_xe/models/car_model.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/owner_vehicle_viewmodel.dart';
import 'package:duantotnghiep_app_thue_xe/providers/auth_provider.dart';

class OwnerVehicleListView extends StatefulWidget {
  const OwnerVehicleListView({super.key});

  @override
  State<OwnerVehicleListView> createState() => _OwnerVehicleListViewState();
}

class _OwnerVehicleListViewState extends State<OwnerVehicleListView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabTitles = [
    'Tất cả',
    'Hoạt động',
    'Chờ duyệt',
    'Dừng hoạt động',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabTitles.length, vsync: this);
    _tabController.addListener(_handleTabSelection);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshVehicles();
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
    setState(() {});
  }

  void _refreshVehicles() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;
    if (user != null) {
      context.read<OwnerVehicleViewModel>().fetchOwnerCars(user.id);
    }
  }

  List<Car> _getCarsForCurrentTab(OwnerVehicleViewModel viewModel) {
    switch (_tabController.index) {
      case 1:
        return viewModel.activeCars;
      case 2:
        return viewModel.pendingCars;
      case 3:
        return viewModel.lockedCars;
      case 0:
      default:
        return viewModel.cars;
    }
  }

  String _formatPrice(num price) {
    final value = price.toInt();
    final formatted = value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
    return '$formattedđ';
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OwnerVehicleViewModel>();
    final cars = _getCarsForCurrentTab(viewModel);

    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/owner-dashboard');
            }
          },
        ),
        title: Text(
          'Xe của tôi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: context.textPrimary),
            onPressed: _refreshVehicles,
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
            child: Container(
              color: context.scaffoldBackgroundColor,
              child: TabBar(
                controller: _tabController,
                isScrollable: false,
                indicator: BoxDecoration(
                  color: context.primaryColor,
                  borderRadius: BorderRadius.circular(30),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: context.textSecondary,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12.5,
                ),
                tabs: _tabTitles.map((title) => Tab(text: title)).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Main list
          Expanded(
            child: viewModel.isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      _refreshVehicles();
                    },
                    child: cars.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            itemCount: cars.length,
                            itemBuilder: (context, index) {
                              return _buildCarCard(cars[index]);
                            },
                          ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/register-car'),
        backgroundColor: context.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Đăng ký xe mới',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.directions_car_outlined,
                size: 64,
                color: context.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Không tìm thấy chiếc xe nào',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bạn chưa có xe trong danh mục này hoặc chưa đăng ký chiếc xe nào lên hệ thống.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: context.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/register-car'),
              icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white),
              label: const Text('Đăng ký xe ngay'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarCard(Car car) {
    final String imageUrl = car.images.isNotEmpty
        ? car.images.firstWhere((img) => img.isThumbnail, orElse: () => car.images.first).imageUrl
        : 'https://via.placeholder.com/600x300';

    // Status Badge Info
    Color badgeColor;
    Color badgeTextColor;
    String statusText;

    switch (car.status) {
      case 0:
        badgeColor = context.isDarkMode ? Colors.grey.shade800 : const Color(0xFFF3F4F6);
        badgeTextColor = context.textSecondary;
        statusText = 'Dừng hoạt động';
        break;
      case 1:
        badgeColor = context.successSurface;
        badgeTextColor = context.success;
        statusText = 'Hoạt động';
        break;
      case 2:
        badgeColor = context.warningSurface;
        badgeTextColor = context.warning;
        statusText = 'Chờ duyệt';
        break;
      case 3:
        badgeColor = context.errorSurface;
        badgeTextColor = context.error;
        statusText = 'Bị từ chối';
        break;
      default:
        badgeColor = Colors.grey.withValues(alpha: 0.15);
        badgeTextColor = Colors.grey;
        statusText = 'Chưa xác định';
    }

    final isAuto = car.transmission.toLowerCase().contains("tự động") ||
        car.transmission.toLowerCase().contains("auto");

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section: Image & Badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.network(
                  imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 150,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: badgeTextColor.withValues(alpha: 0.3), width: 0.8),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: badgeTextColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Section: Details
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        car.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatPrice(car.unitPrice),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: context.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: context.isDarkMode ? Colors.grey.shade800 : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        car.licensePlate,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: context.textSecondary,
                        ),
                      ),
                    ),
                    Text(
                      '/ ngày',
                      style: TextStyle(
                        fontSize: 11,
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: context.border, height: 1),
                const SizedBox(height: 12),

                // Specifications
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.airline_seat_recline_normal, size: 16, color: context.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '${car.seatCount} chỗ',
                          style: TextStyle(fontSize: 12, color: context.textSecondary),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(isAuto ? Icons.autorenew_outlined : Icons.settings, size: 16, color: context.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          isAuto ? 'Số tự động' : 'Số sàn',
                          style: TextStyle(fontSize: 12, color: context.textSecondary),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.local_gas_station_outlined, size: 16, color: context.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          car.fuelType == 'gasoline'
                              ? 'Xăng'
                              : car.fuelType == 'diesel'
                                  ? 'Dầu'
                                  : car.fuelType == 'electric'
                                      ? 'Điện'
                                      : car.fuelType == 'hybrid'
                                          ? 'Hybrid'
                                          : car.fuelType,
                          style: TextStyle(fontSize: 12, color: context.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Divider(color: context.border, height: 1),
                const SizedBox(height: 12),

                // Ratings & Trip count
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 3),
                        Text(
                          car.reviewsAvgRating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                        Text(
                          ' • ${car.tripsCount} chuyến',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Button Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          context.push('/car_detail/${car.id}');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.primaryColor,
                          side: BorderSide(color: context.primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Chi tiết xe',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await context.push('/edit-car/${car.id}');
                          _refreshVehicles();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Chỉnh sửa',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
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
}
