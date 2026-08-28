import 'package:duantotnghiep_app_thue_xe/models/trip_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TripModel parsing', () {
    test('parses renter info and review stats from trip payload', () {
      final trip = TripModel.fromJson({
        'id': 12,
        'status': 2,
        'trip_type': 1,
        'cost': 1200000,
        'discount_amount': 0,
        'start_at': '2026-08-10T10:00:00Z',
        'end_at': '2026-08-11T10:00:00Z',
        'car_id': 9,
        'user_id': 33,
        'user': {
          'id': 33,
          'name': 'Nguyễn Văn A',
          'avatar': 'https://example.com/avatar.jpg',
          'rating': 4.8,
          'reviews_count': 16,
        },
      });

      expect(trip.renter, isNotNull);
      expect(trip.renter!.name, 'Nguyễn Văn A');
      expect(trip.renter!.rating, 4.8);
      expect(trip.renter!.reviewsCount, 16);
      expect(trip.userId, 33);
    });

    test('calculates correct extension days if extended_days is 0 or null', () {
      final trip = TripModel.fromJson({
        'id': 12,
        'status': 2,
        'trip_type': 1,
        'cost': 1200000,
        'discount_amount': 0,
        'start_at': '2026-09-01T09:00:00',
        'end_at': '2026-09-06T09:00:00',
        'car_id': 9,
        'user_id': 33,
        'latest_extension': {
          'id': 1,
          'trip_id': 12,
          'extension_amount': 1300000.0,
          'status': 2,
          'start_date': null,
          'end_date': '2026-09-07T09:00:00',
          'extended_days': 0,
        }
      });

      expect(trip.latestExtension, isNotNull);
      expect(trip.latestExtension!.extendedDays, 1);
    });

    test('calculates correct extension days using extension start_date', () {
      final trip = TripModel.fromJson({
        'id': 12,
        'status': 2,
        'trip_type': 1,
        'cost': 1200000,
        'discount_amount': 0,
        'start_at': '2026-09-01T09:00:00',
        'end_at': '2026-09-06T09:00:00',
        'car_id': 9,
        'user_id': 33,
        'latest_extension': {
          'id': 1,
          'trip_id': 12,
          'extension_amount': 1300000.0,
          'status': 2,
          'start_date': '2026-09-06T09:00:00',
          'end_date': '2026-09-07T09:00:00',
          'extended_days': 0,
        }
      });

      expect(trip.latestExtension, isNotNull);
      expect(trip.latestExtension!.extendedDays, 1);
    });
  });
}
