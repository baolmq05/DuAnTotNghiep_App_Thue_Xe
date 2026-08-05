import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../themes/app_colors.dart';
import '../../models/trip_model.dart';
import '../../services/trip_service.dart';
import '../../widgets/app_toast.dart';

/// Bottom sheet cho khách thuê chọn ngày gia hạn và gửi yêu cầu
class ExtensionRequestSheet extends StatefulWidget {
  final TripModel trip;
  final VoidCallback onExtensionSuccess;

  const ExtensionRequestSheet({
    super.key,
    required this.trip,
    required this.onExtensionSuccess,
  });

  @override
  State<ExtensionRequestSheet> createState() => _ExtensionRequestSheetState();
}

class _ExtensionRequestSheetState extends State<ExtensionRequestSheet> {
  final TripService _tripService = TripService();
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  DateTime? _selectedEndDate;
  TimeOfDay _selectedEndTime = const TimeOfDay(hour: 21, minute: 0);
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Mặc định chọn ngày trả xe hiện tại + 1 ngày
    _selectedEndDate = widget.trip.endAt.add(const Duration(days: 1));
    // Giữ giờ trả xe ban đầu
    _selectedEndTime = TimeOfDay(
      hour: widget.trip.endAt.hour,
      minute: widget.trip.endAt.minute,
    );
  }

  double get _unitPrice => widget.trip.car?.unitPrice ?? 0;

  int get _extensionDays {
    if (_selectedEndDate == null) return 1;
    final newEnd = DateTime(
      _selectedEndDate!.year,
      _selectedEndDate!.month,
      _selectedEndDate!.day,
      _selectedEndTime.hour,
      _selectedEndTime.minute,
    );
    final currentEnd = widget.trip.endAt;
    final diffMinutes = newEnd.difference(currentEnd).inMinutes;
    if (diffMinutes <= 0) return 1;
    return (diffMinutes / 1440).ceil().clamp(1, 365);
  }

  double get _extensionAmount => _extensionDays * _unitPrice;

  DateTime get _minDate => widget.trip.endAt.add(const Duration(days: 1));

  String _formatDate(DateTime date) {
    const weekdays = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    String pad(int v) => v.toString().padLeft(2, '0');
    final weekdayStr = weekdays[date.weekday % 7];
    return '$weekdayStr, ${pad(date.day)}/${pad(date.month)}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    String pad(int v) => v.toString().padLeft(2, '0');
    return '${pad(date.hour)}:${pad(date.minute)} - ${pad(date.day)}/${pad(date.month)}/${date.year}';
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate ?? _minDate,
      firstDate: _minDate,
      lastDate: DateTime.now().add(const Duration(days: 90)),
      locale: const Locale('vi', 'VN'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: context.primaryColor,
              onPrimary: Colors.white,
              surface: context.cardColor,
              onSurface: context.textPrimary,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: context.cardColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedEndDate = picked);
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: context.primaryColor,
              onPrimary: Colors.white,
              surface: context.cardColor,
              onSurface: context.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedEndTime = picked);
    }
  }

  Future<void> _submitExtension() async {
    if (_selectedEndDate == null) return;
    setState(() => _isSubmitting = true);

    try {
      final end = DateTime(
        _selectedEndDate!.year,
        _selectedEndDate!.month,
        _selectedEndDate!.day,
        _selectedEndTime.hour,
        _selectedEndTime.minute,
      );

      final endFormatted =
          '${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')} '
          '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}:00';

      final result = await _tripService.requestExtension(
        widget.trip.id,
        endDate: endFormatted,
        extendedDays: _extensionDays,
        extensionAmount: _extensionAmount,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        AppToast.show(
          context,
          message: 'Đã gửi yêu cầu gia hạn thành công!',
          type: ToastType.success,
        );
        Navigator.pop(context);
        widget.onExtensionSuccess();
      } else {
        AppToast.show(
          context,
          message: result['message'] ?? 'Gửi yêu cầu gia hạn thất bại.',
          type: ToastType.error,
        );
      }
    } catch (e) {
      if (!mounted) return;
      AppToast.show(
        context,
        message: 'Có lỗi xảy ra khi gửi yêu cầu gia hạn.',
        type: ToastType.error,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 8,
          bottom: MediaQuery.of(context).padding.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.calendar_month_outlined,
                    color: context.primaryColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gia hạn chuyến đi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Chọn ngày và giờ trả xe mới',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: context.textSecondary),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Current end date info
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'THỜI GIAN TRẢ XE HIỆN TẠI',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: context.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDateTime(widget.trip.endAt),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'ĐƠN GIÁ THUÊ',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: context.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_currencyFormat.format(_unitPrice)} / ngày',
                        style: TextStyle(
                          fontSize: 14,
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

            // Date & Time pickers
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildPickerButton(
                    icon: Icons.calendar_today_outlined,
                    label: 'NGÀY TRẢ XE MỚI',
                    value: _selectedEndDate != null
                        ? _formatDate(_selectedEndDate!)
                        : 'Chọn ngày',
                    onTap: _pickEndDate,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: _buildPickerButton(
                    icon: Icons.access_time_outlined,
                    label: 'GIỜ TRẢ XE',
                    value: '${_selectedEndTime.hour.toString().padLeft(2, '0')}:${_selectedEndTime.minute.toString().padLeft(2, '0')}',
                    onTap: _pickEndTime,
                    isDark: isDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Extension summary
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.primaryColor.withOpacity(isDark ? 0.15 : 0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: context.primaryColor.withOpacity(isDark ? 0.3 : 0.15),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Số ngày gia hạn thêm',
                        style: TextStyle(
                          fontSize: 13,
                          color: context.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '$_extensionDays ngày',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: context.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    height: 20,
                    color: context.primaryColor.withOpacity(0.15),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Phí gia hạn dự kiến',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                      ),
                      Text(
                        _currencyFormat.format(_extensionAmount),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: context.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.amber.shade900.withOpacity(0.2) : Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: isDark ? Colors.amber.shade300 : Colors.amber.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Yêu cầu gia hạn sẽ được gửi đến chủ xe để phê duyệt. Sau khi được duyệt, bạn cần thanh toán phí gia hạn để hoàn tất.',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.amber.shade200 : Colors.amber.shade800,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Hủy',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: context.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitExtension,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Xác nhận gia hạn',
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
          ],
        ),
      ),
    );
  }

  Widget _buildPickerButton({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 12, color: context.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: context.textSecondary,
                      letterSpacing: 0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
