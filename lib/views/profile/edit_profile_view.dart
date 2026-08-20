import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'package:duantotnghiep_app_thue_xe/models/bank_model.dart';
import 'package:duantotnghiep_app_thue_xe/providers/auth_provider.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:duantotnghiep_app_thue_xe/widgets/app_toast.dart';
import 'package:duantotnghiep_app_thue_xe/components/edit_profile_components/edit_profile_avatar.dart';

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
  late TextEditingController _bankNameController;
  late TextEditingController _bankAccountNumberController;

  int? _selectedGender;
  XFile? _selectedAvatar;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;

    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _dobController = TextEditingController(text: user?.dob ?? '');
    _bankNameController = TextEditingController(text: user?.bankName ?? '');
    _bankAccountNumberController =
        TextEditingController(text: user?.bankAccountNumber ?? '');
    _selectedGender = user?.gender;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBanks();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _bankNameController.dispose();
    _bankAccountNumberController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final dob = _dobController.text.trim();
    final bankName = _bankNameController.text.trim();
    final bankAccountNumber = _bankAccountNumberController.text.trim();

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
      bankName: bankName.isNotEmpty ? bankName : null,
      bankAccountNumber: bankAccountNumber.isNotEmpty ? bankAccountNumber : null,
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
          message:
              authProvider.errorMessage ??
              'Cập nhật thất bại. Vui lòng thử lại.',
          type: ToastType.error,
        );
      }
    }
  }

  List<BankModel> _banks = [];
  bool _isLoadingBanks = false;

  void _loadBanks() async {
    if (mounted) {
      setState(() {
        _isLoadingBanks = true;
      });
    }
    try {
      final response = await http.get(Uri.parse('https://vietqr.app/banks.json'));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final list = decoded['data'] as List<dynamic>;
        if (mounted) {
          setState(() {
            _banks = list.map((item) => BankModel.fromJson(item)).toList();
          });
        }
      } else {
        _useFallbackBanks();
      }
    } catch (_) {
      _useFallbackBanks();
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingBanks = false;
        });
      }
    }
  }

  void _useFallbackBanks() {
    final list = [
      {"name": "Ngân hàng TMCP Công thương Việt Nam", "code": "ICB", "bin": "970415", "short_name": "VietinBank", "supported": true},
      {"name": "Ngân hàng TMCP Ngoại Thương Việt Nam", "code": "VCB", "bin": "970436", "short_name": "Vietcombank", "supported": true},
      {"name": "Ngân hàng TMCP Quân đội", "code": "MB", "bin": "970422", "short_name": "MBBank", "supported": true},
      {"name": "Ngân hàng TMCP Á Châu", "code": "ACB", "bin": "970416", "short_name": "ACB", "supported": true},
      {"name": "Ngân hàng TMCP Việt Nam Thịnh Vượng", "code": "VPB", "bin": "970432", "short_name": "VPBank", "supported": true},
      {"name": "Ngân hàng TMCP Tiên Phong", "code": "TPB", "bin": "970423", "short_name": "TPBank", "supported": true},
      {"name": "Ngân hàng TMCP Hàng Hải Việt Nam", "code": "MSB", "bin": "970426", "short_name": "MSB", "supported": true},
      {"name": "Ngân hàng TMCP Đầu tư và Phát triển Việt Nam", "code": "BIDV", "bin": "970418", "short_name": "BIDV", "supported": true},
      {"name": "Ngân hàng TMCP Sài Gòn Thương Tín", "code": "STB", "bin": "970403", "short_name": "Sacombank", "supported": true},
      {"name": "Ngân hàng TMCP Quốc tế Việt Nam", "code": "VIB", "bin": "970441", "short_name": "VIB", "supported": true},
      {"name": "Ngân hàng TMCP Phát triển Thành phố Hồ Chí Minh", "code": "HDB", "bin": "970437", "short_name": "HDBank", "supported": true},
      {"name": "Ngân hàng Nông nghiệp và Phát triển Nông thôn Việt Nam", "code": "VBA", "bin": "970405", "short_name": "Agribank", "supported": true},
      {"name": "Ngân hàng TMCP Kỹ thương Việt Nam", "code": "TCB", "bin": "970407", "short_name": "Techcombank", "supported": true},
      {"name": "Ngân hàng TMCP Đông Á", "code": "DOB", "bin": "970406", "short_name": "DongABank", "supported": true},
      {"name": "Ngân hàng TMCP Sài Gòn Hà Nội", "code": "SHB", "bin": "970443", "short_name": "SHB", "supported": true},
    ];
    if (mounted) {
      setState(() {
        _banks = list.map((item) => BankModel.fromJson(item)).toList();
      });
    }
  }

  void _showBankSelectionBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _BankSelectionSheet(
          banks: _banks,
          isLoading: _isLoadingBanks,
          onSelected: (bank) {
            setState(() {
              _bankNameController.text = bank.shortName;
            });
            Navigator.pop(context);
          },
          onRefresh: _loadBanks,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: context.textPrimary,
            size: 20,
          ),
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
        centerTitle: false,
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
                        style: TextStyle(
                          fontSize: 15,
                          color: context.textPrimary,
                        ),
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
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade600,
                        ),
                        decoration: _buildInputDecoration(
                          hintText: 'Email',
                          prefixIcon: Icons.email_outlined,
                          fillColor: context.inputBackground,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Phone number input
                      _buildLabel('Số điện thoại *'),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(
                          fontSize: 15,
                          color: context.textPrimary,
                        ),
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
                        style: TextStyle(
                          fontSize: 15,
                          color: context.textPrimary,
                        ),
                        decoration: _buildInputDecoration(
                          hintText: 'Chọn ngày sinh (YYYY-MM-DD)',
                          prefixIcon: Icons.calendar_month_outlined,
                        ),
                        onTap: () async {
                          DateTime initial = DateTime(2000);
                          if (_dobController.text.isNotEmpty) {
                            final parsed = DateTime.tryParse(
                              _dobController.text,
                            );
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
                                    primary: context.primaryColor,
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
                      const SizedBox(height: 20),

                      // Bank Name Input
                      _buildLabel('Tên ngân hàng liên kết'),
                      TextFormField(
                        controller: _bankNameController,
                        readOnly: true,
                        style: TextStyle(
                          fontSize: 15,
                          color: context.textPrimary,
                        ),
                        decoration: _buildInputDecoration(
                          hintText: 'Chọn ngân hàng liên kết',
                          prefixIcon: Icons.account_balance_rounded,
                        ),
                        onTap: _showBankSelectionBottomSheet,
                      ),
                      const SizedBox(height: 20),

                      // Bank Account Number Input
                      _buildLabel('Số tài khoản ngân hàng'),
                      TextFormField(
                        controller: _bankAccountNumberController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          fontSize: 15,
                          color: context.textPrimary,
                        ),
                        decoration: _buildInputDecoration(
                          hintText: 'Nhập số tài khoản ngân hàng thụ hưởng',
                          prefixIcon: Icons.credit_card_rounded,
                        ),
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
                color: context.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: context.isDarkMode
                        ? Colors.black.withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.05),
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
                    backgroundColor: context.primaryColor,
                    disabledBackgroundColor: context.primaryColor.withValues(
                      alpha: 0.5,
                    ),
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
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
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
      selectedColor: context.primaryColor,
      backgroundColor: context.cardColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : context.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 14,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? context.primaryColor : context.border,
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
      fillColor: fillColor ?? context.cardColor,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.border, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.error, width: 1.5),
      ),
    );
  }
}

