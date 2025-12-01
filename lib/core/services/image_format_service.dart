import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageFormatService {
  /// Desteklenen formatlar
  static const List<String> supportedFormats = [
    'jpg',
    'jpeg',
    'png',
    'webp',
    'bmp',
    'gif'
  ];

  /// HEIF/HEVC formatları
  static const List<String> heifFormats = ['heif', 'heic', 'heifs', 'heics'];

  /// Dosya formatını kontrol et
  static bool isHeifFormat(String filePath) {
    final extension =
        path.extension(filePath).toLowerCase().replaceAll('.', '');
    return heifFormats.contains(extension);
  }

  /// Desteklenen format mı kontrol et
  static bool isSupportedFormat(String filePath) {
    final extension =
        path.extension(filePath).toLowerCase().replaceAll('.', '');
    return supportedFormats.contains(extension);
  }

  /// HEIF/HEVC dosyasını JPEG'e çevir
  static Future<File?> convertHeifToJpeg(File heifFile) async {
    try {
      // HEIF dosyasını decode et
      final bytes = await heifFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        debugPrint('HEIF dosyası decode edilemedi');
        return null;
      }

      // JPEG olarak encode et
      final jpegBytes = img.encodeJpg(image, quality: 90);

      // Geçici dosya oluştur
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(path.join(tempDir.path,
          '${path.basenameWithoutExtension(heifFile.path)}_converted.jpg'));

      // JPEG dosyasını yaz
      await tempFile.writeAsBytes(jpegBytes);

      debugPrint('HEIF dosyası JPEG\'e çevrildi: ${tempFile.path}');
      return tempFile;
    } catch (e) {
      debugPrint('HEIF to JPEG conversion hatası: $e');
      return null;
    }
  }

  /// Herhangi bir dosyayı desteklenen formata çevir
  static Future<File?> convertToSupportedFormat(File imageFile) async {
    try {
      final filePath = imageFile.path;

      // Zaten desteklenen format ise
      if (isSupportedFormat(filePath)) {
        return imageFile;
      }

      // HEIF format ise JPEG'e çevir
      if (isHeifFormat(filePath)) {
        return await convertHeifToJpeg(imageFile);
      }

      // Diğer formatları da dene
      return await _convertOtherFormats(imageFile);
    } catch (e) {
      debugPrint('Format conversion hatası: $e');
      return null;
    }
  }

  /// Diğer formatları desteklenen formata çevir
  static Future<File?> _convertOtherFormats(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        debugPrint('Dosya decode edilemedi');
        return null;
      }

      // JPEG olarak encode et
      final jpegBytes = img.encodeJpg(image, quality: 90);

      // Geçici dosya oluştur
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(path.join(tempDir.path,
          '${path.basenameWithoutExtension(imageFile.path)}_converted.jpg'));

      await tempFile.writeAsBytes(jpegBytes);
      return tempFile;
    } catch (e) {
      debugPrint('Other format conversion hatası: $e');
      return null;
    }
  }

  /// Dosya boyutunu kontrol et (max 10MB)
  static bool isFileSizeValid(File file) {
    const maxSize = 10 * 1024 * 1024; // 10MB
    return file.lengthSync() <= maxSize;
  }

  /// Aspect ratio kontrolü (Pixverse: 1:4 - 4:1)
  static bool isAspectRatioValid(double aspectRatio) {
    return aspectRatio >= 0.25 && aspectRatio <= 4.0;
  }

  /// Pixverse uyumlu format kontrolü
  static bool isPixverseCompatible(String filePath) {
    final extension =
        path.extension(filePath).toLowerCase().replaceAll('.', '');
    const pixverseFormats = ['jpg', 'jpeg', 'png'];
    return pixverseFormats.contains(extension);
  }

  /// Dosya boyutunu formatla
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Dosya bilgilerini getir
  static Future<Map<String, dynamic>> getFileInfo(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      final aspectRatio = image != null ? image.width / image.height : 0.0;

      return {
        'path': file.path,
        'size': file.lengthSync(),
        'sizeFormatted': formatFileSize(file.lengthSync()),
        'extension': path.extension(file.path).toLowerCase(),
        'isHeif': isHeifFormat(file.path),
        'isSupported': isSupportedFormat(file.path),
        'isPixverseCompatible': isPixverseCompatible(file.path),
        'width': image?.width ?? 0,
        'height': image?.height ?? 0,
        'aspectRatio': aspectRatio,
        'isAspectRatioValid': isAspectRatioValid(aspectRatio),
        'sizeValid': isFileSizeValid(file),
      };
    } catch (e) {
      return {
        'path': file.path,
        'size': file.lengthSync(),
        'sizeFormatted': formatFileSize(file.lengthSync()),
        'extension': path.extension(file.path).toLowerCase(),
        'isHeif': isHeifFormat(file.path),
        'isSupported': isSupportedFormat(file.path),
        'error': e.toString(),
      };
    }
  }

  /// Geçici dosyaları temizle
  static Future<void> cleanupTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final tempFiles = tempDir.listSync().whereType<File>();

      for (final file in tempFiles) {
        if (file.path.contains('_converted')) {
          await file.delete();
        }
      }
    } catch (e) {
      debugPrint('Temp file cleanup hatası: $e');
    }
  }

  /// Minimum boyut kontrolü yap ve gerekirse siyah alan ekle
  /// Her iki boyut da minimum 300px olacak şekilde düzenler
  static Future<File?> ensureMinimumSize(
    File imageFile, {
    int minWidth = 300,
    int minHeight = 300,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        debugPrint('Image decode edilemedi');
        return null;
      }

      final currentWidth = image.width;
      final currentHeight = image.height;

      // Eğer her iki boyut da minimum değerin üzerindeyse, orijinal dosyayı döndür
      if (currentWidth >= minWidth && currentHeight >= minHeight) {
        debugPrint('Image boyutu yeterli: ${currentWidth}x$currentHeight');
        return imageFile;
      }

      // Yeni boyutları hesapla
      final targetWidth = currentWidth < minWidth ? minWidth : currentWidth;
      final targetHeight =
          currentHeight < minHeight ? minHeight : currentHeight;

      debugPrint(
          'Image boyutu küçük: ${currentWidth}x$currentHeight. Yeni boyut: ${targetWidth}x$targetHeight');

      // Siyah zemin oluştur
      final paddedImage = img.Image(width: targetWidth, height: targetHeight);

      // Siyah renk ile doldur
      img.fill(paddedImage, color: img.ColorRgb8(0, 0, 0));

      // Orijinal resmi ortaya yerleştir
      final offsetX = ((targetWidth - currentWidth) / 2).round();
      final offsetY = ((targetHeight - currentHeight) / 2).round();

      img.compositeImage(
        paddedImage,
        image,
        dstX: offsetX,
        dstY: offsetY,
      );

      // JPEG olarak encode et
      final jpegBytes = img.encodeJpg(paddedImage, quality: 90);

      // Geçici dosya oluştur
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(path.join(tempDir.path,
          '${path.basenameWithoutExtension(imageFile.path)}_padded.jpg'));

      // Dosyayı yaz
      await tempFile.writeAsBytes(jpegBytes);

      debugPrint('Image minimum boyuta yükseltildi: ${tempFile.path}');
      return tempFile;
    } catch (e) {
      debugPrint('Minimum size padding hatası: $e');
      return null;
    }
  }
}
