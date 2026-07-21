import 'dart:core';
import 'package:duantotnghiep_app_thue_xe/models/CarDetail/car_image_model.dart';
import 'package:duantotnghiep_app_thue_xe/models/CarDetail/car_feature_model.dart';
import 'package:duantotnghiep_app_thue_xe/models/CarDetail/car_location_model.dart';
import 'package:duantotnghiep_app_thue_xe/models/CarDetail/car_brand_model.dart';
import 'package:duantotnghiep_app_thue_xe/models/CarDetail/car_type_model.dart';
import 'package:duantotnghiep_app_thue_xe/models/CarDetail/delivery_option_model.dart';
import 'package:duantotnghiep_app_thue_xe/models/CarDetail/usage_limit_model.dart';
import 'package:duantotnghiep_app_thue_xe/models/CarDetail/car_owner_model.dart';

class Car_Detail {
  final int id;
  final String name;
  final String licensePlate;
  final String VIN;
  final String engineNumber;
  final int fuelConsumption;
  final String unitPrice;
  final String discountValue;
  final String? description;
  final String rentalTerms;
  final int carLocationId;
  final int carBrandId;
  final int carTypeId;
  final String seatCount;
  final String manufactureYear;
  final String fuelType;
  final String transmission;
  final int userId;
  final int deliveryOptionId;
  final int usageLimitId;
  final int status;
  final String createdAt;
  final String updatedAt;
  final double? reviewsAvgRating;
  final int tripsCount;
  final CarLocation carLocation;
  final CarBrand carBrand;
  final CarType carType;
  final DeliveryOption deliveryOption;
  final UsageLimit usageLimit;
  final CarOwner owner;
  final List<CarImage> images;
  final List<CarFeature> features;

  Car_Detail({
    required this.id,
    required this.name,
    required this.licensePlate,
    required this.VIN,
    required this.engineNumber,
    required this.fuelConsumption,
    required this.unitPrice,
    required this.discountValue,
    this.description,
    required this.rentalTerms,
    required this.carLocationId,
    required this.carBrandId,
    required this.carTypeId,
    required this.seatCount,
    required this.manufactureYear,
    required this.fuelType,
    required this.transmission,
    required this.userId,
    required this.deliveryOptionId,
    required this.usageLimitId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.reviewsAvgRating,
    required this.tripsCount,
    required this.carLocation,
    required this.carBrand,
    required this.carType,
    required this.deliveryOption,
    required this.usageLimit,
    required this.owner,
    required this.images,
    required this.features,
  });

  factory Car_Detail.fromJson(Map<String, dynamic> json) {
    return Car_Detail(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      licensePlate: json['license_plate']?.toString() ?? '',
      VIN: json['vin']?.toString() ?? '',
      engineNumber: json['engine_number']?.toString() ?? '',
      fuelConsumption: json['fuel_consumption'] is int
          ? json['fuel_consumption']
          : int.tryParse(json['fuel_consumption']?.toString() ?? '') ?? 0,
      unitPrice: json['unit_price']?.toString() ?? '0',
      discountValue: json['discount_value']?.toString() ?? '0',
      description: json['description']?.toString(),
      rentalTerms: json['rental_terms']?.toString() ?? '',
      carLocationId: json['car_location_id'] is int
          ? json['car_location_id']
          : int.tryParse(json['car_location_id']?.toString() ?? '') ?? 0,
      carBrandId: json['car_brand_id'] is int
          ? json['car_brand_id']
          : int.tryParse(json['car_brand_id']?.toString() ?? '') ?? 0,
      carTypeId: json['car_type_id'] is int
          ? json['car_type_id']
          : int.tryParse(json['car_type_id']?.toString() ?? '') ?? 0,
      seatCount: json['seat_count']?.toString() ?? '0',
      manufactureYear: json['manufacture_year']?.toString() ?? '',
      fuelType: json['fuel_type']?.toString() ?? '',
      transmission: json['transmission']?.toString() ?? '',
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id']?.toString() ?? '') ?? 0,
      deliveryOptionId: json['delivery_option_id'] is int
          ? json['delivery_option_id']
          : int.tryParse(json['delivery_option_id']?.toString() ?? '') ?? 0,
      usageLimitId: json['usage_limit_id'] is int
          ? json['usage_limit_id']
          : int.tryParse(json['usage_limit_id']?.toString() ?? '') ?? 0,
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? '') ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      reviewsAvgRating: json['reviews_avg_rating'] == null
          ? null
          : double.tryParse(json['reviews_avg_rating'].toString()),
      tripsCount: json['trips_count'] is int
          ? json['trips_count']
          : int.tryParse(json['trips_count']?.toString() ?? '') ?? 0,
      carLocation: CarLocation.fromJson(json['car_location'] ?? {}),
      carBrand: CarBrand.fromJson(json['car_brand'] ?? {}),
      carType: CarType.fromJson(json['car_type'] ?? {}),
      deliveryOption: DeliveryOption.fromJson(json['delivery_option'] ?? {}),
      usageLimit: UsageLimit.fromJson(json['usage_limit'] ?? {}),
      owner: CarOwner.fromJson(json['owner'] ?? {}),
      images: json['images'] != null
          ? (json['images'] as List<dynamic>)
                .map((e) => CarImage.fromJson(e))
                .toList()
          : [],
      features: json['features'] != null
          ? (json['features'] as List<dynamic>)
                .map((e) => CarFeature.fromJson(e))
                .toList()
          : [],
    );
  }
}
