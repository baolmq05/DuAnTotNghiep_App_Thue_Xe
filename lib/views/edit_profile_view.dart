import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../themes/app_colors.dart';
import '../widgets/app_toast.dart';
import '../components/edit_profile_components/edit_profile_avatar.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;

  int? _selectedGender;
  XFile? _selectedAvatar;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _dobController = TextEditingController(text: user?.dob ?? '');
    _selectedGender = user?.gender;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final dob = _dobController.text.trim();

    final authProvider = context.read<AuthProvider>();
    
    final file = kIsWeb
        ? null
        : (_selectedAvatar != null ? File(_selectedAvatar!.path) : null);

    final success = await authProvider.updateProfile(
      name: name,
      phone: phone,
      gender: _selectedGender,
      dob: dob.isNotEmpty ? dob : null,
      avatarFile: file,
      avatarXFile: _selectedAvatar,
    );

    if (mounted) {
      if (success) {
        AppToast.show(
          context,
          message: 'Cập nhật hồ sơ thành công!',
          type: ToastType.success,
        );
        Navigator.pop(context);
      } else {
        AppToast.show(
          context,
          message: authProvider.errorMessage ?? 'Cập nhật thất bại. Vui lòng thử lại.',
          type: ToastType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Chỉnh sửa hồ sơ',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      EditProfileAvatar(
                        user: user,
                        selectedAvatar: _selectedAvatar,
                        onImagePicked: (image) {
                          setState(() {
                            _selectedAvatar = image;
                          });
                        },
                      ),
                      const SizedBox(height: 32),
                      
                      // Full name input
                      _buildLabel('Họ và tên *'),
                      TextFormField(
                        controller: _nameController,
                        style: TextStyle(fontSize: 15, color: context.textPrimary),
                        decoration: _buildInputDecoration(
                          hintText: 'Nhập họ và tên của bạn',
                          prefixIcon: Icons.person_outline_rounded,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập họ và tên';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Email (Readonly)
                      _buildLabel('Địa chỉ Email (Không thể thay đổi)'),
                      TextFormField(
                        initialValue: user?.email ?? '',
                        readOnly: true,
                        style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                        decoration: _buildInputDecoration(
                          hintText: 'Email',
                          prefixIcon: Icons.email_outlined,
                          fillColor: Colors.grey.shade100,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Phone number input
                      _buildLabel('Số điện thoại *'),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(fontSize: 15, color: context.textPrimary),
                        decoration: _buildInputDecoration(
                          hintText: 'Nhập số điện thoại',
                          prefixIcon: Icons.phone_android_rounded,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập số điện thoại';
                          }
                          final phoneRegex = RegExp(r'^(0[35789])[0-9]{8}$');
                          if (!phoneRegex.hasMatch(value.trim())) {
                            return 'Số điện thoại không đúng định dạng Việt Nam (ví dụ: 0912345678)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Gender Selector
                      _buildLabel('Giới tính'),
                      Row(
                        children: [
                          _buildGenderChip('Nam', 1),
                          const SizedBox(width: 12),
                          _buildGenderChip('Nữ', 2),
                          const SizedBox(width: 12),
                          _buildGenderChip('Khác', 0),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // DOB Picker
                      _buildLabel('Ngày sinh'),
                      TextFormField(
                        controller: _dobController,
                        readOnly: true,
                        style: TextStyle(fontSize: 15, color: context.textPrimary),
                        decoration: _buildInputDecoration(
                          hintText: 'Chọn ngày sinh (YYYY-MM-DD)',
                          prefixIcon: Icons.calendar_month_outlined,
                        ),
                        onTap: () async {
                          DateTime initial = DateTime(2000);
                          if (_dobController.text.isNotEmpty) {
                            final parsed = DateTime.tryParse(_dobController.text);
                            if (parsed != null) initial = parsed;
                          }
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: initial,
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: AppColors.primary,
                                    onPrimary: Colors.white,
                                    onSurface: context.textPrimary,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );

                          if (picked != null) {
                            setState(() {
                              _dobController.text =
                                  "${picked.year.toString().padLeft(4, '0')}-"
                                  "${picked.month.toString().padLeft(2, '0')}-"
                                  "${picked.day.toString().padLeft(2, '0')}";
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            
            // Bottom Action Button
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: auth.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Lưu thay đổi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: context.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildGenderChip(String label, int value) {
    final isSelected = _selectedGender == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedGender = selected ? value : null;
        });
      },
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : context.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 14,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: 1,
        ),
      ),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Color? fillColor,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: context.textSecondary, fontSize: 15),
      prefixIcon: Icon(prefixIcon, color: context.textSecondary, size: 22),
      filled: true,
      fillColor: fillColor ?? Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }
}
