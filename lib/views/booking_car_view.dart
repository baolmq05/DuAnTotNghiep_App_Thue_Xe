import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../themes/app_colors.dart';
import '../models/trip_model.dart';
import '../viewmodels/trip_viewmodel.dart';
import '../services/car_service.dart';
import '../services/goong_map_service.dart';
import '../services/promotion_service.dart';
import '../services/base_service.dart';
import '../widgets/app_toast.dart';
import 'package:go_router/go_router.dart';

class BookingCarView extends StatefulWidget {
  final int carId; // Nhận duy nhất ID xe từ trang chi tiết truyền sang

  const BookingCarView({super.key, required this.carId});

  @override
  State<BookingCarView> createState() => _BookingCarViewState();
}

class _BookingCarViewState extends State<BookingCarView> {
  final String goongMaptilesKey = "lvcebA0VIPS4ZP4omHIRxH...";
  final String goongApiKey = "Gmptoo7f9LZDC6Mrcib9N...";

  CarModel? car;
  bool isPageLoading = true;
  List<TripModel> carActiveTrips = [];
  List<Map<String, String>> _suggestions = [];
  final MapController _mapController = MapController();

  // --- BIẾN THỜI GIAN ĐÃ ĐƯỢC CHUYỂN THÀNH STATE ĐỂ KHÁCH TỰ CHỌN ---
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

  // Hàm hiển thị thông báo lỗi dạng Toast
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

    // Khởi tạo thời gian mẫu và mặc định cho khách hàng khi mở trang đặt xe lần đầu tiên
    // Khách hàng có thể đổi lại mốc thời gian này bằng nút bấm chọn lịch
    final now = DateTime.now();
    startDate = DateTime(now.year, now.month, now.day + 1, 9, 0);
    endDate = DateTime(now.year, now.month, now.day + 3, 17, 0);

