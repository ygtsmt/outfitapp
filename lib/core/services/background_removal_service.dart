import 'dart:convert';
import 'dart:typed_data';
import 'package:comby/core/utils/api_retry_helper.dart';
import 'package:http/http.dart' as http;

/// Service for removing background from images using fal.ai rembg API
/// This service can be used anywhere in the app where background removal is needed
class BackgroundRemovalService {
  // Fal.ai API Key for background removal
  static const String _falApiKey =
      '9b3bcecc-7c35-46ba-a2a7-95b313c20dea:0c2fcbfa514aeb9c2c6c17e04f8463a6';

  static const String _rembgEndpoint =
      'https://fal.run/fal-ai/imageutils/rembg';

  /// Remove background from an image using fal.ai rembg API
  /// [imageUrl] must be a publicly accessible URL
  /// Returns the URL of the background-removed image from fal.ai
  /// Note: The returned URL is temporary, download and save to your own storage
  Future<String> removeBackground(String imageUrl) async {
    try {
      // Hackathon için retry mekanizması
      final response = await ApiRetryHelper.withRetry(
        () => http.post(
          Uri.parse(_rembgEndpoint),
          headers: {
            'Authorization': 'Key $_falApiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'image_url': imageUrl,
          }),
        ),
        maxRetries: 2,
      );

      if (response.statusCode != 200) {
        throw BackgroundRemovalException(
          'Failed to remove background: ${response.statusCode} - ${response.body}',
        );
      }

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final imageData = jsonResponse['image'] as Map<String, dynamic>;
      final transparentImageUrl = imageData['url'] as String;

      return transparentImageUrl;
    } catch (e) {
      if (e is BackgroundRemovalException) rethrow;
      throw BackgroundRemovalException(
        'Failed to remove background: ${e.toString()}',
      );
    }
  }

  /// Download image bytes from a URL
  /// Useful for downloading the temporary fal.ai image before saving to your storage
  Future<Uint8List> downloadImageBytes(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode != 200) {
        throw BackgroundRemovalException(
          'Failed to download image: ${response.statusCode}',
        );
      }

      return response.bodyBytes;
    } catch (e) {
      if (e is BackgroundRemovalException) rethrow;
      throw BackgroundRemovalException(
        'Failed to download image: ${e.toString()}',
      );
    }
  }

  /// Convenience method: Remove background and return the image bytes directly
  /// This combines removeBackground and downloadImageBytes into one call
  Future<Uint8List> removeBackgroundAndGetBytes(String imageUrl) async {
    final transparentUrl = await removeBackground(imageUrl);
    return downloadImageBytes(transparentUrl);
  }
}

/// Custom exception for background removal errors
class BackgroundRemovalException implements Exception {
  final String message;

  BackgroundRemovalException(this.message);

  @override
  String toString() => message;
}
