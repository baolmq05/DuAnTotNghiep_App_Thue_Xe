class TripModel {
  final int id;
  final double cost;
  final double discountAmount;
  final int status;
  final int tripType;
  final DateTime startAt;
  final DateTime endAt;
  final int carId;
  final int userId;
  final String? deliveryAddress;
  final String? deliveryLocation;
  final String? statusText;
  final String? tripTypeText;
  final CarModel? car;

  TripModel({
    required this.id,
    required this.cost,
    required this.discountAmount,
    required this.status,
    required this.tripType,
    required this.startAt,
    required this.endAt,
    required this.carId,
    required this.userId,
    this.deliveryAddress,
    this.deliveryLocation,
    this.statusText,
    this.tripTypeText,
    this.car,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'],
      cost: double.tryParse(json['cost']?.toString() ?? '0') ?? 0.0,
      discountAmount: double.tryParse(json['discount_amount']?.toString() ?? '0') ?? 0.0,
      status: json['status'],
      tripType: json['trip_type'],
      startAt: DateTime.parse(json['start_at']),
      endAt: DateTime.parse(json['end_at']),
      carId: json['car_id'],
      userId: json['user_id'],
      deliveryAddress: json['delivery_address'],
      deliveryLocation: json['delivery_location'],
      statusText: json['status_text'],
      tripTypeText: json['trip_type_text'],
      car: json['car'] != null ? CarModel.fromJson(json['car']) : null,
    );
  }

  // Tiện ích định dạng trạng thái
  String getStatusDisplay() {
    if (statusText != null && statusText!.isNotEmpty) {
      return statusText!;
    }
    switch (status) {
      case 0: return 'Chờ duyệt';
      case 1: return 'Chờ thanh toán';
      case 2: return 'Đã xác nhận';
      case 3: return 'Đang di chuyển';
      case 4: return 'Hoàn tất';
      case 5: return 'Người thuê hủy';
      case 6: return 'Chủ xe hủy';
      default: return 'Không xác định';
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
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    var imagesList = json['images'] as List? ?? [];
    List<CarImageModel> parsedImages = imagesList.map((i) => CarImageModel.fromJson(i)).toList();

    return CarModel(
      id: json['id'],
      name: json['name'] ?? '',
      licensePlate: json['license_plate'] ?? '',
      unitPrice: double.tryParse(json['unit_price']?.toString() ?? '0') ?? 0.0,
      discountValue: double.tryParse(json['discount_value']?.toString() ?? '0') ?? 0.0,
      description: json['description'],
      rentalTerms: json['rental_terms'],
      seatCount: int.tryParse(json['seat_count']?.toString() ?? '5') ?? 5,
      fuelType: json['fuel_type'],
      transmission: json['transmission'],
      userId: json['user_id'] ?? 0,
      images: parsedImages,
      carLocation: json['car_location'] != null ? CarLocationModel.fromJson(json['car_location']) : null,
      owner: json['owner'] != null ? OwnerModel.fromJson(json['owner']) : null,
    );
  }

  String getFirstImageUrl() {
    if (images.isNotEmpty) {
      return images.first.imageUrl;
    }
    return 'https://picsum.photos/300/200'; // fallback image
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

  factory CarImageModel.fromJson(Map<String, dynamic> json) {
    return CarImageModel(
      id: json['id'],
      isThumbnail: json['is_thumbnail'] ?? 0,
      imageUrl: json['image_url'] ?? '',
    );
  }
}

class CarLocationModel {
  final int id;
  final String? address;
  final String? city;

  CarLocationModel({
    required this.id,
    this.address,
    this.city,
  });

  factory CarLocationModel.fromJson(Map<String, dynamic> json) {
    return CarLocationModel(
      id: json['id'],
      address: json['address'],
      city: json['city'],
    );
  }
}

class OwnerModel {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? avatar;

  OwnerModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.avatar,
  });

  factory OwnerModel.fromJson(Map<String, dynamic> json) {
    return OwnerModel(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'],
      avatar: json['avatar'],
    );
  }
}
