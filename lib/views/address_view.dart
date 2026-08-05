import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:duantotnghiep_app_thue_xe/providers/auth_provider.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/address_viewmodel.dart';
import 'package:duantotnghiep_app_thue_xe/models/address_model.dart';

// Components
import 'package:duantotnghiep_app_thue_xe/components/address_components/address_card.dart';
import 'package:duantotnghiep_app_thue_xe/components/address_components/address_empty_state.dart';

class AddressView extends StatefulWidget {
  const AddressView({super.key});

  @override
  State<AddressView> createState() => _AddressViewState();
}

class _AddressViewState extends State<AddressView> {
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (!authProvider.isAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng đăng nhập để truy cập trang địa chỉ.'),
            backgroundColor: AppColors.error,
          ),
        );
        context.go('/login');
      } else {
        context.read<AddressViewModel>().loadAddresses();
      }
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _showAddressDialog({AddressModel? address}) {
    final isEdit = address != null;
    _addressController.text = isEdit ? address.addressName : '';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isEdit ? 'Cập nhật địa chỉ' : 'Thêm địa chỉ mới',
            style: TextStyle(fontWeight: FontWeight.bold, color: context.primaryColor),
          ),
          content: TextField(
            controller: _addressController,
            autofocus: true,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              hintText: 'Nhập địa chỉ của bạn...',
              hintStyle: TextStyle(color: context.textSecondary),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.primaryColor, width: 1.5),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Hủy', style: TextStyle(color: context.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                final addressName = _addressController.text.trim();
                if (addressName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Địa chỉ không được để trống.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext); // Close dialog

                final addressVM = context.read<AddressViewModel>();
                final authProvider = context.read<AuthProvider>();
                final userId = authProvider.user?.id ?? 0;

                bool success;
                if (isEdit) {
                  success = await addressVM.editAddress(address.id, addressName);
                } else {
                  success = await addressVM.addAddress(addressName, userId);
                }

                if (mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isEdit
                            ? 'Cập nhật địa chỉ thành công!'
                            : 'Thêm địa chỉ mới thành công!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(addressVM.errorMessage ?? 'Thao tác thất bại.'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: Text(isEdit ? 'Lưu' : 'Thêm'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(AddressModel address) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Xóa địa chỉ',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.error),
          ),
          content: Text(
            'Bạn có chắc chắn muốn xóa địa chỉ này?\n\n"${address.addressName}"',
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Hủy', style: TextStyle(color: context.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext); // Close dialog

                final addressVM = context.read<AddressViewModel>();
                final success = await addressVM.removeAddress(address.id);

                if (mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Xóa địa chỉ thành công!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(addressVM.errorMessage ?? 'Xóa thất bại.'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(
          'Địa chỉ của tôi',
          style: TextStyle(
            color: context.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.textPrimary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profile');
            }
          },
        ),
        actions: [
          if (user != null)
            IconButton(
              icon: Icon(Icons.add_location_alt_outlined, color: context.primaryColor, size: 26),
              onPressed: () => _showAddressDialog(),
              tooltip: 'Thêm địa chỉ',
            ),
        ],
      ),
      body: Consumer<AddressViewModel>(
        builder: (context, addressVM, child) {
          if (addressVM.isLoading && addressVM.addresses.isEmpty) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(context.primaryColor),
              ),
            );
          }

          if (addressVM.addresses.isEmpty) {
            return AddressEmptyState(
              onAddAddress: () => _showAddressDialog(),
            );
          }

          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: () => addressVM.loadAddresses(),
                color: context.primaryColor,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: addressVM.addresses.length,
                  itemBuilder: (context, index) {
                    final address = addressVM.addresses[index];
                    return AddressCard(
                      address: address,
                      index: index,
                      onEdit: () => _showAddressDialog(address: address),
                      onDelete: () => _confirmDelete(address),
                    );
                  },
                ),
              ),
              if (addressVM.isLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.15),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(context.primaryColor),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<AddressViewModel>(
        builder: (context, addressVM, child) {
          if (addressVM.addresses.isEmpty) return const SizedBox.shrink();
          return FloatingActionButton(
            onPressed: () => _showAddressDialog(),
            backgroundColor: context.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: const Icon(Icons.add_location_rounded, size: 26),
          );
        },
      ),
    );
  }
}
