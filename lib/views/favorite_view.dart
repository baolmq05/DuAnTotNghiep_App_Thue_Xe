import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
// import '../controllers/favorite_controller.dart';

class FavoriteView extends StatelessWidget {
  const FavoriteView({super.key});

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
                  child: ExcludeFocus(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
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
                          contentPadding: EdgeInsets.symmetric(vertical: 13),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // danh sách xe yêu thích dạng lưới 2 cột
          Expanded(
            child: GridView(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.62,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              children: [
                _buildHardcodedCarCard(
                  name: 'Toyota Camry',
                  image:
                      'https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?q=80&w=500',
                  discount: 'GIẢM 10%',
                  ownerName: 'Bình',
                  ownerAvatar:
                      'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=500',
                  rating: '5.0',
                  location: 'Tân Thạnh Đông, Củ...',
                  seats: '5 chỗ',
                  transmission: 'Số tự động',
                  fuel: 'Xăng',
                  trips: '1 chuyến',
                  price: '1.000.000đ',
                  isFavorite: "true",
                  isDelivery: context,
                ),
                _buildHardcodedCarCard(
                  name: 'Honda Civic',
                  image:
                      'https://images.unsplash.com/photo-1606016159991-dfe4f2746ad5?q=80&w=500',
                  discount: 'GIẢM 6%',
                  ownerName: 'Nam',
                  ownerAvatar:
                      'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=500',
                  rating: '4.0',
                  location: 'Lê Duẩn, Hải Châu, ...',
                  seats: '5 chỗ',
                  transmission: 'Số tự sàn',
                  fuel: 'Xăng',
                  trips: '0 chuyến',
                  price: '900.000đ',
                  isFavorite: "true",
                  isDelivery: context,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //tạo widget cho dữ liệu xe
  Widget _buildHardcodedCarCard({
    required String name,
    required String image,
    required String discount,
    required String ownerName,
    required String ownerAvatar,
    required String rating,
    required String location,
    required String seats,
    required String transmission,
    required String fuel,
    required String trips,
    required String price,
    required String isFavorite,
    required BuildContext isDelivery,
  }) {
    return Container(
      //
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
                // trái tim
                Positioned(
                  top: 8,
                  right: 10,
                  child: Icon(
                    Icons.favorite_rounded,
                     color: const Color(0xFFFF4D6D),
                    size: 20,
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
                            name,
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
                      padding: const EdgeInsets.symmetric(vertical: 6),
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
                            transmission
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
                                fontSize: 11,
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
                                    fontSize: 14,
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
