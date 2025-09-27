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
      // Validate input URL
      if (url.isEmpty) {
        debugPrint('GlbCacheService: Empty URL provided');
        return null;
      }

      final dir = await getApplicationDocumentsDirectory();
      final name = fileName ?? Uri.parse(url).pathSegments.last;
      final file = File('${dir.path}/$name');

      debugPrint('GlbCacheService: Attempting to download $url to ${file.path}');

      // Check if file already exists and is valid
      if (await file.exists()) {
        final fileSize = await file.length();
        debugPrint('GlbCacheService: File already exists (${fileSize} bytes), returning cached path');
        if (fileSize > 0) {
          return file.path;
        } else {
          debugPrint('GlbCacheService: Cached file is empty, re-downloading');
          await file.delete();
        }
      }

      debugPrint('GlbCacheService: Starting download...');
      
      // Configure Dio instance with proper timeouts
      _dio.options.connectTimeout = const Duration(seconds: 30);
      _dio.options.receiveTimeout = const Duration(minutes: 5);
      _dio.options.sendTimeout = const Duration(minutes: 2);
      
      final response = await _dio.get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'User-Agent': 'PersonalizedSofa/1.0',
            'Accept': 'application/octet-stream, */*',
          },
        ),
      );
      
      debugPrint('GlbCacheService: Download response status: ${response.statusCode}');

      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) {
        debugPrint('GlbCacheService: No bytes received from URL');
        return null;
      }
      
      await file.writeAsBytes(bytes, flush: true);
      final savedSize = await file.length();
      debugPrint('GlbCacheService: Successfully downloaded ${bytes.length} bytes, saved ${savedSize} bytes to ${file.path}');
      
      // Verify the file was saved correctly
      if (savedSize != bytes.length) {
        debugPrint('GlbCacheService: File size mismatch, deleting corrupted file');
        await file.delete();
        return null;
      }
      
      return file.path;
    } catch (e) {
      debugPrint('GlbCacheService: download failed: $e');
      // Try to clean up any partial file
      try {
        final dir = await getApplicationDocumentsDirectory();
        final name = fileName ?? Uri.parse(url).pathSegments.last;
        final file = File('${dir.path}/$name');
        if (await file.exists()) {
          await file.delete();
          debugPrint('GlbCacheService: Cleaned up partial download file');
        }
      } catch (cleanupError) {
        debugPrint('GlbCacheService: Failed to cleanup partial file: $cleanupError');
      }
      return null;
    }
  }

  /// Lists all cached GLB files for debugging purposes
  static Future<List<String>> listCachedFiles() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final files = await dir.list().where((entity) => 
        entity is File && entity.path.endsWith('.glb')
      ).cast<File>().toList();
      
      final filePaths = <String>[];
      for (final file in files) {
        final size = await file.length();
        final path = file.path;
        filePaths.add('$path (${size} bytes)');
        debugPrint('GlbCacheService: Cached file: $path (${size} bytes)');
      }
      
      return filePaths;
    } catch (e) {
      debugPrint('GlbCacheService: Failed to list cached files: $e');
      return [];
    }
  }

  /// Clears all cached GLB files
  static Future<bool> clearCache() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final files = await dir.list().where((entity) => 
        entity is File && entity.path.endsWith('.glb')
      ).cast<File>().toList();
      
      for (final file in files) {
        await file.delete();
        debugPrint('GlbCacheService: Deleted cached file: ${file.path}');
      }
      
      debugPrint('GlbCacheService: Cleared ${files.length} cached files');
      return true;
    } catch (e) {
      debugPrint('GlbCacheService: Failed to clear cache: $e');
      return false;
    }
  }
}
