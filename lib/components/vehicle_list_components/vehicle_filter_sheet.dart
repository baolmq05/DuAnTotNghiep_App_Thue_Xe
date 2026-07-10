import 'package:duantotnghiep_app_thue_xe/models/CarDetail/car_brand_model.dart';
import 'package:duantotnghiep_app_thue_xe/services/car_service.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:flutter/material.dart';

class VehicleFilterSheet extends StatefulWidget {
  final String initialAddress;
  final DateTime? initialPickupDate;
  final TimeOfDay? initialPickupTime;
  final DateTime? initialReturnDate;
  final TimeOfDay? initialReturnTime;
  final String? initialSeatCount;
  final String? initialTransmission;
  final String? initialFuelType;
  final String? initialBrandId;
  final double? initialMinPrice;
  final double? initialMaxPrice;

  const VehicleFilterSheet({
    super.key,
    this.initialAddress = '',
    this.initialPickupDate,
    this.initialPickupTime,
    this.initialReturnDate,
    this.initialReturnTime,
    this.initialSeatCount,
    this.initialTransmission,
    this.initialFuelType,
    this.initialBrandId,
    this.initialMinPrice,
    this.initialMaxPrice,
  });

  @override
  State<VehicleFilterSheet> createState() => _VehicleFilterSheetState();
}

class _VehicleFilterSheetState extends State<VehicleFilterSheet> {
  final CarService _carService = CarService();
  late TextEditingController _addressController;

  DateTime? _pickupDate;
  TimeOfDay? _pickupTime;
  DateTime? _returnDate;
  TimeOfDay? _returnTime;

  String? _selectedSeatCount;
  String? _selectedTransmission;
  String? _selectedFuelType;
  String? _selectedBrandId;
  
  late RangeValues _priceRange;

  List<CarBrand> _brands = [];
  bool _isLoadingBrands = true;

  // Fallback popular brands in case API fails
  final List<CarBrand> _fallbackBrands = [
    CarBrand(id: 1, brand_name: 'Toyota', createdAt: null, updatedAt: null),
    CarBrand(id: 2, brand_name: 'Hyundai', createdAt: null, updatedAt: null),
    CarBrand(id: 3, brand_name: 'Kia', createdAt: null, updatedAt: null),
    CarBrand(id: 4, brand_name: 'Mazda', createdAt: null, updatedAt: null),
    CarBrand(id: 5, brand_name: 'VinFast', createdAt: null, updatedAt: null),
    CarBrand(id: 6, brand_name: 'Honda', createdAt: null, updatedAt: null),
    CarBrand(id: 7, brand_name: 'Ford', createdAt: null, updatedAt: null),
    CarBrand(id: 8, brand_name: 'Mitsubishi', createdAt: null, updatedAt: null),
  ];

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(text: widget.initialAddress);
    _pickupDate = widget.initialPickupDate ?? DateTime.now().add(const Duration(days: 1));
    _pickupTime = widget.initialPickupTime ?? const TimeOfDay(hour: 9, minute: 0);
    _returnDate = widget.initialReturnDate ?? DateTime.now().add(const Duration(days: 3));
    _returnTime = widget.initialReturnTime ?? const TimeOfDay(hour: 9, minute: 0);
    
    _selectedSeatCount = widget.initialSeatCount;
    _selectedTransmission = widget.initialTransmission;
    _selectedFuelType = widget.initialFuelType;
    _selectedBrandId = widget.initialBrandId;

    _priceRange = RangeValues(
      widget.initialMinPrice ?? 0.0,
      widget.initialMaxPrice ?? 3000000.0,
    );

    _fetchBrands();
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _fetchBrands() async {
    try {
      final brandsList = await _carService.getCarBrands();
      if (mounted) {
        setState(() {
          _brands = brandsList;
          _isLoadingBrands = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to load brands: $e');
      if (mounted) {
        setState(() {
          _brands = _fallbackBrands;
          _isLoadingBrands = false;
        });
      }
    }
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

  String _formatPriceValue(double val) {
    if (val >= 1000000) {
      final million = val / 1000000;
      return '${million.toStringAsFixed(million.truncateToDouble() == million ? 0 : 1)}M';
    }
    return '${(val / 1000).round()}k';
  }

  Future<void> _selectPickupDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _pickupDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => _datePickerTheme(context, child),
    );
    if (picked != null) {
      setState(() {
        _pickupDate = picked;
        if (_returnDate != null && _returnDate!.isBefore(picked)) {
          _returnDate = picked.add(const Duration(days: 2));
        }
      });
    }
  }

  Future<void> _selectReturnDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _returnDate ?? (_pickupDate ?? DateTime.now()).add(const Duration(days: 2)),
      firstDate: _pickupDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => _datePickerTheme(context, child),
    );
    if (picked != null) {
      setState(() {
        _returnDate = picked;
      });
    }
  }

  Widget _datePickerTheme(BuildContext context, Widget? child) {
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
  }

