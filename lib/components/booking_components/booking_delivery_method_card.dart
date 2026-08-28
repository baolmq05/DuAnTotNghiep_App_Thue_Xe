import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:duantotnghiep_app_thue_xe/models/trip_model.dart';
import 'package:duantotnghiep_app_thue_xe/services/goong_map_service.dart';
import 'package:duantotnghiep_app_thue_xe/widgets/app_toast.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/address_viewmodel.dart';

class BookingDeliveryMethodCard extends StatefulWidget {
  final CarModel car;
  final bool isDeliveryToLocation;
  final double distanceInKm;
  final double? customerLatitude;
  final double? customerLongitude;
  final double? carLatitude;
  final double? carLongitude;
  final TextEditingController addressController;
  final bool isCalculatingMap;
  final bool hasDistanceError;
  final double calculatedDeliveryFee;
  final ValueChanged<bool> onDeliveryMethodChanged;
  final Function({
    required double distance,
    required double? customerLat,
    required double? customerLng,
    required bool hasError,
    required bool isCalculating,
  }) onAddressVerified;
  final List<BoxShadow>? shadow;

  const BookingDeliveryMethodCard({
    super.key,
    required this.car,
    required this.isDeliveryToLocation,
    required this.distanceInKm,
    required this.customerLatitude,
    required this.customerLongitude,
    required this.carLatitude,
    required this.carLongitude,
    required this.addressController,
    required this.isCalculatingMap,
    required this.hasDistanceError,
    required this.calculatedDeliveryFee,
    required this.onDeliveryMethodChanged,
    required this.onAddressVerified,
    this.shadow,
  });

  @override
  State<BookingDeliveryMethodCard> createState() => _BookingDeliveryMethodCardState();
}

class _BookingDeliveryMethodCardState extends State<BookingDeliveryMethodCard> {
  final String goongApiKey = "xEcFmnV3loWHnfqa9ZsEENH7Wu6lehK4QmabQk7V";
  List<Map<String, String>> _suggestions = [];
  final MapController _mapController = MapController();

