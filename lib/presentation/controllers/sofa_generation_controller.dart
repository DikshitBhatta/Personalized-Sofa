import 'package:get/get.dart';
import 'package:timberr/api/api.dart';
import 'package:timberr/api/http_manager.dart';
import 'package:timberr/core/env/env.dart';
import 'package:timberr/domain/repositories/meshy_repository.dart';
import 'package:timberr/domain/models/sofa_config.dart';
import 'package:timberr/domain/models/meshy_task.dart';
import 'package:timberr/application/generate_sofa_from_personalization.dart';
import 'package:timberr/models/generated_sofa_model.dart';
import 'package:timberr/models/personalization_data.dart';
import 'package:timberr/models/preview_model.dart';
import 'package:timberr/services/saved_models_service.dart';
import 'package:timberr/services/glb_cache_service.dart';

class SofaGenerationController extends GetxController {
  final _http = HttpManager(baseUrl: Env.meshyBase);
  late final ApiService _apiService;
  late final MeshyRepository _repo;
  late final GenerateSofaFromPersonalization _usecase;

  SofaGenerationController() {
    _apiService = ApiService(_http);
    _repo = MeshyRepository(_apiService);
    _usecase = GenerateSofaFromPersonalization(_repo);
  }

  // Original single generation variables (kept for backward compatibility)
  var isGenerating = false.obs;
  var previewProgress = 0.obs;
  var refineProgress = 0.obs;
  var errorMessage = RxnString();
  var glbUrl = RxnString();
  var thumbnailUrl = RxnString();

  // New two-preview system variables
  var isGeneratingPreviews = false.obs;
  var previewModels = <PreviewModel>[].obs;
  var selectedPreviewIndex = RxnInt();
  var isRefining = false.obs;
  var refinedModel = Rxn<RefinedModel>();
  var preview1Progress = 0.obs;
  var preview2Progress = 0.obs;

  Future<void> generate(SofaConfig cfg, {PersonalizationData? personalizationData}) async {
    isGenerating.value = true;
    errorMessage.value = null;
    glbUrl.value = null;
    thumbnailUrl.value = null;

    try {
      final previewPrompt = cfg.toPreviewPrompt();
      final refinePrompt = cfg.toRefineTexturePrompt();
      print('SofaGenerationController: Starting generation');
      print('Preview prompt (${previewPrompt.length} chars): $previewPrompt');
      print('Refine prompt (${refinePrompt.length} chars): $refinePrompt');
      
      final result = await _usecase.call(cfg, onProgress: (p1, p2) {
        previewProgress.value = p1;
        refineProgress.value = p2;
      });

      print('SofaGenerationController: generation finished, task result: glb=${result.glbUrl} thumb=${result.thumbnailUrl}');
      
      // For now, let's use the remote URL directly and add extensive logging
      glbUrl.value = result.glbUrl;
      thumbnailUrl.value = result.thumbnailUrl;
      
      // Log the exact URL we're setting
      print('SofaGenerationController: Set glbUrl to: ${glbUrl.value}');
      print('SofaGenerationController: Set thumbnailUrl to: ${thumbnailUrl.value}');
      
      // Download and cache the GLB locally to avoid remote WebView/CORS issues
      String? localPath;
      if (result.glbUrl != null) {
        print('SofaGenerationController: Attempting to download GLB locally...');
        localPath = await GlbCacheService.downloadAndCache(result.glbUrl!, fileName: 'generated_sofa_${DateTime.now().millisecondsSinceEpoch}.glb');
      }

      String? chosenGlbPath;
      if (localPath != null && localPath.isNotEmpty) {
        // Use local path directly (ModelViewer should handle local file paths)
        print('SofaGenerationController: Using local GLB path: $localPath');
        glbUrl.value = localPath;
        chosenGlbPath = localPath;
      } else {
        print('SofaGenerationController: Using remote GLB URL (download failed or not attempted)');
        glbUrl.value = result.glbUrl;
        chosenGlbPath = result.glbUrl;
      }

      thumbnailUrl.value = result.thumbnailUrl;

      // Save the generated model if personalization data is provided
      if (personalizationData != null && (chosenGlbPath != null || result.thumbnailUrl != null)) {
        await _saveGeneratedModel(result, cfg, personalizationData, chosenGlbPath);
      }
    } catch (e) {
      print('SofaGenerationController: generation failed: $e');
      errorMessage.value = e.toString();
    } finally {
      isGenerating.value = false;
    }
  }

