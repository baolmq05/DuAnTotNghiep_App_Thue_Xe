import 'package:duantotnghiep_app_thue_xe/components/home_components/home_car_card.dart';
import 'package:duantotnghiep_app_thue_xe/components/vehicle_list_components/vehicle_filter_sheet.dart';
import 'package:duantotnghiep_app_thue_xe/models/car_model.dart';
import 'package:duantotnghiep_app_thue_xe/services/car_service.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/favorite_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../widgets/app_toast.dart';

class VehicleListView extends StatefulWidget {
  final Map<String, String> queryParameters;

  const VehicleListView({super.key, this.queryParameters = const {}});

  @override
  State<VehicleListView> createState() => _VehicleListViewState();
}

class _VehicleListViewState extends State<VehicleListView> {
  final CarService _carService = CarService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<Car> _cars = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  int _visibleCount = 8;

  // Local Filter States
  String _address = '';
  DateTime? _pickupDate;
  TimeOfDay? _pickupTime;
  DateTime? _returnDate;
  TimeOfDay? _returnTime;

  String? _selectedSeatCount;
  String? _selectedTransmission;
  String? _selectedFuelType;
  String? _selectedBrandId;
  String? _selectedTypeId;
  double? _minPrice;
  double? _maxPrice;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);

    // Parse initial query parameters
    _address = _readQueryValue(['address', 'location']);

    final parsedPickupDateTime = _queryDateTime(['startDate']);
    if (parsedPickupDateTime != null) {
      _pickupDate = parsedPickupDateTime;
      _pickupTime = TimeOfDay.fromDateTime(parsedPickupDateTime);
    } else {
      _pickupDate = _parseDate(_readQueryValue(['pickupDate']));
      _pickupTime = _parseTime(_readQueryValue(['pickupTime']));
    }

    final parsedReturnDateTime = _queryDateTime(['endDate']);
    if (parsedReturnDateTime != null) {
      _returnDate = parsedReturnDateTime;
      _returnTime = TimeOfDay.fromDateTime(parsedReturnDateTime);
    } else {
      _returnDate = _parseDate(_readQueryValue(['returnDate']));
      _returnTime = _parseTime(_readQueryValue(['returnTime']));
    }

    // Default dates if null
    _pickupDate ??= DateTime.now().add(const Duration(days: 1));
    _pickupTime ??= const TimeOfDay(hour: 9, minute: 0);
    _returnDate ??= DateTime.now().add(const Duration(days: 3));
    _returnTime ??= const TimeOfDay(hour: 9, minute: 0);

    final carType = _readQueryValue(['carType']);
    if (carType.isNotEmpty) {
      if (RegExp(r'^\d+$').hasMatch(carType)) {
        _selectedSeatCount = carType;
      } else if (carType.toLowerCase() == 'ev') {
        _selectedFuelType = 'Điện';
      }
    }

    final brandId = _readQueryValue(['brand_id']);
    _selectedBrandId = brandId.isEmpty ? null : brandId;

    final typeId = _readQueryValue(['type_id']);
    _selectedTypeId = typeId.isEmpty ? null : typeId;

    final minPriceStr = _readQueryValue(['min_price']);
    if (minPriceStr.isNotEmpty) {
      _minPrice = double.tryParse(minPriceStr);
    }
    final maxPriceStr = _readQueryValue(['max_price']);
    if (maxPriceStr.isNotEmpty) {
      _maxPrice = double.tryParse(maxPriceStr);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoriteViewModel>().fetchFavorites();
    });
    _fetchCars();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchCars() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cars = await _carService.getCars(
        queryParameters: _backendQueryParameters,
      );
      if (!mounted) return;
      setState(() {
        _cars = cars;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;

    final reachedBottom =
        _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200;

    if (reachedBottom && _visibleCount < _filteredCars.length) {
      setState(() {
        _visibleCount += 8;
      });
    }
  }

  String _readQueryValue(List<String> keys) {
    for (final key in keys) {
      final value = widget.queryParameters[key];
      if (value != null && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return '';
  }

  DateTime? _parseDate(String value) {
    if (value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  TimeOfDay? _parseTime(String value) {
    if (value.isEmpty) return null;
    final parts = value.split(':');
    if (parts.length != 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;

    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatDate(DateTime date) {
    const weekdays = ['Th2', 'Th3', 'Th4', 'Th5', 'Th6', 'Th7', 'CN'];
    final weekday = weekdays[date.weekday - 1];
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$weekday, $day/$month/${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatBackendDateTime(DateTime dateTime) {
    final year = dateTime.year.toString().padLeft(4, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute:$second';
  }

  DateTime? _combineDateAndTime(DateTime? date, TimeOfDay? time) {
    if (date == null || time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  DateTime? _parseDateTimeValue(String value) {
    if (value.isEmpty) return null;
    return DateTime.tryParse(value.replaceFirst(' ', 'T')) ??
        DateTime.tryParse(value);
  }

  DateTime? _queryDateTime(List<String> keys) {
    for (final key in keys) {
      final value = widget.queryParameters[key];
      if (value != null && value.trim().isNotEmpty) {
        final parsed = _parseDateTimeValue(value.trim());
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  String _getCleanedLocationForBackend(String rawAddress) {
    if (rawAddress.isEmpty) return '';
    final lower = rawAddress.toLowerCase();

    // Check for common cities in Vietnam
    if (lower.contains('hồ chí minh') ||
        lower.contains('hcm') ||
        lower.contains('sài gòn') ||
        lower.contains('sai gon')) {
      return 'Hồ Chí Minh';
    }
    if (lower.contains('hà nội') || lower.contains('ha noi')) {
      return 'Hà Nội';
    }
    if (lower.contains('đà nẵng') || lower.contains('da nang')) {
      return 'Đà Nẵng';
    }
    if (lower.contains('bình dương') || lower.contains('binh duong')) {
      return 'Bình Dương';
    }
    if (lower.contains('đồng nai') || lower.contains('dong nai')) {
      return 'Đồng Nai';
    }
    if (lower.contains('cần thơ') || lower.contains('can tho')) {
      return 'Cần Thơ';
    }
    if (lower.contains('hải phòng') || lower.contains('hai phong')) {
      return 'Hải Phòng';
    }
    if (lower.contains('vũng tàu') ||
        lower.contains('bà rịa') ||
        lower.contains('vung tau') ||
        lower.contains('ba ria')) {
      return 'Vũng Tàu';
    }
    if (lower.contains('nha trang') ||
        lower.contains('khánh hòa') ||
        lower.contains('khanh hoa')) {
      return 'Khánh Hòa';
    }
    if (lower.contains('đà lạt') ||
        lower.contains('lâm đồng') ||
        lower.contains('lam dong')) {
      return 'Lâm Đồng';
    }

    // Split by comma and try to take the last segment (which is usually the city/province)
    final segments = rawAddress.split(',');
    if (segments.isNotEmpty) {
      final lastSegment = segments.last.trim();
      String cleaned = lastSegment
          .replaceFirst(
            RegExp(
              r'^(TP\.|TP|Thành phố|Tỉnh|Thành Phố)\s+',
              caseSensitive: false,
            ),
            '',
          )
          .trim();
      if (cleaned.isNotEmpty) {
        return cleaned;
      }
    }

    return rawAddress;
  }

  bool _isAddressMatch(String query, String carAddress) {
    if (query.isEmpty) return true;
    if (carAddress.isEmpty) return false;

    final q = query.toLowerCase();
    final c = carAddress.toLowerCase();

    // 1. Direct check
    if (c.contains(q) || q.contains(c)) return true;

    // 2. City-based check
    final qIsHCM =
        q.contains('hồ chí minh') ||
        q.contains('hcm') ||
        q.contains('sài gòn') ||
        q.contains('sai gon');
    final cIsHCM =
        c.contains('hồ chí minh') ||
        c.contains('hcm') ||
        c.contains('sài gòn') ||
        c.contains('sai gon');
    if (qIsHCM && cIsHCM) return true;

    final qIsHN = q.contains('hà nội') || q.contains('ha noi');
    final cIsHN = c.contains('hà nội') || c.contains('ha noi');
    if (qIsHN && cIsHN) return true;

    final qIsDN = q.contains('đà nẵng') || q.contains('da nang');
    final cIsDN = c.contains('đà nẵng') || c.contains('da nang');
    if (qIsDN && cIsDN) return true;

    // 3. Segment match (excluding common words)
    final qSegments = q
        .split(RegExp(r'[,.\-\s]+'))
        .map((s) => s.trim())
        .where((s) => s.length >= 3)
        .toList();
    final cSegments = c
        .split(RegExp(r'[,.\-\s]+'))
        .map((s) => s.trim())
        .where((s) => s.length >= 3)
        .toList();

    const stopWords = {
      'quận',
      'huyện',
      'tỉnh',
      'thành',
      'phố',
      'phường',
      'đường',
      'viet',
      'nam',
      'việt',
    };

    for (final qs in qSegments) {
      if (stopWords.contains(qs)) continue;
      for (final cs in cSegments) {
        if (stopWords.contains(cs)) continue;
        if (qs == cs || cs.contains(qs) || qs.contains(cs)) {
          return true;
        }
      }
    }

    return false;
  }

  Map<String, String> get _backendQueryParameters {
    final queryParameters = <String, String>{};

    final cleanedAddress = _getCleanedLocationForBackend(_address);
    if (cleanedAddress.trim().isNotEmpty) {
      queryParameters['address'] = cleanedAddress.trim();
    }

    final pickupDateTime = _combineDateAndTime(_pickupDate, _pickupTime);
    final returnDateTime = _combineDateAndTime(_returnDate, _returnTime);

    if (pickupDateTime != null) {
      queryParameters['startDate'] = _formatBackendDateTime(pickupDateTime);
    }
    if (returnDateTime != null) {
      queryParameters['endDate'] = _formatBackendDateTime(returnDateTime);
    }

    if (_selectedSeatCount != null &&
        RegExp(r'^\d+$').hasMatch(_selectedSeatCount!)) {
      queryParameters['seat_count'] = _selectedSeatCount!;
    }

    if (_selectedBrandId != null && _selectedBrandId!.isNotEmpty) {
      queryParameters['brand_id'] = _selectedBrandId!;
    }

    if (_minPrice != null) {
      queryParameters['min_price'] = _minPrice!.toInt().toString();
    }
    if (_maxPrice != null) {
      queryParameters['max_price'] = _maxPrice!.toInt().toString();
    }

    if (_selectedTypeId != null && _selectedTypeId!.isNotEmpty) {
      queryParameters['type_id'] = _selectedTypeId!;
    }

    for (final key in ['user_id', 'status']) {
      final value = widget.queryParameters[key];
      if (value != null && value.trim().isNotEmpty) {
        queryParameters[key] = value.trim();
      }
    }

    return queryParameters;
  }

  List<Car> get _filteredCars {
    var cars = List<Car>.from(_cars);

    // Apply local fuzzy matching for address
    if (_address.isNotEmpty) {
      cars = cars.where((car) {
        final carAddress =
            car.carLocation?.address ?? car.carLocation?.location ?? '';
        return _isAddressMatch(_address, carAddress);
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final search = _searchQuery.toLowerCase();
      cars = cars.where((car) {
        final location =
            car.carLocation?.address ?? car.carLocation?.location ?? '';
        return car.name.toLowerCase().contains(search) ||
            location.toLowerCase().contains(search) ||
            car.fuelType.toLowerCase().contains(search);
      }).toList();
    }

    // Filter by transmission (local filter)
    if (_selectedTransmission != null) {
      final trans = _selectedTransmission!.toLowerCase();
      cars = cars.where((car) {
        final carTrans = car.transmission.toLowerCase();
        if (trans == 'tự động') {
          return carTrans.contains('tự động') || carTrans.contains('auto');
        } else {
          return carTrans.contains('số sàn') || carTrans.contains('manual');
        }
      }).toList();
    }

    // Filter by fuel type (local filter)
    if (_selectedFuelType != null) {
      final fuel = _selectedFuelType!.toLowerCase();
      cars = cars.where((car) {
        final carFuel = car.fuelType.toLowerCase();
        if (fuel == 'điện') {
          return carFuel.contains('điện') || carFuel.contains('electric');
        } else if (fuel == 'xăng') {
          return carFuel.contains('xăng') ||
              carFuel.contains('gasoline') ||
              carFuel.contains('petrol');
        } else if (fuel == 'dầu') {
          return carFuel.contains('dầu') || carFuel.contains('diesel');
        }
        return true;
      }).toList();
    }

    return cars;
  }

  int get _activeFiltersCount {
    int count = 0;
    if (_address.isNotEmpty) count++;
    if (_selectedSeatCount != null) count++;
    if (_selectedTransmission != null) count++;
    if (_selectedFuelType != null) count++;
    if (_selectedBrandId != null) count++;
    if (_minPrice != null && _minPrice! > 0) count++;
    if (_maxPrice != null && _maxPrice! < 3000000.0) count++;
    return count;
  }

  void _showFilterSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VehicleFilterSheet(
        initialAddress: _address,
        initialPickupDate: _pickupDate,
        initialPickupTime: _pickupTime,
        initialReturnDate: _returnDate,
        initialReturnTime: _returnTime,
        initialSeatCount: _selectedSeatCount,
        initialTransmission: _selectedTransmission,
        initialFuelType: _selectedFuelType,
        initialBrandId: _selectedBrandId,
        initialMinPrice: _minPrice,
        initialMaxPrice: _maxPrice,
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _address = result['address'] ?? _address;
        _pickupDate = result['pickupDate'];
        _pickupTime = result['pickupTime'];
        _returnDate = result['returnDate'];
        _returnTime = result['returnTime'];
        _selectedSeatCount = result['seatCount'];
        _selectedTransmission = result['transmission'];
        _selectedFuelType = result['fuelType'];
        _selectedBrandId = result['brandId'];
        _minPrice = result['minPrice'];
        _maxPrice = result['maxPrice'];
        _visibleCount = 8;
      });
      _fetchCars();
    }
  }

  Widget _buildFilterTriggerChip() {
    final count = _activeFiltersCount;
    final hasFilters = count > 0;
    return InkWell(
      onTap: _showFilterSheet,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: hasFilters ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasFilters ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune_rounded,
              size: 16,
              color: hasFilters ? Colors.white : AppColors.textPrimary,
            ),
            const SizedBox(width: 6),
            Text(
              hasFilters ? 'Bộ lọc ($count)' : 'Bộ lọc',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: hasFilters ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickFilterChip({
    required String label,
    required bool isSelected,
    required ValueChanged<bool> onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: isSelected ? Colors.white : AppColors.textPrimary,
      ),
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
      ),
      showCheckmark: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredCars = _filteredCars;
    final visibleCars = filteredCars.take(_visibleCount).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text(
          'Danh sách xe',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchCars,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Search Bar header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: InkWell(
                  onTap: _showFilterSheet,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: AppColors.border.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _address.isNotEmpty
                                    ? _address
                                    : 'Tất cả địa điểm',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_formatDate(_pickupDate!)} (${_formatTime(_pickupTime!)}) - ${_formatDate(_returnDate!)} (${_formatTime(_returnTime!)})',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit_location_alt_outlined,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Quick filters horizontal scroll
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  spacing: 8,
                  children: [
                    // Main Filter Trigger
                    _buildFilterTriggerChip(),

                    // Seats Quick Chips
                    _buildQuickFilterChip(
                      label: '4 chỗ',
                      isSelected: _selectedSeatCount == '4',
                      onSelected: (selected) {
                        setState(() {
                          _selectedSeatCount = selected ? '4' : null;
                          _visibleCount = 8;
                        });
                        _fetchCars();
                      },
                    ),
                    _buildQuickFilterChip(
                      label: '5 chỗ',
                      isSelected: _selectedSeatCount == '5',
                      onSelected: (selected) {
                        setState(() {
                          _selectedSeatCount = selected ? '5' : null;
                          _visibleCount = 8;
                        });
                        _fetchCars();
                      },
                    ),
                    _buildQuickFilterChip(
                      label: '7 chỗ',
                      isSelected: _selectedSeatCount == '7',
                      onSelected: (selected) {
                        setState(() {
                          _selectedSeatCount = selected ? '7' : null;
                          _visibleCount = 8;
                        });
                        _fetchCars();
                      },
                    ),

                    // Transmission Quick Chips
                    _buildQuickFilterChip(
                      label: 'Tự động',
                      isSelected: _selectedTransmission == 'Tự động',
                      onSelected: (selected) {
                        setState(() {
                          _selectedTransmission = selected ? 'Tự động' : null;
                          _visibleCount = 8;
                        });
                      },
                    ),
                    _buildQuickFilterChip(
                      label: 'Số sàn',
                      isSelected: _selectedTransmission == 'Số sàn',
                      onSelected: (selected) {
                        setState(() {
                          _selectedTransmission = selected ? 'Số sàn' : null;
                          _visibleCount = 8;
                        });
                      },
                    ),

                    // Fuel Quick Chips
                    _buildQuickFilterChip(
                      label: 'Điện',
                      isSelected: _selectedFuelType == 'Điện',
                      onSelected: (selected) {
                        setState(() {
                          _selectedFuelType = selected ? 'Điện' : null;
                          _visibleCount = 8;
                        });
                      },
                    ),
                    _buildQuickFilterChip(
                      label: 'Xăng',
                      isSelected: _selectedFuelType == 'Xăng',
                      onSelected: (selected) {
                        setState(() {
                          _selectedFuelType = selected ? 'Xăng' : null;
                          _visibleCount = 8;
                        });
                      },
                    ),
                    _buildQuickFilterChip(
                      label: 'Dầu',
                      isSelected: _selectedFuelType == 'Dầu',
                      onSelected: (selected) {
                        setState(() {
                          _selectedFuelType = selected ? 'Dầu' : null;
                          _visibleCount = 8;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Text search field
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _visibleCount = 8;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Tìm theo tên xe, địa điểm, từ khóa...',
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    suffixIcon: _searchQuery.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                                _searchController.clear();
                                _visibleCount = 8;
                              });
                            },
                            icon: const Icon(Icons.clear_rounded, size: 20),
                          ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.border.withOpacity(0.5),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.border.withOpacity(0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
            ),

            // Result count chip info
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(
                      avatar: const Icon(
                        Icons.directions_car_outlined,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      label: Text('${filteredCars.length} xe phù hợp'),
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: AppColors.primary.withOpacity(0.12),
                      ),
                      labelStyle: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    if (_activeFiltersCount > 0)
                      ActionChip(
                        avatar: const Icon(
                          Icons.clear_all_rounded,
                          size: 16,
                          color: Colors.red,
                        ),
                        label: const Text('Xóa tất cả bộ lọc'),
                        onPressed: () {
                          setState(() {
                            _address = '';
                            _selectedSeatCount = null;
                            _selectedTransmission = null;
                            _selectedFuelType = null;
                            _selectedBrandId = null;
                            _minPrice = null;
                            _maxPrice = null;
                            _searchQuery = '';
                            _searchController.clear();
                            _visibleCount = 8;
                          });
                          _fetchCars();
                        },
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.red.withOpacity(0.2)),
                        labelStyle: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            if (_isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_errorMessage != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 52,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage ?? 'Đã xảy ra lỗi',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchCars,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                          child: const Text(
                            'Thử lại',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (filteredCars.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE9F3F4),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: const Icon(
                            Icons.directions_car_outlined,
                            size: 42,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Không tìm thấy xe phù hợp',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Thử đổi địa điểm hoặc từ khóa tìm kiếm để xem thêm xe.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _address = '';
                              _selectedSeatCount = null;
                              _selectedTransmission = null;
                              _selectedFuelType = null;
                              _selectedBrandId = null;
                              _minPrice = null;
                              _maxPrice = null;
                              _searchQuery = '';
                              _searchController.clear();
                              _visibleCount = 8;
                            });
                            _fetchCars();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                          ),
                          child: const Text('Xem tất cả xe'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
                sliver: SliverList.separated(
                  itemCount: visibleCars.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    final car = visibleCars[index];
                    return Consumer<FavoriteViewModel>(
                      builder: (context, favoriteVM, _) {
                        return HomeCarCard(
                          width: double.infinity,
                          car: car,
                          isFavorite: favoriteVM.isFavorite(car.id),
                          onFavoriteTap: () {
                            final currentlyFavorite = favoriteVM.isFavorite(
                              car.id,
                            );
                            favoriteVM.toggleFavorite(carId: car.id, car: car);
                            if (context.mounted) {
                              if (currentlyFavorite) {
                                AppToast.show(
                                  context,
                                  message: "Đã xóa xe khỏi danh sách yêu thích",
                                  type: ToastType.info,
                                );
                              } else {
                                AppToast.show(
                                  context,
                                  message:
                                      "Đã thêm xe vào danh sách yêu thích thành công!",
                                  type: ToastType.success,
                                );
                              }
                            }
                          },
                          onTap: () {
                            context.push('/car_detail/${car.id}');
                          },
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
