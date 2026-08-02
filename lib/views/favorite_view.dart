import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../themes/app_colors.dart';
import '../viewmodels/favorite_viewmodel.dart';
import '../components/favorite_components/favorite_car_card.dart';

class FavoriteView extends StatefulWidget {
  const FavoriteView({super.key});

  @override
  State<FavoriteView> createState() => _FavoriteViewState();
}

class _FavoriteViewState extends State<FavoriteView> {
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoriteViewModel>().fetchFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          color: context.textPrimary,
        ),
        title: const Text(
          'Yêu thích',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Danh sách yêu thích',
                  style: TextStyle(color: AppColors.primary, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  'Các xe bạn đã đánh dấu yêu thích',
                  style: TextStyle(color: AppColors.primary, fontSize: 14),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: context.cardColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: context.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(width: 12),
                        Icon(
                          Icons.search,
                          color: context.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                searchQuery = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Tìm xe trong danh sách yêu thích...',
                              hintStyle: TextStyle(
                                color: context.textSecondary,
                                fontSize: 13,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                            style: TextStyle(
                              color: context.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<FavoriteViewModel>(
              builder: (context, favoriteVM, child) {
                if (favoriteVM.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (favoriteVM.errorMessage != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            favoriteVM.errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => favoriteVM.fetchFavorites(),
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                var cars = favoriteVM.favoriteCars;
                if (searchQuery.isNotEmpty) {
                  cars = cars
                      .where((car) =>
                          car.name.toLowerCase().contains(searchQuery.toLowerCase()))
                      .toList();
                }

                if (cars.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.favorite_border_rounded,
                          size: 64,
                          color: Colors.black12,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          searchQuery.isNotEmpty
                              ? 'Không tìm thấy xe phù hợp'
                              : 'Danh sách yêu thích trống',
                          style: const TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cars.length,
                  itemBuilder: (context, index) {
                    final car = cars[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FavoriteCarCard(
                        car: car,
                        onTap: () {
                          context.push('/car_detail/${car.id}');
                        },
                        onFavoriteTap: () {
                          favoriteVM.toggleFavorite(carId: car.id, car: car);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
