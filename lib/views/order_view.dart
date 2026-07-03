import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import 'package:go_router/go_router.dart';

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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  "Chờ duyệt",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _buildOrderItem(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem() {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 16),
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
                  "https://res.cloudinary.com/djbobb5oe/image/upload/v1783074877/bbnbeqxwn8c2zydoyimv.webp",
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      "Toyota Corolla Cross 2023",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Text(
                          "#RT123456",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xffFFF3E0),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Chờ duyệt",
                            style: TextStyle(
                              color: Color(0xffF57C00),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    const Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 15,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "12/06/2025 - 14/06/2025",
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    const Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 6),

                        Expanded(
                          child: Text(
                            "TP. Hồ Chí Minh",
                            style: TextStyle(fontSize: 13),
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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "2.000.000đ",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "Đăt cọc: ",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        Text(
                          "2.000.000đ",
                          style: TextStyle(
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
                    context.push('/order-detail');
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