    _updateTotalDays();
    _fetchCarDetailFromServer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyPromoCode(showFeedback: false);
    });
  }

  // Hàm tính toán số ngày dựa trên mốc startDate và endDate hiện tại
  void _updateTotalDays() {
    if (startDate != null && endDate != null) {
      int diffMinutes = endDate!.difference(startDate!).inMinutes;
      totalDays = (diffMinutes / 1440).ceil();
      if (totalDays < 1) totalDays = 1;

      // Tính lại giá xe theo số ngày mới
      if (car != null) {
        baseRentalPrice = car!.unitPrice * totalDays;
        carDiscountTotal = car!.discountValue * totalDays;

        if (_promoController.text.isNotEmpty && promoDiscount > 0.0) {
          _applyPromoCode(showFeedback: false);
        }
      }
    }
  }

  // Sự kiện khi người dùng chọn xong thời gian mới từ bộ lịch (DatePicker/Modal)
  void onDateTimeChanged(DateTime newStart, DateTime newEnd) {
    setState(() {
      startDate = newStart;
      endDate = newEnd;
      _updateTotalDays(); // Tính toán lại toàn bộ bảng giá tiền lập tức
    });
  }

  // Kiểm tra xem xe có bận trong khoảng thời gian start-end hay không
  bool _isCarBusy(DateTime start, DateTime end) {
    for (var trip in carActiveTrips) {
      if (start.isBefore(trip.endAt) && end.isAfter(trip.startAt)) {
        return true;
      }
    }
    return false;
  }

  // Lấy chuyến đi đang bận trùng với khoảng thời gian start-end nếu có
  TripModel? _getOverlappingTrip(DateTime start, DateTime end) {
    for (var trip in carActiveTrips) {
      if (start.isBefore(trip.endAt) && end.isAfter(trip.startAt)) {
        return trip;
      }
    }
    return null;
  }

  // Hàm hiển thị thông báo lỗi dạng Toast
  Future<void> _selectPickupDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
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

    if (pickedDate == null) return;

    DateTime newStart = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      startDate?.hour ?? 9,
      startDate?.minute ?? 0,
    );

    // Nếu thời gian mặc định/đang chọn nằm ở quá khứ so với thời điểm hiện tại
    if (newStart.isBefore(DateTime.now())) {
      // Tự động đẩy giờ nhận lên cách hiện tại 1 tiếng
      final suggested = DateTime.now().add(const Duration(hours: 1));
      newStart = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        suggested.hour,
        0, // Làm tròn phút về 00
      );

      // Nếu sau khi điều chỉnh vẫn bị quá khứ (ví dụ chọn ngày hôm trước)
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

  // hàm chọn giờ nhận xe
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

  // hàm chọn ngày trả xe
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

  void _updateMapView() {
    if (customerLatitude != null && customerLongitude != null) {
      _mapController.move(LatLng(customerLatitude!, customerLongitude!), 13);
    } else if (carLatitude != null && carLongitude != null) {
      _mapController.move(LatLng(carLatitude!, carLongitude!), 13);
    }
  }

  Future<void> _fetchCarDetailFromServer() async {
    try {
      // 1. Gọi API lấy xe từ Laravel (Ví dụ)
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
        carActiveTrips = activeTrips
            .where((t) => t.status != 5 && t.status != 6)
            .toList();
        _updateTotalDays();

        if (car != null && car!.carLocation?.location != null) {
          final coords = car!.carLocation!.location!.split(',');
          if (coords.length == 2) {
            // Gán thẳng vị trí thực tế của chủ xe đăng ký từ database vào State
            carLatitude = double.tryParse(coords[0].trim());
            carLongitude = double.tryParse(coords[1].trim());
          }
        }
        isPageLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _updateMapView());
    } catch (e) {
      setState(() => isPageLoading = false);
      _showToastError('Lỗi tải vị trí xe.');
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    _addressController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  double get calculatedDeliveryFee {
    // Nếu không giao xe đến địa chỉ khách hàng hoặc chưa có dữ liệu xe thì phí giao luôn là 0
    if (!isDeliveryToLocation || car == null) return 0.0;
    final option = car!.deliveryOption;
    if (option == null) return 0.0;
    // Nếu chưa có dữ liệu khoảng cách thì phí giao luôn là 0
    final double freeDist = option.freeDistance
        .toDouble(); // Ngưỡng miễn phí (km)
    final double feeDist = option.feeDistance
        .toDouble(); // Đơn giá mỗi km vượt ngưỡng (VNĐ)

    if (distanceInKm <= freeDist) {
      return 0.0; // Miễn phí
    }

    // Tính phí theo khoảng cách thực tế vượt quá ngưỡng miễn phí và ko làm tròn
    final double chargeableKm = double.parse(
      (distanceInKm - freeDist).toStringAsFixed(1),
    );
    final double rawFee = chargeableKm * feeDist;
    // Làm tròn đến 1.000đ gần nhất
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

  // tổng tiền giảm =  tiền giảm thuê xe + tiền mã giảm giá
  double get totalDiscountAmount => carDiscountTotal + promoDiscount;

  // Áp dụng mã giảm giá
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
        AppToast.show(
          context,
          message:
              'Áp dụng mã $codeText thành công! Giảm ${_formatCurrency(promoDiscount)}',
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

  // Xác minh địa chỉ từ ID địa điểm và thông báo
  Future<void> _verifyAddressFromPlaceId(
    String placeId,
    String formattedAddress,
  ) async {
    setState(() {
      isCalculatingMap = true;
      hasDistanceError = false;
    });

    try {
      final latLng = await GoongMapService().getPlaceLatLng(placeId);
      if (latLng != null) {
        final cLat = latLng['lat'];
        final cLng = latLng['lng'];
        double dist = 0.0;
        bool errorOccurred = false;

        if (carLatitude != null &&
            carLongitude != null &&
            cLat != null &&
            cLng != null) {
          final drivingDist = await GoongMapService().getDrivingDistance(
            carLatitude!,
            carLongitude!,
            cLat,
            cLng,
          );
          if (drivingDist != null) {
            dist = drivingDist;
          } else {
            _showToastError(
              'Không thể lấy khoảng cách lái xe, vui lòng thử lại!',
            );
            dist = 0.0;
            errorOccurred = true;
          }
        }

        setState(() {
          _addressController.text = formattedAddress;
          customerLatitude = cLat;
          customerLongitude = cLng;
          distanceInKm = double.parse(dist.toStringAsFixed(1));
          hasDistanceError = errorOccurred;
          isCalculatingMap = false;
        });
        _updateMapView();
      } else {
        _showToastError('Không tìm thấy vị trí tương ứng.');
        setState(() {
          hasDistanceError = true;
          isCalculatingMap = false;
        });
      }
    } catch (e) {
      _showToastError('Lỗi tính toán khoảng cách.');
      setState(() {
        hasDistanceError = true;
        isCalculatingMap = false;
      });
    }
  }

  // --- HÀM TÌM ĐỊA CHỈ THẬT QUA GOONG MAPS (ĐÃ BỎ GEOLOCATOR) ---
  Future<void> _searchAndVerifyAddress(String addressInput) async {
    if (addressInput.isEmpty) return;

    setState(() {
      isCalculatingMap = true;
      hasDistanceError = false;
    });

    final String url =
        "https://rsapi.goong.io/Geocode?address=${Uri.encodeComponent(addressInput)}&api_key=$goongApiKey";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['results'] != null && data['results'].isNotEmpty) {
          // 1. Lấy chuỗi địa chỉ định dạng chuẩn từ Goong Maps
          final String formattedAddress =
              data['results'][0]['formatted_address'];
          final location = data['results'][0]['geometry']['location'];
          final cLat = double.parse(location['lat'].toString());
          final cLng = double.parse(location['lng'].toString());
          double dist = 0.0;
          bool errorOccurred = false;

          if (carLatitude != null && carLongitude != null) {
            final drivingDist = await GoongMapService().getDrivingDistance(
              carLatitude!,
              carLongitude!,
              cLat,
              cLng,
            );
            if (drivingDist != null) {
              dist = drivingDist;
            } else {
              _showToastError(
                'Không thể lấy khoảng cách lái xe, vui lòng thử lại!',
              );
              dist = 0.0;
              errorOccurred = true;
            }
          }

          setState(() {
            // Điền địa chỉ chuẩn vào ô nhập liệu cho đẹp mắt
            _addressController.text = formattedAddress;
            customerLatitude = cLat;
            customerLongitude = cLng;
            distanceInKm = double.parse(dist.toStringAsFixed(1));
            hasDistanceError = errorOccurred;
            isCalculatingMap = false;
          });
          _updateMapView();
        } else {
          _showToastError('Không tìm thấy vị trí tương ứng.');
          setState(() {
            hasDistanceError = true;
            isCalculatingMap = false;
          });
        }
      }
    } catch (e) {
      _showToastError('Lỗi kiểm tra vị trí: $e');
      setState(() {
        hasDistanceError = true;
        isCalculatingMap = false;
      });
    }
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
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (car == null) {
      return Scaffold(
        body: const Center(
          child: Text('Không tìm thấy dữ liệu xe. Vui lòng thử lại!'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.card,
      appBar: AppBar(
        title: const Text(
          'Xác nhận đặt xe',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textSecondary,
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
                  _buildCarInfoCard(),
                  const SizedBox(height: 16),
                  _buildRentalTimeCard(), // Khối hiển thị & chọn thời gian thuê xe
                  const SizedBox(height: 16),
                  _buildDeliveryMethodCard(),
                  const SizedBox(height: 16),
                  _buildPromoCodeCard(),
                  const SizedBox(height: 16),
                  _buildPriceBreakdownCard(),
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

  Widget _buildCarInfoCard() {
    return GestureDetector(
      onTap: () {
        if (car != null) {
          context.push('/car_detail/${car!.id}');
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _cardShadow,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                car!.getFirstImageUrl(),
                width: 95,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    car!.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: AppColors.warning,
                        size: 18,
                      ),
                      const Text(
                        ' 5.0 ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '• Ghế: ${car!.seatCount} • Biển: ${car!.licensePlate}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      car!.transmission ?? 'Tự động',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRentalTimeCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              SizedBox(width: 8),
              Text(
                'Thời gian thuê',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // NHẬN XE row
          const Text(
            'Nhận xe',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _buildSubInputBox(
                  startDate != null
                      ? DateFormat('dd/MM/yyyy').format(startDate!)
                      : 'Chọn ngày',
                  Icons.calendar_today_rounded,
                  _selectPickupDate,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: _buildSubInputBox(
                  startDate != null
                      ? DateFormat('HH:mm').format(startDate!)
                      : 'Chọn giờ',
                  Icons.access_time_rounded,
                  _selectPickupTime,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // TRẢ XE row
          const Text(
            'Trả xe',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _buildSubInputBox(
                  endDate != null
                      ? DateFormat('dd/MM/yyyy').format(endDate!)
                      : 'Chọn ngày',
                  Icons.calendar_today_rounded,
                  _selectReturnDate,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: _buildSubInputBox(
                  endDate != null
                      ? DateFormat('HH:mm').format(endDate!)
                      : 'Chọn giờ',
                  Icons.access_time_rounded,
                  _selectReturnTime,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- HÀM XÂY DỰNG Ô NHẬP LIỆU NHỎ (DÙNG CHO NGÀY & GIỜ) ---
  Widget _buildSubInputBox(String text, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HÀM XÂY DỰNG KHỐI CHỌN HÌNH THỨC NHẬN XE ---
  Widget _buildDeliveryMethodCard() {
    double maxDist = car!.deliveryOption?.maxDistance ?? 10.0;
    bool isTooFar = isDeliveryToLocation && (distanceInKm > maxDist);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.local_shipping_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              SizedBox(width: 8),
              Text(
                'Hình thức nhận xe',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildDeliveryButton(
                false,
                'Tại vị trí xe',
                Icons.location_on_outlined,
              ),
              const SizedBox(width: 12),
              _buildDeliveryButton(
                true,
                'Giao tận nơi',
                Icons.electric_car_outlined,
              ),
            ],
          ),
          if (!isDeliveryToLocation) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Địa chỉ nhận xe',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          car?.carLocation?.address ??
                              'Đang cập nhật địa chỉ...',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (isDeliveryToLocation) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Vị trí xe hiện tại',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          car?.carLocation?.address ??
                              'Đang cập nhật địa chỉ...',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _addressController,
              onChanged: (value) async {
                if (value.trim().isEmpty) {
                  setState(() => _suggestions = []);
                  return;
                }
                final suggestions = await GoongMapService()
                    .getSuggestionsWithPlaceId(value);
                setState(() {
                  _suggestions = suggestions;
                });
              },
              onSubmitted: (value) async {
                setState(() => _suggestions = []);
                await _searchAndVerifyAddress(value);
              },
              decoration: InputDecoration(
                hintText: 'Nhập địa chỉ nhận xe...',
                prefixIcon: isCalculatingMap
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : const Icon(
                        Icons.map_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                fillColor: AppColors.card,
                filled: true,
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
              ),
            ),
            if (_suggestions.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                  boxShadow: _cardShadow,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: _suggestions.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (context, index) {
                    final suggestion = _suggestions[index];
                    final desc = suggestion['description'] ?? '';
                    final pid = suggestion['place_id'] ?? '';
                    return ListTile(
                      dense: true,
                      leading: const Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      title: Text(
                        desc,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      onTap: () async {
                        _addressController.text = desc;
                        setState(() {
                          _suggestions = [];
                        });
                        if (pid.isNotEmpty) {
                          await _verifyAddressFromPlaceId(pid, desc);
                        } else {
                          await _searchAndVerifyAddress(desc);
                        }
                      },
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Khoảng cách: $distanceInKm km',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Giới hạn giao xe: ${maxDist.toInt()} km',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            if (isTooFar) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.error,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Vị trí quá xa! Chủ xe này chỉ nhận giao xe dưới ${maxDist.toInt()} km.',
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            // Hiển thị phí giao xe ước tính ngay trong section chọn địa chỉ
            if (distanceInKm > 0 && !isTooFar) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: calculatedDeliveryFee == 0
                      ? AppColors.success.withValues(alpha: 0.08)
                      : AppColors.secondary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: calculatedDeliveryFee == 0
                        ? AppColors.success.withValues(alpha: 0.4)
                        : AppColors.secondary.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          calculatedDeliveryFee == 0
                              ? Icons.check_circle_outline_rounded
                              : Icons.electric_car_outlined,
                          size: 16,
                          color: calculatedDeliveryFee == 0
                              ? AppColors.success
                              : AppColors.secondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Phí giao xe',
                          style: TextStyle(
                            fontSize: 13,
                            color: calculatedDeliveryFee == 0
                                ? AppColors.success
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      calculatedDeliveryFee == 0
                          ? 'Miễn phí'
                          : _formatCurrency(calculatedDeliveryFee),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: calculatedDeliveryFee == 0
                            ? AppColors.success
                            : AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            Container(
              height: 250,
              width: double.infinity,
              margin: const EdgeInsets.only(top: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(
                      carLatitude ?? 10.7760,
                      carLongitude ?? 106.7009,
                    ),
                    initialZoom: 13,
                    interactionOptions: const InteractionOptions(
                      flags:
                          InteractiveFlag.drag |
                          InteractiveFlag.pinchZoom |
                          InteractiveFlag.doubleTapZoom,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                    ),
                    MarkerLayer(
                      markers: [
                        if (carLatitude != null && carLongitude != null)
                          Marker(
                            point: LatLng(carLatitude!, carLongitude!),
                            width: 80,
                            height: 80,
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.directions_car_filled_rounded,
                                  color: AppColors.primary,
                                  size: 30,
                                ),
                                Card(
                                  margin: EdgeInsets.only(top: 2),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    child: Text(
                                      'Vị trí xe',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (customerLatitude != null &&
                            customerLongitude != null)
                          Marker(
                            point: LatLng(
                              customerLatitude!,
                              customerLongitude!,
                            ),
                            width: 80,
                            height: 80,
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.person_pin_circle_rounded,
                                  color: AppColors.success,
                                  size: 30,
                                ),
                                Card(
                                  margin: EdgeInsets.only(top: 2),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    child: Text(
                                      'Điểm nhận',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
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
            ),
          ],
        ],
      ),
    );
  }

  // --- HÀM XÂY DỰNG NÚT CHỌN HÌNH THỨC NHẬN XE (TẠI VỊ TRÍ XE HOẶC GIAO TẬN NƠI) ---
  Widget _buildDeliveryButton(bool isForLocation, String title, IconData icon) {
    bool isSelected = isForLocation == isDeliveryToLocation;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => isDeliveryToLocation = isForLocation),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryDark : AppColors.background,
            border: Border.all(
              color: isSelected ? Colors.transparent : AppColors.border,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppColors.background
                    : AppColors.textPrimary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.background
                      : AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- HÀM XÂY DỰNG KHỐI NHẬP MÃ KHUYẾN MÃI ---
  Widget _buildPromoCodeCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.confirmation_num_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              SizedBox(width: 8),
              Text(
                'Mã giảm giá',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _promoController,
                  decoration: InputDecoration(
                    hintText: 'Nhập mã khuyến mãi...',
                    hintStyle: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    fillColor: AppColors.card,
                    filled: true,
                    prefixIcon: const Icon(
                      Icons.discount_outlined,
                      size: 18,
                      color: AppColors.warning,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => _applyPromoCode(showFeedback: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Áp dụng',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.background,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- HÀM XÂY DỰNG KHỐI HIỂN THỊ BẢNG TÍNH GIÁ CHI TIẾT ---
  Widget _buildPriceBreakdownCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bảng tính giá chi tiết',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildPriceRow(
            'Đơn giá thuê',
            '${_formatCurrency(car!.unitPrice)}/ngày',
          ),
          const SizedBox(height: 12),
          _buildPriceRow(
            'Tổng tiền thuê ($totalDays ngày)',
            _formatCurrency(baseRentalPrice),
          ),
          const SizedBox(height: 12),
          if (isDeliveryToLocation)
            _buildPriceRow(
              'Phí giao xe tận nơi',
              calculatedDeliveryFee == 0
                  ? 'Miễn phí'
                  : _formatCurrency(calculatedDeliveryFee),
              isFree: calculatedDeliveryFee == 0,
            ),
          if (car!.discountValue > 0)
            _buildPriceRow(
              'Giảm giá từ chủ xe',
              '-${_formatCurrency(carDiscountTotal)}',
              isDiscount: true,
            ),
          if (promoDiscount > 0)
            _buildPriceRow(
              'Mã voucher giảm thêm',
              '-${_formatCurrency(promoDiscount)}',
              isDiscount: true,
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, thickness: 1, color: AppColors.border),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accentSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng cộng',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatCurrency(totalAmount),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    if (totalDiscountAmount > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Tiết kiệm ${_formatCurrency(totalDiscountAmount)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- HÀM XÂY DỰNG HÀNG HIỂN THỊ GIÁ TRONG BẢNG TÍNH GIÁ ---
  Widget _buildPriceRow(
    String label,
    String value, {
    bool isDiscount = false,
    bool isFree = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            color: isDiscount || isFree
                ? AppColors.success
                : AppColors.textPrimary,
            fontSize: 14,
            fontWeight: isDiscount || isFree
                ? FontWeight.bold
                : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  // -- HÀM XÂY DỰNG THANH HÀNH ĐỘNG Ở CUỐI MÀN HÌNH (NÚT ĐẶT XE) ---
  Widget _buildBottomActionBar(bool isTablet, TripViewModel tripViewModel) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onChanged: (value) =>
                            setState(() => isTermsAgreed = value!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Tôi đồng ý với Chính sách hủy chuyến của ứng dụng.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
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
                                  calculatedDeliveryFee, // Tổng tiền thuê + phí giao xe (chưa trừ giảm giá)
                              'discount_amount': totalDiscountAmount,
                              'delivery_address': isDeliveryToLocation
                                  ? _addressController.text
                                  : null,
                              'delivery_location': isDeliveryToLocation
                                  ? "$customerLatitude,$customerLongitude"
                                  : null,
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
                                  title: const Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: AppColors.error,
                                      ),
                                      SizedBox(width: 8),
                                      Text('Đặt xe thất bại'),
                                    ],
                                  ),
                                  content: Text(tripViewModel.errorMessage),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text(
                                        'Đóng',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
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
                        : Text(
                            'Gửi yêu cầu đặt xe',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.background,
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
