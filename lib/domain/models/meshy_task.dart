enum MeshyStatus { pending, inProgress, succeeded, failed, canceled }

class MeshyTask {
  final String id;
  final MeshyStatus status;
  final int progress;
  final String? thumbnailUrl;
  final String? glbUrl;
  final List<Map<String, String>> textureUrls;
  final String? taskErrorMessage;

  MeshyTask({
    required this.id,
    required this.status,
    required this.progress,
    required this.thumbnailUrl,
    required this.glbUrl,
    required this.textureUrls,
    required this.taskErrorMessage,
  });

  factory MeshyTask.fromJson(Map<String, dynamic> j) {
    MeshyStatus parse(String s) {
      switch (s) {
        case 'IN_PROGRESS': return MeshyStatus.inProgress;
        case 'SUCCEEDED':   return MeshyStatus.succeeded;
        case 'FAILED':      return MeshyStatus.failed;
        case 'CANCELED':    return MeshyStatus.canceled;
        default:            return MeshyStatus.pending;
      }
    }

    final modelUrls = (j['model_urls'] ?? {}) as Map<String, dynamic>;
    final textures  = (j['texture_urls'] ?? []) as List<dynamic>;
    String? err;
    if (j['task_error'] is Map && (j['task_error']['message'] ?? '').toString().isNotEmpty) {
      err = j['task_error']['message'];
    }

    return MeshyTask(
      id: j['id'] ?? '',
      status: parse(j['status'] ?? 'PENDING'),
      progress: (j['progress'] ?? 0) as int,
      thumbnailUrl: j['thumbnail_url'] as String?,
      glbUrl: modelUrls['glb'] as String?,
      textureUrls: textures.map((e) => Map<String, String>.from(e as Map)).toList(),
      taskErrorMessage: err,
    );
  }
}
