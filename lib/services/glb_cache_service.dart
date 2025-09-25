import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

/// Simple GLB download and cache service.
/// Usage: final path = await GlbCacheService.downloadAndCache(url, fileName: 'sofa.glb');
class GlbCacheService {
  static final Dio _dio = Dio();

  /// Downloads a GLB from [url] and stores it under app's cache directory using [fileName].
  /// If the file already exists, returns the existing path.
  /// Returns the absolute file path string on success, or null on failure.
  /// Note: Returns a platform-appropriate path that ModelViewer can load.
  static Future<String?> downloadAndCache(String url, {String? fileName}) async {
    try {
      final dir = await getApplicationDocumentsDirectory(); // Use documents instead of temp
      final name = fileName ?? Uri.parse(url).pathSegments.last;
      final file = File('${dir.path}/$name');

      debugPrint('GlbCacheService: Attempting to download $url to ${file.path}');

      if (await file.exists()) {
        debugPrint('GlbCacheService: File already exists, returning cached path');
        return file.path;
      }

      final response = await _dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      final bytes = response.data;
      if (bytes == null) {
        debugPrint('GlbCacheService: No bytes received from URL');
        return null;
      }
      
      await file.writeAsBytes(bytes, flush: true);
      debugPrint('GlbCacheService: Successfully downloaded ${bytes.length} bytes to ${file.path}');
      return file.path;
    } catch (e) {
      debugPrint('GlbCacheService: download failed: $e');
      return null;
    }
  }
}
