import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:duantotnghiep_app_thue_xe/models/trip_model.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/trip_viewmodel.dart';
import 'package:duantotnghiep_app_thue_xe/services/car_service.dart';
import 'package:duantotnghiep_app_thue_xe/services/promotion_service.dart';
import 'package:duantotnghiep_app_thue_xe/services/base_service.dart';
import 'package:duantotnghiep_app_thue_xe/widgets/app_toast.dart';

// Components
import 'package:duantotnghiep_app_thue_xe/components/booking_components/booking_car_info_card.dart';
import 'package:duantotnghiep_app_thue_xe/components/booking_components/booking_rental_time_card.dart';
import 'package:duantotnghiep_app_thue_xe/components/booking_components/booking_delivery_method_card.dart';
import 'package:duantotnghiep_app_thue_xe/components/booking_components/booking_promo_code_card.dart';
import 'package:duantotnghiep_app_thue_xe/components/booking_components/booking_price_breakdown_card.dart';

class BookingCarView extends StatefulWidget {
  final int carId;

  const BookingCarView({super.key, required this.carId});

  @override
  State<BookingCarView> createState() => _BookingCarViewState();
}

class _BookingCarViewState extends State<BookingCarView> {
  CarModel? car;
  bool isPageLoading = true;
  List<TripModel> carActiveTrips = [];

  DateTime? startDate;
  DateTime? endDate;

  bool isDeliveryToLocation = false;
  bool isTermsAgreed = true;
  bool isCalculatingMap = false;
  bool hasDistanceError = false;

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _promoController = TextEditingController();

  int totalDays = 0;
  double baseRentalPrice = 0.0;
  double carDiscountTotal = 0.0;

  double? carLatitude;
  double? carLongitude;

  double? customerLatitude;
  double? customerLongitude;
  double distanceInKm = 0.0;
  double promoDiscount = 0.0;

