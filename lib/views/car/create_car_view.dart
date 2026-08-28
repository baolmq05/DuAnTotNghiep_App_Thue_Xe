import 'dart:typed_data';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/create_car_viewmodel.dart';

class CreateCarView extends StatefulWidget {
  final int? carId;
  const CreateCarView({super.key, this.carId});

  @override
  State<CreateCarView> createState() => _CreateCarViewState();
}

class _CreateCarViewState extends State<CreateCarView> {
  final _imageUrlController = TextEditingController();
  final _addressController = TextEditingController();
  final _mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<CreateCarViewModel>();
      if (widget.carId != null) {
        await vm.fetchInitialDataAndLoadCar(widget.carId!);
        _addressController.text = vm.address;
      } else {
        await vm.fetchInitialData();
      }
    });
  }

  @override
  void dispose() {
    _imageUrlController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Searchable Modal Bottom Sheet to select Brand or Car Type
  void _showSearchableSelectionModal<T>({
    required String title,
    required List<T> items,
    required String Function(T item) getItemName,
    required int Function(T item) getItemId,
    required int? selectedId,
    required ValueChanged<T> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredItems = items.where((item) {
              final name = getItemName(item).toLowerCase();
              return name.contains(searchQuery.toLowerCase());
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.65,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar & Header
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: context.textSecondary,
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(modalContext),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Search bar
                  TextField(
                    onChanged: (val) {
                      setModalState(() {
                        searchQuery = val;
                      });
                    },
                    style: TextStyle(color: context.textPrimary, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Nhập từ khóa tìm kiếm...',
                      hintStyle: TextStyle(
                        color: context.textSecondary.withValues(alpha: 0.5),
                        fontSize: 13,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: context.textSecondary,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: context.inputBackground,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: context.inputBorderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: context.inputBorderColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // List result
                  Expanded(
                    child: filteredItems.isEmpty
                        ? Center(
                            child: Text(
                              'Không tìm thấy kết quả phù hợp',
                              style: TextStyle(
                                color: context.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filteredItems.length,
                            separatorBuilder: (_, __) =>
                                Divider(color: context.border, height: 1),
                            itemBuilder: (context, index) {
                              final item = filteredItems[index];
                              final isSelected = getItemId(item) == selectedId;
                              return ListTile(
                                dense: true,
                                title: Text(
                                  getItemName(item),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? context.primaryColor
                                        : context.textPrimary,
                                  ),
                                ),
                                trailing: isSelected
                                    ? Icon(
                                        Icons.check_circle,
                                        color: context.primaryColor,
                                        size: 20,
                                      )
                                    : null,
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  onSelected(item);
                                  Navigator.pop(modalContext);
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
      },
    );
  }

  // Bottom Sheet Choose Image
  void _showImagePickerSourceSheet(CreateCarViewModel vm) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(
                  Icons.photo_library_outlined,
                  color: context.primaryColor,
                ),
                title: Text(
                  'Chọn từ thư viện ảnh',
                  style: TextStyle(color: context.textPrimary, fontSize: 14),
                ),
                onTap: () {
                  Navigator.pop(context);
                  vm.pickLocalImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.camera_alt_outlined,
                  color: context.primaryColor,
                ),
                title: Text(
                  'Chụp ảnh mới bằng máy ảnh',
                  style: TextStyle(color: context.textPrimary, fontSize: 14),
                ),
                onTap: () {
                  Navigator.pop(context);
                  vm.pickLocalImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateCarViewModel>();

    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text(
          vm.isEditMode ? 'Chỉnh sửa thông tin xe' : 'Đăng ký xe mới',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
        ),
      ),
      body: vm.isLoadingData
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: context.primaryColor),
                  const SizedBox(height: 16),
                  Text(
                    'Đang tải danh mục xe...',
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thông báo lỗi nếu có
                  if (vm.errorMessage.isNotEmpty)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              vm.errorMessage,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Section 1: Thông tin cơ bản
                  _buildSectionCard(
                    context,
                    title: '1. Thông tin cơ bản',
                    icon: Icons.info_outline,
                    children: [
                      // Thương hiệu (Searchable Modal)
                      _buildLabel(context, 'Thương hiệu xe *'),
                      InkWell(
                        onTap: () {
                          _showSearchableSelectionModal(
                            title: 'Chọn thương hiệu xe',
                            items: vm.brands,
                            getItemName: (b) => b.brand_name,
                            getItemId: (b) => b.id,
                            selectedId: vm.selectedBrandId,
                            onSelected: (b) => vm.fetchTypesForBrand(b.id),
                          );
                        },
                        child: _buildCustomSelectorTile(
                          context,
                          text: vm.selectedBrandName.isNotEmpty
                              ? vm.selectedBrandName
                              : 'Bấm để tìm & chọn thương hiệu',
                          isSelected: vm.selectedBrandId != null,
                          hasError: vm.fieldErrors['car_brand_id'] != null,
                        ),
                      ),
                      if (vm.fieldErrors['car_brand_id'] != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          vm.fieldErrors['car_brand_id']!,
                          style: const TextStyle(color: Colors.red, fontSize: 11),
                        ),
                      ],
                      const SizedBox(height: 12),

                      // Loại xe (Searchable Modal)
                      _buildLabel(context, 'Loại xe *'),
                      vm.isLoadingTypes
                          ? const LinearProgressIndicator()
                          : InkWell(
                              onTap: () {
                                if (vm.types.isEmpty) {
                                  _showToast(
                                    'Vui lòng chọn Thương hiệu xe trước!',
                                    isError: true,
                                  );
                                  return;
                                }
                                _showSearchableSelectionModal(
                                  title: 'Chọn loại xe',
                                  items: vm.types,
                                  getItemName: (t) => t.typeName,
                                  getItemId: (t) => t.id,
                                  selectedId: vm.selectedTypeId,
                                  onSelected: (t) {
                                    vm.selectedTypeId = t.id;
                                  },
                                );
                              },
                              child: _buildCustomSelectorTile(
                                context,
                                text: vm.selectedTypeName.isNotEmpty
                                    ? vm.selectedTypeName
                                    : 'Bấm để tìm & chọn loại xe',
                                isSelected: vm.selectedTypeId != null,
                                hasError: vm.fieldErrors['car_type_id'] != null,
                              ),
                            ),
                      if (vm.fieldErrors['car_type_id'] != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          vm.fieldErrors['car_type_id']!,
                          style: const TextStyle(color: Colors.red, fontSize: 11),
                        ),
                      ],
                      const SizedBox(height: 12),

                      // Biển số xe & Số khung
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel(context, 'Biển số xe *'),
                                TextFormField(
                                  initialValue: vm.licensePlate,
                                  style: TextStyle(
                                    color: context.textPrimary,
                                    fontSize: 13,
                                  ),
                                  decoration: _buildInputDecoration(
                                    context,
                                    'Ví dụ: 65A-12345',
                                    errorText: vm.fieldErrors['license_plate'],
                                  ),
                                  onChanged: (v) => vm.licensePlate = v,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel(context, 'Số khung (VIN) *'),
                                TextFormField(
                                  initialValue: vm.vin,
                                  style: TextStyle(
                                    color: context.textPrimary,
                                    fontSize: 13,
                                  ),
                                  decoration: _buildInputDecoration(
                                    context,
                                    '17 ký tự',
                                    errorText: vm.fieldErrors['vin'],
                                  ),
                                  onChanged: (v) => vm.vin = v,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Số máy & Năm sản xuất
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel(context, 'Số máy *'),
                                TextFormField(
                                  initialValue: vm.engineNumber,
                                  style: TextStyle(
                                    color: context.textPrimary,
                                    fontSize: 13,
                                  ),
                                  decoration: _buildInputDecoration(
                                    context,
                                    'Nhập số máy',
                                    errorText: vm.fieldErrors['engine_number'],
                                  ),
                                  onChanged: (v) => vm.engineNumber = v,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel(context, 'Năm sản xuất *'),
                                TextFormField(
                                  initialValue: vm.manufactureYear.toString(),
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                    color: context.textPrimary,
                                    fontSize: 13,
                                  ),
                                  decoration: _buildInputDecoration(
                                    context,
                                    '2022',
                                    errorText: vm.fieldErrors['manufacture_year'],
                                  ),
                                  onChanged: (v) => vm.manufactureYear =
                                      int.tryParse(v) ?? 2022,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Số chỗ & Nhiên liệu
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel(context, 'Số chỗ ngồi *'),
                                TextFormField(
                                  initialValue: vm.seatCount.toString(),
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                    color: context.textPrimary,
                                    fontSize: 13,
                                  ),
                                  decoration: _buildInputDecoration(
                                    context,
                                    '5',
                                    errorText: vm.fieldErrors['seat_count'],
                                  ),
                                  onChanged: (v) =>
                                      vm.seatCount = int.tryParse(v) ?? 5,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel(context, 'Loại nhiên liệu'),
                                DropdownButtonFormField<String>(
                                  initialValue: vm.fuelType,
                                  dropdownColor: context.cardColor,
                                  decoration: _buildInputDecoration(
                                    context,
                                    'Chọn',
                                    errorText: vm.fieldErrors['fuel_type'],
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'gasoline',
                                      child: Text('Xăng'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'diesel',
                                      child: Text('Dầu (Diesel)'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'electric',
                                      child: Text('Điện'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'hybrid',
                                      child: Text('Hybrid'),
                                    ),
                                  ],
                                  onChanged: (v) {
                                    if (v != null) vm.fuelType = v;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Hộp số & Tiêu thụ nhiên liệu
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel(context, 'Hộp số'),
                                DropdownButtonFormField<String>(
                                  initialValue: vm.transmission,
                                  dropdownColor: context.cardColor,
                                  decoration: _buildInputDecoration(
                                    context,
                                    'Chọn',
                                    errorText: vm.fieldErrors['transmission'],
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'automatic',
                                      child: Text('Số tự động'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'manual',
                                      child: Text('Số sàn'),
                                    ),
                                  ],
                                  onChanged: (v) {
                                    if (v != null) vm.transmission = v;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel(context, 'Mức tiêu thụ (L/100km)'),
                                TextFormField(
                                  initialValue: vm.fuelConsumption.toString(),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  style: TextStyle(
                                    color: context.textPrimary,
                                    fontSize: 13,
                                  ),
                                  decoration: _buildInputDecoration(
                                    context,
                                    '6.5',
                                    errorText: vm.fieldErrors['fuel_consumption'],
                                  ),
                                  onChanged: (v) => vm.fuelConsumption =
                                      double.tryParse(v) ?? 6.5,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Section 2: Giá thuê
                  _buildSectionCard(
                    context,
                    title: '2. Giá thuê & Ưu đãi',
                    icon: Icons.monetization_on_outlined,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel(
                                  context,
                                  'Đơn giá thuê/ngày (VNĐ) *',
                                ),
                                TextFormField(
                                  initialValue: vm.unitPrice.toInt().toString(),
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                    color: context.textPrimary,
                                    fontSize: 13,
                                  ),
                                  decoration: _buildInputDecoration(
                                    context,
                                    '500000',
                                    errorText: vm.fieldErrors['unit_price'],
                                  ),
                                  onChanged: (v) =>
                                      vm.unitPrice = double.tryParse(v) ?? 0,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel(context, 'Giảm giá (VNĐ)'),
                                TextFormField(
                                  initialValue: vm.discountValue
                                      .toInt()
                                      .toString(),
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                    color: context.textPrimary,
                                    fontSize: 13,
                                  ),
                                  decoration: _buildInputDecoration(
                                    context,
                                    '0',
                                    errorText: vm.fieldErrors['discount_value'],
                                  ),
                                  onChanged: (v) => vm.discountValue =
                                      double.tryParse(v) ?? 0,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Section 3: Mô tả & Điều khoản
                  _buildSectionCard(
                    context,
                    title: '3. Mô tả & Điều khoản thuê xe',
                    icon: Icons.description_outlined,
                    children: [
                      _buildLabel(context, 'Mô tả chi tiết về xe'),
                      TextFormField(
                        initialValue: vm.description,
                        maxLines: 3,
                        style: TextStyle(
                          color: context.textPrimary,
                          fontSize: 13,
                        ),
                        decoration: _buildInputDecoration(
                          context,
                          'Xe sạch sẽ, bảo dưỡng định kỳ...',
                          errorText: vm.fieldErrors['description'],
                        ),
                        onChanged: (v) => vm.description = v,
                      ),
                      const SizedBox(height: 12),

                      _buildLabel(context, 'Điều khoản thuê xe'),
                      TextFormField(
                        initialValue: vm.rentalTerms,
                        maxLines: 3,
                        style: TextStyle(
                          color: context.textPrimary,
                          fontSize: 13,
                        ),
                        decoration: _buildInputDecoration(
                          context,
                          'Không hút thuốc trong xe, giữ vệ sinh...',
                          errorText: vm.fieldErrors['rental_terms'],
                        ),
                        onChanged: (v) => vm.rentalTerms = v,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Section 4: Địa điểm (Gợi ý địa chỉ từ GoongMap)
                  _buildSectionCard(
                    context,
                    title: '4. Vị trí & Địa chỉ xe',
                    icon: Icons.location_on_outlined,
                    children: [
                      _buildLabel(context, 'Khu vực / Tỉnh/Thành phố *'),
                      TextFormField(
                        initialValue: vm.location,
                        style: TextStyle(
                          color: context.textPrimary,
                          fontSize: 13,
                        ),
                        decoration: _buildInputDecoration(
                          context,
                          'Ví dụ: Ninh Kiều, Cần Thơ',
                          errorText: vm.fieldErrors['location'],
                        ),
                        onChanged: (v) => vm.location = v,
                      ),
                      const SizedBox(height: 12),

                      _buildLabel(
                        context,
                        'Địa chỉ chi tiết (Bản đồ GoongMap) *',
                      ),
                      TextFormField(
                        controller: _addressController,
                        style: TextStyle(
                          color: context.textPrimary,
                          fontSize: 13,
                        ),
                        decoration: _buildInputDecoration(
                          context,
                          'Nhập số nhà, tên đường để gợi ý tìm địa chỉ...',
                          errorText: vm.fieldErrors['address'],
                        ),
                        onChanged: (v) => vm.fetchAddressSuggestions(v),
                      ),
                      if (vm.addressSuggestionsWithId.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          constraints: const BoxConstraints(maxHeight: 220),
                          decoration: BoxDecoration(
                            color: context.cardColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: context.inputBorderColor),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: vm.addressSuggestionsWithId.length,
                              separatorBuilder: (_, __) => Divider(
                                color: context.inputBorderColor.withValues(alpha: 0.5),
                                height: 1,
                              ),
                              itemBuilder: (context, index) {
                                final sugItem =
                                    vm.addressSuggestionsWithId[index];
                                final sugText = sugItem['description'] ?? '';
                                return ListTile(
                                  dense: true,
                                  leading: Icon(
                                    Icons.my_location_rounded,
                                    color: context.primaryColor,
                                    size: 18,
                                  ),
                                  title: Text(
                                    sugText,
                                    style: TextStyle(
                                      color: context.textPrimary,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                  onTap: () async {
                                    FocusScope.of(context).unfocus();
                                    _addressController.text = sugText;
                                    _addressController.selection =
                                        TextSelection.fromPosition(
                                          TextPosition(offset: sugText.length),
                                        );
                                    await vm.selectAddressSuggestionItem(
                                      sugItem,
                                    );
                                    try {
                                      _mapController.move(
                                        LatLng(vm.selectedLat, vm.selectedLng),
                                        15.0,
                                      );
                                    } catch (e) {
                                      debugPrint('Map move error: $e');
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                        ),

                      // Bản đồ vị trí xe (Luôn hiển thị trực quan)
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Icon(
                            Icons.map_outlined,
                            color: context.primaryColor,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Vị trí xe trên bản đồ:',
                            style: TextStyle(
                              color: context.textPrimary,
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 190,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: context.border, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: LatLng(
                                vm.selectedLat,
                                vm.selectedLng,
                              ),
                              initialZoom: 15.0,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName:
                                    'com.example.duantotnghiep_app_thue_xe',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: LatLng(
                                      vm.selectedLat,
                                      vm.selectedLng,
                                    ),
                                    width: 44,
                                    height: 44,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withValues(
                                          alpha: 0.2,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.location_on,
                                        color: Colors.red,
                                        size: 34,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Section 5: Delivery
                  _buildSectionCard(
                    context,
                    title: '5. Giao nhận xe tận nơi',
                    icon: Icons.local_shipping_outlined,
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Cho phép giao xe tận nơi',
                          style: TextStyle(
                            color: context.textPrimary,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        value: vm.deliveryEnabled,
                        activeColor: context.primaryColor,
                        onChanged: (val) => vm.setDeliveryEnabled(val),
                      ),
                      if (vm.deliveryEnabled) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel(
                                    context,
                                    'Khoảng cách tối đa (km)',
                                  ),
                                  TextFormField(
                                    initialValue: vm.deliveryMaxDistance
                                        .toString(),
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                      color: context.textPrimary,
                                      fontSize: 13,
                                    ),
                                    decoration: _buildInputDecoration(
                                      context,
                                      '20',
                                    ),
                                    onChanged: (v) => vm.deliveryMaxDistance =
                                        double.tryParse(v) ?? 0,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel(
                                    context,
                                    'Khoảng cách miễn phí (km)',
                                  ),
                                  TextFormField(
                                    initialValue: vm.deliveryFreeDistance
                                        .toString(),
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                      color: context.textPrimary,
                                      fontSize: 13,
                                    ),
                                    decoration: _buildInputDecoration(
                                      context,
                                      '5',
                                    ),
                                    onChanged: (v) => vm.deliveryFreeDistance =
                                        double.tryParse(v) ?? 0,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildLabel(context, 'Phí giao xe phụ trội (VNĐ/km)'),
                        TextFormField(
                          initialValue: vm.deliveryFee.toInt().toString(),
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            color: context.textPrimary,
                            fontSize: 13,
                          ),
                          decoration: _buildInputDecoration(context, '10000'),
                          onChanged: (v) =>
                              vm.deliveryFee = double.tryParse(v) ?? 0,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Section 6: Giới hạn km
                  _buildSectionCard(
                    context,
                    title: '6. Giới hạn số km',
                    icon: Icons.speed_outlined,
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Giới hạn số km di chuyển mỗi ngày',
                          style: TextStyle(
                            color: context.textPrimary,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        value: vm.kmLimitEnabled,
                        activeColor: context.primaryColor,
                        onChanged: (val) => vm.setKmLimitEnabled(val),
                      ),
                      if (vm.kmLimitEnabled) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel(context, 'Số km tối đa/ngày'),
                                  TextFormField(
                                    initialValue: vm.kmLimitValue.toString(),
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                      color: context.textPrimary,
                                      fontSize: 13,
                                    ),
                                    decoration: _buildInputDecoration(
                                      context,
                                      '200',
                                    ),
                                    onChanged: (v) => vm.kmLimitValue =
                                        double.tryParse(v) ?? 0,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel(context, 'Phí vượt km (VNĐ/km)'),
                                  TextFormField(
                                    initialValue: vm.overFeeValue
                                        .toInt()
                                        .toString(),
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                      color: context.textPrimary,
                                      fontSize: 13,
                                    ),
                                    decoration: _buildInputDecoration(
                                      context,
                                      '5000',
                                    ),
                                    onChanged: (v) => vm.overFeeValue =
                                        double.tryParse(v) ?? 0,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Section 7: Features
                  _buildSectionCard(
                    context,
                    title: '7. Tính năng tiện ích nổi bật',
                    icon: Icons.star_outline_rounded,
                    children: [
                      vm.features.isEmpty
                          ? Text(
                              'Chưa có danh sách tính năng.',
                              style: TextStyle(
                                color: context.textSecondary,
                                fontSize: 12,
                              ),
                            )
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: vm.features.map((feat) {
                                final isSelected = vm.selectedFeatures.contains(
                                  feat.id,
                                );
                                return FilterChip(
                                  label: Text(feat.featureName),
                                  selected: isSelected,
                                  selectedColor: context.primaryColor
                                      .withValues(alpha: 0.2),
                                  checkmarkColor: context.primaryColor,
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? context.primaryColor
                                        : context.textPrimary,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: 12,
                                  ),
                                  backgroundColor: context.inputBackground,
                                  onSelected: (_) => vm.toggleFeature(feat.id),
                                );
                              }).toList(),
                            ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Section 8: Images (Tải ảnh trực tiếp lên Cloudinary)
                  _buildSectionCard(
                    context,
                    title: '8. Hình ảnh xe (Tải ảnh từ máy)',
                    icon: Icons.cloud_upload_outlined,
                    children: [
                      // Nút chọn & tải ảnh trực tiếp lên Cloudinary
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: OutlinedButton.icon(
                          onPressed: vm.isUploadingImage
                              ? null
                              : () => _showImagePickerSourceSheet(vm),
                          icon: vm.isUploadingImage
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  Icons.add_a_photo_outlined,
                                  color: context.primaryColor,
                                  size: 18,
                                ),
                          label: Text(
                            vm.isUploadingImage
                                ? 'Đang tải ảnh lên...'
                                : 'Tải ảnh lên từ thiết bị',
                            style: TextStyle(
                              color: context.primaryColor,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: context.primaryColor,
                              width: 1.2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      if (vm.fieldErrors['images'] != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          vm.fieldErrors['images']!,
                          style: const TextStyle(color: Colors.red, fontSize: 11),
                        ),
                      ],
                      const SizedBox(height: 12),

                      // Hoặc nhập URL thủ công
                      ExpansionTile(
                        title: Text(
                          'Hoặc nhập URL ảnh trực tiếp',
                          style: TextStyle(
                            color: context.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        tilePadding: EdgeInsets.zero,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _imageUrlController,
                                  style: TextStyle(
                                    color: context.textPrimary,
                                    fontSize: 13,
                                  ),
                                  decoration: _buildInputDecoration(
                                    context,
                                    'https://res.cloudinary.com/...',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  if (_imageUrlController.text.isNotEmpty) {
                                    vm.addImageUrl(_imageUrlController.text);
                                    _imageUrlController.clear();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: context.primaryColor,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                ),
                                child: const Text(
                                  'Thêm',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (vm.selectedImageFiles.isEmpty && vm.images.isEmpty)
                        Text(
                          'Chưa có hình ảnh nào được thêm.',
                          style: TextStyle(
                            color: context.textSecondary,
                            fontSize: 12,
                          ),
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nhấn vào ảnh để chọn làm ảnh đại diện (Thumbnail):',
                              style: TextStyle(
                                color: context.textSecondary,
                                fontSize: 11.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: vm.selectedImageFiles.isNotEmpty
                                    ? vm.selectedImageFiles.length
                                    : vm.images.length,
                                itemBuilder: (context, index) {
                                  final isThumbnail =
                                      vm.thumbnailIndex == index;
                                  final isLocal =
                                      vm.selectedImageFiles.isNotEmpty;
                                  final xfile = isLocal
                                      ? vm.selectedImageFiles[index]
                                      : null;
                                  final url = !isLocal
                                      ? vm.images[index]
                                      : null;

                                  return GestureDetector(
                                    onTap: () => vm.setThumbnailIndex(index),
                                    child: Container(
                                      width: 95,
                                      margin: const EdgeInsets.only(right: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isThumbnail
                                              ? context.primaryColor
                                              : context.border,
                                          width: isThumbnail ? 2.5 : 1,
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              9,
                                            ),
                                            child: isLocal && xfile != null
                                                ? FutureBuilder<Uint8List>(
                                                    future: xfile.readAsBytes(),
                                                    builder: (context, snapshot) {
                                                      if (snapshot.hasData) {
                                                        return Image.memory(
                                                          snapshot.data!,
                                                          width: 95,
                                                          height: 100,
                                                          fit: BoxFit.cover,
                                                        );
                                                      }
                                                      return Container(
                                                        width: 95,
                                                        height: 100,
                                                        color: Colors
                                                            .grey
                                                            .shade200,
                                                        child: const Center(
                                                          child: SizedBox(
                                                            width: 20,
                                                            height: 20,
                                                            child:
                                                                CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2,
                                                                ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  )
                                                : Image.network(
                                                    url ?? '',
                                                    width: 95,
                                                    height: 100,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (
                                                          _,
                                                          __,
                                                          ___,
                                                        ) => Container(
                                                          color: Colors
                                                              .grey
                                                              .shade200,
                                                          child: const Icon(
                                                            Icons.broken_image,
                                                            color: Colors.grey,
                                                            size: 24,
                                                          ),
                                                        ),
                                                  ),
                                          ),
                                          if (isThumbnail)
                                            Positioned(
                                              top: 4,
                                              left: 4,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 5,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: context.primaryColor,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: const Text(
                                                  'Thumbnail',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          Positioned(
                                            top: 4,
                                            right: 4,
                                            child: GestureDetector(
                                              onTap: () =>
                                                  vm.removeImageAt(index),
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  2,
                                                ),
                                                decoration: const BoxDecoration(
                                                  color: Colors.black54,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                  size: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: (vm.isSubmitting || vm.isUploadingImage)
                          ? null
                          : () async {
                              final res = await vm.submitCarRegistration();
                              if (res.success) {
                                _showToast(res.message, isError: false);
                                if (mounted) {
                                  if (context.canPop()) {
                                    context.pop();
                                  } else {
                                    context.go('/owner-dashboard');
                                  }
                                }
                              } else {
                                _showToast(res.message, isError: true);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: vm.isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              vm.isEditMode ? 'Cập nhật xe' : 'Đăng ký xe ngay',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildCustomSelectorTile(
    BuildContext context, {
    required String text,
    required bool isSelected,
    bool hasError = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: context.inputBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasError
              ? Colors.red
              : isSelected
                  ? context.primaryColor
                  : context.inputBorderColor,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isSelected
                    ? context.textPrimary
                    : context.textSecondary.withValues(alpha: 0.5),
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: context.textSecondary,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: context.primaryColor, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: context.textSecondary,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    BuildContext context,
    String hint, {
    String? errorText,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: context.textSecondary.withValues(alpha: 0.45),
        fontSize: 12.5,
      ),
      errorText: errorText,
      filled: true,
      fillColor: context.inputBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: errorText != null ? Colors.red : context.inputBorderColor,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: errorText != null ? Colors.red : context.inputBorderColor,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: errorText != null ? Colors.red : context.primaryColor,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }
}
