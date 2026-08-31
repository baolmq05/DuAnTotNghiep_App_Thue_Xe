import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../themes/app_colors.dart';
import '../../models/trip_model.dart';
import '../../services/payment_service.dart';
import '../../widgets/app_toast.dart';

/// Bottom sheet thanh toán phí gia hạn qua ZaloPay
class ExtensionPaymentSheet extends StatefulWidget {
  final TripModel trip;
  final VoidCallback onPaymentSuccess;

  const ExtensionPaymentSheet({
    super.key,
    required this.trip,
    required this.onPaymentSuccess,
  });

  @override
  State<ExtensionPaymentSheet> createState() => _ExtensionPaymentSheetState();
}

class _ExtensionPaymentSheetState extends State<ExtensionPaymentSheet>
    with WidgetsBindingObserver {
  final PaymentService _paymentService = PaymentService();
  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  String? _currentAppTransId;
  String? _transactionId;

  int _secondsRemaining = 900; // 15 phút
  Timer? _countdownTimer;

  bool _isLoading = false;
  String _loadingMessage = '';
  bool _isWaitingForPayment = false;
  bool _paymentCompleted = false;
  bool _isSuccess = true;

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
    if (_currentAppTransId == null ||
        _currentAppTransId!.isEmpty ||
        _isLoading ||
        _paymentCompleted ||
        !_isWaitingForPayment) {
      return;
    }

    setState(() {
      _isLoading = true;
      _loadingMessage = 'Đang xác minh kết quả thanh toán gia hạn...';
    });

    await Future.delayed(const Duration(seconds: 1));

    final verifyResult =
        await _paymentService.verifyZaloPayPayment(_currentAppTransId!);

    setState(() => _isLoading = false);

    if (verifyResult['success'] == true) {
      setState(() {
        _paymentCompleted = true;
        _isSuccess = true;
        _isWaitingForPayment = false;

        final rawData = verifyResult['data'];
        String? transNo;
        if (rawData is Map) {
          transNo = rawData['transaction_no']?.toString() ??
              rawData['transaction_code']?.toString();
        }
        _transactionId = transNo ??
            _currentAppTransId ??
            'ZP-EXT-${widget.trip.id}-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}';
      });
      if (mounted) {
        AppToast.show(
          context,
          message: 'Thanh toán gia hạn thành công!',
          type: ToastType.success,
        );
      }
    }
  }

  void _startTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
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
        content: const Text(
            'Thời gian thanh toán gia hạn đã hết hạn. Vui lòng thử lại.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '--';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    String pad(int v) => v.toString().padLeft(2, '0');
    return '${pad(date.hour)}:${pad(date.minute)} - ${pad(date.day)}/${pad(date.month)}/${date.year}';
  }

  Future<void> _handlePayment() async {
    setState(() {
      _isLoading = true;
      _loadingMessage = 'Đang tạo liên kết thanh toán gia hạn...';
    });

    final ext = widget.trip.latestExtension;
    final amount = ext?.extensionAmount ?? 0.0;

    final result = await _paymentService.createZaloPayPayment(
      widget.trip.id,
      amount: amount,
      paymentType: 'extension',
    );

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      _currentAppTransId = result['app_trans_id']?.toString();
      final orderUrl = result['order_url'];
      if (orderUrl != null && orderUrl.isNotEmpty) {
        final uri = Uri.parse(orderUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (mounted) {
            setState(() => _isWaitingForPayment = true);
          }
        } else {
          _showError('Không thể mở liên kết thanh toán.');
        }
      } else {
        _showError('Không tìm thấy order_url trong phản hồi.');
      }
    } else {
      _showError(result['message'] ?? 'Tạo giao dịch thất bại.');
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
            const Text('Lỗi'),
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
    final sheetHeight = MediaQuery.of(context).size.height * 0.75;
    final isDark = context.isDarkMode;

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
              ? _buildResultScreen(isDark)
              : _isLoading
                  ? _buildLoadingScreen(isDark)
                  : _isWaitingForPayment
                      ? _buildWaitingScreen(isDark)
                      : _buildCheckoutContent(isDark),
        ),
      ),
    );
  }

  Widget _buildCheckoutContent(bool isDark) {
    final ext = widget.trip.latestExtension;
    final amount = ext?.extensionAmount ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
          decoration: BoxDecoration(
            color: context.cardColor,
            border: Border(
              bottom: BorderSide(color: context.border, width: 0.5),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: context.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.payment_outlined,
                      color: context.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thanh toán phí gia hạn',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                      Text(
                        'Thời gian còn lại: ${_formatTimer(_secondsRemaining)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: _secondsRemaining < 120
                              ? AppColors.error
                              : context.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: context.textSecondary),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Extension details card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chi tiết gia hạn',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        'Thời gian trả xe ban đầu',
                        _formatDate(widget.trip.endAt.toIso8601String()),
                        isDark,
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        'Thời gian trả xe mới',
                        _formatDate(ext?.endDate),
                        isDark,
                        isHighlight: true,
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        'Số ngày gia hạn',
                        '${ext?.extendedDays ?? 0} ngày',
                        isDark,
                      ),
                      Divider(
                        height: 24,
                        color: isDark
                            ? Colors.grey.shade700
                            : Colors.grey.shade200,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tổng phí gia hạn',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: context.textPrimary,
                            ),
                          ),
                          Text(
                            _currencyFormat.format(amount),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: context.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Payment method
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF007aff).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'ZaloPay',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF007aff),
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
                                fontWeight: FontWeight.bold,
                                color: context.textPrimary,
                              ),
                            ),
                            Text(
                              'QR Code, thẻ ngân hàng',
                              style: TextStyle(
                                fontSize: 12,
                                color: context.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.check_circle,
                        color: context.primaryColor,
                        size: 22,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Note
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.amber.shade900.withOpacity(0.2)
                        : Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: isDark
                            ? Colors.amber.shade300
                            : Colors.amber.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Thanh toán 100% phí gia hạn để hoàn tất gia hạn chuyến đi. Thời gian trả xe sẽ được cập nhật sau khi thanh toán thành công.',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? Colors.amber.shade200
                                : Colors.amber.shade800,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Pay button
        Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: MediaQuery.of(context).padding.bottom + 12,
          ),
          decoration: BoxDecoration(
            color: context.cardColor,
            border: Border(
              top: BorderSide(color: context.border, width: 0.5),
            ),
          ),
          child: ElevatedButton(
            onPressed: _handlePayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: Text(
              'Thanh toán ${_currencyFormat.format(amount)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark,
      {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: context.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isHighlight
                ? Colors.amber.shade700
                : context.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingScreen(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: context.primaryColor),
          const SizedBox(height: 20),
          Text(
            _loadingMessage,
            style: TextStyle(
              color: context.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingScreen(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hourglass_top_outlined,
              size: 48,
              color: context.primaryColor,
            ),
            const SizedBox(height: 20),
            Text(
              'Đang chờ thanh toán gia hạn...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Vui lòng hoàn tất thanh toán trên ZaloPay.\nQuay lại app sau khi đã thanh toán.',
              style: TextStyle(
                color: context.textSecondary,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              _formatTimer(_secondsRemaining),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: _secondsRemaining < 120
                    ? AppColors.error
                    : context.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: _autoVerifyPayment,
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                side: BorderSide(color: context.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Kiểm tra trạng thái',
                style: TextStyle(
                  color: context.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                setState(() {
                  _paymentCompleted = true;
                  _isSuccess = true;
                  _isWaitingForPayment = false;
                  _transactionId = 'MOCK-EXT-${widget.trip.id}-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}';
                });
                AppToast.show(
                  context,
                  message: 'Giả lập thanh toán gia hạn thành công!',
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
      ),
    );
  }

  Widget _buildResultScreen(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isSuccess
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.error.withOpacity(0.1),
              ),
              child: Icon(
                _isSuccess ? Icons.check_circle : Icons.cancel,
                size: 56,
                color: _isSuccess ? AppColors.success : AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _isSuccess
                  ? 'Thanh toán gia hạn thành công!'
                  : 'Thanh toán thất bại',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            if (_transactionId != null) ...[
              const SizedBox(height: 8),
              Text(
                'Mã giao dịch: $_transactionId',
                style: TextStyle(
                  fontSize: 12,
                  color: context.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (_isSuccess) {
                    widget.onPaymentSuccess();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Đóng',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
