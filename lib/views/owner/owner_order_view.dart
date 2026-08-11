import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/owner_order_viewmodel.dart';
import 'package:provider/provider.dart';

// Components
import 'package:duantotnghiep_app_thue_xe/components/order_components/order_item_card.dart';

class OwnerOrderView extends StatefulWidget {
  const OwnerOrderView({super.key});

  @override
  State<OwnerOrderView> createState() => _OwnerOrderViewState();
}

class _OwnerOrderViewState extends State<OwnerOrderView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabTitles = const [
    "Tất cả",
    "Chờ duyệt",
    "Chờ thanh toán",
    "Đã xác nhận",
    "Đang di chuyển",
    "Hoàn tất",
    "Chủ xe hủy",
    "Người thuê hủy",
    "Chờ trả xe",
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabTitles.length, vsync: this);
    _tabController.addListener(_handleTabSelection);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OwnerOrderViewModel>().fetchOwnerTrips();
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
    context.read<OwnerOrderViewModel>().filterTrips(_tabController.index);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OwnerOrderViewModel>();

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
              context.go('/home');
            }
          },
        ),
        title: Text(
          'Đơn cho thuê của tôi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          // Thanh Tabs hiển thị tên + số lượng đơn
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
            child: Container(
              color: context.scaffoldBackgroundColor,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
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
                  fontSize: 13.5,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                tabAlignment: TabAlignment.start,
                tabs: List.generate(_tabTitles.length, (index) {
                  final count = viewModel.getCountForTab(index);
                  final title = _tabTitles[index];
                  return Tab(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(title),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _tabController.index == index
                                  ? Colors.white.withValues(alpha: 0.25)
                                  : context.primaryColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$count',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _tabController.index == index
                                    ? Colors.white
                                    : context.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Nội dung danh sách đơn
          Expanded(
            child: viewModel.isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: context.primaryColor,
                    ),
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
                              onPressed: () =>
                                  viewModel.fetchOwnerTrips(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context.primaryColor,
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
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.assignment_late_outlined,
                                  size: 48,
                                  color: context.textSecondary.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Không tìm thấy đơn cho thuê nào.',
                                  style: TextStyle(
                                    color: context.textSecondary,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async => viewModel.fetchOwnerTrips(),
                            color: context.primaryColor,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: viewModel.filteredTrips.length,
                              itemBuilder: (context, index) {
                                final trip = viewModel.filteredTrips[index];
                                return OrderItemCard(
                                  trip: trip,
                                  onTap: () {
                                    context.push('/order-detail/${trip.id}');
                                  },
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
