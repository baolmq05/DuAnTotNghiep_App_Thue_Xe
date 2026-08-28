import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../themes/app_colors.dart';
import '../../models/trip_model.dart';
import '../../services/trip_service.dart';
import '../../widgets/app_toast.dart';

class ZaloPayCheckoutSheet extends StatefulWidget {
  final TripModel trip;
  final VoidCallback onPaymentSuccess;

  const ZaloPayCheckoutSheet({
    super.key,
    required this.trip,
    required this.onPaymentSuccess,
  });

  @override
  State<ZaloPayCheckoutSheet> createState() => _ZaloPayCheckoutSheetState();
}

class _ZaloPayCheckoutSheetState extends State<ZaloPayCheckoutSheet> with WidgetsBindingObserver {
  final TripService _tripService = TripService();
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
  
  // Lưu mã giao dịch phục vụ việc xác thực
  String? _currentAppTransId;
  
  // Mã giao dịch đã xác nhận (hoặc giả lập) để hiển thị tĩnh trên màn hình kết quả
  String? _transactionId;
  
  // Trạng thái đếm ngược
  int _secondsRemaining = 900; // 15 phút
  Timer? _countdownTimer;

  // Chọn mức thanh toán (true: Đặt cọc 40%, false: Thanh toán 100%)
  bool _isDeposit = false;

  // Trạng thái thanh toán
  bool _isLoading = false;
  String _loadingMessage = '';
  bool _isWaitingForPayment = false;
  
  // Trạng thái kết quả mô phỏng
  bool _paymentCompleted = false;
  bool _isSuccess = true;
  String _errorMessage = '';

