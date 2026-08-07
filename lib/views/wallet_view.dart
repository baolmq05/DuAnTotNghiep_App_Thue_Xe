import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/wallet_viewmodel.dart';
import 'package:duantotnghiep_app_thue_xe/components/wallet_components/withdraw_bottom_sheet.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:duantotnghiep_app_thue_xe/utils/format_price.dart';

class WalletView extends StatefulWidget {
  const WalletView({super.key});

  @override
  State<WalletView> createState() => _WalletViewState();
}

class _WalletViewState extends State<WalletView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletViewModel>().fetchWalletDetails();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    await context.read<WalletViewModel>().fetchWalletDetails();
  }

  void _openWithdrawSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const WithdrawBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final walletVM = context.watch<WalletViewModel>();

    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: context.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Ví của tôi',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: context.primaryColor,
        child: walletVM.isLoading && walletVM.balance == 0
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : CustomScrollView(
                slivers: [
                  // Wallet Balances Header Card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildMainBalanceCard(context, walletVM),
                    ),
                  ),

                  // Sticky TabBar Header
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: Colors.white,
                        unselectedLabelColor: context.textSecondary,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          color: context.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        dividerColor: Colors.transparent,
                        tabs: const [
                          Tab(text: 'Biến động số dư'),
                          Tab(text: 'Lịch sử rút tiền'),
                        ],
                      ),
                    ),
                  ),

                  // Tab Views inside CustomScrollView
                  SliverFillRemaining(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildTransactionsTab(context, walletVM),
                        _buildRefundsTab(context, walletVM),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildMainBalanceCard(BuildContext context, WalletViewModel walletVM) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.primaryColor,
            context.primaryColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: context.primaryColor.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Số dư khả dụng',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                Icons.wallet_outlined,
                color: Colors.white.withValues(alpha: 0.8),
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            formatPriceWithUnit(walletVM.balance.toStringAsFixed(0)),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _openWithdrawSheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.secondaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance_wallet_outlined, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Rút tiền ngay',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsTab(BuildContext context, WalletViewModel walletVM) {
    if (walletVM.transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_rounded,
              size: 64,
              color: context.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Chưa có biến động số dư nào',
              style: TextStyle(
                fontSize: 14,
                color: context.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(), // Scroll managed by CustomScrollView
      itemCount: walletVM.transactions.length,
      separatorBuilder: (context, index) => Divider(color: context.border, height: 1),
      itemBuilder: (context, index) {
        final txn = walletVM.transactions[index];
        final double amount = double.tryParse(txn['amount']?.toString() ?? '') ?? 0.0;
        final isPositive = amount > 0;

        String title = 'Biến động ví';
        String subtitle = 'Giao dịch hệ thống';

        if (txn['trip'] != null) {
          final trip = txn['trip'] as Map<String, dynamic>;
          final car = trip['car'] as Map<String, dynamic>?;
          final carName = car?['name'] ?? 'Thuê xe';
          
          if (isPositive) {
            title = 'Doanh thu cho thuê xe';
            subtitle = '$carName - Khách hàng: ${trip['customer_name'] ?? 'N/A'}';
          } else {
            title = 'Thanh toán thuê xe';
            subtitle = '$carName - Chủ xe: ${trip['owner_name'] ?? 'N/A'}';
          }
        } else {
          // No trip info, likely manual deposit or withdrawal log
          if (isPositive) {
            title = 'Nạp tiền vào ví';
            subtitle = 'Thông qua cổng thanh toán';
          } else {
            title = 'Rút tiền từ ví';
            subtitle = 'Chuyển khoản ngân hàng';
          }
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: isPositive
                      ? context.success.withValues(alpha: 0.1)
                      : context.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPositive ? Icons.add_rounded : Icons.remove_rounded,
                  color: isPositive ? context.success : context.error,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.textSecondary,
                      ),
                    ),
                    if (txn['created_at'] != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        txn['created_at'].toString(),
                        style: TextStyle(
                          fontSize: 10,
                          color: context.textSecondary.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                (isPositive ? '+' : '') + formatPriceWithUnit(amount.toStringAsFixed(0)),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isPositive ? context.success : context.error,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRefundsTab(BuildContext context, WalletViewModel walletVM) {
    if (walletVM.refunds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_outlined,
              size: 64,
              color: context.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Chưa có yêu cầu rút tiền nào',
              style: TextStyle(
                fontSize: 14,
                color: context.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(), // Scroll managed by CustomScrollView
      itemCount: walletVM.refunds.length,
      separatorBuilder: (context, index) => Divider(color: context.border, height: 1),
      itemBuilder: (context, index) {
        final refund = walletVM.refunds[index];
        final double amount = double.tryParse(refund['amount']?.toString() ?? '') ?? 0.0;
        final int statusVal = int.tryParse(refund['status']?.toString() ?? '') ?? 0;

        String statusLabel = 'Chờ xử lý';
        Color statusColor = Colors.grey;
        Color statusBg = Colors.grey.withValues(alpha: 0.1);

        switch (statusVal) {
          case 0:
            statusLabel = 'Chờ duyệt';
            statusColor = context.textSecondary;
            statusBg = context.borderVariant;
            break;
          case 1:
            statusLabel = 'Đang xử lý';
            statusColor = context.info;
            statusBg = context.infoSurface;
            break;
          case 2:
            statusLabel = 'Hoàn thành';
            statusColor = context.success;
            statusBg = context.successSurface;
            break;
          case 3:
            statusLabel = 'Thất bại';
            statusColor = context.error;
            statusBg = context.errorSurface;
            break;
          case 4:
            statusLabel = 'Đã hủy';
            statusColor = context.error;
            statusBg = context.errorSurface;
            break;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: context.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.receipt_rounded,
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
                      refund['transaction_code'] ?? 'RF000000',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      refund['description'] ?? 'Yêu cầu rút tiền',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.textSecondary,
                      ),
                    ),
                    if (refund['created_at'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        refund['created_at'].toString(),
                        style: TextStyle(
                          fontSize: 10,
                          color: context.textSecondary.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatPriceWithUnit(amount.abs().toStringAsFixed(0)),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
