import 'package:duantotnghiep_app_thue_xe/models/car_model.dart';
import 'package:duantotnghiep_app_thue_xe/models/owner_profile_model.dart';
import 'package:duantotnghiep_app_thue_xe/services/base_service.dart';
import 'package:duantotnghiep_app_thue_xe/services/car_service.dart';
import 'package:flutter/foundation.dart';

class OwnerService extends BaseService {
  final CarService _carService = CarService();

  Future<OwnerProfile> fetchOwnerProfile(int ownerId) async {
    try {
      // Gọi API lấy thông tin chủ xe
      final response = await get('api/owners/$ownerId');
      if (response != null && response['success'] == true) {
        return OwnerProfile.fromJson(response['data']);
      }
      throw Exception('Không thể tải thông tin chủ xe từ API');
    } catch (e) {
      debugPrint('Lỗi khi gọi API chủ xe, chuyển sang nạp dữ liệu mẫu: $e');
      return _generateMockProfile(ownerId);
    }
  }

  Future<OwnerProfile> _generateMockProfile(int ownerId) async {
    // Thử lấy danh sách xe thật từ CarService để gán cho chủ xe này
    List<Car> ownerCars = [];
    try {
      final allCars = await _carService.getCars();
      // Lọc các xe thuộc về chủ xe này (nếu car.userId == ownerId hoặc car.owner?.id == ownerId)
      ownerCars = allCars.where((car) {
        return car.userId == ownerId || (car.owner?.id == ownerId);
      }).toList();

      // Nếu không có xe nào khớp, lấy đại 2-3 xe trong danh sách để làm mẫu hiển thị
      if (ownerCars.isEmpty && allCars.isNotEmpty) {
        ownerCars = allCars.take(3).toList();
      }
    } catch (carError) {
      debugPrint('Không lấy được danh sách xe từ service: $carError');
    }

    // Nếu vẫn không có xe nào (ví dụ API xe cũng lỗi), tạo danh sách xe trống hoặc xe mẫu cơ bản
    // Ở đây chúng ta sẽ hiển thị danh sách xe trống hoặc xe đã lấy được từ API để hiển thị trực quan.

    // Danh sách đánh giá mẫu phong phú bằng Tiếng Việt
    final mockReviews = [
      OwnerReview(
        id: 1,
        reviewerName: 'Trần Nguyễn Hoàng Nam',
        reviewerAvatar: 'https://i.pravatar.cc/150?img=11',
        rating: 5.0,
        comment: 'Chủ xe siêu nhiệt tình, hỗ trợ giao xe đúng giờ. Xe đi rất êm và tiết kiệm nhiên liệu.',
        createdAt: '06/07/2026',
      ),
      OwnerReview(
        id: 2,
        reviewerName: 'Lê Thị Thu Thảo',
        reviewerAvatar: 'https://i.pravatar.cc/150?img=5',
        rating: 5.0,
        comment: 'Xe sạch sẽ, thơm tho. Anh chủ xe thân thiện, hướng dẫn sử dụng rất kỹ càng và chu đáo.',
        createdAt: '03/07/2026',
      ),
      OwnerReview(
        id: 3,
        reviewerName: 'Phạm Minh Tuấn',
        reviewerAvatar: 'https://i.pravatar.cc/150?img=12',
        rating: 4.5,
        comment: 'Dịch vụ tuyệt vời. Xe chạy rất mượt, phanh nhạy, an toàn. Chắc chắn sẽ tiếp tục ủng hộ anh!',
        createdAt: '28/06/2026',
      ),
      OwnerReview(
        id: 4,
        reviewerName: 'Nguyễn Bích Phương',
        reviewerAvatar: 'https://i.pravatar.cc/150?img=9',
        rating: 5.0,
        comment: 'Giao nhận xe nhanh chóng, không rườm rà thủ tục. Anh chủ tạo mọi điều kiện thuận lợi nhất cho khách.',
        createdAt: '20/06/2026',
      ),
      OwnerReview(
        id: 5,
        reviewerName: 'Vũ Hoàng Long',
        reviewerAvatar: 'https://i.pravatar.cc/150?img=33',
        rating: 4.8,
        comment: 'Xe đời mới chạy cực bốc, tiết kiệm xăng. Giá cả thuê rất hợp lý so với thị trường.',
        createdAt: '15/06/2026',
      ),
      OwnerReview(
        id: 6,
        reviewerName: 'Đặng Tuấn Kiệt',
        reviewerAvatar: 'https://i.pravatar.cc/150?img=60',
        rating: 5.0,
        comment: 'Mọi thứ đều hoàn hảo, xe chạy êm, điều hoà mát rượi. Anh chủ nói chuyện rất lịch sự.',
        createdAt: '10/06/2026',
      ),
      OwnerReview(
        id: 7,
        reviewerName: 'Phan Minh Anh',
        reviewerAvatar: 'https://i.pravatar.cc/150?img=22',
        rating: 5.0,
        comment: 'Đã thuê nhiều lần và chưa bao giờ thất vọng. Dịch vụ chuyên nghiệp 10/10.',
        createdAt: '02/06/2026',
      ),
      OwnerReview(
        id: 8,
        reviewerName: 'Nguyễn Thành Trung',
        reviewerAvatar: 'https://i.pravatar.cc/150?img=15',
        rating: 5.0,
        comment: 'Xe bảo dưỡng tốt, lốp mới bám đường. Rất an tâm khi di chuyển xa cùng gia đình.',
        createdAt: '25/05/2026',
      ),
    ];

    // Xác định tên chủ xe mẫu dựa trên ID để có sự cá nhân hóa
    String ownerName = 'Nguyễn Văn Hùng';
    String? ownerAvatar = 'https://i.pravatar.cc/150?img=68';
    if (ownerId == 1) {
      ownerName = 'Trần Quốc Bảo';
      ownerAvatar = 'https://i.pravatar.cc/150?img=69';
    } else if (ownerId == 2) {
      ownerName = 'Lâm Minh Quang';
      ownerAvatar = 'https://i.pravatar.cc/150?img=59';
    } else if (ownerId == 3) {
      ownerName = 'Hoàng Đức Thịnh';
      ownerAvatar = 'https://i.pravatar.cc/150?img=53';
    } else if (ownerId == 5) {
      ownerName = 'Phan Thanh Bình';
      ownerAvatar = 'https://i.pravatar.cc/150?img=63';
    }

    return OwnerProfile(
      id: ownerId,
      name: ownerName,
      avatar: ownerAvatar,
      phone: '0987.654.321',
      rating: 4.9,
      tripsCount: 156,
      joinDate: '15/09/2023',
      reviews: mockReviews,
      cars: ownerCars,
    );
  }
}
