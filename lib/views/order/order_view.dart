import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/order_viewmodel.dart';
import 'package:provider/provider.dart';

// Components
import 'package:duantotnghiep_app_thue_xe/components/order_components/order_item_card.dart';

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
    _tabController = TabController(length: 8, vsync: this);
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

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OrderViewModel>();

    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.scaffoldBackgroundColor,
        centerTitle: false,
        title: Text(
          'Đơn hàng của bạn',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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
                  Tab(text: "Đã xác nhận"),
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
                ? Center(
                    child: CircularProgressIndicator(color: context.primaryColor),
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
                ? const Center(
                    child: Text(
                      'Không tìm thấy đơn hàng nào.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async => viewModel.fetchTrips(),
                    color: context.primaryColor,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: viewModel.filteredTrips.length,
                      itemBuilder: (context, index) {
                        final trip = viewModel.filteredTrips[index];
                        return OrderItemCard(
                          trip: trip,
                          onTap: () {
                            context.go('/order-detail/${trip.id}');
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
