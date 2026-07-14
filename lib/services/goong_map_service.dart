import 'dart:convert';
import 'package:http/http.dart' as http;

class GoongMapService {
  static const String _apiKey = 'xEcFmnV3loWHnfqa9ZsEENH7Wu6lehK4QmabQk7V';

  // Get Suggetions
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
}
