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
    CarModel? parsedCar;
    if (json['car'] != null && json['car'] is Map<String, dynamic>) {
      parsedCar = CarModel.fromJson(json['car'] as Map<String, dynamic>);
    } else {
      parsedCar = CarModel.fromJson(json);
    }

    if (parsedCar.images.isEmpty || parsedCar.images.every((img) => img.imageUrl.isEmpty)) {
      final topImage = json['car_image']?.toString() ??
          json['car_images']?.toString() ??
          json['image_url']?.toString() ??
          json['image']?.toString() ??
          json['thumbnail']?.toString();
      if (topImage != null && topImage.isNotEmpty) {
        final List<CarImageModel> newImages = [
          CarImageModel(id: 0, isThumbnail: 1, imageUrl: topImage)
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

    return TripModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      cost: double.tryParse(json['cost']?.toString() ?? json['total_cost']?.toString() ?? json['price']?.toString() ?? '0') ?? 0.0,
      discountAmount:
          double.tryParse(json['discount_amount']?.toString() ?? '0') ?? 0.0,
      status: json['status'] is int ? json['status'] as int : int.tryParse(json['status']?.toString() ?? '') ?? 0,
      tripType: json['trip_type'] is int ? json['trip_type'] as int : int.tryParse(json['trip_type']?.toString() ?? '') ?? 0,
      startAt: json['start_at'] != null ? DateTime.tryParse(json['start_at'].toString()) ?? DateTime.now() : DateTime.now(),
      endAt: json['end_at'] != null ? DateTime.tryParse(json['end_at'].toString()) ?? DateTime.now() : DateTime.now(),
      carId: json['car_id'] is int ? json['car_id'] as int : int.tryParse(json['car_id']?.toString() ?? '') ?? 0,
      userId: json['user_id'] is int ? json['user_id'] as int : int.tryParse(json['user_id']?.toString() ?? '') ?? 0,
      deliveryAddress: json['delivery_address']?.toString() ?? json['address']?.toString() ?? json['pickup_address']?.toString(),
      deliveryLocation: json['delivery_location']?.toString() ?? json['location']?.toString() ?? json['pickup_location']?.toString(),
      statusText: json['status_text']?.toString() ?? json['status_name']?.toString(),
      tripTypeText: json['trip_type_text']?.toString(),
      car: parsedCar,
    );
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
    var imagesList = (json['images'] ??
        json['car_images'] ??
        json['car_image'] ??
        json['carImages'] ??
        json['photos']) as List? ?? [];

    List<CarImageModel> parsedImages = imagesList
        .where((i) => i != null)
        .map((i) => CarImageModel.fromJson(i))
        .toList();

    if (parsedImages.isEmpty || parsedImages.every((img) => img.imageUrl.isEmpty)) {
      final directImage = json['image_url']?.toString() ??
          json['image']?.toString() ??
          json['car_image']?.toString() ??
          json['car_image_url']?.toString() ??
          json['thumbnail']?.toString() ??
          json['avatar']?.toString() ??
          json['photo']?.toString();
      if (directImage != null && directImage.isNotEmpty) {
        parsedImages.add(CarImageModel(id: 0, isThumbnail: 1, imageUrl: directImage));
      }
    }

    return CarModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? json['car_name']?.toString() ?? '',
      licensePlate: json['license_plate']?.toString() ?? json['licensePlate']?.toString() ?? '',
      unitPrice: double.tryParse(json['unit_price']?.toString() ?? json['price']?.toString() ?? '0') ?? 0.0,
      discountValue:
          double.tryParse(json['discount_value']?.toString() ?? '0') ?? 0.0,
      description: json['description']?.toString(),
      rentalTerms: json['rental_terms']?.toString(),
      seatCount: int.tryParse(json['seat_count']?.toString() ?? '5') ?? 5,
      fuelType: json['fuel_type']?.toString(),
      transmission: json['transmission']?.toString(),
      userId: json['user_id'] is int ? json['user_id'] as int : int.tryParse(json['user_id']?.toString() ?? '') ?? 0,
      images: parsedImages,
      carLocation: json['car_location'] != null && json['car_location'] is Map<String, dynamic>
          ? CarLocationModel.fromJson(json['car_location'])
          : (json['location'] != null
              ? CarLocationModel.fromJson(json['location'])
              : null),
      owner: json['owner'] != null && json['owner'] is Map<String, dynamic> ? OwnerModel.fromJson(json['owner']) : null,
      deliveryOption: json['delivery_option'] != null && json['delivery_option'] is Map<String, dynamic>
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
        id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0,
        isThumbnail: json['is_thumbnail'] is int ? json['is_thumbnail'] as int : int.tryParse(json['is_thumbnail']?.toString() ?? '') ?? 0,
        imageUrl: json['image_url']?.toString() ?? json['image']?.toString() ?? json['url']?.toString() ?? json['path']?.toString() ?? '',
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
        id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0,
        address: json['address']?.toString() ?? json['full_address']?.toString() ?? json['street']?.toString(),
        city: json['city']?.toString() ?? json['province']?.toString() ?? json['district']?.toString(),
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
