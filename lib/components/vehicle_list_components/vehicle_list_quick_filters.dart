import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';

class VehicleListQuickFilters extends StatelessWidget {
  final int activeFiltersCount;
  final String? selectedSeatCount;
  final String? selectedTransmission;
  final String? selectedFuelType;
  final VoidCallback onShowFilterSheet;
  final Function(String? seatCount) onSeatCountSelected;
  final Function(String? transmission) onTransmissionSelected;
  final Function(String? fuelType) onFuelTypeSelected;

  const VehicleListQuickFilters({
    super.key,
    required this.activeFiltersCount,
    required this.selectedSeatCount,
    required this.selectedTransmission,
    required this.selectedFuelType,
    required this.onShowFilterSheet,
    required this.onSeatCountSelected,
    required this.onTransmissionSelected,
    required this.onFuelTypeSelected,
  });

  Widget _buildFilterTriggerChip(BuildContext context) {
    final count = activeFiltersCount;
    final hasFilters = count > 0;
    return InkWell(
      onTap: onShowFilterSheet,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: hasFilters ? AppColors.primary : context.cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasFilters ? AppColors.primary : context.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune_rounded,
              size: 16,
              color: hasFilters ? Colors.white : context.textPrimary,
            ),
            const SizedBox(width: 6),
            Text(
              hasFilters ? 'Bộ lọc ($count)' : 'Bộ lọc',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: hasFilters ? Colors.white : context.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required ValueChanged<bool> onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: isSelected ? Colors.white : context.textPrimary,
      ),
      backgroundColor: context.cardColor,
      side: BorderSide(
        color: isSelected ? AppColors.primary : context.border,
      ),
      showCheckmark: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Row(
        spacing: 8,
        children: [
          _buildFilterTriggerChip(context),
          _buildQuickFilterChip(
            context,
            label: '4 chỗ',
            isSelected: selectedSeatCount == '4',
            onSelected: (selected) {
              onSeatCountSelected(selected ? '4' : null);
            },
          ),
          _buildQuickFilterChip(
            context,
            label: '5 chỗ',
            isSelected: selectedSeatCount == '5',
            onSelected: (selected) {
              onSeatCountSelected(selected ? '5' : null);
            },
          ),
          _buildQuickFilterChip(
            context,
            label: '7 chỗ',
            isSelected: selectedSeatCount == '7',
            onSelected: (selected) {
              onSeatCountSelected(selected ? '7' : null);
            },
          ),
          _buildQuickFilterChip(
            context,
            label: 'Tự động',
            isSelected: selectedTransmission == 'Tự động',
            onSelected: (selected) {
              onTransmissionSelected(selected ? 'Tự động' : null);
            },
          ),
          _buildQuickFilterChip(
            context,
            label: 'Số sàn',
            isSelected: selectedTransmission == 'Số sàn',
            onSelected: (selected) {
              onTransmissionSelected(selected ? 'Số sàn' : null);
            },
          ),
          _buildQuickFilterChip(
            context,
            label: 'Điện',
            isSelected: selectedFuelType == 'Điện',
            onSelected: (selected) {
              onFuelTypeSelected(selected ? 'Điện' : null);
            },
          ),
          _buildQuickFilterChip(
            context,
            label: 'Xăng',
            isSelected: selectedFuelType == 'Xăng',
            onSelected: (selected) {
              onFuelTypeSelected(selected ? 'Xăng' : null);
            },
          ),
          _buildQuickFilterChip(
            context,
            label: 'Dầu',
            isSelected: selectedFuelType == 'Dầu',
            onSelected: (selected) {
              onFuelTypeSelected(selected ? 'Dầu' : null);
            },
          ),
        ],
      ),
    );
  }
}
