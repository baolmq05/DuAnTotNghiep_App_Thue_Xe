import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user_model.dart';
import '../themes/app_colors.dart';
import '../viewmodels/driver_license_viewmodel.dart';
import '../widgets/app_toast.dart';

class DriverLicenseView extends StatefulWidget {
  const DriverLicenseView({super.key});

  @override
  State<DriverLicenseView> createState() => _DriverLicenseViewState();
}

class _DriverLicenseViewState extends State<DriverLicenseView> {
  final DriverLicenseViewModel _viewModel = DriverLicenseViewModel();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  final ImagePicker _picker = ImagePicker(); // khởi tạo ImagePicker để chọn ảnh
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // Dispose các controller khi widget bị hủy
  @override
  void dispose() {
    _numberController.dispose();
    _fullNameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_viewModel.isLoading && _viewModel.user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Giấy phép lái xe",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildNotice(),
              const SizedBox(height: 20),
              _buildUploadBox(),
              const SizedBox(height: 20),
              _buildForm(),
              const SizedBox(height: 30),
              _buildButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        "Hình chụp cần thấy được ảnh chân dung và số GPLX rõ ràng.",
        style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w500),
      ),
    );
  }

  String getStatusText() {
    final status = _viewModel.user?.drivingLicense?.status;
    switch (status) {
      case 1:
        return "Đã duyệt";
      case 2:
        return "Từ chối";
      default:
        return "Chờ duyệt";
    }
  }

  Color getStatusColor() {
    final status = _viewModel.user?.drivingLicense?.status;
    switch (status) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Widget _buildUploadBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Ảnh mặt trước GPLX",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: getStatusColor().withOpacity(.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                getStatusText(),
                style: TextStyle(
                  color: getStatusColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: _buildLicenseImage(),
          ),
        ),
      ],
    );
  }

  Widget _buildLicenseImage() {
    if (_selectedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: kIsWeb
            ? Image.network(_selectedImage!.path, fit: BoxFit.cover)
            : Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
      );
    }

    final imageUrl = _viewModel.user?.drivingLicense?.image;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.network(imageUrl, fit: BoxFit.cover),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.cloud_upload_outlined, size: 60, color: Colors.green),
        const SizedBox(height: 15),
        const Text("Nhấn để chọn hoặc chụp ảnh"),
        const SizedBox(height: 5),
        Text(
          "PNG, JPG tối đa 5MB",
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Số GPLX",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _numberController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: "Nhập số GPLX (9 - 12 chữ số)",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "Vui lòng nhập số GPLX";
            }
            final cleanValue = value.trim();
            if (cleanValue.length < 9 || cleanValue.length > 12) {
              return "Số GPLX phải hợp lệ (từ 9 đến 12 ký tự)";
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        const Text(
          "Họ và tên",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _fullNameController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: "Nhập họ và tên trên GPLX",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "Vui lòng nhập họ và tên";
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        const Text(
          "Ngày sinh",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _dobController,
          readOnly: true,
          decoration: InputDecoration(
            hintText: "Chọn ngày sinh (YYYY-MM-DD)",
            suffixIcon: const Icon(Icons.calendar_month),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "Vui lòng chọn ngày sinh";
            }
            return null;
          },
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime(2000),
              firstDate: DateTime(1950),
              lastDate: DateTime.now(),
            );

            if (picked != null) {
              _dobController.text =
                  "${picked.year.toString().padLeft(4, '0')}-"
                  "${picked.month.toString().padLeft(2, '0')}-"
                  "${picked.day.toString().padLeft(2, '0')}";
            }
          },
        ),
      ],
    );
  }

  Widget _buildButton() {
    final bool isDisabled = _viewModel.isLoading;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isDisabled ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isDisabled
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                "Gửi yêu cầu duyệt",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  // Lấy dữ liệu profile và giấy phép lái xe từ server
  Future<void> _loadProfile() async {
    await _viewModel.fetchProfile();

    final DrivingLicenseModel? license = _viewModel.user?.drivingLicense;

    if (license != null) {
      _numberController.text = license.drivingLicenseNumber;
      _fullNameController.text = license.fullName;
      _dobController.text = license.dob;
    }
     if (mounted) {
      setState(() {});
    }
  }

  // Chọn ảnh từ thư viện hoặc chụp ảnh mới
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) return;

    setState(() {
      _selectedImage = image;
    });
  }

  // Gửi dữ liệu lên server
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final bool hasImage =
        _viewModel.user?.drivingLicense?.image?.isNotEmpty == true;
    if (_selectedImage == null && !hasImage) {
      AppToast.show(
        context,
        message: "Vui lòng chọn hoặc chụp ảnh mặt trước GPLX",
        type: ToastType.warning,
      );
      return;
    }

    final file = kIsWeb
        ? null
        : (_selectedImage != null ? File(_selectedImage!.path) : null);

    await _viewModel.submitDrivingLicense(
      number: _numberController.text.trim(),
      fullName: _fullNameController.text.trim(),
      dob: _dobController.text.trim(),
      image: file,
      xfile: _selectedImage,
    );

    if (!mounted) return;

    if (_viewModel.errorMessage == null) {
      AppToast.show(
        context,
        message: "Gửi yêu cầu xác thực thành công!",
        type: ToastType.success,
      );

      setState(() => _selectedImage = null);
      _loadProfile();
    } else {
      AppToast.show(
        context,
        message: _viewModel.errorMessage!,
        type: ToastType.error,
      );
    }
  }
}
