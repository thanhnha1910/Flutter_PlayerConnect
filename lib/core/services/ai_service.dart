import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

class AiService {
  final Dio _dio;

  AiService(this._dio);

  /// Generate AI content from image
  /// Returns a map with 'title' and 'content' keys
  Future<Map<String, String>> generateContent(Uint8List imageBytes) async {
    try {
      // Create FormData with image
      final formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(
          imageBytes,
          filename: 'image.jpg',
          contentType: DioMediaType('image', 'jpeg'),
        ),
      });

      // Call Next.js frontend API instead of backend
      final response = await _dio.post(
        '${ApiConstants.frontendUrl}/api/ai/generate',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return {
          'title': data['title']?.toString() ?? '',
          'content': data['content']?.toString() ?? '',
        };
      } else {
        throw Exception('Failed to generate AI content: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}