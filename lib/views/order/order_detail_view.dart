import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:duantotnghiep_app_thue_xe/models/trip_model.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/order_detail_viewmodel.dart';
import 'package:duantotnghiep_app_thue_xe/services/conversation_service.dart';
import 'package:duantotnghiep_app_thue_xe/services/trip_service.dart';
import 'package:duantotnghiep_app_thue_xe/models/conversation_model.dart';
import 'package:duantotnghiep_app_thue_xe/widgets/app_toast.dart';
import 'package:provider/provider.dart';
import 'package:duantotnghiep_app_thue_xe/components/payment/zalopay_checkout_sheet.dart';
import 'package:duantotnghiep_app_thue_xe/components/extension/extension_request_sheet.dart';
import 'package:duantotnghiep_app_thue_xe/components/extension/extension_payment_sheet.dart';
import 'package:duantotnghiep_app_thue_xe/providers/auth_provider.dart';

// Components
import 'package:duantotnghiep_app_thue_xe/components/order_detail_components/order_detail_header.dart';
import 'package:duantotnghiep_app_thue_xe/components/order_detail_components/order_detail_car_card.dart';
import 'package:duantotnghiep_app_thue_xe/components/order_detail_components/order_detail_owner_card.dart';
import 'package:duantotnghiep_app_thue_xe/components/order_detail_components/order_detail_time_card.dart';
import 'package:duantotnghiep_app_thue_xe/components/order_detail_components/order_detail_price_card.dart';
import 'package:duantotnghiep_app_thue_xe/components/order_detail_components/order_detail_timeline.dart';

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

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OrderDetailViewModel>();

    if (viewModel.isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: context.primaryColor),
        ),
      );
    }

    if (viewModel.errorMessage.isNotEmpty || viewModel.trip == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: context.primaryColor,
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
                  backgroundColor: context.primaryColor,
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

    final auth = context.watch<AuthProvider>();
    final currentUser = auth.user;
    final isOwner = currentUser != null && car != null && currentUser.id == car.userId;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: context.primaryColor,
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
                OrderDetailHeader(trip: trip),
                Transform.translate(
                  offset: const Offset(0, -30),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        if (car != null) OrderDetailCarCard(car: car),
                        if (trip.latestExtension != null) ...[
                          const SizedBox(height: 20),
                          _buildExtensionBanner(trip),
                        ],
                        const SizedBox(height: 20),
                        if (trip.renter != null)
                          OrderDetailOwnerCard(
                            trip: trip,
                            renter: trip.renter!,
                            isCreatingChat: _isCreatingChat,
                            onStartChat: _handleStartChat,
                            onCall: _showPhoneDialog,
                          ),
                        const SizedBox(height: 20),
                        OrderDetailTimeCard(trip: trip),
                        const SizedBox(height: 20),
                        OrderDetailPriceCard(trip: trip),
                        const SizedBox(height: 20),
                        OrderDetailTimeline(
                          trip: trip,
                          onCancel: _showCancelConfirmDialog,
                        ),
                        if (trip.status == 4) ...[
                          const SizedBox(height: 20),
                          _buildCompletedReviewCard(trip),
                        ],
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
        child: isOwner
            ? _buildOwnerBottomNavigationBar(trip)
            : Column(
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
                        backgroundColor: context.primaryColor,
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
                                        backgroundColor: context.primaryColor,
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
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (trip.status == 4 && trip.renterReview == null) ...[
                    ElevatedButton.icon(
                      onPressed: () => _showReviewDialog(trip),
                      icon: const Icon(Icons.star_rounded, color: Colors.white, size: 20),
                      label: const Text(
                        'Đánh giá chủ xe & chuyến đi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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
                    const SizedBox(height: 10),
                  ],
                  _buildBottomActionButtons(trip),
                ],
              ),
      ),
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

  Widget _buildOwnerBottomNavigationBar(TripModel trip) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (trip.status == 0) ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showRejectDialog(trip),
                  icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
                  label: const Text(
                    'Từ chối',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showApproveConfirmDialog(trip),
                  icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                  label: const Text(
                    'Duyệt đơn',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryColor,
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
        if (trip.status == 1) ...[
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: context.infoSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: context.info, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Đang chờ khách hàng thanh toán đặt cọc.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: context.info,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
        _buildBottomActionButtons(trip),
      ],
    );
  }

  void _showRejectDialog(TripModel trip) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: const [
              Icon(Icons.cancel_outlined, color: AppColors.error),
              SizedBox(width: 8),
              Text(
                'Từ chối đơn thuê xe',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vui lòng nhập lý do từ chối yêu cầu thuê xe này (không bắt buộc):',
                style: TextStyle(fontSize: 13, color: context.textSecondary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Lý do từ chối (ví dụ: bận đột xuất, xe đang bảo dưỡng...)...',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade400,
                  ),
                  filled: true,
                  fillColor: context.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.primaryColor),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(
                'Quay lại',
                style: TextStyle(color: context.textSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                // Secondary confirmation dialog before final rejection
                showDialog(
                  context: context,
                  builder: (confirmCtx) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: Row(
                      children: const [
                        Icon(Icons.warning_amber_rounded, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Xác nhận từ chối'),
                      ],
                    ),
                    content: const Text(
                      'Bạn có chắc chắn muốn từ chối yêu cầu thuê xe này không?\nQuyết định này không thể hoàn tác.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(confirmCtx),
                        child: Text(
                          'Hủy',
                          style: TextStyle(color: context.textSecondary),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                        ),
                        onPressed: () async {
                          final currentContext = this.context;
                          final detailViewModel = currentContext.read<OrderDetailViewModel>();
                          
                          // Close confirm dialog
                          Navigator.pop(confirmCtx);
                          // Close reason dialog
                          Navigator.pop(dialogCtx);
                          
                          final reason = reasonController.text.trim();
                          final result = await detailViewModel.rejectTrip(
                            trip.id,
                            reason: reason.isNotEmpty ? reason : null,
                          );
                          
                          if (!mounted) return;
                          if (currentContext.mounted) {
                            if (result['success'] == true) {
                              AppToast.show(
                                currentContext,
                                message: 'Đã từ chối đơn thuê xe thành công!',
                                type: ToastType.success,
                              );
                            } else {
                              AppToast.show(
                                currentContext,
                                message: result['message'] ?? 'Không thể từ chối đơn thuê.',
                                type: ToastType.error,
                              );
                            }
                          }
                        },
                        child: const Text(
                          'Xác nhận từ chối',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: const Text(
                'Từ chối',
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

  void _showApproveConfirmDialog(TripModel trip) {
    bool isSubmitting = false;
    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: const [
              Icon(Icons.check_circle_outline, color: AppColors.success),
              SizedBox(width: 8),
              Text('Duyệt đơn thuê xe'),
            ],
          ),
          content: const Text(
            'Bạn có đồng ý duyệt yêu cầu thuê xe này không?\nSau khi duyệt, khách hàng sẽ nhận được thông báo để đặt cọc.',
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(dialogCtx),
              child: Text(
                'Quay lại',
                style: TextStyle(color: context.textSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final currentContext = this.context;
                      final nav = Navigator.of(dialogCtx);
                      final detailViewModel = currentContext.read<OrderDetailViewModel>();

                      setDialogState(() => isSubmitting = true);
                      final result = await detailViewModel.confirmTrip(trip.id);
                      nav.pop();

                      if (!mounted) return;
                      if (currentContext.mounted) {
                        if (result['success'] == true) {
                          AppToast.show(
                            currentContext,
                            message: 'Đã xác nhận yêu cầu thuê xe thành công!',
                            type: ToastType.success,
                          );
                        } else {
                          AppToast.show(
                            currentContext,
                            message: result['message'] ?? 'Duyệt đơn thuê xe thất bại.',
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
                      'Xác nhận duyệt',
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

  Future<void> _handleStartChat(TripModel trip, TripRenterInfo renter) async {
    if (_isCreatingChat) return;
    setState(() => _isCreatingChat = true);

    try {
      final conversationService = ConversationService();
      var conv = await conversationService.createConversation(
        receiverId: renter.id,
        tripId: trip.id,
        carId: trip.carId,
      );

      // Nếu API trả về otherUser có tên mặc định/trống hoặc ID = 0, đồng bộ lại từ thông tin của khách thuê
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
            id: renter.id,
            name: renter.name,
            avatar: renter.avatar,
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

  void _showPhoneDialog(TripRenterInfo renter) {
    final phone = (renter.phone != null && renter.phone!.isNotEmpty)
        ? renter.phone!
        : 'Chưa cập nhật số điện thoại';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.call, color: context.primaryColor),
            SizedBox(width: 8),
            Text(
              'Số điện thoại khách thuê',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Khách thuê: ${renter.name}',
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
                  Icon(
                    Icons.phone_android,
                    color: context.primaryColor,
                    size: 20,
                  ),
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
            child: Text('Đóng', style: TextStyle(color: context.primaryColor)),
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
    Color valColor = context.primaryColor;
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
                color: context.primaryColor,
              ),
              title: Text('Liên hệ trung tâm hỗ trợ'),
              onTap: () {
                Navigator.pop(context);
                context.push('/support');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.article_outlined,
                color: context.primaryColor,
              ),
              title: Text('Chính sách & Quy định thuê xe'),
              onTap: () {
                Navigator.pop(context);
                context.push('/policy');
              },
            ),
            if (trip.car?.owner != null)
              ListTile(
                leading: Icon(
                  Icons.person_outline,
                  color: context.primaryColor,
                ),
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
                  backgroundColor: context.primaryColor,
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
                  backgroundColor: context.primaryColor,
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
                                color: context.primaryColor,
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
                backgroundColor: context.primaryColor,
              ),
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final currentContext = this.context;
                      final nav = Navigator.of(dialogCtx);
                      final viewModel = currentContext
                          .read<OrderDetailViewModel>();

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
                            message:
                                result['message'] ??
                                'Gửi yêu cầu trả xe thất bại.',
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

  Widget _buildCompletedReviewCard(TripModel trip) {
    final renterReview = trip.renterReview;
    final isDark = context.isDarkMode;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B382B) : const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.green.shade800 : Colors.green.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF059669),
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chuyến đi đã kết thúc',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark
                            ? Colors.green.shade100
                            : Colors.green.shade900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Cảm ơn bạn đã sử dụng dịch vụ! Chuyến đi đã được hoàn thành thành công.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.green.shade200
                            : Colors.green.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(
            height: 1,
            color: isDark ? Colors.green.shade800 : Colors.green.shade200,
          ),
          const SizedBox(height: 14),
          if (renterReview != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Đánh giá của bạn về chủ xe:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: context.textPrimary,
                        ),
                      ),
                      Row(
                        children: List.generate(5, (index) {
                          final starValue = index + 1;
                          return Icon(
                            starValue <= renterReview.rating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: starValue <= renterReview.rating
                                ? Colors.amber
                                : Colors.grey.shade400,
                            size: 18,
                          );
                        }),
                      ),
                    ],
                  ),
                  if (renterReview.comment != null &&
                      renterReview.comment!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      '"${renterReview.comment}"',
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: context.textSecondary,
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 6),
                    Text(
                      'Không có bình luận.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showReviewDialog(trip),
                icon: const Icon(
                  Icons.star_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                label: const Text(
                  'Đánh giá chủ xe & chuyến đi',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showReviewDialog(TripModel trip) {
    int selectedRating = 5;
    final commentController = TextEditingController();
    bool isSubmitting = false;

    String getRatingLabel(int rating) {
      switch (rating) {
        case 1:
          return 'Rất kém 😠';
        case 2:
          return 'Kém 🙁';
        case 3:
          return 'Bình thường 😐';
        case 4:
          return 'Tốt 🙂';
        case 5:
          return 'Tuyệt vời 🥰';
        default:
          return 'Chọn số sao';
      }
    }

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: const [
                Icon(Icons.star_rounded, color: Colors.amber, size: 24),
                SizedBox(width: 8),
                Text(
                  'Đánh giá chuyến đi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (trip.car?.owner != null) ...[
                    Text(
                      'Chủ xe: ${trip.car!.owner!.name}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    'Hãy chia sẻ trải nghiệm của bạn về chủ xe và chuyến đi vừa rồi nhé!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starValue = index + 1;
                      return IconButton(
                        onPressed: isSubmitting
                            ? null
                            : () {
                                setDialogState(() {
                                  selectedRating = starValue;
                                });
                              },
                        icon: Icon(
                          starValue <= selectedRating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: starValue <= selectedRating
                              ? Colors.amber
                              : Colors.grey.shade400,
                          size: 36,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        constraints: const BoxConstraints(),
                      );
                    }),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    getRatingLabel(selectedRating),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: context.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: commentController,
                    enabled: !isSubmitting,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText:
                          'Nhập ý kiến đánh giá của bạn (không bắt buộc)...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade400,
                      ),
                      filled: true,
                      fillColor: context.cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.primaryColor),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
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
                onPressed: isSubmitting
                    ? null
                    : () async {
                        final currentContext = this.context;
                        final nav = Navigator.of(dialogCtx);
                        final viewModel = currentContext
                            .read<OrderDetailViewModel>();

                        setDialogState(() => isSubmitting = true);

                        final result = await TripService().submitReview(
                          trip.id,
                          rating: selectedRating,
                          comment: commentController.text.trim(),
                        );

                        nav.pop();

                        if (!mounted) return;
                        if (currentContext.mounted) {
                          if (result['success'] == true) {
                            AppToast.show(
                              currentContext,
                              message:
                                  result['message'] ??
                                  'Gửi đánh giá thành công!',
                              type: ToastType.success,
                            );
                            viewModel.fetchTripDetail(trip.id);
                          } else {
                            AppToast.show(
                              currentContext,
                              message:
                                  result['message'] ?? 'Gửi đánh giá thất bại.',
                              type: ToastType.error,
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Gửi đánh giá',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
