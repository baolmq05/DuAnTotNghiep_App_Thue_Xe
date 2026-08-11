import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:duantotnghiep_app_thue_xe/providers/auth_provider.dart';
import 'package:duantotnghiep_app_thue_xe/views/owner/owner_dashboard_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/owner/owner_register_promo_view.dart';

class OwnerTabWrapperView extends StatelessWidget {
  const OwnerTabWrapperView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isOwner = user?.isOwner ?? false;

    if (isOwner) {
      return const OwnerDashboardView();
    }
    return const OwnerRegisterPromoView();
  }
}
