import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:duantotnghiep_app_thue_xe/models/trip_model.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:duantotnghiep_app_thue_xe/widgets/app_toast.dart';

/// BottomSheet Giao diện Báo cáo vi phạm chuyến đi
/// Khớp 100% với cấu trúc bảng `reports` trong Database:
/// - report_type: 0 (Giao sai xe), 1 (Không đến giao/nhận xe), 2 (Gian lận), 3 (Khác)
/// - title: Tiêu đề báo cáo (varchar 255)
/// - description: Chi tiết báo cáo (text)
/// - trip_id: Mã chuyến đi (bigint)
/// - reporter_id: Mã người báo cáo (bigint)
/// - status: 0 (Chờ xử lý), 1 (Đang xử lý), 2 (Đã giải quyết), 3 (Từ chối)
class OrderDetailReportViolationSheet extends StatefulWidget {
  final TripModel trip;
  final VoidCallback? onReportSubmitted;

  const OrderDetailReportViolationSheet({
    super.key,
    required this.trip,
    this.onReportSubmitted,
  });

  /// Hàm tiện ích để mở BottomSheet báo cáo vi phạm
  static Future<void> show(
    BuildContext context, {
    required TripModel trip,
    VoidCallback? onReportSubmitted,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => OrderDetailReportViolationSheet(
        trip: trip,
        onReportSubmitted: onReportSubmitted,
      ),
    );
  }

  @override
  State<OrderDetailReportViolationSheet> createState() =>
      _OrderDetailReportViolationSheetState();
}

