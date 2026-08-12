import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:duantotnghiep_app_thue_xe/models/trip_model.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/owner_order_detail_viewmodel.dart';
import 'package:duantotnghiep_app_thue_xe/widgets/app_toast.dart';

import 'package:duantotnghiep_app_thue_xe/components/order_detail_components/order_detail_header.dart';
import 'package:duantotnghiep_app_thue_xe/components/order_detail_components/order_detail_car_card.dart';
import 'package:duantotnghiep_app_thue_xe/components/order_detail_components/order_detail_owner_card.dart';
import 'package:duantotnghiep_app_thue_xe/components/order_detail_components/order_detail_time_card.dart';
import 'package:duantotnghiep_app_thue_xe/components/order_detail_components/order_detail_price_card.dart';
import 'package:duantotnghiep_app_thue_xe/components/order_detail_components/order_detail_timeline.dart';

class OwnerOrderDetailView extends StatefulWidget {
  final int orderId;

  const OwnerOrderDetailView({super.key, required this.orderId});

  @override
  State<OwnerOrderDetailView> createState() => _OwnerOrderDetailViewState();
}

class _OwnerOrderDetailViewState extends State<OwnerOrderDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OwnerOrderDetailViewModel>().fetchTripDetail(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OwnerOrderDetailViewModel>();

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
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
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
                    : 'Không tìm thấy đơn thuê xe.',
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => viewModel.fetchTripDetail(widget.orderId),
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
            backgroundColor: context.primaryColor,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            title: const Text(
              'Chi tiết đơn thuê',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                OrderDetailHeader(trip: trip),
                Transform.translate(
                  offset: const Offset(0, -30),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        if (car != null) OrderDetailCarCard(car: car),
                        const SizedBox(height: 20),
                        if (trip.renter != null)
                          OrderDetailOwnerCard(
                            trip: trip,
                            renter: trip.renter!,
                            isCreatingChat: false,
                            onStartChat: (_, __) {},
                            onCall: (_) {},
                          ),
                        const SizedBox(height: 20),
                        OrderDetailTimeCard(trip: trip),
                        const SizedBox(height: 20),
                        OrderDetailPriceCard(trip: trip),
                        const SizedBox(height: 20),
                        OrderDetailTimeline(
                          trip: trip,
                          isOwner: true,
                          onCancel: (t) => _showStatusUpdateDialog(t, 'Hủy chuyến đi', 6),
                        ),
                        const SizedBox(height: 24),
                        _buildOwnerActions(trip),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerActions(TripModel trip) {
    final status = trip.status;
    final actions = <Widget>[];

    if (status == 0) {
      actions.add(
        _buildActionButton(
          title: 'Duyệt đơn',
          icon: Icons.check_circle_outline,
          color: Colors.green,
          onPressed: () => _showStatusUpdateDialog(trip, 'Duyệt đơn', 2),
        ),
      );
      actions.add(const SizedBox(height: 10));
      actions.add(
        _buildActionButton(
          title: 'Từ chối',
          icon: Icons.close_rounded,
          color: Colors.red,
          onPressed: () => _showStatusUpdateDialog(trip, 'Từ chối đơn', 6),
        ),
      );
    } else if (status == 2) {
      actions.add(
        _buildActionButton(
          title: 'Bắt đầu chuyến',
          icon: Icons.drive_eta_outlined,
          color: context.primaryColor,
          onPressed: () => _showStatusUpdateDialog(trip, 'Bắt đầu chuyến', 3),
        ),
      );
    } else if (status == 3) {
      actions.add(
        _buildActionButton(
          title: 'Hoàn tất chuyến',
          icon: Icons.done_all_rounded,
          color: Colors.teal,
          onPressed: () => _showStatusUpdateDialog(trip, 'Hoàn tất chuyến', 4),
        ),
      );
    }

    if (actions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.border),
        ),
        child: Text(
          'Đơn này đang ở trạng thái ${trip.getStatusDisplay()}.',
          textAlign: TextAlign.center,
          style: TextStyle(color: context.textSecondary),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: actions,
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }

  void _showStatusUpdateDialog(
    TripModel trip,
    String actionLabel,
    int nextStatus,
  ) {
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(actionLabel),
              content: Text(
                'Bạn chắc chắn muốn $actionLabel cho đơn #RT${trip.id}?',
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.of(dialogCtx).pop(),
                  child: Text(
                    'Hủy',
                    style: TextStyle(color: context.textSecondary),
                  ),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          setDialogState(() => isSubmitting = true);
                          final viewModel = this.context.read<OwnerOrderDetailViewModel>();
                          Map<String, dynamic> result = {'success': false, 'message': 'Không xác định'};

                          if (nextStatus == 2) {
                            result = await viewModel.confirmTrip(trip.id);
                          } else if (nextStatus == 6 && actionLabel == 'Từ chối đơn') {
                            result = await viewModel.rejectTrip(trip.id);
                          } else if (nextStatus == 6 && actionLabel == 'Hủy chuyến đi') {
                            result = await viewModel.cancelTrip(trip.id);
                          } else {
                            // Local updates for other statuses if there's no API
                            await Future.delayed(const Duration(milliseconds: 300));
                            setState(() {
                              trip.status = nextStatus;
                              trip.statusText = trip.getStatusDisplay();
                            });
                            result = {'success': true};
                          }

                          if (!mounted) return;
                          Navigator.of(dialogCtx).pop();

                          if (this.context.mounted) {
                            if (result['success'] == true) {
                              AppToast.show(
                                this.context,
                                message: '$actionLabel thành công.',
                                type: ToastType.success,
                              );
                            } else {
                              AppToast.show(
                                this.context,
                                message: result['message'] ?? '$actionLabel thất bại.',
                                type: ToastType.error,
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: nextStatus == 2 ? Colors.green : AppColors.error,
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
                          'Xác nhận',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
