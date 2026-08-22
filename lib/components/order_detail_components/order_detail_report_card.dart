import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/models/report_model.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:duantotnghiep_app_thue_xe/services/report_service.dart';
import 'package:duantotnghiep_app_thue_xe/widgets/app_toast.dart';

class OrderDetailReportCard extends StatelessWidget {
  final ReportModel report;
  final bool isOwnerView;
  final VoidCallback? onReportCancelled;

  const OrderDetailReportCard({
    super.key,
    required this.report,
    this.isOwnerView = false,
    this.onReportCancelled,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    Color statusBgColor;
    switch (report.status) {
      case 1:
        statusColor = Colors.green.shade700;
        statusBgColor = Colors.green.shade50;
        break;
      case 2:
        statusColor = Colors.red.shade700;
        statusBgColor = Colors.red.shade50;
        break;
      case 3:
        statusColor = Colors.grey.shade700;
        statusBgColor = Colors.grey.shade200;
        break;
      case 0:
      default:
        statusColor = Colors.orange.shade700;
        statusBgColor = Colors.orange.shade50;
        break;
    }

    final isDark = context.isDarkMode;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: report.status == 0
              ? Colors.orange.shade300
              : context.border,
          width: report.status == 0 ? 1.2 : 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.error.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.report_problem_rounded,
                      color: AppColors.error,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Khiếu nại / Báo cáo sự cố',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? statusColor.withAlpha(40) : statusBgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: isDark ? Border.all(color: statusColor, width: 0.5) : null,
                ),
                child: Text(
                  report.getStatusDisplay(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            report.title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            report.description,
            style: TextStyle(
              fontSize: 13,
              color: context.textSecondary,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (report.images.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  size: 14,
                  color: context.primaryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '${report.images.length} ảnh bằng chứng đính kèm',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text(
                    'Xem chi tiết khiếu nại',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  onPressed: () => _showReportDetailBottomSheet(context, report),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.primaryColor,
                    side: BorderSide(color: context.primaryColor.withAlpha(150)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              if (!isOwnerView && report.status == 0) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _confirmAndCancelReport(context, report.id),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      'Thu hồi khiếu nại',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showReportDetailBottomSheet(BuildContext context, ReportModel report) {
    Color statusColor;
    Color statusBgColor;
    switch (report.status) {
      case 1:
        statusColor = Colors.green.shade700;
        statusBgColor = Colors.green.shade50;
        break;
      case 2:
        statusColor = Colors.red.shade700;
        statusBgColor = Colors.red.shade50;
        break;
      case 3:
        statusColor = Colors.grey.shade700;
        statusBgColor = Colors.grey.shade200;
        break;
      case 0:
      default:
        statusColor = Colors.orange.shade700;
        statusBgColor = Colors.orange.shade50;
        break;
    }

    final isDark = context.isDarkMode;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(sheetCtx).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(sheetCtx).padding.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chi tiết báo cáo sự cố',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(sheetCtx),
                  ),
                ],
              ),
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Trạng thái:',
                    style: TextStyle(color: context.textSecondary, fontSize: 13),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? statusColor.withAlpha(40) : statusBgColor,
                      borderRadius: BorderRadius.circular(20),
                      border: isDark ? Border.all(color: statusColor, width: 0.5) : null,
                    ),
                    child: Text(
                      report.getStatusDisplay(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              if (report.createdAt != null) ...[
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Thời gian gửi:',
                      style: TextStyle(color: context.textSecondary, fontSize: 13),
                    ),
                    Text(
                      '${report.createdAt!.day.toString().padLeft(2, '0')}/${report.createdAt!.month.toString().padLeft(2, '0')}/${report.createdAt!.year} ${report.createdAt!.hour.toString().padLeft(2, '0')}:${report.createdAt!.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: context.textPrimary,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
              if (report.resolvedAt != null) ...[
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Thời gian xử lý:',
                      style: TextStyle(color: context.textSecondary, fontSize: 13),
                    ),
                    Text(
                      '${report.resolvedAt!.day.toString().padLeft(2, '0')}/${report.resolvedAt!.month.toString().padLeft(2, '0')}/${report.resolvedAt!.year} ${report.resolvedAt!.hour.toString().padLeft(2, '0')}:${report.resolvedAt!.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: context.textPrimary,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
              const Divider(height: 24),
              Text(
                'Tiêu đề báo cáo:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: context.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                report.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Nội dung chi tiết:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: context.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: context.border, width: 0.5),
                ),
                child: Text(
                  report.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
              if (report.images.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Hình ảnh bằng chứng (${report.images.length}):',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 90,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: report.images.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final imgUrl = report.images[index];
                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => Dialog(
                              backgroundColor: Colors.transparent,
                              insetPadding: const EdgeInsets.all(16),
                              child: Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  InteractiveViewer(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        imgUrl,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: Colors.black54,
                                          padding: const EdgeInsets.all(20),
                                          child: const Icon(
                                            Icons.broken_image_rounded,
                                            color: Colors.white,
                                            size: 40,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imgUrl,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 90,
                              height: 90,
                              color: Colors.grey.shade300,
                              child: const Icon(
                                Icons.broken_image_rounded,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              if (!isOwnerView && report.status == 0) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(sheetCtx);
                      _confirmAndCancelReport(context, report.id);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Thu hồi khiếu nại',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _confirmAndCancelReport(BuildContext context, int reportId) {
    bool isRevoking = false;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.error),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Xác nhận thu hồi',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Text(
            'Bạn có chắc chắn muốn thu hồi khiếu nại này không? Quyết định này không thể hoàn tác.',
            style: TextStyle(fontSize: 13, color: context.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: isRevoking ? null : () => Navigator.pop(dialogCtx),
              child: Text(
                'Quay lại',
                style: TextStyle(color: context.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: isRevoking
                  ? null
                  : () async {
                      setDialogState(() => isRevoking = true);
                      
                      final result = await ReportService().cancelReport(reportId);
                      
                      if (!dialogCtx.mounted) return;
                      Navigator.pop(dialogCtx);

                      if (context.mounted) {
                        if (result['success'] == true) {
                          AppToast.show(
                            context,
                            message: result['message'] ?? 'Đã thu hồi khiếu nại thành công!',
                            type: ToastType.success,
                          );
                          onReportCancelled?.call();
                        } else {
                          AppToast.show(
                            context,
                            message: result['message'] ?? 'Thu hồi khiếu nại thất bại.',
                            type: ToastType.error,
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isRevoking
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Thu hồi',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
