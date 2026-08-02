import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:duantotnghiep_app_thue_xe/models/user_model.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:duantotnghiep_app_thue_xe/widgets/app_toast.dart';

class EditProfileAvatar extends StatefulWidget {
  final UserModel? user;
  final XFile? selectedAvatar;
  final Function(XFile) onImagePicked;

  const EditProfileAvatar({
    super.key,
    required this.user,
    required this.selectedAvatar,
    required this.onImagePicked,
  });

  @override
  State<EditProfileAvatar> createState() => _EditProfileAvatarState();
}

class _EditProfileAvatarState extends State<EditProfileAvatar> {
  final ImagePicker _picker = ImagePicker();

  ImageProvider _getAvatarImage(UserModel? user) {
    if (widget.selectedAvatar != null) {
      if (kIsWeb) {
        return NetworkImage(widget.selectedAvatar!.path);
      }
      return FileImage(File(widget.selectedAvatar!.path));
    }
    
    final avatar = user?.avatar;
    if (avatar != null && avatar.trim().isNotEmpty) {
      if (avatar.startsWith('http://') || avatar.startsWith('https://')) {
        return NetworkImage(avatar);
      }
      if (avatar.startsWith('assets/') || avatar.startsWith('lib/assets/')) {
        return AssetImage(avatar);
      }
    }
    return const NetworkImage(
      'https://res.cloudinary.com/dfmoftnpw/image/upload/v1775786630/b5b1ad45e85705c2be3030cb2d566925_tplv-tiktokx-cropcenter_1080_1080_lzsdr8.jpg',
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (image != null) {
        widget.onImagePicked(image);
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(
          context,
          message: 'Không thể mở máy ảnh hoặc thư viện hình ảnh.',
          type: ToastType.error,
        );
      }
    }
  }

  void _showImageSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  'Thay đổi ảnh đại diện',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                  ),
                  title: const Text('Chụp ảnh mới', style: TextStyle(fontWeight: FontWeight.w500)),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
                  ),
                  title: const Text('Chọn từ thư viện', style: TextStyle(fontWeight: FontWeight.w500)),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.white, width: 4),
          ),
          child: CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: _getAvatarImage(widget.user),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 4,
          child: GestureDetector(
            onTap: _showImageSourceBottomSheet,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
