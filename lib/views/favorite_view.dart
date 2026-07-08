import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../themes/app_colors.dart';
import '../models/car_model.dart';
import '../viewmodels/favorite_viewmodel.dart';

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

  String _formatPrice(num price) {
    final value = price.toInt();
    final formatted = value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
    return '$formattedđ';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.black,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
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
          // phần tìm kiếm xe
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: 'Tìm xe trong danh sách yêu thích...',
                        hintStyle: TextStyle(
                          color: Colors.black38,
                          fontSize: 13,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.black38,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 11),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // danh sách xe yêu thích dạng lưới 2 cột
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

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.58,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: cars.length,
                  itemBuilder: (context, index) {
                    final car = cars[index];
                    return GestureDetector(
                      onTap: () {
                        context.push('/car_detail/${car.id}');
                      },
                      child: _buildCarCard(context, car),
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

  //tạo widget cho dữ liệu xe từ object Car
  Widget _buildCarCard(BuildContext context, Car car) {
    // Lấy ảnh thumbnail hoặc ảnh đầu tiên
    final String image = car.images.isEmpty
        ? 'https://via.placeholder.com/600x300'
        : car.images.firstWhere((img) => img.isThumbnail, orElse: () => car.images.first).imageUrl;

    // Tính phần trăm giảm giá
    String discount = '';
    if (car.unitPrice > 0 && car.discountValue > 0) {
      final pct = ((car.discountValue / car.unitPrice) * 100).round();
      discount = 'GIẢM $pct%';
    }

    final ownerName = car.owner?.name ?? 'Chủ xe';
    final ownerAvatar = car.owner?.avatar ?? 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=500';
    final rating = car.reviewsAvgRating.toStringAsFixed(1);
    final location = car.carLocation?.location ?? car.carLocation?.address ?? 'Chưa xác định';
    final seats = '${car.seatCount} chỗ';
    final transmission = car.transmission.toLowerCase().contains('tự động') ||
            car.transmission.toLowerCase().contains('auto')
        ? 'Tự động'
        : 'Số sàn';
    final fuel = car.fuelType;
    final trips = '${car.tripsCount} chuyến';
    final price = _formatPrice(car.unitPrice - car.discountValue);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ảnh và các thông tin nằm trên ảnh (giảm giá, trái tim, tên chủ xe + avatar)
            Stack(
              children: [
                Image.network(
                  image,
                  height: 105,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 105,
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.directions_car_rounded,
                      color: Colors.grey,
                      size: 36,
                    ),
                  ),
                ),
                if (discount.isNotEmpty)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF4D6D),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.local_offer_outlined,
                            color: Colors.white,
                            size: 10,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            discount,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // trái tim (nhấn vào để bỏ yêu thích)
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      context.read<FavoriteViewModel>().toggleFavorite(carId: car.id, car: car);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Color(0xFFFF4D6D),
                        size: 16,
                      ),
                    ),
                  ),
                ),
                // tên chủ xe + avatar
                Positioned(
                  bottom: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            ownerAvatar,
                            width: 12,
                            height: 12,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => const Icon(
                              Icons.account_circle,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          ownerName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // giao xe tận nơi
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(115, 227, 242, 253),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Giao xe tận nơi',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // tên xe + đánh giá sao
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            car.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 14,
                            ),
                            Text(
                              ' $rating',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),

                    // vị trí xe
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: Colors.black45,
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black45,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // số chỗ, hộp số, nhiên liệu
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSpecItem(
                            Icons.airline_seat_recline_normal_rounded,
                            seats,
                          ),
                          _buildSpecItem(
                            Icons.brightness_auto_rounded,
                            transmission,
                          ),
                          _buildSpecItem(Icons.local_gas_station_rounded, fuel),
                        ],
                      ),
                    ),
                    const Spacer(),

                    // thuê xe theo chuyến + giá tiền
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Đã chạy',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.black45,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              trips,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'GIÁ TỪ',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.black45,
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  price,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const Text(
                                  '/ngày',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.black45,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget hỗ trợ vẽ nhanh Icon thông số kỹ thuật
  Widget _buildSpecItem(IconData icon, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.black45),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 9,
            color: Colors.black45,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
