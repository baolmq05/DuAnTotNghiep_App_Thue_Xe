import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CarDetailPage extends StatefulWidget {
  const CarDetailPage({super.key});
  // Track the favorite state

  @override
  State<CarDetailPage> createState() => _CarDetailPageState();
}

class _CarDetailPageState extends State<CarDetailPage> {
  bool isFavorite = false; // Track the favorite state
  final List<String> imageUrls = [
    'https://res.cloudinary.com/dfmoftnpw/image/upload/v1782701253/723259832561355_vwjsa7.jpg',
    'https://canthoauto.com/wp-content/uploads/2023/05/new-toyota-vios-2023-can-tho-auto-avatar.jpg',
    'https://images.unsplash.com/photo-1522202176988-66273c2fd55f',
  ];
  int currentIndex = 0; // Track the current image index

  final List<Map<String, String>> amenities = [
    {
      'name': 'Bản đồ',
      'image': 'https://res.cloudinary.com/dfmoftnpw/image/upload/v1781073781/gps-v2_cjy1dg.png',
    },
    {
      'name': 'Bluetooth',
      'image': 'https://res.cloudinary.com/dfmoftnpw/image/upload/v1781073780/bluetooth-v2_m9z2wh.png',
    },
    {
      'name': 'Camera lùi',
      'image': 'https://res.cloudinary.com/dfmoftnpw/image/upload/v1781073782/reverse_camera-v2_yanwh4.png',
    },
    {
      'name': 'Cảm biến lốp',
      'image': 'https://res.cloudinary.com/dfmoftnpw/image/upload/v1781073783/tpms-v2_kgsvg4.png',
    },
    {
      'name': 'Ghế trẻ em',
      'image': 'https://res.cloudinary.com/dfmoftnpw/image/upload/v1781073782/sunroof-v2_kyo2mt.png',
    },
    {
      'name': 'USB kết nối',
      'image': 'https://res.cloudinary.com/dfmoftnpw/image/upload/v1781073782/usb-v2_vvx1vt.png',
    },
    {
      'name': 'Định vị GPS',
      'image': 'https://res.cloudinary.com/dfmoftnpw/image/upload/v1781073781/gps-v2_cjy1dg.png',
    },
    {
      'name': 'Điều hòa',
      'image': 'https://res.cloudinary.com/dfmoftnpw/image/upload/v1781073781/head_up-v2_fxa7mn.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: isFavorite
                      ? const Icon(Icons.favorite)
                      : const Icon(Icons.favorite_border),
                  color: isFavorite ? Colors.red : AppColors.primary,
                  onPressed: () {
                    // Handle favorite button press
                    setState(() {
                      isFavorite = !isFavorite; // Toggle the favorite state
                    });
                  },
                  padding: const EdgeInsets.all(10.0),
                  iconSize: 20.0, // Adjust the size as needed
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(
                      color: AppColors.primary,
                      width: 1.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10.0,
                ), // Add some spacing between the buttons
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    // Handle share button press
                  },
                  padding: const EdgeInsets.all(10.0),
                  iconSize: 20.0, // Adjust the size as needed
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(
                      color: AppColors.primary,
                      width: 1.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildImageCarousel(),
          const SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Toyota Vios 2023',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 16.0),
                        child: Icon(Icons.star, color: Colors.amber),
                      ),
                      const SizedBox(width: 4.0),
                      const Text(
                        '4.5 (120 đánh giá)',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '500.000đ',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          const TextSpan(
                            text: ' / ngày',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    const Text(
                      'Đặt cọc: 1.000.000đ',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: Color.fromARGB(92, 158, 158, 158), thickness: 1,),
          ),
          _buildSpecSection(),
          const SizedBox(height: 24.0),
          _buildAmenitiesSection(),
          const SizedBox(height: 24.0),
          _buildHostSection(),
          const SizedBox(height: 24.0),
          _buildDescriptionSection(),
          const SizedBox(height: 24.0),
          _buildRequirementsSection(),
          const SizedBox(height: 24.0),
          _buildTermsSection(),
          const SizedBox(height: 32.0),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tổng cộng (ước tính)',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '500.000đ',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const TextSpan(
                          text: ' / ngày',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  // Handle booking action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'ĐẶT XE NGAY',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
    );
  }

