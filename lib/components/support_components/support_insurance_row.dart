import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';

class SupportInsuranceRow extends StatelessWidget {
  final Function(String name, String phone) onCallInsurance;

  const SupportInsuranceRow({
    super.key,
    required this.onCallInsurance,
  });

  Widget _buildInsuranceCard(BuildContext context, String name, String phone) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 12, bottom: 4),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => onCallInsurance(name, phone),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                phone,
                style: TextStyle(
                  fontSize: 11,
                  color: context.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildInsuranceCard(context, 'MIC', '1900 558891'),
          _buildInsuranceCard(context, 'PVI', '1900 545458'),
          _buildInsuranceCard(context, 'DBV', '1900 6484'),
        ],
      ),
    );
  }
}
