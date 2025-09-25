import 'dart:async';
import 'package:dio/dio.dart';
import 'package:timberr/core/env/env.dart';
import 'package:timberr/domain/models/meshy_task.dart';
import 'package:timberr/api/http_manager.dart';

class MeshyApiClient {
  late final HttpManager _http;

  MeshyApiClient() {
    _http = HttpManager(baseUrl: Env.meshyBase);
  }

  Options get _authOptions => Options(headers: {
        'Authorization': 'Bearer ${Env.meshyKey}',
        'Content-Type': 'application/json',
      });

  Future<String> createPreview({
    required String prompt,
    String artStyle = 'realistic',
    bool shouldRemesh = true,
    String topology = 'triangle',
    int targetPolycount = 80000,
    String aiModel = 'meshy-5',
    String symmetryMode = 'auto',
    int? seed,
  }) async {
    final body = {
      'mode': 'preview',
      'prompt': prompt,
      'art_style': artStyle,
      'should_remesh': shouldRemesh,
      'topology': topology,
      'target_polycount': targetPolycount,
      'ai_model': aiModel,
      'symmetry_mode': symmetryMode,
      if (seed != null) 'seed': seed,
    };

    final r = await _http.post<Map<String, dynamic>>(
      '/openapi/v2/text-to-3d',
      data: body,
      options: _authOptions,
    );

    if (r.statusCode != 200) {
      throw Exception('Preview create failed: ${r.statusCode} ${r.data}');
    }

    return (r.data ?? {})['result'] as String;
  }

  Future<String> createRefine({
    required String previewTaskId,
    bool enablePbr = true,
    String? texturePrompt,
    String? textureImageUrl,
    String aiModel = 'meshy-5',
  }) async {
    final body = {
      'mode': 'refine',
      'preview_task_id': previewTaskId,
      'enable_pbr': enablePbr,
      'ai_model': aiModel,
      if (texturePrompt != null && texturePrompt.isNotEmpty) 'texture_prompt': texturePrompt
      else if (textureImageUrl != null && textureImageUrl.isNotEmpty) 'texture_image_url': textureImageUrl,
    };

    final r = await _http.post<Map<String, dynamic>>(
      '/openapi/v2/text-to-3d',
      data: body,
      options: _authOptions,
    );

    if (r.statusCode != 200) {
      throw Exception('Refine create failed: ${r.statusCode} ${r.data}');
    }

    return (r.data ?? {})['result'] as String;
  }

  Future<MeshyTask> getTask(String taskId) async {
    final r = await _http.get<Map<String, dynamic>>(
      '/openapi/v2/text-to-3d/$taskId',
      options: _authOptions,
    );

    if (r.statusCode != 200) {
      throw Exception('Get task failed: ${r.statusCode} ${r.data}');
    }

    return MeshyTask.fromJson(r.data ?? {});
  }

  Future<MeshyTask> waitForTask(
    String taskId, {
    Duration initialDelay = const Duration(seconds: 2),
    Duration maxDelay = const Duration(seconds: 12),
    int maxAttempts = 20,
    void Function(MeshyTask)? onProgress,
  }) async {
    var delay = initialDelay;
    for (int i = 0; i < maxAttempts; i++) {
      final t = await getTask(taskId);
      onProgress?.call(t);
      if (t.status == MeshyStatus.succeeded) return t;
      if (t.status == MeshyStatus.failed || t.status == MeshyStatus.canceled) {
        throw Exception('Task ${t.id} ${t.status.name}: ${t.taskErrorMessage ?? 'Unknown error'}');
      }
      await Future.delayed(delay);
      final nextMs = (delay.inMilliseconds * 1.6).clamp(2000, maxDelay.inMilliseconds);
      delay = Duration(milliseconds: nextMs.toInt());
    }
    throw Exception('Timeout waiting for task $taskId');
  }
}