class _OrderDetailReportViolationSheetState
    extends State<OrderDetailReportViolationSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];

  int? _selectedReportType; // 0, 1, 2, 3 tương ứng trong database
  bool _isSubmitting = false;
  static const int _maxImages = 5;

  /// Danh mục 4 loại vi phạm khớp chuẩn xác theo trường `report_type` trong CSDL
  final List<Map<String, dynamic>> _violationReasons = [
    {
      'type': 0,
      'title': 'Giao sai xe',
      'desc': 'Xe được giao không đúng mẫu mã, đời xe, biển số hoặc tính năng đã thỏa thuận',
      'icon': Icons.directions_car_outlined,
      'suggestedTitle': 'Báo cáo giao sai xe',
    },
    {
      'type': 1,
      'title': 'Không đến giao/nhận xe',
      'desc': 'Đối tác hoặc khách thuê không có mặt tại điểm hẹn, không thể liên lạc',
      'icon': Icons.person_off_outlined,
      'suggestedTitle': 'Báo cáo không đến giao/nhận xe',
    },
    {
      'type': 2,
      'title': 'Gian lận',
      'desc': 'Yêu cầu thu thêm chi phí ngoài hợp đồng, tráo linh kiện hoặc hành vi lừa đảo',
      'icon': Icons.warning_amber_rounded,
      'suggestedTitle': 'Báo cáo hành vi gian lận',
    },
    {
      'type': 3,
      'title': 'Khác',
      'desc': 'Các vi phạm, sự cố hoặc tranh chấp khác phát sinh trong chuyến đi',
      'icon': Icons.more_horiz_rounded,
      'suggestedTitle': 'Báo cáo sự cố phát sinh',
    },
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onSelectReportType(int reportType, String suggestedTitle) {
    setState(() {
      _selectedReportType = reportType;
      // Tự động điền tiêu đề gợi ý nếu ô tiêu đề đang trống
      if (_titleController.text.trim().isEmpty) {
        _titleController.text = '$suggestedTitle #${widget.trip.displayCode}';
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_selectedImages.length >= _maxImages) {
      AppToast.show(
        context,
        message: 'Bạn chỉ có thể tải lên tối đa $_maxImages hình ảnh.',
        type: ToastType.warning,
      );
      return;
    }

    try {
      if (source == ImageSource.gallery) {
        final List<XFile> pickedList = await _picker.pickMultiImage();
        if (pickedList.isNotEmpty) {
          setState(() {
            for (var img in pickedList) {
              if (_selectedImages.length < _maxImages) {
                _selectedImages.add(img);
              }
            }
          });
        }
      } else {
        final XFile? photo = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
        );
        if (photo != null) {
          setState(() {
            _selectedImages.add(photo);
          });
        }
      }
    } catch (e) {
      debugPrint('Lỗi chọn ảnh: $e');
    }
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  'Chọn nguồn ảnh bằng chứng',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: context.primaryColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.photo_library_outlined,
                      color: context.primaryColor,
                    ),
                  ),
                  title: Text(
                    'Chọn từ thư viện ảnh',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'Cho phép chọn nhiều ảnh cùng lúc',
                    style: TextStyle(fontSize: 12, color: context.textSecondary),
                  ),
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: context.primaryColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.camera_alt_outlined,
                      color: context.primaryColor,
                    ),
                  ),
                  title: Text(
                    'Chụp ảnh trực tiếp từ máy ảnh',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'Chụp ảnh hiện trạng xe / sự việc',
                    style: TextStyle(fontSize: 12, color: context.textSecondary),
                  ),
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _handleSubmitReport() async {
    // Validation các trường theo Database
    if (_selectedReportType == null) {
      AppToast.show(
        context,
        message: 'Vui lòng chọn loại báo cáo vi phạm.',
        type: ToastType.warning,
      );
      return;
    }

    final title = _titleController.text.trim();
    if (title.isEmpty) {
      AppToast.show(
        context,
        message: 'Vui lòng nhập tiêu đề báo cáo.',
        type: ToastType.warning,
      );
      return;
    }

    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      AppToast.show(
        context,
        message: 'Vui lòng nhập chi tiết nội dung báo cáo.',
        type: ToastType.warning,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Giả lập gửi dữ liệu giao diện
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    Navigator.pop(context);

    AppToast.show(
      context,
      message:
          'Đã gửi báo cáo vi phạm thành công! Drivio sẽ tiếp nhận và xử lý trong 24h.',
      type: ToastType.success,
    );

    widget.onReportSubmitted?.call();
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    final car = trip.car;
    final isDark = context.isDarkMode;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header / Drag Handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Title Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.report_problem_rounded,
                    color: AppColors.error,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Báo cáo vi phạm chuyến đi',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Gửi khiếu nại hoặc phản ánh vấn đề xảy ra đến Admin',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: context.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Scrollable Body Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trip Summary Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: car != null
                              ? Image.network(
                                  car.getFirstImageUrl(),
                                  width: 54,
                                  height: 54,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 54,
                                    height: 54,
                                    color: Colors.grey.shade300,
                                    child: const Icon(
                                      Icons.directions_car,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : Container(
                                  width: 54,
                                  height: 54,
                                  color: context.primaryColor.withAlpha(30),
                                  child: Icon(
                                    Icons.directions_car,
                                    color: context.primaryColor,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: context.primaryColor.withAlpha(30),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Mã chuyến đi: #${trip.displayCode}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: context.primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                car?.name ?? 'Xe thuê tự lái',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: context.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (car?.licensePlate != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'Biển số xe: ${car!.licensePlate}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: context.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Section 1: Loại vi phạm
                  Row(
                    children: [
                      Text(
                        '1. Chọn loại vi phạm',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                      const Text(
                        ' *',
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // 4 loại báo cáo
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _violationReasons.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = _violationReasons[index];
                      final reportType = item['type'] as int;
                      final isSelected = _selectedReportType == reportType;

                      return InkWell(
                        onTap: () => _onSelectReportType(
                          reportType,
                          item['suggestedTitle'] as String,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark
                                    ? const Color(0xFF3B1E1E)
                                    : const Color(0xFFFEF2F2))
                                : context.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.error
                                  : context.border,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.error.withAlpha(30)
                                      : context.primaryColor.withAlpha(15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  item['icon'] as IconData,
                                  size: 18,
                                  color: isSelected
                                      ? AppColors.error
                                      : context.primaryColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['title'] as String,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w600,
                                        color: isSelected
                                            ? (isDark
                                                ? Colors.red.shade200
                                                : Colors.red.shade900)
                                            : context.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item['desc'] as String,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isSelected
                                            ? (isDark
                                                ? Colors.red.shade300
                                                : Colors.red.shade700)
                                            : context.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 20,
                                height: 20,
                                margin: const EdgeInsets.only(left: 8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.error
                                        : Colors.grey.shade400,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? Center(
                                        child: Container(
                                          width: 10,
                                          height: 10,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.error,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 18),

                  // Section 2: Tiêu đề báo cáo
                  Row(
                    children: [
                      Text(
                        '2. Tiêu đề báo cáo',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                      const Text(
                        ' *',
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
                    maxLength: 255,
                    decoration: InputDecoration(
                      hintText: 'Nhập tóm tắt tiêu đề báo cáo...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade400,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.error,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    style: TextStyle(fontSize: 13, color: context.textPrimary),
                  ),

                  const SizedBox(height: 12),

                  // Section 3: Chi tiết báo cáo
                  Row(
                    children: [
                      Text(
                        '3. Chi tiết nội dung báo cáo',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                      const Text(
                        ' *',
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText:
                          'Vui lòng mô tả chi tiết sự việc, thời gian, địa điểm, các bằng chứng hoặc tổn thất xảy ra để được hỗ trợ...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade400,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.error,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                    style: TextStyle(fontSize: 13, color: context.textPrimary),
                  ),

                  const SizedBox(height: 16),

                  // Section 4: Hình ảnh bằng chứng
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            '4. Hình ảnh bằng chứng',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: context.textPrimary,
                            ),
                          ),
                          Text(
                            ' (Tối đa $_maxImages ảnh)',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${_selectedImages.length}/$_maxImages',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _selectedImages.length >= _maxImages
                              ? AppColors.error
                              : context.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Images Grid & Add Button
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      // Preview thumbnails
                      ..._selectedImages.asMap().entries.map((entry) {
                        final index = entry.key;
                        final xFile = entry.value;

                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: context.border,
                                  width: 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(11),
                                child: kIsWeb
                                    ? Image.network(
                                        xFile.path,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(
                                        File(xFile.path),
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            Positioned(
                              top: -6,
                              right: -6,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: AppColors.error,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),

                      // Add Image Button (Visible if < _maxImages)
                      if (_selectedImages.length < _maxImages)
                        InkWell(
                          onTap: _showImageSourcePicker,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: context.primaryColor.withAlpha(100),
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo_outlined,
                                  color: context.primaryColor,
                                  size: 24,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Thêm ảnh',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: context.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Section 5: Quy trình tiếp nhận
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2A2318)
                          : const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? Colors.amber.shade900
                            : Colors.amber.shade200,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: Colors.amber.shade700,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Quy trình tiếp nhận & xử lý',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.amber.shade200
                                    : Colors.amber.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '• Báo cáo sau khi gửi sẽ được chuyển đến ban quản trị tiếp nhận và xử lý.\n• Đội ngũ Drivio sẽ xác minh thông tin và liên hệ với các bên liên quan trong vòng 24h.\n• Vui lòng cung cấp thông tin trung thực và chính xác để được hỗ trợ giải quyết tốt nhất.',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark
                                ? Colors.amber.shade200
                                : Colors.amber.shade900,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 1),

          // Bottom Action Buttons
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed:
                          _isSubmitting ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: context.border),
                      ),
                      child: Text(
                        'Hủy',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: context.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _handleSubmitReport,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.send_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                      label: Text(
                        _isSubmitting
                            ? 'Đang gửi...'
                            : 'Gửi báo cáo vi phạm',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
