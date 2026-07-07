class CarLocation {
  final int id;
  final String location;
  final String address;

  CarLocation({
    required this.id,
    required this.location,
    required this.address,
  });

  factory CarLocation.fromJson(Map<String, dynamic> json) {
    return CarLocation(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      location: json['location'] ?? '',
      address: json['address'] ?? '',
    );
  }
}

class CarImage {
  final int id;
  final int carId;
  final String imageUrl;
  final bool isThumbnail;

  CarImage({
    required this.id,
    required this.carId,
    required this.imageUrl,
    required this.isThumbnail,
  });

  factory CarImage.fromJson(Map<String, dynamic> json) {
    return CarImage(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      carId: int.tryParse(json['car_id']?.toString() ?? '') ?? 0,
      imageUrl: json['image_url'] ?? '',
      isThumbnail: (json['is_thumbnail'] == 1 ||
          json['is_thumbnail'] == true ||
          json['is_thumbnail'] == '1'),
    );
  }
}

class Feature {
  final int id;
  final String featureName;
  final String icon;
  final String description;
  final int status;

  Feature({
    required this.id,
    required this.featureName,
    required this.icon,
    required this.description,
    required this.status,
  });

  factory Feature.fromJson(Map<String, dynamic> json) {
    return Feature(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      featureName: json['feature_name'] ?? '',
      icon: json['icon'] ?? '',
      description: json['description'] ?? '',
      status: int.tryParse(json['status']?.toString() ?? '') ?? 0,
    );
  }
}

class CarOwner {
  final int id;
  final String name;
  final String? avatar;

  CarOwner({
    required this.id,
    required this.name,
    this.avatar,
  });

  factory CarOwner.fromJson(Map<String, dynamic> json) {
    return CarOwner(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name'] ?? '',
      avatar: json['avatar'],
    );
  }
}

class Car {
  final int id;
  final String name;
  final String licensePlate;
  final num fuelConsumption;
  final num unitPrice;
  final num discountValue;
  final String description;
  final String rentalTerms;
  final int seatCount;
  final String manufactureYear;
  final String fuelType;
  final String transmission;
  final int status;
  final int userId;
  final double reviewsAvgRating;
  final int tripsCount;
  final List<CarImage> images;
  final List<Feature> features;
  final CarLocation? carLocation;
  final CarOwner? owner;

  Car({
    required this.id,
    required this.name,
    required this.licensePlate,
    required this.fuelConsumption,
    required this.unitPrice,
    required this.discountValue,
    required this.description,
    required this.rentalTerms,
    required this.seatCount,
    required this.manufactureYear,
    required this.fuelType,
    required this.transmission,
    required this.status,
    required this.userId,
    required this.reviewsAvgRating,
    required this.tripsCount,
    required this.images,
    required this.features,
    this.carLocation,
    this.owner,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    double rating = 0.0;
    if (json['reviews_avg_rating'] != null) {
      rating = double.tryParse(json['reviews_avg_rating'].toString()) ?? 0.0;
    }

    return Car(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name'] ?? '',
      licensePlate: json['license_plate'] ?? '',
      fuelConsumption:
          num.tryParse(json['fuel_consumption']?.toString() ?? '') ?? 0,
      unitPrice: num.tryParse(json['unit_price']?.toString() ?? '') ?? 0,
      discountValue:
          num.tryParse(json['discount_value']?.toString() ?? '') ?? 0,
      description: json['description'] ?? '',
      rentalTerms: json['rental_terms'] ?? '',
      seatCount: int.tryParse(json['seat_count']?.toString() ?? '') ?? 0,
      manufactureYear: json['manufacture_year'] ?? '',
      fuelType: json['fuel_type'] ?? '',
      transmission: json['transmission'] ?? '',
      status: int.tryParse(json['status']?.toString() ?? '') ?? 0,
      userId: int.tryParse(json['user_id']?.toString() ?? '') ?? 0,
      reviewsAvgRating: rating,
      tripsCount: int.tryParse(json['trips_count']?.toString() ?? '') ?? 0,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => CarImage.fromJson(e))
              .toList() ??
          [],
      features: (json['features'] as List<dynamic>?)
              ?.map((e) => Feature.fromJson(e))
              .toList() ??
          [],
      carLocation: json['car_location'] != null
          ? CarLocation.fromJson(json['car_location'])
          : null,
      owner: json['owner'] != null ? CarOwner.fromJson(json['owner']) : null,
    );
  }
}