  Future<void> _selectPickupTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _pickupTime ?? const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) => _datePickerTheme(context, child),
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
      initialTime: _returnTime ?? const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) => _datePickerTheme(context, child),
    );
    if (picked != null) {
      setState(() {
        _returnTime = picked;
      });
    }
  }

  void _resetFilters() {
    setState(() {
      _addressController.clear();
      _pickupDate = DateTime.now().add(const Duration(days: 1));
      _pickupTime = const TimeOfDay(hour: 9, minute: 0);
      _returnDate = DateTime.now().add(const Duration(days: 3));
      _returnTime = const TimeOfDay(hour: 9, minute: 0);
      _selectedSeatCount = null;
      _selectedTransmission = null;
      _selectedFuelType = null;
      _selectedBrandId = null;
      _priceRange = const RangeValues(0.0, 3000000.0);
    });
  }

  void _applyFilters() {
    Navigator.pop(context, {
      'address': _addressController.text.trim(),
      'pickupDate': _pickupDate,
      'pickupTime': _pickupTime,
      'returnDate': _returnDate,
      'returnTime': _returnTime,
      'seatCount': _selectedSeatCount,
      'transmission': _selectedTransmission,
      'fuelType': _selectedFuelType,
      'brandId': _selectedBrandId,
      'minPrice': _priceRange.start,
      'maxPrice': _priceRange.end,
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
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

          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bộ lọc nâng cao',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: _resetFilters,
                child: const Text(
                  'Thiết lập lại',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 10),

          // Scrollable filter contents
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: [
                // 1. Location
                _buildSectionHeader('Địa chỉ nhận xe'),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    hintText: 'Nhập thành phố, quận huyện...',
                    prefixIcon: const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.primary,
                    ),
                    suffixIcon: _addressController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                            onPressed: () {
                              setState(() {
                                _addressController.clear();
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                    filled: true,
                    fillColor: AppColors.card,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                  onChanged: (val) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 16),

                // 2. Dates & Times
                _buildSectionHeader('Thời gian thuê xe'),
                Row(
                  spacing: 12,
                  children: [
                    // Pickup selector
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Nhận xe',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: _selectPickupDate,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                                      _pickupDate != null ? _formatDate(_pickupDate!) : 'Chọn ngày',
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Icon(Icons.calendar_month_outlined, size: 16, color: AppColors.primary),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: _selectPickupTime,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(8),
                                color: AppColors.card,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _pickupTime != null ? _formatTime(_pickupTime!) : 'Chọn giờ',
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                  const Icon(Icons.access_time, size: 16, color: AppColors.primary),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Return selector
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Trả xe',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: _selectReturnDate,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                                      _returnDate != null ? _formatDate(_returnDate!) : 'Chọn ngày',
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Icon(Icons.calendar_month_outlined, size: 16, color: AppColors.primary),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: _selectReturnTime,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(8),
                                color: AppColors.card,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _returnTime != null ? _formatTime(_returnTime!) : 'Chọn giờ',
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                  const Icon(Icons.access_time, size: 16, color: AppColors.primary),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 3. Car Brand (Hãng xe)
                _buildSectionHeader('Hãng xe'),
                _isLoadingBrands
                    ? const SizedBox(
                        height: 50,
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : Container(
                        height: 46,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _brands.length,
                          itemBuilder: (context, index) {
                            final brand = _brands[index];
                            final isSelected = _selectedBrandId == brand.id.toString();
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(brand.brand_name),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedBrandId = selected ? brand.id.toString() : null;
                                  });
                                },
                                selectedColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                                backgroundColor: AppColors.card,
                                side: BorderSide(
                                  color: isSelected ? AppColors.primary : AppColors.border,
                                ),
                                showCheckmark: false,
                              ),
                            );
                          },
                        ),
                      ),

                // 4. Seats (Số chỗ)
                _buildSectionHeader('Số chỗ'),
                Row(
                  spacing: 10,
                  children: ['4', '5', '7'].map((seats) {
                    final isSelected = _selectedSeatCount == seats;
                    return Expanded(
                      child: ChoiceChip(
                        label: Center(child: Text('$seats chỗ')),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedSeatCount = selected ? seats : null;
                          });
                        },
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        backgroundColor: AppColors.card,
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                        showCheckmark: false,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // 5. Transmission (Hộp số)
                _buildSectionHeader('Hộp số'),
                Row(
                  spacing: 12,
                  children: ['Tự động', 'Số sàn'].map((trans) {
                    final isSelected = _selectedTransmission == trans;
                    return Expanded(
                      child: ChoiceChip(
                        label: Center(child: Text(trans)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedTransmission = selected ? trans : null;
                          });
                        },
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        backgroundColor: AppColors.card,
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                        showCheckmark: false,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // 6. Fuel (Nhiên liệu)
                _buildSectionHeader('Nhiên liệu'),
                Row(
                  spacing: 10,
                  children: ['Xăng', 'Dầu', 'Điện'].map((fuel) {
                    final isSelected = _selectedFuelType == fuel;
                    return Expanded(
                      child: ChoiceChip(
                        label: Center(child: Text(fuel)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedFuelType = selected ? fuel : null;
                          });
                        },
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        backgroundColor: AppColors.card,
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                        showCheckmark: false,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // 7. Price Range (Mức giá)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionHeader('Giá thuê 1 ngày'),
                    Text(
                      '${_formatPriceValue(_priceRange.start)} - ${_formatPriceValue(_priceRange.end)}${_priceRange.end >= 3000000 ? '+' : ''}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                RangeSlider(
                  values: _priceRange,
                  min: 0.0,
                  max: 3000000.0,
                  divisions: 30,
                  labels: RangeLabels(
                    _formatPriceValue(_priceRange.start),
                    _formatPriceValue(_priceRange.end),
                  ),
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.border,
                  onChanged: (values) {
                    setState(() {
                      _priceRange = values;
                    });
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Apply Button
          ElevatedButton(
            onPressed: _applyFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(double.infinity, 50),
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
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
