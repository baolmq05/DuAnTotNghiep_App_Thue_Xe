import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

/// Widget hiển thị slide ảnh (carousel) của xe
/// Dành cho newbie: Sử dụng StatefulWidget vì cần lưu trữ trạng thái index ảnh hiện tại (currentIndex)
class CarImageCarousel extends StatefulWidget {
  final List<String> imageUrls;

  const CarImageCarousel({super.key, required this.imageUrls});

  @override
  State<CarImageCarousel> createState() => _CarImageCarouselState();
}

class _CarImageCarouselState extends State<CarImageCarousel> {
  // Biến lưu trữ vị trí ảnh hiện tại đang xem
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Nếu không có ảnh nào, hiển thị ảnh lỗi/mặc định hình chiếc xe
    if (widget.imageUrls.isEmpty) {
      return Container(
        height: 300,
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.directions_car, size: 64, color: Colors.grey),
        ),
      );
    }

    return Stack(
      children: [
        // Widget chạy slide ảnh tự động hoặc vuốt bằng tay
        CarouselSlider(
          options: CarouselOptions(
            height: 300.0,
            enlargeCenterPage: false,
            padEnds: false,
            aspectRatio: 16 / 9,
            enableInfiniteScroll: widget.imageUrls.length > 1,
            viewportFraction: 1,
            // Lắng nghe sự kiện đổi trang để cập nhật số trang hiển thị
            onPageChanged: (index, reason) {
              setState(() {
                currentIndex = index;
              });
            },
          ),
          items: widget.imageUrls.map((url) {
            return Builder(
              builder: (BuildContext context) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: ClipRRect(
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      // Hiển thị icon broken khi ảnh lỗi hoặc link hỏng
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        // Widget hiển thị số thứ tự trang ảnh ở góc dưới bên phải (ví dụ: 1/5)
        Positioned(
          right: 16,
          bottom: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black54, // Màu nền đen mờ
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${currentIndex + 1}/${widget.imageUrls.length}',
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
}