  final List<BoxShadow> _cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.02),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _promoController.text = "";

    final now = DateTime.now();
    startDate = DateTime(now.year, now.month, now.day + 1, 9, 0);
    endDate = DateTime(now.year, now.month, now.day + 3, 17, 0);

    _updateTotalDays();
    _fetchCarDetailFromServer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyPromoCode(showFeedback: false);
    });
  }

  void _updateTotalDays() {
    if (startDate != null && endDate != null) {
      int diffMinutes = endDate!.difference(startDate!).inMinutes;
      totalDays = (diffMinutes / 1440).ceil();
      if (totalDays < 1) totalDays = 1;

      if (car != null) {
        baseRentalPrice = car!.unitPrice * totalDays;
        carDiscountTotal = car!.discountValue * totalDays;

        if (_promoController.text.isNotEmpty && promoDiscount > 0.0) {
          _applyPromoCode(showFeedback: false);
        }
      }
    }
  }

  void onDateTimeChanged(DateTime newStart, DateTime newEnd) {
    setState(() {
      startDate = newStart;
      endDate = newEnd;
      _updateTotalDays();
    });
  }

  bool _isCarBusy(DateTime start, DateTime end) {
    for (var trip in carActiveTrips) {
      if (start.isBefore(trip.endAt) && end.isAfter(trip.startAt)) {
        return true;
      }
    }
    return false;
  }

  TripModel? _getOverlappingTrip(DateTime start, DateTime end) {
    for (var trip in carActiveTrips) {
      if (start.isBefore(trip.endAt) && end.isAfter(trip.startAt)) {
        return trip;
      }
    }
    return null;
  }

  Future<void> _selectPickupDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: context.primaryColor,
              onPrimary: Colors.white,
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

    if (pickedDate == null) return;

    DateTime newStart = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      startDate?.hour ?? 9,
      startDate?.minute ?? 0,
    );

    if (newStart.isBefore(DateTime.now())) {
      final suggested = DateTime.now().add(const Duration(hours: 1));
      newStart = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        suggested.hour,
        0,
      );

      if (newStart.isBefore(DateTime.now())) {
        _showToastError('Thời gian nhận xe không thể ở quá khứ!');
        return;
      }
    }

    DateTime tempEnd = endDate ?? newStart.add(const Duration(days: 2));
    if (tempEnd.isBefore(newStart)) {
      tempEnd = newStart.add(const Duration(days: 2));
    }

    final overlapping = _getOverlappingTrip(newStart, tempEnd);
    if (overlapping != null) {
      final formatter = DateFormat('HH:mm dd/MM');
      _showToastError(
        'Xe đã có lịch bận từ ${formatter.format(overlapping.startAt)} đến ${formatter.format(overlapping.endAt)}!',
      );
      return;
    }

    setState(() {
      startDate = newStart;
      endDate = tempEnd;
      _updateTotalDays();
    });
  }

  Future<void> _selectPickupTime() async {
    if (!mounted) return;
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: startDate?.hour ?? 9,
        minute: startDate?.minute ?? 0,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: context.primaryColor,
              onPrimary: Colors.white,
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

    if (pickedTime == null) return;

    final newStart = DateTime(
      startDate?.year ?? DateTime.now().year,
      startDate?.month ?? DateTime.now().month,
      startDate?.day ?? DateTime.now().day,
      pickedTime.hour,
      pickedTime.minute,
    );

    if (newStart.isBefore(DateTime.now())) {
      _showToastError('Thời gian nhận xe không thể ở quá khứ!');
      return;
    }

    DateTime tempEnd = endDate ?? newStart.add(const Duration(days: 2));
    if (tempEnd.isBefore(newStart)) {
      tempEnd = newStart.add(const Duration(days: 2));
    }

    final overlapping = _getOverlappingTrip(newStart, tempEnd);
    if (overlapping != null) {
      final formatter = DateFormat('HH:mm dd/MM');
      _showToastError(
        'Xe đã có lịch bận từ ${formatter.format(overlapping.startAt)} đến ${formatter.format(overlapping.endAt)}!',
      );
      return;
    }

    setState(() {
      startDate = newStart;
      endDate = tempEnd;
      _updateTotalDays();
    });
  }

  Future<void> _selectReturnDate() async {
    if (startDate == null) {
      _showToastError('Vui lòng chọn ngày nhận xe trước!');
      return;
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: endDate ?? startDate!.add(const Duration(days: 2)),
      firstDate: startDate!,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: context.primaryColor,
              onPrimary: Colors.white,
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

    if (pickedDate == null) return;

    final newEnd = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      endDate?.hour ?? 17,
      endDate?.minute ?? 0,
    );

    if (newEnd.isBefore(startDate!)) {
      _showToastError('Thời gian trả xe phải sau thời gian nhận xe!');
      return;
    }

    final overlapping = _getOverlappingTrip(startDate!, newEnd);
    if (overlapping != null) {
      final formatter = DateFormat('HH:mm dd/MM');
      _showToastError(
        'Xe đã có lịch bận từ ${formatter.format(overlapping.startAt)} đến ${formatter.format(overlapping.endAt)}!',
      );
      return;
    }

    setState(() {
      endDate = newEnd;
      _updateTotalDays();
    });
  }

  Future<void> _selectReturnTime() async {
    if (startDate == null) {
      _showToastError('Vui lòng chọn ngày nhận xe trước!');
      return;
    }

    if (!mounted) return;
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: endDate?.hour ?? 17,
        minute: endDate?.minute ?? 0,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: context.primaryColor,
              onPrimary: Colors.white,
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

    if (pickedTime == null) return;

    final newEnd = DateTime(
      endDate?.year ?? DateTime.now().year,
      endDate?.month ?? DateTime.now().month,
      endDate?.day ?? DateTime.now().day,
      pickedTime.hour,
      pickedTime.minute,
    );

    if (newEnd.isBefore(startDate!)) {
      _showToastError('Thời gian trả xe phải sau thời gian nhận xe!');
      return;
    }

    final overlapping = _getOverlappingTrip(startDate!, newEnd);
    if (overlapping != null) {
      final formatter = DateFormat('HH:mm dd/MM');
      _showToastError(
        'Xe đã có lịch bận từ ${formatter.format(overlapping.startAt)} đến ${formatter.format(overlapping.endAt)}!',
      );
      return;
    }

    setState(() {
      endDate = newEnd;
      _updateTotalDays();
    });
  }

  Future<void> _fetchCarDetailFromServer() async {
    try {
      final response = await CarService().get('/api/cars/${widget.carId}');

      List<TripModel> activeTrips = [];
      try {
        final List? rawTrips = response['data']['trips'] as List?;
        if (rawTrips != null) {
          activeTrips = rawTrips
              .map((json) => TripModel.fromJson(json))
              .toList();
        }
      } catch (_) {}

      if (activeTrips.isEmpty) {
        try {
          final tripsResponse = await CarService().get(
            '/api/trips?car_id=${widget.carId}',
            requiresAuth: true,
          );
          if (tripsResponse != null && tripsResponse['success'] == true) {
            final rawData = tripsResponse['data'];
            List dataList = [];
            if (rawData is List) {
              dataList = rawData;
            } else if (rawData is Map) {
              final booked = rawData['booked'] as List? ?? [];
              final owner = rawData['owner'] as List? ?? [];
              dataList = [...booked, ...owner];
            }
            activeTrips = dataList
                .map((json) => TripModel.fromJson(json))
                .toList();
          }
        } catch (_) {}
      }

      if (activeTrips.isEmpty) {
        try {
          final tripsResponse = await CarService().get(
            '/api/cars/${widget.carId}/trips',
            requiresAuth: true,
          );
          if (tripsResponse != null && tripsResponse['success'] == true) {
            final List dataList = tripsResponse['data'] as List? ?? [];
            activeTrips = dataList
                .map((json) => TripModel.fromJson(json))
                .toList();
          }
        } catch (_) {}
      }

      setState(() {
        car = CarModel.fromJson(response['data']);
        carActiveTrips = activeTrips.where((t) {
          if (t.status == 5 || t.status == 6) return false;
          if (t.carId != 0 && t.carId != widget.carId) return false;
          if (t.car != null && t.car!.id != 0 && t.car!.id != widget.carId) return false;
          return true;
        }).toList();
        _updateTotalDays();

        if (car != null && car!.carLocation?.location != null) {
          final coords = car!.carLocation!.location!.split(',');
          if (coords.length == 2) {
            carLatitude = double.tryParse(coords[0].trim());
            carLongitude = double.tryParse(coords[1].trim());
          }
        }
        isPageLoading = false;
      });
    } catch (e) {
      setState(() => isPageLoading = false);
      _showToastError('Lỗi tải vị trí xe.');
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  double get calculatedDeliveryFee {
    if (!isDeliveryToLocation || car == null) return 0.0;
    final option = car!.deliveryOption;
    if (option == null) return 0.0;
    final double freeDist = option.freeDistance.toDouble();
    final double feeDist = option.feeDistance.toDouble();

    if (distanceInKm <= freeDist) {
      return 0.0;
    }

    final double chargeableKm = double.parse(
      (distanceInKm - freeDist).toStringAsFixed(1),
    );
    final double rawFee = chargeableKm * feeDist;
    return (rawFee / 1000).round() * 1000.0;
  }

  double get totalAmount {
    double finalCost =
        baseRentalPrice -
        carDiscountTotal +
        calculatedDeliveryFee -
        promoDiscount;
    return finalCost < 0 ? 0.0 : finalCost;
  }

  double get totalDiscountAmount => carDiscountTotal + promoDiscount;

  Future<void> _applyPromoCode({bool showFeedback = true}) async {
    final codeText = _promoController.text.trim();
    if (codeText.isEmpty) {
      if (showFeedback) _showToastError('Vui lòng nhập mã giảm giá!');
      return;
    }

    if (startDate == null || endDate == null || car == null) {
      if (showFeedback) _showToastError('Vui lòng chọn thời gian thuê trước!');
      return;
    }

    try {
      final data = await PromotionService().checkPromotion(
        code: codeText,
        startAt: DateFormat('yyyy-MM-dd HH:mm:ss').format(startDate!),
        endAt: DateFormat('yyyy-MM-dd HH:mm:ss').format(endDate!),
        carId: car!.id,
        deliveryFee: calculatedDeliveryFee,
      );

      setState(() {
        promoDiscount = (data['discount_amount'] as num).toDouble();
      });

      if (showFeedback) {
        if (!mounted) return;
        final formatter = NumberFormat.currency(
          locale: 'vi_VN',
          symbol: 'đ',
          decimalDigits: 0,
        );
        AppToast.show(
          context,
          message:
              'Áp dụng mã $codeText thành công! Giảm ${formatter.format(promoDiscount)}',
          type: ToastType.success,
        );
      }
    } catch (e) {
      setState(() {
        promoDiscount = 0.0;
      });
      if (showFeedback) {
        String errorMsg = 'Mã giảm giá không hợp lệ hoặc đã hết hạn!';
        if (e is ApiException) {
          errorMsg = e.message;
        }
        _showToastError(errorMsg);
      }
    }
  }

  void _onAddressVerified({
    required double distance,
    required double? customerLat,
    required double? customerLng,
    required bool hasError,
    required bool isCalculating,
  }) {
    setState(() {
      distanceInKm = distance;
      customerLatitude = customerLat;
      customerLongitude = customerLng;
      hasDistanceError = hasError;
      isCalculatingMap = isCalculating;
      _updateTotalDays();
    });
  }

  void _showToastError(String message) {
    if (!mounted) return;
    AppToast.show(context, message: message, type: ToastType.error);
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.width > 600;
    final tripViewModel = Provider.of<TripViewModel>(context);

    if (isPageLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: context.primaryColor),
        ),
      );
    }

    if (car == null) {
      return const Scaffold(
        body: Center(
          child: Text('Không tìm thấy dữ liệu xe. Vui lòng thử lại!'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Xác nhận đặt xe',
          style: TextStyle(
            color: context.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: context.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: context.textSecondary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 600 : double.infinity,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BookingCarInfoCard(
                    car: car!,
                    shadow: _cardShadow,
                  ),
                  const SizedBox(height: 16),
                  BookingRentalTimeCard(
                    startDate: startDate,
                    endDate: endDate,
                    onSelectPickupDate: _selectPickupDate,
                    onSelectPickupTime: _selectPickupTime,
                    onSelectReturnDate: _selectReturnDate,
                    onSelectReturnTime: _selectReturnTime,
                    shadow: _cardShadow,
                  ),
                  const SizedBox(height: 16),
                  BookingDeliveryMethodCard(
                    car: car!,
                    isDeliveryToLocation: isDeliveryToLocation,
                    distanceInKm: distanceInKm,
                    customerLatitude: customerLatitude,
                    customerLongitude: customerLongitude,
                    carLatitude: carLatitude,
                    carLongitude: carLongitude,
                    addressController: _addressController,
                    isCalculatingMap: isCalculatingMap,
                    hasDistanceError: hasDistanceError,
                    calculatedDeliveryFee: calculatedDeliveryFee,
                    onDeliveryMethodChanged: (value) {
                      setState(() {
                        isDeliveryToLocation = value;
                        _updateTotalDays();
                      });
                    },
                    onAddressVerified: _onAddressVerified,
                    shadow: _cardShadow,
                  ),
                  const SizedBox(height: 16),
                  BookingPromoCodeCard(
                    controller: _promoController,
                    onApply: () => _applyPromoCode(showFeedback: true),
                    shadow: _cardShadow,
                  ),
                  const SizedBox(height: 16),
                  BookingPriceBreakdownCard(
                    car: car!,
                    totalDays: totalDays,
                    baseRentalPrice: baseRentalPrice,
                    isDeliveryToLocation: isDeliveryToLocation,
                    calculatedDeliveryFee: calculatedDeliveryFee,
                    carDiscountTotal: carDiscountTotal,
                    promoDiscount: promoDiscount,
                    totalAmount: totalAmount,
                    totalDiscountAmount: totalDiscountAmount,
                    shadow: _cardShadow,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(isTablet, tripViewModel),
    );
  }

  Widget _buildBottomActionBar(bool isTablet, TripViewModel tripViewModel) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardColor,
        boxShadow: [
          BoxShadow(
            color: context.isDarkMode
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: 1.0,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 600 : double.infinity,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: isTermsAgreed,
                        activeColor: context.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onChanged: (value) =>
                            setState(() => isTermsAgreed = value!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tôi đồng ý với Chính sách hủy chuyến của ứng dụng.',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: tripViewModel.isLoading
                        ? null
                        : () async {
                            if (!isTermsAgreed) {
                              _showToastError(
                                'Bạn cần đồng ý với Chính sách hủy chuyến của ứng dụng.',
                              );
                              return;
                            }
                            if (startDate == null || endDate == null) {
                              _showToastError(
                                'Vui lòng chọn ngày nhận và trả xe trước!',
                              );
                              return;
                            }
                            if (startDate!.isBefore(DateTime.now())) {
                              _showToastError(
                                'Thời gian nhận xe không thể ở quá khứ!',
                              );
                              return;
                            }
                            if (endDate!.isBefore(startDate!)) {
                              _showToastError(
                                'Thời gian trả xe phải sau thời gian nhận xe!',
                              );
                              return;
                            }
                            if (_isCarBusy(startDate!, endDate!)) {
                              final overlapping = _getOverlappingTrip(
                                startDate!,
                                endDate!,
                              );
                              if (overlapping != null) {
                                final formatter = DateFormat('HH:mm dd/MM');
                                _showToastError(
                                  'Xe đã có lịch bận từ ${formatter.format(overlapping.startAt)} đến ${formatter.format(overlapping.endAt)}!',
                                );
                              } else {
                                _showToastError(
                                  'Xe đã có lịch bận trong thời gian này!',
                                );
                              }
                              return;
                            }
                            if (isDeliveryToLocation) {
                              if (_addressController.text.trim().isEmpty) {
                                _showToastError(
                                  'Vui lòng nhập địa chỉ nhận xe!',
                                );
                                return;
                              }
                              if (isCalculatingMap) {
                                _showToastError(
                                  'Đang tính toán khoảng cách giao xe, vui lòng đợi...',
                                );
                                return;
                              }
                              if (hasDistanceError) {
                                _showToastError(
                                  'Không thể tính toán khoảng cách lái xe từ địa chỉ này, vui lòng nhập/chọn lại địa chỉ khác!',
                                );
                                  return;
                              }
                              double maxDist =
                                  car!.deliveryOption?.maxDistance ?? 10.0;
                              if (distanceInKm > maxDist) {
                                _showToastError(
                                  'Vị trí giao xe quá xa. Vui lòng chọn vị trí dưới ${maxDist.toInt()} km.',
                                );
                                return;
                              }
                            }

                            String? defaultCarAddress = car?.carLocation?.address;
                            if (defaultCarAddress == null ||
                                defaultCarAddress.trim().isEmpty) {
                              if (car?.carLocation?.city != null &&
                                  car!.carLocation!.city!.trim().isNotEmpty) {
                                defaultCarAddress = car!.carLocation!.city;
                              } else if (carLatitude != null &&
                                  carLongitude != null) {
                                defaultCarAddress =
                                    "$carLatitude, $carLongitude";
                              } else {
                                defaultCarAddress = "Nhận xe tại vị trí xe";
                              }
                            }

                            String? defaultCarLocation =
                                car?.carLocation?.location;
                            if (defaultCarLocation == null ||
                                defaultCarLocation.trim().isEmpty) {
                              if (carLatitude != null &&
                                  carLongitude != null) {
                                defaultCarLocation =
                                    "$carLatitude,$carLongitude";
                              }
                            }

                            Map<String, dynamic> requestBody = {
                              'car_id': car!.id,
                              'trip_type': 0,
                              'status': 0,
                              'start_at': DateFormat(
                                'yyyy-MM-dd HH:mm:ss',
                              ).format(startDate!),
                              'end_at': DateFormat(
                                'yyyy-MM-dd HH:mm:ss',
                              ).format(endDate!),
                              'cost':
                                  baseRentalPrice +
                                  calculatedDeliveryFee,
                              'discount_amount': totalDiscountAmount,
                              'delivery_address': isDeliveryToLocation
                                  ? _addressController.text
                                  : defaultCarAddress,
                              'delivery_location': isDeliveryToLocation
                                  ? "$customerLatitude,$customerLongitude"
                                  : defaultCarLocation,
                              'promo_code': _promoController.text.isNotEmpty
                                  ? _promoController.text
                                  : null,
                              'delivery_fee': calculatedDeliveryFee,
                            };

                            bool isSuccess = await tripViewModel.bookingCar(
                              requestBody,
                            );
                            if (!mounted) return;
                            if (isSuccess) {
                              AppToast.show(
                                context,
                                message:
                                    'Gửi yêu cầu thuê xe thành công! Vui lòng chờ chủ xe duyệt.',
                                type: ToastType.success,
                              );
                              Navigator.pop(context);
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: AppColors.error,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text('Đặt xe thất bại'),
                                    ],
                                  ),
                                  content: Text(tripViewModel.errorMessage),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                        'Đóng',
                                        style: TextStyle(
                                          color: context.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primaryColor,
                      disabledBackgroundColor: AppColors.border,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: tripViewModel.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Gửi yêu cầu đặt xe',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
