import 'package:timberr/domain/models/sofa_config.dart';
import 'package:timberr/domain/models/meshy_task.dart';
import 'package:timberr/domain/repositories/meshy_repository.dart';

class GenerateSofaFromPersonalization {
  final MeshyRepository repo;
  GenerateSofaFromPersonalization(this.repo);

  /// Returns the final (refined) task with GLB URL.
  Future<MeshyTask> call(SofaConfig cfg, {void Function(int p1, int p2)? onProgress}) async {
    // 1) Preview (mesh)
    print('Starting preview generation...');
    final previewId = await repo.startPreview(cfg.toPreviewPrompt());
    print('Preview task created: $previewId');
    
    // Poll preview with progress updates
    while (true) {
      try {
        final task = await repo.waitPreviewSingle(previewId);
        onProgress?.call(task.progress, 0);
        
        if (task.status == MeshyStatus.succeeded) {
          break;
        } else if (task.status == MeshyStatus.failed) {
          throw Exception('Preview failed: ${task.taskErrorMessage}');
        }
        
        // Wait before next poll
        await Future.delayed(Duration(seconds: 5));
      } catch (e) {
        print('Error during preview polling: $e');
        rethrow;
      }
    }

    // 2) Refine (texture)
    print('Starting refine generation...');
    final refineId = await repo.startRefine(
      previewTaskId: previewId,
      texturePrompt: cfg.toRefineTexturePrompt(),
      enablePbr: true,
    );
    print('Refine task created: $refineId');
    
    // Poll refine with progress updates
    while (true) {
      try {
        final task = await repo.waitRefineSingle(refineId);
        onProgress?.call(100, task.progress);
        
        if (task.status == MeshyStatus.succeeded) {
          return task;
        } else if (task.status == MeshyStatus.failed) {
          throw Exception('Refine failed: ${task.taskErrorMessage}');
        }
        
        // Wait before next poll
        await Future.delayed(Duration(seconds: 5));
      } catch (e) {
        print('Error during refine polling: $e');
        rethrow;
      }
    }
  }
}
