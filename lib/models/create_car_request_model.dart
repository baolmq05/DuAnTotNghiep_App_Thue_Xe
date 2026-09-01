class CreateCarRequest {
  final int carBrandId;
  final int carTypeId;

  final String licensePlate;
  final String vin;
  final String engineNumber;

  final double fuelConsumption;
  final double unitPrice;
  final double discountValue;

  final String description;
  final String rentalTerms;

  final int seatCount;
  final int manufactureYear;

  final String fuelType;
  final String transmission;

  final String location;
  final String address;

  final bool deliveryEnabled;
  final double deliveryMaxDistance;
  final double deliveryFee;
  final double deliveryFreeDistance;

  final List<int> features;

  final List<String> images;
  final int thumbnailIndex;

  CreateCarRequest({
    required this.carBrandId,
    required this.carTypeId,
    required this.licensePlate,
    required this.vin,
    required this.engineNumber,
    required this.fuelConsumption,
    required this.unitPrice,
    required this.discountValue,
    required this.description,
    required this.rentalTerms,
    required this.seatCount,
    required this.manufactureYear,
    required this.fuelType,
    required this.transmission,
    required this.location,
    required this.address,
    required this.deliveryEnabled,
    required this.deliveryMaxDistance,
    required this.deliveryFee,
    required this.deliveryFreeDistance,
    required this.features,
    required this.images,
    required this.thumbnailIndex,
  });

  Map<String, dynamic> toJson() {
    return {
      'car_brand_id': carBrandId,
      'car_type_id': carTypeId,
      'license_plate': licensePlate,
      'VIN': vin,
      'engine_number': engineNumber,
      'fuel_consumption': fuelConsumption,
      'unit_price': unitPrice.toInt(),
      'discount_value': discountValue.toInt(),
      'description': description,
      'rental_terms': rentalTerms,
      'seat_count': seatCount,
      'manufacture_year': manufactureYear,
      'fuel_type': fuelType,
      'transmission': transmission,
      'location': location,
      'address': address,
      'delivery_enabled': deliveryEnabled ? '1' : '0',
      'delivery_max_distance': deliveryEnabled ? deliveryMaxDistance : 0,
      'delivery_fee': deliveryEnabled ? deliveryFee.toInt() : 0,
      'delivery_free_distance': deliveryEnabled ? deliveryFreeDistance : 0,
      'features': features,
      'images': images,
      'thumbnail_index': thumbnailIndex,
    };
  }
}
