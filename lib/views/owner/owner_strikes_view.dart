import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/owner_order_viewmodel.dart';
import 'package:duantotnghiep_app_thue_xe/components/owner_profile_components/owner_profile_strikes_card.dart';

class OwnerStrikesView extends StatefulWidget {
  const OwnerStrikesView({super.key});

  @override
  State<OwnerStrikesView> createState() => _OwnerStrikesViewState();
}

class _OwnerStrikesViewState extends State<OwnerStrikesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OwnerOrderViewModel>().fetchOwnerReportSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderVM = context.watch<OwnerOrderViewModel>();
    final summary = orderVM.reportSummary;

    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: context.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Tình trạng kỷ luật & Strike',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<OwnerOrderViewModel>().fetchOwnerReportSummary(),
        color: context.primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (orderVM.isLoadingSummary && summary == null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: CircularProgressIndicator(color: context.primaryColor),
                  ),
                )
              else if (summary != null) ...[
                OwnerProfileStrikesCard(summary: summary),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
