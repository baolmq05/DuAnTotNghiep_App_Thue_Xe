import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:duantotnghiep_app_thue_xe/models/trip_model.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/owner_order_detail_viewmodel.dart';
import 'package:duantotnghiep_app_thue_xe/widgets/app_toast.dart';
import 'package:duantotnghiep_app_thue_xe/models/conversation_model.dart';
import 'package:duantotnghiep_app_thue_xe/services/conversation_service.dart';
import 'package:duantotnghiep_app_thue_xe/utils/format_price.dart';

import 'package:duantotnghiep_app_thue_xe/components/order_detail_components/order_detail_header.dart';
import 'package:duantotnghiep_app_thue_xe/components/order_detail_components/order_detail_car_card.dart';
import 'package:duantotnghiep_app_thue_xe/components/order_detail_components/order_detail_owner_card.dart';
import 'package:duantotnghiep_app_thue_xe/components/order_detail_components/order_detail_time_card.dart';
import 'package:duantotnghiep_app_thue_xe/components/order_detail_components/order_detail_price_card.dart';
import 'package:duantotnghiep_app_thue_xe/components/order_detail_components/order_detail_timeline.dart';
import 'package:duantotnghiep_app_thue_xe/components/order_detail_components/order_detail_pre_trip_photos_card.dart';
import 'package:duantotnghiep_app_thue_xe/components/order_detail_components/order_detail_report_card.dart';
import 'package:duantotnghiep_app_thue_xe/components/order_detail_components/complete_trip_confirmation_sheet.dart';

class OwnerOrderDetailView extends StatefulWidget {
  final int orderId;

  const OwnerOrderDetailView({super.key, required this.orderId});

  @override
  State<OwnerOrderDetailView> createState() => _OwnerOrderDetailViewState();
}

class _OwnerOrderDetailViewState extends State<OwnerOrderDetailView> {
  bool _isCreatingChat = false;

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
                          OrderDetailOwnerCard.renter(
                            trip: trip,
                            renter: trip.renter!,
                            isCreatingChat: _isCreatingChat,
                            onStartChat: () => _handleStartChat(trip, trip.renter!),
                          ),
                        const SizedBox(height: 20),
                        OrderDetailTimeCard(trip: trip),
                        const SizedBox(height: 20),
                        OrderDetailPriceCard(trip: trip),
                        if (trip.latestExtension != null) ...[
                          const SizedBox(height: 20),
                          _buildExtensionSection(trip, viewModel),
                        ],
                        const SizedBox(height: 20),
                        OrderDetailTimeline(
                          trip: trip,
                          isOwner: true,
                          onCancel: (t) => _showStatusUpdateDialog(t, 'Hủy chuyến đi', 6),
                        ),
                        if (trip.reports.isNotEmpty) ...[
                          for (final r in trip.reports) ...[
                            const SizedBox(height: 20),
                            OrderDetailReportCard(
                              report: r,
                              isOwnerView: true,
                            ),
                          ],
                        ] else if (trip.report != null) ...[
                          const SizedBox(height: 20),
                          OrderDetailReportCard(
                            report: trip.report!,
                            isOwnerView: true,
                          ),
                        ],
                        const SizedBox(height: 24),
                        _buildOwnerActions(trip),
                        