  Future<void> _saveGeneratedModel(dynamic result, SofaConfig cfg, PersonalizationData personalizationData, [String? chosenGlbPath]) async {
    try {
      print('SofaGenerationController: _saveGeneratedModel called with:');
      print('  result.glbUrl: ${result.glbUrl}');
      print('  chosenGlbPath: $chosenGlbPath');
      print('  Will save glbUrl as: ${chosenGlbPath ?? result.glbUrl}');
      
      final model = GeneratedSofaModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Personalized Sofa ${DateTime.now().toString().split(' ')[0]}',
        // Prefer the local cached GLB path if available
        glbUrl: chosenGlbPath ?? result.glbUrl,
        thumbnailUrl: result.thumbnailUrl,
        personalizationData: personalizationData,
        createdAt: DateTime.now(),
        previewPrompt: cfg.toPreviewPrompt(),
        refinePrompt: cfg.toRefineTexturePrompt(),
      );

      print('SofaGenerationController: Created model with glbUrl: ${model.glbUrl}');
      
      final success = await SavedModelsService.saveModel(model);
      if (success) {
        print('SofaGenerationController: Model saved successfully with glbUrl: ${model.glbUrl}');
      } else {
        print('SofaGenerationController: Failed to save model');
      }
    } catch (e) {
      print('SofaGenerationController: Error saving model: $e');
    }
  }

  // NEW: Generate two preview models
  Future<void> generatePreviews(SofaConfig cfg) async {
    isGeneratingPreviews.value = true;
    errorMessage.value = null;
    previewModels.clear();
    selectedPreviewIndex.value = null;
    refinedModel.value = null;
    preview1Progress.value = 0;
    preview2Progress.value = 0;

    try {
      print('SofaGenerationController: Starting two-preview generation');

      // Generate two different preview prompts
      final basePrompt = cfg.toPreviewPrompt();
      final prompt1 = '$basePrompt, style variation 1, modern minimalist approach';
      final prompt2 = '$basePrompt, style variation 2, classic elegant design';

      print('Preview prompt 1: $prompt1');
      print('Preview prompt 2: $prompt2');

      // Start both previews simultaneously
      final future1 = _generateSinglePreview(prompt1, 0);
      final future2 = _generateSinglePreview(prompt2, 1);

      final results = await Future.wait([future1, future2]);

      previewModels.value = results;
      print('SofaGenerationController: Both previews completed');
      print('Preview models count: ${previewModels.length}');
      for (int i = 0; i < results.length; i++) {
        print('Preview $i: glbUrl=${results[i].basicGlbUrl}, thumbnailUrl=${results[i].thumbnailUrl}');
      }

    } catch (e) {
      print('SofaGenerationController: Preview generation failed: $e');
      errorMessage.value = e.toString();
    } finally {
      isGeneratingPreviews.value = false;
    }
  }

  // Helper method to generate a single preview
  Future<PreviewModel> _generateSinglePreview(String prompt, int index) async {
    try {
      final taskId = await _repo.startPreview(prompt);
      print('Started preview $index with taskId: $taskId');

      // Poll for completion with progress updates
      while (true) {
        final task = await _repo.waitPreviewSingle(taskId);
        
        // Update progress for this specific preview
        if (index == 0) {
          preview1Progress.value = task.progress;
        } else {
          preview2Progress.value = task.progress;
        }

        if (task.status == MeshyStatus.succeeded) {
          print('Preview $index completed successfully:');
          print('  - TaskId: $taskId');
          print('  - GLB URL: ${task.glbUrl}');
          print('  - Thumbnail URL: ${task.thumbnailUrl}');
          
          // Download and cache the GLB locally to avoid CORS issues
          String? localGlbPath;
          if (task.glbUrl != null && task.glbUrl!.isNotEmpty) {
            try {
              print('Preview $index: Downloading GLB to local cache...');
              localGlbPath = await GlbCacheService.downloadAndCache(
                task.glbUrl!,
                fileName: 'preview_${index}_${DateTime.now().millisecondsSinceEpoch}.glb',
              );
              print('Preview $index: GLB cached locally at: $localGlbPath');
            } catch (e) {
              print('Preview $index: Failed to cache GLB locally: $e');
              // Continue with remote URL as fallback
            }
          }
          
          final previewModel = PreviewModel(
            taskId: taskId,
            thumbnailUrl: task.thumbnailUrl,
            basicGlbUrl: localGlbPath ?? task.glbUrl, // Use local path if available
            prompt: prompt,
          );
          
          print('Preview $index: Using GLB path: ${previewModel.basicGlbUrl}');
          return previewModel;
        } else if (task.status == MeshyStatus.failed) {
          throw Exception('Preview $index failed: ${task.taskErrorMessage ?? "Unknown error"}');
        }

        // Wait before next poll
        await Future.delayed(Duration(seconds: 5));
      }
    } catch (e) {
      print('Error generating preview $index: $e');
      rethrow;
    }
  }

  // NEW: Select a preview and refine it
  Future<void> selectAndRefinePreview(int index, SofaConfig cfg, {PersonalizationData? personalizationData}) async {
    if (index >= previewModels.length) return;

    selectedPreviewIndex.value = index;
    isRefining.value = true;
    refinedModel.value = null;

    try {
      final selectedPreview = previewModels[index];
      print('SofaGenerationController: Refining selected preview ${selectedPreview.taskId}');

      final refineTaskId = await _repo.startRefine(
        previewTaskId: selectedPreview.taskId,
        texturePrompt: cfg.toRefineTexturePrompt(),
      );

      // Poll for refinement completion
      while (true) {
        final task = await _repo.waitRefineSingle(refineTaskId);
        refineProgress.value = task.progress;

        if (task.status == MeshyStatus.succeeded) {
          final refined = RefinedModel(
            glbUrl: task.glbUrl,
            thumbnailUrl: task.thumbnailUrl,
            taskId: refineTaskId,
          );

          refinedModel.value = refined;

          // Cache the GLB locally
          if (refined.glbUrl != null) {
            final localPath = await GlbCacheService.downloadAndCache(
              refined.glbUrl!, 
              fileName: 'refined_sofa_${DateTime.now().millisecondsSinceEpoch}.glb'
            );
            if (localPath != null) {
              refinedModel.value = RefinedModel(
                glbUrl: localPath,
                thumbnailUrl: refined.thumbnailUrl,
                taskId: refineTaskId,
              );
            }
          }

          // Save the model if personalization data is provided
          if (personalizationData != null) {
            await _saveRefinedModel(refined, cfg, personalizationData);
          }

          break;
        } else if (task.status == MeshyStatus.failed) {
          throw Exception('Refinement failed: ${task.taskErrorMessage ?? "Unknown error"}');
        }

        await Future.delayed(Duration(seconds: 5));
      }

      print('SofaGenerationController: Refinement completed');
    } catch (e) {
      print('SofaGenerationController: Refinement failed: $e');
      errorMessage.value = e.toString();
    } finally {
      isRefining.value = false;
    }
  }

  Future<void> _saveRefinedModel(RefinedModel refined, SofaConfig cfg, PersonalizationData personalizationData) async {
    try {
      final model = GeneratedSofaModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Personalized Sofa ${DateTime.now().toString().split(' ')[0]}',
        glbUrl: refined.glbUrl,
        thumbnailUrl: refined.thumbnailUrl,
        personalizationData: personalizationData,
        createdAt: DateTime.now(),
        previewPrompt: cfg.toPreviewPrompt(),
        refinePrompt: cfg.toRefineTexturePrompt(),
      );

      final success = await SavedModelsService.saveModel(model);
      if (success) {
        print('SofaGenerationController: Refined model saved successfully');
      }
    } catch (e) {
      print('SofaGenerationController: Error saving refined model: $e');
    }
  }
}