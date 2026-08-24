import 'report_model.dart';

class TripReviewModel {
  final int id;
  final int tripId;
  final int reviewerId;
  final int targetId;
  final int? carId;
  final double rating;
  final String? comment;
  final int reviewType; // 0: owner -> renter, 1: renter -> owner
  final DateTime? createdAt;

  TripReviewModel({
    required this.id,
    required this.tripId,
    required this.reviewerId,
    required this.targetId,
    this.carId,
    required this.rating,
    this.comment,
    required this.reviewType,
    this.createdAt,
  });

  factory TripReviewModel.fromJson(Map<String, dynamic> json) {
    return TripReviewModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      tripId: json['trip_id'] is int
          ? json['trip_id'] as int
          : int.tryParse(json['trip_id']?.toString() ?? '') ?? 0,
      reviewerId: json['reviewer_id'] is int
          ? json['reviewer_id'] as int
          : int.tryParse(json['reviewer_id']?.toString() ?? '') ?? 0,
      targetId: json['target_id'] is int
          ? json['target_id'] as int
          : int.tryParse(json['target_id']?.toString() ?? '') ?? 0,
      carId: json['car_id'] is int
          ? json['car_id'] as int
          : int.tryParse(json['car_id']?.toString() ?? ''),
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      comment: json['comment']?.toString(),
      reviewType: json['review_type'] is int
          ? json['review_type'] as int
          : int.tryParse(json['review_type']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}

class TripExtensionModel {
  final int id;
  final int tripId;
  final double extensionAmount;
  final int
  status; // 0: Chưa gia hạn, 1: Chờ duyệt, 2: Chờ thanh toán, 3: Đã gia hạn, 4: Bị từ chối
  final String? startDate;
  final String? endDate;
  final int? extendedDays;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TripExtensionModel({
    required this.id,
    required this.tripId,
    required this.extensionAmount,
    required this.status,
    this.startDate,
    this.endDate,
    this.extendedDays,
    this.createdAt,
    this.updatedAt,
  });

  factory TripExtensionModel.fromJson(Map<String, dynamic> json) {
    return TripExtensionModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      tripId: json['trip_id'] is int
          ? json['trip_id'] as int
          : int.tryParse(json['trip_id']?.toString() ?? '') ?? 0,
      extensionAmount:
          double.tryParse(json['extension_amount']?.toString() ?? '0') ?? 0.0,
      status: json['status'] is int
          ? json['status'] as int
          : int.tryParse(json['status']?.toString() ?? '0') ?? 0,
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      extendedDays: json['extended_days'] is int
          ? json['extended_days'] as int
          : int.tryParse(json['extended_days']?.toString() ?? ''),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  String getStatusText() {
    switch (status) {
      case 0:
        return 'Chưa gia hạn';
      case 1:
        return 'Chờ duyệt';
      case 2:
        return 'Chờ thanh toán';
      case 3:
        return 'Đã gia hạn';
      case 4:
        return 'Bị từ chối';
      default:
        return 'Không xác định';
    }
  }
}

class TripImageModel {
  final int id;
  final int tripId;
  final String imageUrl;
  final int type; // 0: Trước chuyến đi, 1: Sau chuyến đi
  final int isThumbnail;

  TripImageModel({
    required this.id,
    required this.tripId,
    required this.imageUrl,
    required this.type,
    this.isThumbnail = 0,
  });

  factory TripImageModel.fromJson(Map<String, dynamic> json) {
    return TripImageModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      tripId: json['trip_id'] is int
          ? json['trip_id'] as int
          : int.tryParse(json['trip_id']?.toString() ?? '') ?? 0,
      imageUrl: json['image_url']?.toString() ??
          json['url']?.toString() ??
          json['image']?.toString() ??
          '',
      type: json['type'] is int
          ? json['type'] as int
          : int.tryParse(json['type']?.toString() ?? '0') ?? 0,
      isThumbnail: json['is_thumbnail'] is int
          ? json['is_thumbnail'] as int
          : int.tryParse(json['is_thumbnail']?.toString() ?? '0') ?? 0,
    );
  }
}

class TripRenterInfo {
  final int id;
  final String name;
  final String? avatar;
  final String? phone;
  final double rating;
  final int reviewsCount;

  TripRenterInfo({
    required this.id,
    required this.name,
    this.avatar,
    this.phone,
    this.rating = 0.0,
    this.reviewsCount = 0,
  });

  factory TripRenterInfo.fromJson(Map<String, dynamic> json) {
    return TripRenterInfo(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? 'Khách thuê',
      avatar: json['avatar']?.toString(),
      phone: json['phone']?.toString(),
      rating:
          double.tryParse(
            json['rating']?.toString() ??
                json['reviews_avg_rating']?.toString() ??
                json['avg_rating']?.toString() ??
                json['average_rating']?.toString() ??
                '0',
          ) ??
          0.0,
      reviewsCount: json['reviews_count'] is int
          ? json['reviews_count'] as int
          : (json['review_count'] is int
                ? json['review_count'] as int
                : int.tryParse(
                        json['reviews_count']?.toString() ??
                            json['review_count']?.toString() ??
                            json['reviewsCount']?.toString() ??
                            '0',
                      ) ??
                      0),
    );
  }
}

class TripModel {
  final int id;
  final String? tripCode;
  final double cost;
  final double discountAmount;
  final double deliveryFee;
  final double paidAmount;
  int status;
  final int tripType;
  final DateTime startAt;
  final DateTime endAt;
  final DateTime? createdAt;
  final int carId;
  final int userId;
  final TripRenterInfo? renter;
  final String? deliveryAddress;
  final String? deliveryLocation;
  String? statusText;
  final String? tripTypeText;
  final CarModel? car;
  final TripExtensionModel? latestExtension;
  final List<TripReviewModel> reviews;
  final List<TripImageModel> tripImages;
  final List<ReportModel> reports;

  ReportModel? get report => reports.isNotEmpty ? reports.first : null;

  TripModel({
    required this.id,
    this.tripCode,
    required this.cost,
    required this.discountAmount,
    this.deliveryFee = 0.0,
    this.paidAmount = 0.0,
    required this.status,
    required this.tripType,
    required this.startAt,
    required this.endAt,
    this.createdAt,
    required this.carId,
    required this.userId,
    this.renter,
    this.deliveryAddress,
    this.deliveryLocation,
    this.statusText,
    this.tripTypeText,
    this.car,
    this.latestExtension,
    this.reviews = const [],
    this.tripImages = const [],
    List<ReportModel>? reports,
    ReportModel? report,
  }) : reports = reports != null && reports.isNotEmpty
            ? reports
            : (report != null ? [report] : const []);

  /// Mã chuyến đi hiển thị (ưu tiên trip_code từ backend, nếu không có fallback về #RT{id})
  String get displayCode =>
      (tripCode != null && tripCode!.isNotEmpty) ? tripCode! : '#RT$id';

  factory TripModel.fromJson(Map<String, dynamic> json) {
    CarModel? parsedCar;
    if (json['car'] != null && json['car'] is Map<String, dynamic>) {
      parsedCar = CarModel.fromJson(json['car'] as Map<String, dynamic>);
    } else {
      parsedCar = CarModel.fromJson(json);
    }

    if (parsedCar.images.isEmpty ||
        parsedCar.images.every((img) => img.imageUrl.isEmpty)) {
      final topImage =
          json['car_image']?.toString() ??
          json['car_images']?.toString() ??
          json['image_url']?.toString() ??
          json['image']?.toString() ??
          json['thumbnail']?.toString();
      if (topImage != null && topImage.isNotEmpty) {
        final List<CarImageModel> newImages = [
          CarImageModel(id: 0, isThumbnail: 1, imageUrl: topImage),
        ];
        parsedCar = CarModel(
          id: parsedCar.id,
          name: parsedCar.name,
          licensePlate: parsedCar.licensePlate,
          unitPrice: parsedCar.unitPrice,
          discountValue: parsedCar.discountValue,
          description: parsedCar.description,
          rentalTerms: parsedCar.rentalTerms,
          seatCount: parsedCar.seatCount,
          fuelType: parsedCar.fuelType,
          transmission: parsedCar.transmission,
          userId: parsedCar.userId,
          images: newImages,
          carLocation: parsedCar.carLocation,
          owner: parsedCar.owner,
          deliveryOption: parsedCar.deliveryOption,
        );
      }
    }

    // Fallback nếu car.owner chưa có nhưng top-level json có owner
    if (parsedCar.owner == null &&
        (json['owner'] != null || json['car_owner'] != null || json['host'] != null)) {
      final ownerMap = json['owner'] ?? json['car_owner'] ?? json['host'];
      if (ownerMap is Map<String, dynamic>) {
        parsedCar = CarModel(
          id: parsedCar.id,
          name: parsedCar.name,
          licensePlate: parsedCar.licensePlate,
          unitPrice: parsedCar.unitPrice,
          discountValue: parsedCar.discountValue,
          description: parsedCar.description,
          rentalTerms: parsedCar.rentalTerms,
          seatCount: parsedCar.seatCount,
          fuelType: parsedCar.fuelType,
          transmission: parsedCar.transmission,
          userId: parsedCar.userId,
          images: parsedCar.images,
          carLocation: parsedCar.carLocation,
          owner: OwnerModel.fromJson(ownerMap),
          deliveryOption: parsedCar.deliveryOption,
        );
      }
    }

    double parsedPaidAmount = 0.0;
    if (json['transactions'] != null && json['transactions'] is List) {
      for (var txn in json['transactions']) {
        if (txn is Map<String, dynamic>) {
          parsedPaidAmount +=
              double.tryParse(txn['amount']?.toString() ?? '0') ?? 0.0;
        }
      }
    } else if (json['pending_balances'] != null &&
        json['pending_balances'] is List) {
      for (var pb in json['pending_balances']) {
        if (pb is Map<String, dynamic>) {
          parsedPaidAmount +=
              double.tryParse(pb['amount']?.toString() ?? '0') ?? 0.0;
        }
      }
    } else if (json['paid_amount'] != null) {
      parsedPaidAmount = double.tryParse(json['paid_amount'].toString()) ?? 0.0;
    }

    // Parse latest_extension
    TripExtensionModel? parsedExtension;
    if (json['latest_extension'] != null &&
        json['latest_extension'] is Map<String, dynamic>) {
      parsedExtension = TripExtensionModel.fromJson(
        json['latest_extension'] as Map<String, dynamic>,
      );
    }

    // Parse reviews
    List<TripReviewModel> parsedReviews = [];
    if (json['reviews'] != null && json['reviews'] is List) {
      parsedReviews = (json['reviews'] as List)
          .where((r) => r != null && r is Map<String, dynamic>)
          .map((r) => TripReviewModel.fromJson(r as Map<String, dynamic>))
          .toList();
    }

    // Parse trip images (bàn giao trước/sau chuyến)
    List<TripImageModel> parsedTripImages = [];
    if (json['images'] != null && json['images'] is List) {
      parsedTripImages = (json['images'] as List)
          .where((img) => img != null && img is Map<String, dynamic>)
          .map((img) => TripImageModel.fromJson(img as Map<String, dynamic>))
          .toList();
    } else if (json['trip_images'] != null && json['trip_images'] is List) {
      parsedTripImages = (json['trip_images'] as List)
          .where((img) => img != null && img is Map<String, dynamic>)
          .map((img) => TripImageModel.fromJson(img as Map<String, dynamic>))
          .toList();
    }

    // Parse reports from backend show response reports list
    List<ReportModel> parsedReports = [];
    if (json['reports'] != null && json['reports'] is List) {
      final List reportsList = json['reports'] as List;
      for (var r in reportsList) {
        if (r != null && r is Map) {
          parsedReports.add(ReportModel.fromJson(Map<String, dynamic>.from(r)));
        }
      }
    } else if (json['report'] != null && json['report'] is Map) {
      parsedReports.add(ReportModel.fromJson(Map<String, dynamic>.from(json['report'] as Map)));
    }

    final renterJson = json['renter'] is Map<String, dynamic>
        ? json['renter'] as Map<String, dynamic>
        : (json['customer'] is Map<String, dynamic>
              ? json['customer'] as Map<String, dynamic>
              : (json['user'] is Map<String, dynamic>
                    ? json['user'] as Map<String, dynamic>
                    : null));

    return TripModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      tripCode: json['trip_code']?.toString() ??
          json['tripCode']?.toString() ??
          json['code']?.toString(),
      cost:
          double.tryParse(
            json['cost']?.toString() ??
                json['total_cost']?.toString() ??
                json['price']?.toString() ??
                '0',
          ) ??
          0.0,
      discountAmount:
          double.tryParse(json['discount_amount']?.toString() ?? '0') ?? 0.0,
      deliveryFee:
          double.tryParse(json['delivery_fee']?.toString() ?? '0') ?? 0.0,
      paidAmount: parsedPaidAmount,
      status: json['status'] is int
          ? json['status'] as int
          : int.tryParse(json['status']?.toString() ?? '') ?? 0,
      tripType: json['trip_type'] is int
          ? json['trip_type'] as int
          : int.tryParse(json['trip_type']?.toString() ?? '') ?? 0,
      startAt: json['start_at'] != null
          ? DateTime.tryParse(json['start_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      endAt: json['end_at'] != null
          ? DateTime.tryParse(json['end_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      carId: json['car_id'] is int
          ? json['car_id'] as int
          : int.tryParse(json['car_id']?.toString() ?? '') ?? 0,
      userId: json['user_id'] is int
          ? json['user_id'] as int
          : int.tryParse(json['user_id']?.toString() ?? '') ?? 0,
      renter: renterJson != null ? TripRenterInfo.fromJson(renterJson) : null,
      deliveryAddress:
          json['delivery_address']?.toString() ??
          json['address']?.toString() ??
          json['pickup_address']?.toString(),
      deliveryLocation:
          json['delivery_location']?.toString() ??
          json['location']?.toString() ??
          json['pickup_location']?.toString(),
      statusText:
          json['status_text']?.toString() ?? json['status_name']?.toString(),
      tripTypeText: json['trip_type_text']?.toString(),
      car: parsedCar,
      latestExtension: parsedExtension,
      reviews: parsedReviews,
      tripImages: parsedTripImages,
      reports: parsedReports,
    );
  }

  // Danh sách ảnh bàn giao trước chuyến đi (type = 0)
  List<String> get beforeTripImages {
    return tripImages
        .where((img) => img.type == 0 && img.imageUrl.isNotEmpty)
        .map((img) => img.imageUrl)
        .toList();
  }

  // Danh sách ảnh bàn giao sau chuyến đi (type = 1)
  List<String> get afterTripImages {
    return tripImages
        .where((img) => img.type == 1 && img.imageUrl.isNotEmpty)
        .map((img) => img.imageUrl)
        .toList();
  }

  TripReviewModel? get renterReview {
    for (var r in reviews) {
      if (r.reviewType == 1) {
        return r;
      }
    }
    return null;
  }

  // Tiện ích định dạng trạng thái
  String getStatusDisplay() {
    if (statusText != null && statusText!.isNotEmpty) {
      return statusText!;
    }
    switch (status) {
      case 0:
        return 'Chờ duyệt';
      case 1:
        return 'Chờ thanh toán';
      case 2:
        return 'Đã xác nhận';
      case 3:
        return 'Đang di chuyển';
      case 4:
        return 'Hoàn tất';
      case 5:
        return 'Người thuê hủy';
      case 6:
        return 'Chủ xe hủy';
      case 7:
        return 'Chờ gia hạn';
      case 8:
        return 'Chờ trả xe';
      default:
        return 'Không xác định';
    }
  }
}

class CarModel {
  final int id;
  final String name;
  final String licensePlate;
  final double unitPrice;
  final double discountValue;
  final String? description;
  final String? rentalTerms;
  final int seatCount;
  final String? fuelType;
  final String? transmission;
  final int userId;
  final List<CarImageModel> images;
  final CarLocationModel? carLocation;
  final OwnerModel? owner;
  final CarDeliveryOptionModel? deliveryOption;
  CarModel({
    required this.id,
    required this.name,
    required this.licensePlate,
    required this.unitPrice,
    required this.discountValue,
    this.description,
    this.rentalTerms,
    required this.seatCount,
    this.fuelType,
    this.transmission,
    required this.userId,
    required this.images,
    this.carLocation,
    this.owner,
    this.deliveryOption,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    var imagesList =
        (json['images'] ??
                json['car_images'] ??
                json['car_image'] ??
                json['carImages'] ??
                json['photos'])
            as List? ??
        [];

    List<CarImageModel> parsedImages = imagesList
        .where((i) => i != null)
        .map((i) => CarImageModel.fromJson(i))
        .toList();

    if (parsedImages.isEmpty ||
        parsedImages.every((img) => img.imageUrl.isEmpty)) {
      final directImage =
          json['image_url']?.toString() ??
          json['image']?.toString() ??
          json['car_image']?.toString() ??
          json['car_image_url']?.toString() ??
          json['thumbnail']?.toString() ??
          json['avatar']?.toString() ??
          json['photo']?.toString();
      if (directImage != null && directImage.isNotEmpty) {
        parsedImages.add(
          CarImageModel(id: 0, isThumbnail: 1, imageUrl: directImage),
        );
      }
    }

    return CarModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? json['car_name']?.toString() ?? '',
      licensePlate:
          json['license_plate']?.toString() ??
          json['licensePlate']?.toString() ??
          '',
      unitPrice:
          double.tryParse(
            json['unit_price']?.toString() ?? json['price']?.toString() ?? '0',
          ) ??
          0.0,
      discountValue:
          double.tryParse(json['discount_value']?.toString() ?? '0') ?? 0.0,
      description: json['description']?.toString(),
      rentalTerms: json['rental_terms']?.toString(),
      seatCount: int.tryParse(json['seat_count']?.toString() ?? '5') ?? 5,
      fuelType: json['fuel_type']?.toString(),
      transmission: json['transmission']?.toString(),
      userId: json['user_id'] is int
          ? json['user_id'] as int
          : int.tryParse(json['user_id']?.toString() ?? '') ?? 0,
      images: parsedImages,
      carLocation:
          json['car_location'] != null &&
              json['car_location'] is Map<String, dynamic>
          ? CarLocationModel.fromJson(json['car_location'])
          : (json['location'] != null
                ? CarLocationModel.fromJson(json['location'])
                : null),
      owner: json['owner'] != null && json['owner'] is Map<String, dynamic>
          ? OwnerModel.fromJson(json['owner'])
          : null,
      deliveryOption:
          json['delivery_option'] != null &&
              json['delivery_option'] is Map<String, dynamic>
          ? CarDeliveryOptionModel.fromJson(json['delivery_option'])
          : null,
    );
  }

  String getFirstImageUrl() {
    if (images.isNotEmpty) {
      for (final img in images) {
        if (img.imageUrl.isNotEmpty) {
          return img.imageUrl;
        }
      }
    }
    return 'https://picsum.photos/300/200';
  }
}

class CarImageModel {
  final int id;
  final int isThumbnail;
  final String imageUrl;

  CarImageModel({
    required this.id,
    required this.isThumbnail,
    required this.imageUrl,
  });

  factory CarImageModel.fromJson(dynamic json) {
    if (json is String) {
      return CarImageModel(id: 0, isThumbnail: 0, imageUrl: json);
    }
    if (json is Map<String, dynamic>) {
      return CarImageModel(
        id: json['id'] is int
            ? json['id'] as int
            : int.tryParse(json['id']?.toString() ?? '') ?? 0,
        isThumbnail: json['is_thumbnail'] is int
            ? json['is_thumbnail'] as int
            : int.tryParse(json['is_thumbnail']?.toString() ?? '') ?? 0,
        imageUrl:
            json['image_url']?.toString() ??
            json['image']?.toString() ??
            json['url']?.toString() ??
            json['path']?.toString() ??
            '',
      );
    }
    return CarImageModel(id: 0, isThumbnail: 0, imageUrl: '');
  }
}

class CarLocationModel {
  final int id;
  final String? address;
  final String? city;
  final String? location;

  CarLocationModel({required this.id, this.address, this.city, this.location});

  factory CarLocationModel.fromJson(dynamic json) {
    if (json is String) {
      return CarLocationModel(id: 0, address: json);
    }
    if (json is Map<String, dynamic>) {
      return CarLocationModel(
        id: json['id'] is int
            ? json['id'] as int
            : int.tryParse(json['id']?.toString() ?? '') ?? 0,
        address:
            json['address']?.toString() ??
            json['full_address']?.toString() ??
            json['street']?.toString(),
        city:
            json['city']?.toString() ??
            json['province']?.toString() ??
            json['district']?.toString(),
        location: json['location']?.toString() ?? json['name']?.toString(),
      );
    }
    return CarLocationModel(id: 0);
  }
}

class OwnerModel {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? avatar;
  final double rating;
  final int reviewsCount;

  OwnerModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.avatar,
    this.rating = 0.0,
    this.reviewsCount = 0,
  });

  factory OwnerModel.fromJson(Map<String, dynamic> json) {
    return OwnerModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? 'Chủ xe',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      avatar: json['avatar']?.toString(),
      rating: double.tryParse(
            json['rating']?.toString() ??
                json['reviews_avg_rating']?.toString() ??
                json['avg_rating']?.toString() ??
                json['average_rating']?.toString() ??
                '0',
          ) ??
          0.0,
      reviewsCount: json['reviews_count'] is int
          ? json['reviews_count'] as int
          : (json['review_count'] is int
              ? json['review_count'] as int
              : int.tryParse(
                      json['reviews_count']?.toString() ??
                          json['review_count']?.toString() ??
                          json['reviewsCount']?.toString() ??
                          '0',
                    ) ??
                  0),
    );
  }
}

class CarDeliveryOptionModel {
  final int id;
  final double maxDistance; // max_distance
  final double feeDistance; // fee_distance
  final double freeDistance; // free_distance
  final int status;

  CarDeliveryOptionModel({
    required this.id,
    required this.maxDistance,
    required this.feeDistance,
    required this.freeDistance,
    required this.status,
  });

  factory CarDeliveryOptionModel.fromJson(Map<String, dynamic> json) {
    return CarDeliveryOptionModel(
      id: json['id'] ?? 0,
      maxDistance:
          double.tryParse(json['max_distance']?.toString() ?? '0') ?? 0.0,
      feeDistance:
          double.tryParse(json['fee_distance']?.toString() ?? '0') ?? 0.0,
      freeDistance:
          double.tryParse(json['free_distance']?.toString() ?? '0') ?? 0.0,
      status: json['status'] ?? 1,
    );
  }
}
