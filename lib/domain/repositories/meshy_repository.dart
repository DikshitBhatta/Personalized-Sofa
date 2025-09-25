import 'package:dio/dio.dart';
import 'package:timberr/api/api.dart';
import 'package:timberr/domain/models/meshy_task.dart';

// Uses ApiService (Dio) under the hood

class MeshyRepository {
  final ApiService _api;
  MeshyRepository(this._api);

  Future<String> startPreview(String prompt) async {
    try {
      final body = {
        'mode': 'preview',
        'prompt': prompt,
        'art_style': 'realistic',  // Add required art_style
        'ai_model': 'meshy-4',     // Use stable model version
        'target_polycount': 10000, // Add target polycount
      };
      final r = await _api.createMeshyPreview(body: body);
      // Meshy may return 200 OK or 202 Accepted with a task id in `result`.
      if (r.statusCode != 200 && r.statusCode != 202) {
        final bodyStr = r.data?.toString() ?? 'no-body';
        final errorMsg = (r.data is Map) ? r.data!['message'] ?? 'Unknown error' : 'Unknown error';
        throw Exception('Preview create failed: ${r.statusCode} - $errorMsg. Full response: $bodyStr');
      }
      final result = (r.data ?? {})['result'];
      if (result == null) {
        throw Exception('Preview create returned no result: ${r.data}');
      }
      return result as String;
    } on DioException catch (e) {
      print('Dio error in startPreview: ${e.type} - ${e.message}');
      if (e.response != null) {
        print('Response status: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');
        final errorMsg = (e.response?.data is Map) ? e.response?.data['message'] ?? 'Unknown error' : 'Unknown error';
        throw Exception('Preview API error: ${e.response?.statusCode} - $errorMsg');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<MeshyTask> waitPreviewSingle(String taskId) async {
    final r = await _api.getMeshyTask(taskId: taskId);
    if (r.statusCode != 200 && r.statusCode != 202) {
      throw Exception('Get task failed: ${r.statusCode} ${r.data}');
    }
    final data = r.data ?? {};
    
    // Debug the full response to see GLB URL
    print('MeshyRepository: Full API response for task $taskId:');
    print('  - Status: ${data['status']}');
    print('  - Progress: ${data['progress']}');
    if (data['model_urls'] != null) {
      final modelUrls = data['model_urls'] as Map<String, dynamic>;
      print('  - Full GLB URL: ${modelUrls['glb']}');
      print('  - GLB URL length: ${modelUrls['glb']?.toString().length ?? 0}');
    }
    print('  - Thumbnail URL: ${data['thumbnail_url']}');
    
    return MeshyTask.fromJson(data);
  }

  Future<MeshyTask> waitPreview(String taskId) async {
    // Poll until task is complete
    while (true) {
      try {
        final r = await _api.getMeshyTask(taskId: taskId);
        if (r.statusCode != 200 && r.statusCode != 202) {
          throw Exception('Get task failed: ${r.statusCode} ${r.data}');
        }
        final data = r.data ?? {};
        final task = MeshyTask.fromJson(data);
        
        print('Preview task $taskId status: ${task.status} progress: ${task.progress}%');
        
        if (task.status == MeshyStatus.succeeded) {
          print('Preview completed! Thumbnail: ${task.thumbnailUrl}');
          return task;
        } else if (task.status == MeshyStatus.failed) {
          throw Exception('Preview task failed: ${task.taskErrorMessage ?? "Unknown error"}');
        }
        
        // Still in progress, wait before polling again
        await Future.delayed(Duration(seconds: 5));
      } catch (e) {
        print('Error polling preview task: $e');
        rethrow;
      }
    }
  }

  Future<String> startRefine({
    required String previewTaskId,
    required String texturePrompt,
    bool enablePbr = true,
  }) async {
    try {
      final body = {
        'mode': 'refine',
        'preview_task_id': previewTaskId,
        'enable_pbr': enablePbr,
        'texture_prompt': texturePrompt,
        // Don't include ai_model for refine with meshy-4 preview
      };
      final r = await _api.createMeshyPreview(body: body);
      // accept 200 OK or 202 Accepted
      if (r.statusCode != 200 && r.statusCode != 202) {
        final bodyStr = r.data?.toString() ?? 'no-body';
        final errorMsg = (r.data is Map) ? r.data!['message'] ?? 'Unknown error' : 'Unknown error';
        throw Exception('Refine create failed: ${r.statusCode} - $errorMsg. Full response: $bodyStr');
      }
      final result = (r.data ?? {})['result'];
      if (result == null) throw Exception('Refine create returned no result: ${r.data}');
      return result as String;
    } on DioException catch (e) {
      print('Dio error in startRefine: ${e.type} - ${e.message}');
      if (e.response != null) {
        print('Response status: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');
        final errorMsg = (e.response?.data is Map) ? e.response?.data['message'] ?? 'Unknown error' : 'Unknown error';
        throw Exception('Refine API error: ${e.response?.statusCode} - $errorMsg');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<MeshyTask> waitRefineSingle(String taskId) async {
    final r = await _api.getMeshyTask(taskId: taskId);
    if (r.statusCode != 200 && r.statusCode != 202) {
      throw Exception('Get task failed: ${r.statusCode} ${r.data}');
    }
    final data = r.data ?? {};
    return MeshyTask.fromJson(data);
  }

  Future<MeshyTask> waitRefine(String taskId) async {
    // Poll until task is complete
    while (true) {
      try {
        final r = await _api.getMeshyTask(taskId: taskId);
        if (r.statusCode != 200 && r.statusCode != 202) {
          throw Exception('Get task failed: ${r.statusCode} ${r.data}');
        }
        final data = r.data ?? {};
        final task = MeshyTask.fromJson(data);
        
        print('Refine task $taskId status: ${task.status} progress: ${task.progress}%');
        
        if (task.status == MeshyStatus.succeeded) {
          print('Refine completed! GLB: ${task.glbUrl}');
          return task;
        } else if (task.status == MeshyStatus.failed) {
          throw Exception('Refine task failed: ${task.taskErrorMessage ?? "Unknown error"}');
        }
        
        // Still in progress, wait before polling again
        await Future.delayed(Duration(seconds: 5));
      } catch (e) {
        print('Error polling refine task: $e');
        rethrow;
      }
    }
  }
}
