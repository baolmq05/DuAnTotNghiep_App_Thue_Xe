import 'package:flutter/material.dart' hide Notification;
import 'package:intl/intl.dart';
import '../models/notification_model.dart';
import '../themes/app_colors.dart';
import '../viewmodels/notification_viewmodel.dart';
import 'package:provider/provider.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  bool _isAllTab = true;
  bool _isSelectionMode = false;
  final Set<int> _selectedNotificationIds = {};
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationViewModel>().loadNotifications();
    });
  }

  // modal thông báo chi tiết
  void _openNotificationDetail(Notification notification) {
    if (_isSelectionMode) {
      _toggleNotificationSelection(notification.id);
      return;
    }

    // Nếu thông báo chưa đọc, đánh dấu là đã đọc
    final detailNotification = notification.isRead
        ? notification
        : notification.copyWith(isRead: true);

    // Cập nhật trạng thái trong danh sách lập tức trên UI
    if (!notification.isRead) {
      context.read<NotificationViewModel>().markAsRead(notification);
    }

    // định nghĩa lại ngày và tg cho chi tiết thông báo
    final String formattedDate = DateFormat(
      'dd/MM/yyyy - HH:mm',
    ).format(detailNotification.createdAt);

    // Hiển thị modal chi tiết thông báo
    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // tiêu đề
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mail_outline_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Chi tiết thông báo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),

                // tg tb
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: Colors.black45,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black45,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // nội dung thông báo
                Flexible(
                  child: SingleChildScrollView(
                    child: Text(
                      detailNotification.message,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 4. Nút Đóng
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Đóng'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Chuyển đổi trạng thái chế độ chọn
  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedNotificationIds.clear();
    });
  }

  // Chọn hoặc bỏ chọn thông báo
  void _toggleNotificationSelection(int notificationId) {
    setState(() {
      if (_selectedNotificationIds.contains(notificationId)) {
        _selectedNotificationIds.remove(notificationId);
      } else {
        _selectedNotificationIds.add(notificationId);
      }
    });
  }

  // Xóa các thông báo đã chọn
  Future<void> _deleteSelectedNotifications() async {
    if (_selectedNotificationIds.isEmpty) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Xóa thông báo đã chọn'),
          content: Text(
            'Bạn có chắc muốn xóa ${_selectedNotificationIds.length} thông báo đã chọn không?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;
    final viewModel = context.read<NotificationViewModel>();
    final selectedNotifications = viewModel.allNotifications
        .where((item) => _selectedNotificationIds.contains(item.id))
        .toList();

    try {
      await Future.wait(
        selectedNotifications
            .map((notification) => viewModel.deleteNotification(notification))
            .toList(),
      );

      if (!mounted) return;
      setState(() {
        _selectedNotificationIds.clear();
        _isSelectionMode = false;
      });

      // hiển thị xóa thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 10),
              Text(
                'Đã xóa các thông báo đã chọn thành công.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          elevation: 3,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // Hiển thị thông báo lỗi khi xóa không thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Không xóa được thông báo: $e',
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.redAccent.shade400,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // UI
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NotificationViewModel>();
    final displayedNotifications = _isAllTab
        ? viewModel.allNotifications
        : viewModel.allNotifications
              .where((notification) => !notification.isRead)
              .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Thông báo',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_isSelectionMode)
            TextButton(
              onPressed: _toggleSelectionMode,
              child: const Text(
                'Hủy',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.black87),
              onPressed: () {
                if (viewModel.allNotifications.isEmpty) return;
                _toggleSelectionMode();
              },
            ),
          if (_isSelectionMode)
            TextButton(
              onPressed: _selectedNotificationIds.isEmpty
                  ? null
                  : _deleteSelectedNotifications,
              child: Text(
                'Xóa (${_selectedNotificationIds.length})',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabToggle(),
          Expanded(
            child: viewModel.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : displayedNotifications.isEmpty
                ? const Center(
                    child: Text(
                      'Không có thông báo nào.',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: displayedNotifications.length,
                    itemBuilder: (context, index) {
                      final item = displayedNotifications[index];
                      final showHeader =
                          index == 0 ||
                          item.timeAgo !=
                              displayedNotifications[index - 1].timeAgo;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showHeader) _buildSectionHeader(item.timeAgo),
                          _buildNotificationItem(notification: item),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // hàm xây dựng toggle giữa tab "Tất cả" và "Chưa đọc"
  Widget _buildTabToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      height: 46,
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / 2;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                left: _isAllTab ? 0 : tabWidth,
                width: tabWidth,
                top: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() => _isAllTab = true),
                      child: Center(
                        child: Text(
                          'Tất cả',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: _isAllTab
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: _isAllTab
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() => _isAllTab = false),
                      child: Center(
                        child: Text(
                          'Chưa đọc',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: !_isAllTab
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: !_isAllTab
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  // hàm xây dựng header cho từng nhóm thông báo theo ngày
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0, left: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  // hàm xây dựng từng item thông báo
  Widget _buildNotificationItem({required Notification notification}) {
    final String timeString = DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(notification.createdAt);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openNotificationDetail(notification),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isSelectionMode) ...[
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _selectedNotificationIds.contains(notification.id),
                    onChanged: (_) =>
                        _toggleNotificationSelection(notification.id),
                    activeColor: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: notification.isRead
                      ? Colors.grey.withOpacity(0.08)
                      : AppColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  notification.isRead
                      ? Icons.notifications_none_rounded
                      : Icons.notifications_active_rounded,
                  color: notification.isRead
                      ? AppColors.textSecondary
                      : AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: notification.isRead
                            ? FontWeight.w400
                            : FontWeight.w600,
                        color: notification.isRead
                            ? Colors.black54
                            : Colors.black87,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      timeString,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (!notification.isRead)
                Container(
                  alignment: Alignment.center,
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
