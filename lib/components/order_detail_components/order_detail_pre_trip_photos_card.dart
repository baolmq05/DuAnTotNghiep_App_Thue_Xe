import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';

class OrderDetailPreTripPhotosCard extends StatelessWidget {
  final List<XFile> localImages;
  final List<String> uploadedPhotos;
  final bool isUploading;
  final bool isReadOnly;
  final String? title;
  final String? subtitle;
  final VoidCallback? onPickFromCamera;
  final VoidCallback? onPickFromGallery;
  final Function(int index)? onRemoveLocalImage;
  final Function(int index)? onRemoveUploadedPhoto;

  const OrderDetailPreTripPhotosCard({
    super.key,
    this.localImages = const [],
    this.uploadedPhotos = const [],
    this.isUploading = false,
    this.isReadOnly = false,
    this.title,
    this.subtitle,
    this.onPickFromCamera,
    this.onPickFromGallery,
    this.onRemoveLocalImage,
    this.onRemoveUploadedPhoto,
  });

  int get totalCount => localImages.length + uploadedPhotos.length;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.primaryColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.photo_camera_rounded,
                  color: context.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title ?? 'Ảnh bàn giao xe (Trước/Sau chuyến đi)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 12,
                          color: isReadOnly ? context.textSecondary : Colors.red.shade600,
                          fontWeight: isReadOnly ? FontWeight.normal : FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (totalCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: context.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$totalCount ảnh',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),

          // Pick/Capture Buttons (Show when not read only)
          if (!isReadOnly) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isUploading ? null : onPickFromCamera,
                    icon: const Icon(Icons.camera_alt_rounded, size: 18),
                    label: const Text('Chụp ảnh'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.primaryColor,
                      side: BorderSide(color: context.primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isUploading ? null : onPickFromGallery,
                    icon: const Icon(Icons.photo_library_rounded, size: 18),
                    label: const Text('Thư viện'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.primaryColor,
                      side: BorderSide(color: context.primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
          ],

          // Loading Progress indicator
          if (isUploading) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.primaryColor.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Đang tải ảnh lên hệ thống...',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: context.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Grid View of photos
          if (totalCount == 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.border,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.no_photography_outlined,
                    size: 40,
                    color: context.textSecondary.withAlpha(150),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isReadOnly
                        ? 'Chưa có ảnh bàn giao nào'
                        : 'Chưa chọn ảnh nào. Vui lòng chụp hoặc chọn ảnh xe.',
                    style: TextStyle(
                      fontSize: 13,
                      color: context.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: totalCount,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.0,
              ),
              itemBuilder: (context, index) {
                final isLocal = index < localImages.length;
                final localIndex = isLocal ? index : -1;
                final uploadedIndex = isLocal ? -1 : index - localImages.length;

                Widget imageWidget;
                if (isLocal) {
                  final xFile = localImages[localIndex];
                  imageWidget = kIsWeb
                      ? Image.network(xFile.path, fit: BoxFit.cover)
                      : Image.file(File(xFile.path), fit: BoxFit.cover);
                } else {
                  final url = uploadedPhotos[uploadedIndex];
                  imageWidget = Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  );
                }

                return GestureDetector(
                  onTap: () {
                    _showFullscreenImage(
                      context,
                      isLocal
                          ? localImages[localIndex].path
                          : uploadedPhotos[uploadedIndex],
                      isLocal: isLocal,
                    );
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: imageWidget,
                        ),
                      ),
                      // Badge for local/pending upload
                      if (isLocal)
                        Positioned(
                          bottom: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(0, 0, 0, 0.6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Mới',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      // Delete button
                      if (!isReadOnly)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              if (isLocal) {
                                onRemoveLocalImage?.call(localIndex);
                              } else {
                                onRemoveUploadedPhoto?.call(uploadedIndex);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void _showFullscreenImage(
    BuildContext context,
    String imagePath, {
    required bool isLocal,
  }) {
    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: isLocal
                  ? (kIsWeb
                        ? Image.network(imagePath, fit: BoxFit.contain)
                        : Image.file(File(imagePath), fit: BoxFit.contain))
                  : Image.network(
                      imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