  @override
  void didUpdateWidget(covariant BookingDeliveryMethodCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.customerLatitude != widget.customerLatitude ||
        oldWidget.customerLongitude != widget.customerLongitude ||
        oldWidget.carLatitude != widget.carLatitude ||
        oldWidget.carLongitude != widget.carLongitude) {
      _updateMapView();
    }
  }

  void _updateMapView() {
    if (widget.customerLatitude != null && widget.customerLongitude != null) {
      _mapController.move(LatLng(widget.customerLatitude!, widget.customerLongitude!), 13);
    } else if (widget.carLatitude != null && widget.carLongitude != null) {
      _mapController.move(LatLng(widget.carLatitude!, widget.carLongitude!), 13);
    }
  }

  Future<void> _verifyAddressFromPlaceId(
    String placeId,
    String formattedAddress,
  ) async {
    widget.onAddressVerified(
      distance: widget.distanceInKm,
      customerLat: widget.customerLatitude,
      customerLng: widget.customerLongitude,
      hasError: false,
      isCalculating: true,
    );

    try {
      final latLng = await GoongMapService().getPlaceLatLng(placeId);
      if (latLng != null) {
        final cLat = latLng['lat'];
        final cLng = latLng['lng'];
        double dist = 0.0;
        bool errorOccurred = false;

        if (widget.carLatitude != null &&
            widget.carLongitude != null &&
            cLat != null &&
            cLng != null) {
          final drivingDist = await GoongMapService().getDrivingDistance(
            widget.carLatitude!,
            widget.carLongitude!,
            cLat,
            cLng,
          );
          if (drivingDist != null) {
            dist = drivingDist;
          } else {
            _showToastError('Không thể lấy khoảng cách lái xe, vui lòng thử lại!');
            dist = 0.0;
            errorOccurred = true;
          }
        }

        widget.addressController.text = formattedAddress;
        widget.onAddressVerified(
          distance: double.parse(dist.toStringAsFixed(1)),
          customerLat: cLat,
          customerLng: cLng,
          hasError: errorOccurred,
          isCalculating: false,
        );
        WidgetsBinding.instance.addPostFrameCallback((_) => _updateMapView());
      } else {
        _showToastError('Không tìm thấy vị trí tương ứng.');
        widget.onAddressVerified(
          distance: 0.0,
          customerLat: null,
          customerLng: null,
          hasError: true,
          isCalculating: false,
        );
      }
    } catch (e) {
      _showToastError('Lỗi tính toán khoảng cách.');
      widget.onAddressVerified(
        distance: 0.0,
        customerLat: null,
        customerLng: null,
        hasError: true,
        isCalculating: false,
      );
    }
  }

  Future<void> _searchAndVerifyAddress(String addressInput) async {
    if (addressInput.isEmpty) return;

    widget.onAddressVerified(
      distance: widget.distanceInKm,
      customerLat: widget.customerLatitude,
      customerLng: widget.customerLongitude,
      hasError: false,
      isCalculating: true,
    );

    final String url =
        "https://rsapi.goong.io/Geocode?address=${Uri.encodeComponent(addressInput)}&api_key=$goongApiKey";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['results'] != null && data['results'].isNotEmpty) {
          final String formattedAddress = data['results'][0]['formatted_address'];
          final location = data['results'][0]['geometry']['location'];
          final cLat = double.parse(location['lat'].toString());
          final cLng = double.parse(location['lng'].toString());
          double dist = 0.0;
          bool errorOccurred = false;

          if (widget.carLatitude != null && widget.carLongitude != null) {
            final drivingDist = await GoongMapService().getDrivingDistance(
              widget.carLatitude!,
              widget.carLongitude!,
              cLat,
              cLng,
            );
            if (drivingDist != null) {
              dist = drivingDist;
            } else {
              _showToastError('Không thể lấy khoảng cách lái xe, vui lòng thử lại!');
              dist = 0.0;
              errorOccurred = true;
            }
          }

          widget.addressController.text = formattedAddress;
          widget.onAddressVerified(
            distance: double.parse(dist.toStringAsFixed(1)),
            customerLat: cLat,
            customerLng: cLng,
            hasError: errorOccurred,
            isCalculating: false,
          );
          WidgetsBinding.instance.addPostFrameCallback((_) => _updateMapView());
        } else {
          _showToastError('Không tìm thấy vị trí tương ứng.');
          widget.onAddressVerified(
            distance: 0.0,
            customerLat: null,
            customerLng: null,
            hasError: true,
            isCalculating: false,
          );
        }
      }
    } catch (e) {
      _showToastError('Lỗi kiểm tra vị trí: $e');
      widget.onAddressVerified(
        distance: 0.0,
        customerLat: null,
        customerLng: null,
        hasError: true,
        isCalculating: false,
      );
    }
  }

  void _showToastError(String message) {
    if (!mounted) return;
    AppToast.show(context, message: message, type: ToastType.error);
  }

  void _showSavedAddressesBottomSheet(BuildContext context) {
    context.read<AddressViewModel>().loadAddresses();

    showModalBottomSheet(
      context: context,
      backgroundColor: context.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (modalContext) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(modalContext).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Địa chỉ đã lưu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(modalContext);
                      context.push('/address');
                    },
                    child: Text(
                      'Quản lý',
                      style: TextStyle(
                        color: context.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Consumer<AddressViewModel>(
                  builder: (context, addressVM, child) {
                    if (addressVM.isLoading) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(context.primaryColor),
                        ),
                      );
                    }

                    if (addressVM.addresses.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_off_outlined,
                                size: 48,
                                color: context.textSecondary,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Chưa có địa chỉ nào được lưu',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: context.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(modalContext);
                                  context.push('/address');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: context.primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Thêm địa chỉ'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: addressVM.addresses.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: context.border,
                      ),
                      itemBuilder: (context, index) {
                        final address = addressVM.addresses[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 4),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: context.primaryColor.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.place_rounded,
                              color: context.primaryColor,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            address.addressName,
                            style: TextStyle(
                              fontSize: 14,
                              color: context.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () async {
                            Navigator.pop(modalContext);
                            widget.addressController.text = address.addressName;
                            await _searchAndVerifyAddress(address.addressName);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
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

  Widget _buildDeliveryButton(bool isForLocation, String title, IconData icon) {
    bool isSelected = isForLocation == widget.isDeliveryToLocation;
    return Expanded(
      child: InkWell(
        onTap: () => widget.onDeliveryMethodChanged(isForLocation),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? context.primaryDark : context.cardColor,
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
                color: isSelected ? AppColors.background : context.textPrimary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? AppColors.background : context.textPrimary,
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

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double maxDist = widget.car.deliveryOption?.maxDistance ?? 10.0;
    bool isTooFar = widget.isDeliveryToLocation && (widget.distanceInKm > maxDist);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: widget.shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_shipping_rounded,
                size: 16,
                color: context.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Hình thức nhận xe',
                style: TextStyle(
                  fontSize: 13,
                  color: context.textSecondary,
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
          if (!widget.isDeliveryToLocation) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: context.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Địa chỉ nhận xe',
                          style: TextStyle(
                            fontSize: 11,
                            color: context.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.car.carLocation?.address ?? 'Đang cập nhật địa chỉ...',
                          style: TextStyle(
                            fontSize: 13,
                            color: context.textPrimary,
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
          if (widget.isDeliveryToLocation) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: context.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vị trí xe hiện tại',
                          style: TextStyle(
                            fontSize: 11,
                            color: context.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.car.carLocation?.address ?? 'Đang cập nhật địa chỉ...',
                          style: TextStyle(
                            fontSize: 13,
                            color: context.textPrimary,
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
              controller: widget.addressController,
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
                prefixIcon: widget.isCalculatingMap
                    ? Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: context.primaryColor,
                        ),
                      )
                    : Icon(
                        Icons.map_rounded,
                        color: context.primaryColor,
                        size: 20,
                      ),
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.collections_bookmark_rounded,
                    color: context.primaryColor,
                  ),
                  tooltip: 'Địa chỉ đã lưu',
                  onPressed: () => _showSavedAddressesBottomSheet(context),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                fillColor: context.cardColor,
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
                  borderSide: BorderSide(
                    color: context.primaryColor,
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
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.border),
                  boxShadow: widget.shadow,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: _suggestions.length,
                  separatorBuilder: (context, index) =>
                      Divider(height: 1, color: AppColors.border),
                  itemBuilder: (context, index) {
                    final suggestion = _suggestions[index];
                    final desc = suggestion['description'] ?? '';
                    final pid = suggestion['place_id'] ?? '';
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: context.primaryColor,
                      ),
                      title: Text(
                        desc,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.textPrimary,
                        ),
                      ),
                      onTap: () async {
                        widget.addressController.text = desc;
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
                  'Khoảng cách: ${widget.distanceInKm} km',
                  style: TextStyle(
                    fontSize: 13,
                    color: context.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Giới hạn giao xe: ${maxDist.toInt()} km',
                  style: TextStyle(
                    fontSize: 13,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
            if (isTooFar) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.error,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Vị trí quá xa! Chủ xe này chỉ nhận giao xe dưới ${maxDist.toInt()} km.',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (widget.distanceInKm > 0 && !isTooFar) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: widget.calculatedDeliveryFee == 0
                      ? AppColors.success.withValues(alpha: 0.08)
                      : AppColors.secondary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: widget.calculatedDeliveryFee == 0
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
                          widget.calculatedDeliveryFee == 0
                              ? Icons.check_circle_outline_rounded
                              : Icons.electric_car_outlined,
                          size: 16,
                          color: widget.calculatedDeliveryFee == 0
                              ? AppColors.success
                              : AppColors.secondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Phí giao xe',
                          style: TextStyle(
                            fontSize: 13,
                            color: widget.calculatedDeliveryFee == 0
                                ? AppColors.success
                                : context.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      widget.calculatedDeliveryFee == 0
                          ? 'Miễn phí'
                          : _formatCurrency(widget.calculatedDeliveryFee),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: widget.calculatedDeliveryFee == 0
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
                      widget.carLatitude ?? 10.7760,
                      widget.carLongitude ?? 106.7009,
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
                        if (widget.carLatitude != null && widget.carLongitude != null)
                          Marker(
                            point: LatLng(widget.carLatitude!, widget.carLongitude!),
                            width: 80,
                            height: 80,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.directions_car_filled_rounded,
                                  color: context.primaryColor,
                                  size: 30,
                                ),
                                Card(
                                  margin: const EdgeInsets.only(top: 2),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    child: Text(
                                      'Vị trí xe',
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (widget.customerLatitude != null &&
                            widget.customerLongitude != null)
                          Marker(
                            point: LatLng(
                              widget.customerLatitude!,
                              widget.customerLongitude!,
                            ),
                            width: 80,
                            height: 80,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.person_pin_circle_rounded,
                                  color: AppColors.success,
                                  size: 30,
                                ),
                                Card(
                                  margin: const EdgeInsets.only(top: 2),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    child: Text(
                                      'Điểm nhận',
                                      style: const TextStyle(
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
}
