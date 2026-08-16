import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/notification_viewmodel.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:duantotnghiep_app_thue_xe/providers/auth_provider.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/wallet_viewmodel.dart';

// Components
import 'package:duantotnghiep_app_thue_xe/components/profile_components/profile_card.dart';
import 'package:duantotnghiep_app_thue_xe/components/profile_components/wallet_card.dart';
import 'package:duantotnghiep_app_thue_xe/components/profile_components/services_card.dart';
import 'package:duantotnghiep_app_thue_xe/components/profile_components/other_card.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().fetchProfile();
      context.read<WalletViewModel>().fetchWalletDetails();
    });
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
          'Hồ sơ',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
        ),
        actions: [
          Consumer<NotificationViewModel>(
            builder: (context, notificationVM, child) {
              final unreadCount = notificationVM.unreadCount;
              return Badge(
                isLabelVisible: unreadCount > 0,
                label: Text(
                  unreadCount > 99 ? '99+' : '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: context.error,
                offset: const Offset(-4, 4),
                child: IconButton(
                  icon: const Icon(Icons.notifications_none_rounded),
                  onPressed: () {
                    context.push('/notification');
                  },
                  iconSize: 26,
                  color: context.primaryColor,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              context.push('/setting');
            },
            iconSize: 26,
            color: context.primaryColor,
            padding: const EdgeInsets.only(right: 16.0),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<AuthProvider>().fetchProfile();
          await context.read<WalletViewModel>().fetchWalletDetails();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          children: [
            ProfileCard(user: user),
            const SizedBox(height: 16),
            const WalletCard(),
            const SizedBox(height: 24),
            Text(
              'Dịch vụ của tôi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ServicesCard(user: user),
            const SizedBox(height: 24),
            Text(
              'Khác',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const OtherCard(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
  
}
