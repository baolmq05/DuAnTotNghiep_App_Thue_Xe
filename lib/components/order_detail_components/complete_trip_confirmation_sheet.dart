import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/models/trip_model.dart';

/// Modal BottomSheet Xác nhận Kiểm tra & Nhận lại xe dành cho Chủ xe
class CompleteTripConfirmationSheet extends StatefulWidget {
  final TripModel trip;
  final VoidCallback onConfirm;

  const CompleteTripConfirmationSheet({
    super.key,
    required this.trip,
    required this.onConfirm,
  });

  /// Hàm tiện ích mở BottomSheet xác nhận
  static Future<bool?> show(
    BuildContext context, {
    required TripModel trip,
    required VoidCallback onConfirm,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CompleteTripConfirmationSheet(
        trip: trip,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<CompleteTripConfirmationSheet> createState() =>
      _CompleteTripConfirmationSheetState();
}

class _CompleteTripConfirmationSheetState
    extends State<CompleteTripConfirmationSheet> {
  bool _exterior = false;
  bool _interior = false;
  bool _documents = false;
  bool _fuelOdo = false;
  bool _operation = false;
  bool _dateTime = false;

  bool get _isAllChecked =>
      _exterior &&
      _interior &&
      _documents &&
      _fuelOdo &&
      _operation &&
      _dateTime;

  void _toggleCheckAll() {
    final target = !_isAllChecked;
    setState(() {
      _exterior = target;
      _interior = target;
      _documents = target;
      _fuelOdo = target;
      _operation = target;
      _dateTime = target;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final carName = widget.trip.car?.name ?? 'Xe';

    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.assignment_turned_in_rounded,
                    color: Colors.teal,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Xác nhận Kiểm tra & Nhận lại xe',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Chuyến đi #${widget.trip.tripCode ?? widget.trip.id} • $carName',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.grey),
                  onPressed: () => Navigator.pop(context, false),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Scrollable Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Short Description
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFDCFCE7)),
                    ),
                    child: const Text(
                      'Vui lòng kiểm tra kỹ lưỡng hiện trạng xe cùng khách thuê trước khi kết thúc chuyến đi nhằm đảm bảo quyền lợi của bạn.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF166534),
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Checklist Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Danh mục kiểm tra bắt buộc *',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF334155),
                        ),
                      ),
                      TextButton(
                        onPressed: _toggleCheckAll,
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          _isAllChecked ? 'Bỏ chọn tất cả' : 'Chọn tất cả',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Checkbox Items
                  _buildChecklistItem(
                    title: 'Ngoại thất xe',
                    desc:
                        'Thân vỏ, gương chiếu hậu, kính xe và hệ thống đèn không phát sinh trầy xước, nứt vỡ mới so với lúc bàn giao.',
                    value: _exterior,
                    onChanged: (val) => setState(() => _exterior = val ?? false),
                  ),
                  const SizedBox(height: 8),

                  _buildChecklistItem(
                    title: 'Nội thất & Vệ sinh',
                    desc:
                        'Ghế da, thảm lót sàn, trần xe sạch sẽ; không bị rách, ố bẩn nặng hoặc lưu lại mùi lạ/khói thuốc.',
                    value: _interior,
                    onChanged: (val) => setState(() => _interior = val ?? false),
                  ),
                  const SizedBox(height: 8),

                  _buildChecklistItem(
                    title: 'Giấy tờ & Phụ kiện',
                    desc:
                        'Đã nhận lại đủ chìa khóa, giấy đăng kiểm, bảo hiểm xe, bánh dự phòng và bộ dụng cụ cứu hộ.',
                    value: _documents,
                    onChanged: (val) => setState(() => _documents = val ?? false),
                  ),
                  const SizedBox(height: 8),

                  _buildChecklistItem(
                    title: 'Mức nhiên liệu & Số km (Odo)',
                    desc:
                        'Mức xăng/pin và số km di chuyển phù hợp với thỏa thuận ban đầu.',
                    value: _fuelOdo,
                    onChanged: (val) => setState(() => _fuelOdo = val ?? false),
                  ),
                  const SizedBox(height: 8),

                  _buildChecklistItem(
                    title: 'Tình trạng vận hành',
                    desc:
                        'Động cơ, hệ thống phanh, điều hòa và lốp xe hoạt động bình thường, không có đèn báo lỗi.',
                    value: _operation,
                    onChanged: (val) => setState(() => _operation = val ?? false),
                  ),
                  const SizedBox(height: 8),

                  _buildChecklistItem(
                    title: 'Thời gian & Địa điểm',
                    desc:
                        'Đã nhận lại xe đúng thời gian và địa điểm theo thỏa thuận với khách thuê.',
                    value: _dateTime,
                    onChanged: (val) => setState(() => _dateTime = val ?? false),
                  ),
                  const SizedBox(height: 16),

                  // Warning Callout Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Color(0xFFD97706),
                              size: 18,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'LƯU Ý QUAN TRỌNG DÀNH CHO CHỦ XE',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF92400E),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Sau khi bấm "Xác nhận hoàn tất", chuyến thuê sẽ chính thức kết thúc và hệ thống sẽ tiến hành giải phóng số dư thanh toán. Bạn sẽ KHÔNG THỂ khiếu nại hoặc yêu cầu bồi thường đối với các hư hại, thiếu sót phát sinh sau thời điểm xác nhận này.',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF78350F),
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Footer Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Kiểm tra lại',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isAllChecked
                        ? () {
                            Navigator.pop(context, true);
                            widget.onConfirm();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Xác nhận hoàn tất',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _isAllChecked ? Colors.white : Colors.grey.shade500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem({
    required String title,
    required String desc,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: value ? const Color(0xFFF0FDF4) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? Colors.teal.shade300 : const Color(0xFFE2E8F0),
            width: value ? 1.2 : 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  value: value,
                  onChanged: onChanged,
                  activeColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF334155),
                    height: 1.4,
                  ),
                  children: [
                    TextSpan(
                      text: '$title: ',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    TextSpan(text: desc),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
