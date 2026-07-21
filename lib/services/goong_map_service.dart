import 'dart:convert';
import 'package:http/http.dart' as http;

class GoongMapService {
  static const String _apiKey = 'xEcFmnV3loWHnfqa9ZsEENH7Wu6lehK4QmabQk7V';

  // lấy danh sách gợi ý địa điểm từ Goong API
  Future<List<String>> getSuggestions(String input) async {
    if (input.trim().isEmpty) {
      return [];
    }

    final url = Uri.parse(
      'https://rsapi.goong.io/place/autocomplete'
      '?input=${Uri.encodeComponent(input)}'
      '&limit=5'
      '&api_key=$_apiKey',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> predictions = data['predictions'] ?? [];
        return predictions
            .map((p) => p['description']?.toString() ?? '')
            .where((desc) => desc.isNotEmpty)
            .toList();
      }
    } catch (e) {
      print('GoongMapService Error: $e');
    }
    return [];
  }

  // lấy danh sách gợi ý địa điểm từ Goong API kèm place_id
  Future<List<Map<String, String>>> getSuggestionsWithPlaceId(String input) async {
    if (input.trim().isEmpty) {
      return [];
    }

    final url = Uri.parse(
      'https://rsapi.goong.io/place/autocomplete'
      '?input=${Uri.encodeComponent(input)}'
      '&limit=5'
      '&api_key=$_apiKey',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> predictions = data['predictions'] ?? [];
        return predictions
            .map((p) => {
                  'description': p['description']?.toString() ?? '',
                  'place_id': p['place_id']?.toString() ?? '',
                })
            .where((map) => map['description']!.isNotEmpty)
            .toList();
      }
    } catch (e) {
      print('GoongMapService Error: $e');
    }
    return [];
  }

  // lấy tọa độ (lat, lng) từ place_id
  Future<Map<String, double>?> getPlaceLatLng(String placeId) async {
    final url = Uri.parse(
      'https://rsapi.goong.io/Place/Detail'
      '?place_id=$placeId'
      '&api_key=$_apiKey',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final location = data['result']?['geometry']?['location'];
        if (location != null) {
          return {
            'lat': double.tryParse(location['lat'].toString()) ?? 0.0,
            'lng': double.tryParse(location['lng'].toString()) ?? 0.0,
          };
        }
      }
    } catch (e) {
      print('GoongMapService Error: $e');
    }
    return null;
  }

  // lấy khoảng cách thực tế (đường xe) từ Goong Distance Matrix API
  Future<double?> getDrivingDistance(double originLat, double originLng, double destLat, double destLng) async {
    final url = Uri.parse(
      'https://rsapi.goong.io/DistanceMatrix'
      '?origins=$originLat,$originLng'
      '&destinations=$destLat,$destLng'
      '&vehicle=car'
      '&api_key=$_apiKey',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['rows'] != null && data['rows'].isNotEmpty) {
          final elements = data['rows'][0]['elements'];
          if (elements != null && elements.isNotEmpty && elements[0]['status'] == 'OK') {
            final distanceValue = elements[0]['distance']?['value'];
            if (distanceValue != null) {
              return (distanceValue as num).toDouble() / 1000.0;
            }
          }
        }
      }
    } catch (e) {
      print('GoongMapService getDrivingDistance Error: $e');
    }
    return null;
  }
}