class _BankSelectionSheet extends StatefulWidget {
  final List<BankModel> banks;
  final bool isLoading;
  final ValueChanged<BankModel> onSelected;
  final VoidCallback onRefresh;

  const _BankSelectionSheet({
    required this.banks,
    required this.isLoading,
    required this.onSelected,
    required this.onRefresh,
  });

  @override
  State<_BankSelectionSheet> createState() => _BankSelectionSheetState();
}

class _BankSelectionSheetState extends State<_BankSelectionSheet> {
  final _searchController = TextEditingController();
  List<BankModel> _filteredBanks = [];

  @override
  void initState() {
    super.initState();
    _filteredBanks = widget.banks;
    _searchController.addListener(_filterBanks);
  }

  @override
  void didUpdateWidget(covariant _BankSelectionSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.banks != widget.banks) {
      _filterBanks();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterBanks() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredBanks = widget.banks;
      } else {
        _filteredBanks = widget.banks.where((bank) {
          return bank.name.toLowerCase().contains(query) ||
              bank.shortName.toLowerCase().contains(query) ||
              bank.code.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          // Indicator
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: context.border,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Chọn ngân hàng',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Search Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm ngân hàng...',
                hintStyle: TextStyle(color: context.textSecondary),
                prefixIcon: Icon(Icons.search_rounded, color: context.textSecondary),
                filled: true,
                fillColor: context.cardColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Banks List
          Expanded(
            child: widget.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredBanks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: context.textSecondary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Không tìm thấy ngân hàng nào',
                              style: TextStyle(
                                color: context.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: _filteredBanks.length,
                        separatorBuilder: (context, index) =>
                            Divider(color: context.border, height: 1),
                        itemBuilder: (context, index) {
                          final bank = _filteredBanks[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 4,
                            ),
                            title: Row(
                              children: [
                                Text(
                                  bank.shortName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: context.textPrimary,
                                  ),
                                ),
                                if (bank.code.isNotEmpty &&
                                    bank.code != bank.shortName) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    '(${bank.code})',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            subtitle: Text(
                              bank.name,
                              style: TextStyle(
                                fontSize: 13,
                                color: context.textSecondary,
                              ),
                            ),
                            onTap: () => widget.onSelected(bank),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