                        // ===== 1. UPLOAD ẢNH BÀN GIAO XE TRƯỚC CHUYẾN (STATUS == 2) =====
                        if (trip.status == 2) ...[
                          const SizedBox(height: 20),
                          OrderDetailPreTripPhotosCard(
                            title: 'Ảnh xe trước khi bàn giao',
                            subtitle: 'Chụp/chọn ảnh xe trước khi giao để làm bằng chứng',
                            localImages: viewModel.selectedPreTripPhotos,
                            uploadedPhotos: const [],
                            isUploading: viewModel.isSubmittingStart,
                            isReadOnly: false,
                            onPickFromCamera: () => viewModel.capturePreTripCameraImage(),
                            onPickFromGallery: () => viewModel.pickPreTripGalleryImages(),
                            onRemoveLocalImage: (index) => viewModel.removePreTripLocalPhoto(index),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: viewModel.isSubmittingStart
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.drive_eta_outlined, color: Colors.white),
                              label: Text(
                                viewModel.isSubmittingStart
                                    ? 'Đang tải ảnh & khởi hành...'
                                    : 'Tải ảnh lên & Bắt đầu chuyến đi',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context.primaryColor,
                                disabledBackgroundColor: context.primaryColor.withAlpha(120),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: viewModel.isSubmittingStart ||
                                      viewModel.selectedPreTripPhotos.isEmpty
                                  ? null
                                  : () async {
                                      final result = await viewModel.submitStartTrip(trip.id);
                                      if (mounted) {
                                        AppToast.show(
                                          context,
                                          message: result['message'] ?? '',
                                          type: result['success'] == true
                                              ? ToastType.success
                                              : ToastType.error,
                                        );
                                      }
                                    },
                            ),
                          ),
                        ],

                        // ===== 2. HIỂN THỊ ẢNH TRƯỚC CHUYẾN ĐI ĐÃ UPLOAD (STATUS >= 3, READ ONLY) =====
                        if (trip.status >= 3 && trip.beforeTripImages.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          OrderDetailPreTripPhotosCard(
                            title: 'Ảnh xe trước khi bàn giao',
                            subtitle: 'Hình ảnh hiện trạng xe trước chuyến đi',
                            uploadedPhotos: trip.beforeTripImages,
                            isReadOnly: true,
                          ),
                        ],

                        // ===== 3. DƯỚI CÙNG: ẢNH XE SAU KHI NHẬN LẠI XE =====
                        // TRẠNG THÁI 8 (CHỜ TRẢ XE): UPLOAD ẢNH XE SAU CHUYẾN ĐỂ HOÀN TẤT
                        if (trip.status == 8) ...[
                          const SizedBox(height: 20),
                          OrderDetailPreTripPhotosCard(
                            title: 'Ảnh xe sau khi nhận lại xe',
                            subtitle: 'Chụp/chọn ảnh hiện trạng xe sau chuyến để đối chiếu & hoàn tất',
                            localImages: viewModel.selectedPostTripPhotos,
                            uploadedPhotos: const [],
                            isUploading: viewModel.isSubmittingComplete,
                            isReadOnly: false,
                            onPickFromCamera: () => viewModel.capturePostTripCameraImage(),
                            onPickFromGallery: () => viewModel.pickPostTripGalleryImages(),
                            onRemoveLocalImage: (index) => viewModel.removePostTripLocalPhoto(index),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: viewModel.isSubmittingComplete
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.done_all_rounded, color: Colors.white),
                              label: Text(
                                viewModel.isSubmittingComplete
                                    ? 'Đang tải ảnh & hoàn tất...'
                                    : 'Tải ảnh lên & Xác nhận hoàn tất chuyến',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                disabledBackgroundColor: Colors.teal.withAlpha(120),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: viewModel.isSubmittingComplete ||
                                      viewModel.selectedPostTripPhotos.isEmpty
                                  ? null
                                  : () {
                                      CompleteTripConfirmationSheet.show(
                                        context,
                                        trip: trip,
                                        onConfirm: () async {
                                          final result = await viewModel
                                              .submitCompleteTrip(trip.id);
                                          if (mounted) {
                                            AppToast.show(
                                              context,
                                              message: result['message'] ?? '',
                                              type: result['success'] == true
                                                  ? ToastType.success
                                                  : ToastType.error,
                                            );
                                          }
                                        },
                                      );
                                    },
                            ),
                          ),
                        ],

                        // TRẠNG THÁI 4 (ĐÃ HOÀN THÀNH): HIỂN THỊ ẢNH SAU CHUYẾN ĐI (READ ONLY)
                        if (trip.status == 4 && trip.afterTripImages.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          OrderDetailPreTripPhotosCard(
                            title: 'Ảnh xe sau khi nhận lại xe',
                            subtitle: 'Hình ảnh hiện trạng xe sau chuyến đi',
                            uploadedPhotos: trip.afterTripImages,
                            isReadOnly: true,
                          ),
                        ],

                        const SizedBox(height: 24),
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
    } else if (status == 8) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.lightBlue.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.lightBlue.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.lightBlue.shade700, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Khách thuê đã yêu cầu trả xe. Vui lòng chụp ảnh xe bên dưới và bấm Xác nhận hoàn tất chuyến.',
                style: TextStyle(
                  color: Colors.lightBlue.shade900,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (actions.isEmpty) {
      String statusMsg = 'Đơn này đang ở trạng thái ${trip.getStatusDisplay()}.';
      if (status == 2) {
        statusMsg = 'Vui lòng chụp ảnh bàn giao xe bên dưới để bắt đầu chuyến đi.';
      } else if (status == 3) {
        statusMsg = 'Chuyến đi đang diễn ra an toàn. Khi khách thuê gửi yêu cầu trả xe, bạn sẽ có thể xác nhận hoàn tất chuyến.';
      } else if (status == 7) {
        statusMsg = 'Khách thuê đang yêu cầu gia hạn thêm ngày.';
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.border),
        ),
        child: Text(
          statusMsg,
          textAlign: TextAlign.center,
          style: TextStyle(color: context.textSecondary, fontSize: 13),
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
                'Bạn chắc chắn muốn $actionLabel cho đơn ${trip.displayCode}?',
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

  Widget _buildExtensionSection(TripModel trip, OwnerOrderDetailViewModel viewModel) {
    final ext = trip.latestExtension;
    if (ext == null) return const SizedBox.shrink();

    String formatDateTimeStr(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return 'N/A';
      final dt = DateTime.tryParse(dateStr);
      if (dt == null) return dateStr;
      final pad = (int v) => v.toString().padLeft(2, '0');
      return '${pad(dt.hour)}:${pad(dt.minute)} ${pad(dt.day)}/${pad(dt.month)}/${dt.year}';
    }

    final DateTime? newEndDate = ext.endDate != null ? DateTime.tryParse(ext.endDate!) : null;
    final int extendedDays = ext.extendedDays ??
        (newEndDate != null ? (newEndDate.difference(trip.endAt).inMinutes / 1440).ceil() : 0);
    final int displayDays = extendedDays <= 0 ? 1 : extendedDays;

    if (ext.status == 1) {
      final isDark = context.isDarkMode;
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row (Icon + Title + Status Badge)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.history_toggle_off_rounded,
                        color: Color(0xFFD97706),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Yêu cầu gia hạn',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? const Color(0xFF78350F) : const Color(0xFFFCD34D),
                    ),
                  ),
                  child: const Text(
                    'Chờ bạn duyệt',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB45309),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 38),
              child: Text(
                'Khách thuê đề xuất thêm thời gian cho chuyến đi này',
                style: TextStyle(
                  fontSize: 12,
                  color: context.textSecondary,
                ),
              ),
            ),
            
            const SizedBox(height: 14),
            
            // Nested Time & Duration Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'HẠN TRẢ CŨ',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: context.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatDateTimeStr(trip.endAt.toIso8601String()),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: context.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? const Color(0xFF1D4ED8) : const Color(0xFFBFDBFE),
                      ),
                    ),
                    child: Text(
                      '+$displayDays ngày',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF2563EB),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'HẠN TRẢ MỚI',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: context.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatDateTimeStr(ext.endDate),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Price Row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.3) : const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? const Color(0xFF047857) : const Color(0xA36EE7B7),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.payments_outlined,
                        size: 20,
                        color: Color(0xFF059669),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Phí gia hạn đề xuất',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    formatPriceWithUnit(ext.extensionAmount.toStringAsFixed(0)),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF059669),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Action Buttons Row
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: viewModel.isSubmittingExtension
                          ? null
                          : () => _showRejectExtensionDialog(trip),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xFF451A1A) : const Color(0xFFFEF2F2),
                        side: BorderSide(
                          color: isDark ? Colors.red.shade800 : const Color(0xFFFCA5A5),
                          width: 1.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.close_rounded, size: 16, color: Color(0xFFDC2626)),
                          SizedBox(width: 6),
                          Text(
                            'Từ chối',
                            style: TextStyle(
                              color: Color(0xFFDC2626),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: viewModel.isSubmittingExtension
                          ? null
                          : () => _showApproveExtensionDialog(trip),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: viewModel.isSubmittingExtension
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_rounded, size: 16, color: Colors.white),
                                SizedBox(width: 6),
                                Text(
                                  'Đồng ý gia hạn',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else if (ext.status == 2) {
      final isDark = context.isDarkMode;
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF13283B) : Colors.blue.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? Colors.blue.shade800 : Colors.blue.shade200, width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? Colors.blue.shade900 : Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.hourglass_top_rounded, color: isDark ? Colors.blue.shade300 : Colors.blue.shade800, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Đã đồng ý gia hạn • Chờ thanh toán',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.blue.shade300 : Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Hạn mới: ${formatDateTimeStr(ext.endDate)} • Phí: ${formatPriceWithUnit(ext.extensionAmount.toStringAsFixed(0))}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.blue.shade200 : Colors.blue.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (ext.status == 3) {
      final isDark = context.isDarkMode;
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF142E1B) : Colors.green.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? Colors.green.shade800 : Colors.green.shade200, width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? Colors.green.shade900 : Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle_outline_rounded, color: isDark ? Colors.green.shade300 : Colors.green.shade800, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gia hạn chuyến đi thành công',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.green.shade300 : Colors.green.shade900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Hạn mới: ${formatDateTimeStr(ext.endDate)} (+${formatPriceWithUnit(ext.extensionAmount.toStringAsFixed(0))})',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.green.shade200 : Colors.green.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (ext.status == 4) {
      final isDark = context.isDarkMode;
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF262626) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300, width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.cancel_outlined, color: isDark ? Colors.grey.shade400 : Colors.grey.shade700, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Yêu cầu gia hạn chuyến đi đã bị từ chối hoặc hủy bỏ.',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _showApproveExtensionDialog(TripModel trip) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.green),
            SizedBox(width: 8),
            Text('Đồng ý gia hạn'),
          ],
        ),
        content: Text(
          'Bạn có đồng ý gia hạn chuyến đi ${trip.displayCode} theo thời gian và mức phí đề xuất không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text('Hủy', style: TextStyle(color: context.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              final viewModel = context.read<OwnerOrderDetailViewModel>();
              final result = await viewModel.approveExtension(trip.id);
              if (mounted) {
                AppToast.show(
                  context,
                  message: result['message'] ?? (result['success'] == true ? 'Duyệt gia hạn thành công!' : 'Lỗi khi duyệt gia hạn'),
                  type: result['success'] == true ? ToastType.success : ToastType.error,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Đồng ý', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showRejectExtensionDialog(TripModel trip) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.cancel_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Từ chối gia hạn'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vui lòng nhập lý do từ chối yêu cầu gia hạn (không bắt buộc):'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: 'Lý do từ chối...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text('Hủy', style: TextStyle(color: context.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final reason = reasonController.text.trim();
              Navigator.of(dialogCtx).pop();
              final viewModel = context.read<OwnerOrderDetailViewModel>();
              final result = await viewModel.rejectExtension(
                trip.id,
                reason: reason.isNotEmpty ? reason : null,
              );
              if (mounted) {
                AppToast.show(
                  context,
                  message: result['message'] ?? (result['success'] == true ? 'Từ chối gia hạn thành công!' : 'Lỗi khi từ chối gia hạn'),
                  type: result['success'] == true ? ToastType.success : ToastType.error,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Từ chối', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