  Widget _buildImageCarousel() {
    return Stack(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 300.0,
            enlargeCenterPage: false,
            padEnds: false,
            aspectRatio: 16 / 9,
            enableInfiniteScroll: true,
            viewportFraction: 1,
            onPageChanged: (index, reason) {
              setState(() {
                currentIndex = index; // Update the current image index
              });
            },
          ),
          items: imageUrls.map((url) {
            return Builder(
              builder: (BuildContext context) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: ClipRRect(
                    child: Image.network(url, fit: BoxFit.cover),
                  ),
                );
              },
            );
          }).toList(),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${currentIndex + 1}/${imageUrls.length}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            crossAxisCount: 2,
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
            children: [
              _buildSpecTile(Icons.airline_seat_recline_normal_rounded, 'Số ghế', '5 chỗ'),
              _buildSpecTile(Icons.settings_suggest_rounded, 'Truyền động', 'Tự động'),
              _buildSpecTile(Icons.local_gas_station_rounded, 'Nhiên liệu', 'Xăng'),
              _buildSpecTile(Icons.speed_rounded, 'Tiêu hao', '6.5L/100km'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecTile(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tiện ích',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: amenities.length,
            itemBuilder: (context, index) {
              final amenity = amenities[index];
              return _buildAmenityImage(amenity['name']!, amenity['image']!);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityImage(String name, String imageUrl) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 50,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(13),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.image_outlined,
                color: AppColors.primary,
                size: 24,
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mô tả',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Toyota Vios 2023 là dòng xe sedan quốc dân được thiết kế hiện đại, nội thất rộng rãi và vận hành êm ái. Xe tiết kiệm nhiên liệu tối ưu, trang bị đầy đủ các tính năng an toàn hiện đại như hệ thống phanh ABS, EBD, túi khí quanh xe và camera lùi sắc nét. Thích hợp cho các chuyến du lịch gia đình, đi công tác hoặc di chuyển trong đô thị đông đúc.',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Giấy tờ thuê xe',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildRequirementCard(
                  Icons.card_membership_outlined,
                  'Bằng lái xe',
                  'Yêu cầu GPLX hạng B1 hoặc B2 trở lên',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRequirementCard(
                  Icons.assignment_ind_outlined,
                  'CCCD gắn chíp',
                  'Hoặc Hộ chiếu bản gốc (đối chiếu khi nhận xe)',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementCard(IconData icon, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(12),
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              desc,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                height: 1.3,
              ),
              overflow: TextOverflow.fade,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chính sách & Điều khoản',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildTermItem(Icons.info_outline, 'Giới hạn quãng đường: Tối đa 250km/ngày, phụ trội 3.000đ/km.'),
          _buildTermItem(Icons.clean_hands_outlined, 'Vệ sinh: Phí vệ sinh 100.000đ - 300.000đ nếu xe bẩn hoặc có mùi thuốc lá.'),
          _buildTermItem(Icons.cancel_presentation_outlined, 'Hủy chuyến: Miễn phí hủy chuyến trước 24 giờ kể từ thời điểm nhận xe.'),
        ],
      ),
    );
  }

  Widget _buildTermItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHostSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(
                    'https://res.cloudinary.com/dfmoftnpw/image/upload/v1775786630/b5b1ad45e85705c2be3030cb2d566925_tplv-tiktokx-cropcenter_1080_1080_lzsdr8.jpg',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Nguyễn Minh Đức',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tham gia từ 06/2022',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text(
                          '4.9 (86)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tỷ lệ phản hồi 98%',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    label: const Text(
                      'Nhắn tin',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Xem trang chủ xe',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
