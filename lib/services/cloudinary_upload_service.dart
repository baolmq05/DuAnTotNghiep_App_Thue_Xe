import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

class CloudinaryUploadService {
  static const String cloudName = 'djbobb5oe';
  static const String uploadPreset = 'Drivio';

  /// Upload XFile image to Cloudinary and return secure_url
  Future<String?> uploadImage(XFile xfile, {String folder = 'cars'}) async {
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', uri);
      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = folder;

      final bytes = await xfile.readAsBytes();
      final filename = xfile.name.isNotEmpty ? xfile.name : 'image.jpg';

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: filename,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['secure_url']?.toString();
      } else {
        debugPrint('Cloudinary upload failed (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      debugPrint('CloudinaryUploadService error: $e');
    }
    return null;
  }
}
