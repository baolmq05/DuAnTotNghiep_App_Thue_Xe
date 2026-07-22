import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/car_detail_viewmodel.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/favorite_viewmodel.dart';
import 'package:duantotnghiep_app_thue_xe/widgets/app_toast.dart';

// Import các component con đã được tách ra
import 'package:duantotnghiep_app_thue_xe/components/car_detail_components/car_image_carousel.dart';
import 'package:duantotnghiep_app_thue_xe/components/car_detail_components/car_info_header.dart';
import 'package:duantotnghiep_app_thue_xe/components/car_detail_components/car_location_section.dart';
import 'package:duantotnghiep_app_thue_xe/components/car_detail_components/car_spec_section.dart';
import 'package:duantotnghiep_app_thue_xe/components/car_detail_components/car_amenities_section.dart';
import 'package:duantotnghiep_app_thue_xe/components/car_detail_components/car_host_section.dart';
import 'package:duantotnghiep_app_thue_xe/components/car_detail_components/car_description_section.dart';
import 'package:duantotnghiep_app_thue_xe/components/car_detail_components/car_requirements_section.dart';
import 'package:duantotnghiep_app_thue_xe/components/car_detail_components/car_terms_section.dart';
import 'package:duantotnghiep_app_thue_xe/components/car_detail_components/car_bottom_bar.dart';

class CarDetailPage extends StatefulWidget {
  final int carId;
  const CarDetailPage({super.key, required this.carId});

  @override
  State<CarDetailPage> createState() => _CarDetailPageState();
}

class _CarDetailPageState extends State<CarDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<CarDetailViewmodel>().fetchCarDetail(id: widget.carId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoriteViewModel>().fetchFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isFav = context.watch<FavoriteViewModel>().isFavorite(widget.carId);

    return Consumer<CarDetailViewmodel>(
      builder: (context, viewmodel, child) {
        if (viewmodel.isLoading) {
          return Scaffold(
            appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (viewmodel.errorMessage != null) {
          return Scaffold(
            appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    viewmodel.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewmodel.fetchCarDetail(id: widget.carId),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          );
        }

        // 3. Không tìm thấy thông tin xe
        final car = viewmodel.carDetail;
        if (car == null) {
          return Scaffold(
            appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
            body: const Center(child: Text('Không tìm thấy thông tin xe')),
          );
        }

        final imageUrls = car.images.map((img) => img.imageUrl).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Chi tiết xe'),
            backgroundColor: Theme.of(context).colorScheme.onPrimary,
            actions: [
              IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : AppColors.textSecondary,
                  size: 26.0,
                ),
                onPressed: () async {
                  await context.read<FavoriteViewModel>().toggleFavorite(
                        carId: widget.carId,
                      );

                  if (mounted) {
                    if (isFav) {
                      AppToast.show(
                        context,
                        message: "Đã xóa xe khỏi danh sách yêu thích",
                        type: ToastType.info,
                      );
                    } else {
                      AppToast.show(
                        context,
                        message:
                            "Đã thêm xe vào danh sách yêu thích thành công!",
                        type: ToastType.success,
                      );
                    }
                  }
                },
              ),
              const SizedBox(width: 8.0),
            ],
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
          ),
          body: ListView(
            padding: EdgeInsets.zero,
            children: [
              CarImageCarousel(imageUrls: imageUrls),
              const SizedBox(height: 20.0),
              CarInfoHeader(car: car),
              const SizedBox(height: 12.0),
              CarLocationSection(car: car),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(
                  color: Color.fromARGB(92, 158, 158, 158),
                  thickness: 1,
                ),
              ),
              CarSpecSection(car: car),
              const SizedBox(height: 24.0),
              CarAmenitiesSection(car: car),
              const SizedBox(height: 10.0),
              CarHostSection(car: car),
              const SizedBox(height: 24.0),
              CarDescriptionSection(car: car),
              const SizedBox(height: 24.0),
              const CarRequirementsSection(),
              const SizedBox(height: 24.0),
              CarTermsSection(car: car),
              const SizedBox(height: 32.0),
            ],
          ),
          bottomNavigationBar: CarBottomBar(car: car),
          extendBodyBehindAppBar: false,
        );
      },
    );
  }
}
