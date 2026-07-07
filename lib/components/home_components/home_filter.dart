import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:flutter/material.dart';

class HomeFilter extends StatefulWidget {
  const HomeFilter({super.key});

  @override
  State<HomeFilter> createState() => _HomeFilterState();
}

class _HomeFilterState extends State<HomeFilter> {
  String _address = "TP Hồ Chí Minh, Quận 1";
  DateTime _pickupDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _pickupTime = const TimeOfDay(hour: 9, minute: 0);
  DateTime _returnDate = DateTime.now().add(const Duration(days: 3));
  TimeOfDay _returnTime = const TimeOfDay(hour: 9, minute: 0);

  String _formatDate(DateTime date) {
    final weekdaysFull = ['Th2', 'Th3', 'Th4', 'Th5', 'Th6', 'Th7', 'CN'];
    final weekdayStr = weekdaysFull[date.weekday - 1];
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$weekdayStr, $day/$month/$year';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _showFilterModal(BuildContext context) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterModalBottomSheet(
        initialAddress: _address,
        initialPickupDate: _pickupDate,
        initialPickupTime: _pickupTime,
        initialReturnDate: _returnDate,
        initialReturnTime: _returnTime,
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _address = result['address'] ?? _address;
        _pickupDate = result['pickupDate'] ?? _pickupDate;
        _pickupTime = result['pickupTime'] ?? _pickupTime;
        _returnDate = result['returnDate'] ?? _returnDate;
        _returnTime = result['returnTime'] ?? _returnTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Row 1: Title and Header Image
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tìm xe phù hợp",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        wordSpacing: 1.5,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "cho hành trình của bạn",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        wordSpacing: 1,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'lib/assets/images/home/filter_banner.png',
                  height: 90,
                  width: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 90,
                      width: 90,
                      color: Colors.white24,
                      child: const Icon(
                        Icons.directions_car,
                        color: Colors.white,
                        size: 36,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Row 2: Pickup Location
          GestureDetector(
            onTap: () => _showFilterModal(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      spacing: 10,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Địa chỉ nhận xe",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _address.isEmpty
                                    ? "Nhập địa chỉ nhận xe"
                                    : _address,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.gps_fixed,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Row 3: Pickup & Return Dates/Times
          GestureDetector(
            onTap: () => _showFilterModal(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 8,
              children: [
                // Pickup
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nhận xe',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(_pickupDate),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          _formatTime(_pickupTime),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Return
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Trả xe',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(_returnDate),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          _formatTime(_returnTime),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.transparent,
            ),
            child: ElevatedButton(
              onPressed: () {
                if (_address.trim().isEmpty) {
                  _showFilterModal(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đang tìm kiếm xe tại: $_address'),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(double.infinity, 40),
              ),
              child: const Text(
                'Tìm xe',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterModalBottomSheet extends StatefulWidget {
  final String initialAddress;
  final DateTime initialPickupDate;
  final TimeOfDay initialPickupTime;
  final DateTime initialReturnDate;
  final TimeOfDay initialReturnTime;

  const _FilterModalBottomSheet({
    required this.initialAddress,
    required this.initialPickupDate,
    required this.initialPickupTime,
    required this.initialReturnDate,
    required this.initialReturnTime,
  });

  @override
  State<_FilterModalBottomSheet> createState() =>
      _FilterModalBottomSheetState();
}

class _FilterModalBottomSheetState extends State<_FilterModalBottomSheet> {
  late TextEditingController _addressController;
  late DateTime _pickupDate;
  late TimeOfDay _pickupTime;
  late DateTime _returnDate;
  late TimeOfDay _returnTime;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(text: widget.initialAddress);
    _pickupDate = widget.initialPickupDate;
    _pickupTime = widget.initialPickupTime;
    _returnDate = widget.initialReturnDate;
    _returnTime = widget.initialReturnTime;
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final weekdaysFull = ['Th2', 'Th3', 'Th4', 'Th5', 'Th6', 'Th7', 'CN'];
    final weekdayStr = weekdaysFull[date.weekday - 1];
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$weekdayStr, $day/$month/$year';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _selectPickupDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _pickupDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: Localizations.override(
            context: context,
            locale: const Locale('vi', 'VN'),
            child: child!,
          ),
        );
      },
    );
    if (picked != null) {
      setState(() {
        _pickupDate = picked;
        if (_returnDate.isBefore(_pickupDate)) {
          _returnDate = _pickupDate.add(const Duration(days: 2));
        }
      });
    }
  }

  Future<void> _selectReturnDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _returnDate,
      firstDate: _pickupDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: Localizations.override(
            context: context,
            locale: const Locale('vi', 'VN'),
            child: child!,
          ),
        );
      },
    );
    if (picked != null) {
      setState(() {
        _returnDate = picked;
      });
    }
  }

  Future<void> _selectPickupTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _pickupTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: Localizations.override(
            context: context,
            locale: const Locale('vi', 'VN'),
            child: child!,
          ),
        );
      },
    );
    if (picked != null) {
      setState(() {
        _pickupTime = picked;
      });
    }
  }

  Future<void> _selectReturnTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _returnTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: Localizations.override(
            context: context,
            locale: const Locale('vi', 'VN'),
            child: child!,
          ),
        );
      },
    );
    if (picked != null) {
      setState(() {
        _returnTime = picked;
      });
    }
  }

  void _applyFilter() {
    Navigator.pop(context, {
      'address': _addressController.text.trim(),
      'pickupDate': _pickupDate,
      'pickupTime': _pickupTime,
      'returnDate': _returnDate,
      'returnTime': _returnTime,
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 20 + bottomInset,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle Bar for BottomSheet
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Bộ lọc tìm kiếm',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),

            // Section 1: Địa chỉ nhận xe
            const Text(
              'Địa chỉ nhận xe',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                hintText: 'Nhập thành phố, quận huyện...',
                prefixIcon: const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.primary,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () => _addressController.clear(),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
                filled: true,
                fillColor: AppColors.card,
              ),
            ),
            const SizedBox(height: 20),

            // Section 2: Thời gian nhận xe & trả xe
            const Text(
              'Thời gian thuê xe',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),

            // Row for Pickup & Return Dates/Times
            Row(
              spacing: 12,
              children: [
                // Pickup Date/Time selectors
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nhận xe',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Date trigger
                      InkWell(
                        onTap: _selectPickupDate,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(8),
                            color: AppColors.card,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  _formatDate(_pickupDate),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(
                                Icons.calendar_month_outlined,
                                size: 18,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Time trigger
                      InkWell(
                        onTap: _selectPickupTime,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(8),
                            color: AppColors.card,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatTime(_pickupTime),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              const Icon(
                                Icons.access_time,
                                size: 18,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Return Date/Time selectors
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Trả xe',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Date trigger
                      InkWell(
                        onTap: _selectReturnDate,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(8),
                            color: AppColors.card,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  _formatDate(_returnDate),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(
                                Icons.calendar_month_outlined,
                                size: 18,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Time trigger
                      InkWell(
                        onTap: _selectReturnTime,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(8),
                            color: AppColors.card,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatTime(_returnTime),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              const Icon(
                                Icons.access_time,
                                size: 18,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Confirm/Search Button
            ElevatedButton(
              onPressed: _applyFilter,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text(
                'Áp dụng bộ lọc',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