  static const bool _isSimulationMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); 
    _startTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); 
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
   
    if (state == AppLifecycleState.resumed) {
      _autoVerifyPayment();
    }
  }

  Future<void> _autoVerifyPayment() async {
    // Chỉ tự động kiểm tra nếu có app_trans_id đang chờ, không đang trong tiến trình loading, 
    if (_currentAppTransId == null || 
        _currentAppTransId!.isEmpty || 
        _isLoading || 
        _isSimulationMode || 
        _paymentCompleted ||
        !_isWaitingForPayment) {
      return;
    }

    setState(() {
      _isLoading = true;
      _loadingMessage = 'Đang tự động xác minh kết quả thanh toán với ZaloPay...';
    });

    // Chờ 1 giây để đảm bảo phía ZaloPay sandbox xử lý xong trạng thái
    await Future.delayed(const Duration(seconds: 1));

    final verifyResult = await _tripService.verifyZaloPayPayment(_currentAppTransId!);

    setState(() {
      _isLoading = false;
    });

    if (verifyResult['success'] == true) {
      debugPrint('ZaloPay Verify Result Response: $verifyResult');
      setState(() {
        _paymentCompleted = true;
        _isSuccess = true;
        _isWaitingForPayment = false;
        
        // Trích xuất mã giao dịch an toàn nhất có thể
        final rawData = verifyResult['data'];
        String? transNo;
        if (rawData is Map) {
          transNo = rawData['transaction_no']?.toString() ?? rawData['transaction_code']?.toString();
        }
        
        _transactionId = transNo ?? _currentAppTransId ?? 'ZP-${widget.trip.id}-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}';
      });
      if (mounted) {
        AppToast.show(
          context,
          message: 'Tự động xác thực thanh toán thành công!',
          type: ToastType.success,
        );
      }
    } else {
      // Nếu thất bại (chưa thanh toán xong), ta im lặng để người dùng có thể thao tác tiếp
      debugPrint('Tự động verify chưa thành công: ${verifyResult['message']}');
    }
  }

  void _startTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _countdownTimer?.cancel();
        _showTimeoutDialog();
      }
    });
  }

  String _formatTimer(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _showTimeoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Hết hạn giao dịch'),
        content: const Text('Thời gian giao dịch thanh toán đã hết hạn (15 phút). Vui lòng khởi tạo lại giao dịch.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Đóng dialog
              Navigator.pop(context); // Đóng bottom sheet
            },
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  int _calculateDays(DateTime start, DateTime end) {
    final diffMinutes = end.difference(start).inMinutes;
    final days = (diffMinutes / 1440).ceil();
    return days <= 0 ? 1 : days;
  }

  String _formatDuration(DateTime start, DateTime end) {
    final diff = end.difference(start);
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    if (days > 0) {
      if (hours > 0) {
        return '$days ngày $hours giờ';
      }
      return '$days ngày';
    }
    return '$hours giờ';
  }

  // Thực hiện thanh toán
  Future<void> _handlePayment(double amountToPay) async {
    const paymentType = 'rental';

    setState(() {
      _isLoading = true;
      _loadingMessage = 'Đang tạo liên kết với ZaloPay...';
    });

    final result = await _tripService.createZaloPayPayment(
      widget.trip.id,
      amount: amountToPay,
      paymentType: paymentType,
    );

    setState(() {
      _isLoading = false;
    });

    if (result['success'] == true) {
      _currentAppTransId = result['app_trans_id']?.toString();
      final orderUrl = result['order_url'];
      if (orderUrl != null && orderUrl.isNotEmpty) {
        final uri = Uri.parse(orderUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (mounted) {
            setState(() {
              _isWaitingForPayment = true;
            });
          }
        } else {
          _showError('Không thể mở liên kết thanh toán: $orderUrl');
        }
      } else {
        _showError('Không tìm thấy order_url trong phản hồi từ backend. Hãy kiểm tra lại API.');
      }
    } else {
      _showError(result['message'] ?? 'Tạo giao dịch ZaloPay thất bại.');
    }
  }



  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.error),
            const SizedBox(width: 8),
            const Text('Lỗi kết nối'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double grossCost = widget.trip.cost;
    final double discount = widget.trip.discountAmount;
    final double netTotal = (grossCost - discount) < 0 ? 0.0 : (grossCost - discount);
    final int rentalDays = _calculateDays(widget.trip.startAt, widget.trip.endAt);
    final double unitPrice = (widget.trip.car != null && widget.trip.car!.unitPrice > 0)
        ? widget.trip.car!.unitPrice
        : (rentalDays > 0 ? (grossCost / rentalDays) : 0.0);
    
    final double depositAmount = (netTotal * 0.4 / 1000).round() * 1000.0;
    final double remainingAmount = netTotal - depositAmount;
    final double amountToPay = _isDeposit ? depositAmount : netTotal;

    final sheetHeight = MediaQuery.of(context).size.height * 0.85;

    return Container(
      height: sheetHeight,
      decoration: BoxDecoration(
        color: context.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _paymentCompleted
              ? _buildResultScreen()
              : _isLoading
                  ? _buildLoadingScreen()
                  : _isWaitingForPayment
                      ? _buildWaitingForPaymentScreen()
                      : _buildCheckoutContent(grossCost, unitPrice, discount, netTotal, depositAmount, remainingAmount, amountToPay),
        ),
      ),
    );
  }

  // Màn hình chi tiết thanh toán chính
  Widget _buildCheckoutContent(
    double grossCost,
    double unitPrice,
    double discount,
    double netTotal,
    double depositAmount,
    double remainingAmount,
    double amountToPay,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Thanh kéo đầu sheet
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 42,
            height: 4.5,
            decoration: BoxDecoration(
              color: context.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Thông tin thanh toán',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: context.textSecondary),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
        ),
        const Divider(height: 1),

        // Scrollable Body
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner Đếm ngược
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    color: context.primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.primaryColor.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.timer_outlined, color: context.primaryColor, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Thời gian thanh toán còn lại',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        _formatTimer(_secondsRemaining),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: context.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 1. CHỌN MỨC THANH TOÁN
                _buildSectionTitle('1. Chọn mức thanh toán'),
                const SizedBox(height: 10),
                
                // Hộp chọn mức thanh toán (Đặt cọc 40% & Thanh toán 100%)
                Row(
                  children: [
                    Expanded(
                      child: _buildPaymentLevelCard(
                        isDepositCard: true,
                        title: 'Đặt cọc 40%',
                        description: 'Trả trước một phần để giữ xe',
                        price: _currencyFormat.format(depositAmount),
                        footer: 'Còn lại: ${_currencyFormat.format(remainingAmount)} (trả trực tiếp cho chủ xe khi nhận xe)',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildPaymentLevelCard(
                        isDepositCard: false,
                        title: 'Thanh toán 100%',
                        description: 'Thanh toán toàn bộ hóa đơn',
                        price: _currencyFormat.format(netTotal),
                        footer: 'Bạn không cần phải thanh toán thêm tại quầy khi nhận xe',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 2. PHƯƠNG THỨC THANH TOÁN (Không cho chọn, chỉ hiện thị tĩnh ZaloPay như website)
                _buildSectionTitle('2. Phương thức thanh toán'),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: context.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.primaryColor.withValues(alpha: 0.4), width: 1.2),
                  ),
                  child: Row(
                    children: [
                      // ZaloPay Logo drawing (giữ nguyên logo thương hiệu ZaloPay xanh)
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00C0F9), Color(0xFF007ADE)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'Zalo',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ví điện tử ZaloPay',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: context.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Hỗ trợ ví ZaloPay, QR Code, thẻ ngân hàng',
                              style: TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.check_circle,
                        color: context.primaryColor,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 3. THÔNG TIN CHUYẾN ĐI (Giống Panel bên phải của Web)
                _buildSectionTitle('3. Chi tiết chuyến đi & Chi phí'),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.border, width: 0.8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Car info row
                      if (widget.trip.car != null) ...[
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                widget.trip.car!.getFirstImageUrl(),
                                width: 72,
                                height: 52,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 72,
                                  height: 52,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.directions_car, color: Colors.grey),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.trip.car!.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: context.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.trip.car!.licensePlate,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                      ],

                      // Time info row
                      _buildInfoRow('Nhận xe', DateFormat('HH:mm dd/MM/yyyy').format(widget.trip.startAt)),
                      const SizedBox(height: 6),
                      _buildInfoRow('Trả xe', DateFormat('HH:mm dd/MM/yyyy').format(widget.trip.endAt)),
                      const SizedBox(height: 6),
                      _buildInfoRow('Tổng thời gian', _formatDuration(widget.trip.startAt, widget.trip.endAt)),
                      
                      const Divider(height: 24),
                      
                      // Payment breakdown
                      _buildInfoRow('Đơn giá thuê', '${_currencyFormat.format(unitPrice)}/ngày'),
                      const SizedBox(height: 6),
                      _buildInfoRow('Khuyến mãi', '-${_currencyFormat.format(discount)}', valueColor: AppColors.success),
                      const SizedBox(height: 6),
                      _buildInfoRow('Thành tiền', _currencyFormat.format(netTotal), isBold: true),
                      
                      const Divider(height: 24),

                      // Số tiền cần trả ngay
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Số tiền cần trả ngay:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: context.textPrimary,
                            ),
                          ),
                          Text(
                            _currencyFormat.format(amountToPay),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF007ADE),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Sticky Bottom Button
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () => _handlePayment(amountToPay),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF286874),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.security, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Thanh toán ${_currencyFormat.format(amountToPay)} bằng ZaloPay',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Mức thanh toán Card Widget
  Widget _buildPaymentLevelCard({
    required bool isDepositCard,
    required String title,
    required String description,
    required String price,
    required String footer,
  }) {
    final bool isSelected = (isDepositCard == _isDeposit);
    return InkWell(
      onTap: () {
        setState(() {
          _isDeposit = isDepositCard;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        height: 175,
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? context.primaryColor : context.border,
            width: isSelected ? 1.8 : 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: isSelected ? context.primaryColor : Colors.grey,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(fontSize: 10, color: context.textSecondary),
            ),
            const Spacer(),
            Text(
              price,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isSelected ? context.primaryColor : context.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              footer,
              style: const TextStyle(fontSize: 8.5, color: Colors.grey, height: 1.2),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Màn hình chờ thanh toán (Thay cho confirm dialog)
  Widget _buildWaitingForPaymentScreen() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 54,
            height: 54,
            child: CircularProgressIndicator(
              color: context.primaryColor,
              strokeWidth: 3.5,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Đang thực hiện giao dịch ZaloPay...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Vui lòng hoàn tất thanh toán trên cửa sổ trình duyệt vừa mở.\n\nTrạng thái đơn hàng sẽ tự động cập nhật và màn hình sẽ chuyển tiếp khi bạn quay lại ứng dụng này.',
            style: TextStyle(
              fontSize: 12.5,
              color: context.textSecondary,
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 36),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _isWaitingForPayment = false;
                _currentAppTransId = null;
              });
            },
            icon: const Icon(Icons.arrow_back, size: 16, color: Colors.grey),
            label: const Text(
              'Hủy giao dịch',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              setState(() {
                _paymentCompleted = true;
                _isSuccess = true;
                _isWaitingForPayment = false;
                _transactionId = 'MOCK-DEP-${widget.trip.id}-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}';
              });
              AppToast.show(
                context,
                message: 'Giả lập thanh toán đặt cọc thành công!',
                type: ToastType.success,
              );
            },
            child: const Text(
              'Giả lập thanh toán thành công (Test)',
              style: TextStyle(
                color: Colors.grey,
                decoration: TextDecoration.underline,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Màn hình Loading
  Widget _buildLoadingScreen() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              color: context.primaryColor,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _loadingMessage,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Vui lòng chờ trong giây lát...',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Màn hình kết quả
  Widget _buildResultScreen() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isSuccess 
                  ? AppColors.success.withValues(alpha: 0.1) 
                  : AppColors.error.withValues(alpha: 0.1),
            ),
            child: Icon(
              _isSuccess ? Icons.check_circle : Icons.error,
              color: _isSuccess ? AppColors.success : AppColors.error,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          
          Text(
            _isSuccess ? 'Thanh toán thành công' : 'Thanh toán thất bại',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          
          Text(
            _isSuccess 
                ? 'Giao dịch ZaloPay đã được hệ thống ghi nhận thành công.'
                : _errorMessage,
            style: TextStyle(
              fontSize: 12,
              color: context.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          
          if (_isSuccess)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: context.border, width: 0.5),
              ),
              child: Column(
                children: [
                  _buildInfoRow('Mã giao dịch', _transactionId ?? 'Không xác định'),
                  const SizedBox(height: 6),
                  _buildInfoRow('Phương thức', 'Ví điện tử ZaloPay'),
                  const SizedBox(height: 6),
                  _buildInfoRow('Mức thanh toán', _isDeposit ? 'Đặt cọc 40%' : 'Thanh toán 100%'),
                  const SizedBox(height: 6),
                  _buildInfoRow('Số tiền đã trả', _currencyFormat.format(_isDeposit ? (widget.trip.cost * 0.4) : widget.trip.cost), isBold: true),
                ],
              ),
            ),
          const SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_isSuccess) {
                  Navigator.pop(context);
                  widget.onPaymentSuccess();
                } else {
                  setState(() {
                    _paymentCompleted = false;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isSuccess ? context.primaryColor : Colors.grey.shade800,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                _isSuccess ? 'Hoàn tất' : 'Thực hiện lại',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: context.textPrimary,
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: context.textSecondary)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12, 
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600, 
              color: valueColor ?? context.textPrimary,
            ),
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
