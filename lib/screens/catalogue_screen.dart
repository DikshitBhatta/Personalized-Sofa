import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/models/generated_sofa_model.dart';
import 'package:timberr/services/saved_models_service.dart';
import 'package:timberr/widgets/glb_viewer.dart';

class CatalogueScreen extends StatefulWidget {
  const CatalogueScreen({super.key});

  @override
  State<CatalogueScreen> createState() => _CatalogueScreenState();
}

class _CatalogueScreenState extends State<CatalogueScreen> {
  List<GeneratedSofaModel> _savedModels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedModels();
  }

  Future<void> _loadSavedModels() async {
    setState(() => _isLoading = true);
    final models = await SavedModelsService.getSavedModels();
    print('CatalogueScreen: Loaded ${models.length} saved models');
    for (int i = 0; i < models.length; i++) {
      final model = models[i];
      print('CatalogueScreen: Model $i - Name: ${model.name}');
      print('CatalogueScreen: Model $i - GLB URL: ${model.glbUrl}');
      print('CatalogueScreen: Model $i - Thumbnail URL: ${model.thumbnailUrl}');
      print('CatalogueScreen: Model $i - Created: ${model.createdAt}');
    }
    setState(() {
      _savedModels = models;
      _isLoading = false;
    });
  }

  Future<void> _deleteModel(String modelId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Model'),
        content: const Text('Are you sure you want to delete this saved model?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await SavedModelsService.deleteModel(modelId);
      if (success) {
        await _loadSavedModels();
        Get.snackbar(
          'Success',
          'Model deleted successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to delete model',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'My Catalogue',
          style: kNunitoSansSemiBold16.copyWith(color: kOffBlack),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kOffBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_savedModels.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: kOffBlack),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear All Models'),
                    content: const Text('Are you sure you want to delete all saved models?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Delete All', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  final success = await SavedModelsService.clearAllModels();
                  if (success) {
                    await _loadSavedModels();
                    Get.snackbar(
                      'Success',
                      'All models cleared',
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  }
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _savedModels.isEmpty
              ? _buildEmptyState()
              : _buildModelsGrid(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chair_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No saved models yet',
            style: kNunitoSansSemiBold16.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Create personalized sofas to see them here',
            style: kNunitoSans14.copyWith(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: kSeaGreen,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: Text(
              'Start Creating',
              style: kNunitoSansSemiBold16.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelsGrid() {
    return RefreshIndicator(
      onRefresh: _loadSavedModels,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: _savedModels.length,
        itemBuilder: (context, index) {
          final model = _savedModels[index];
          return _buildModelCard(model);
        },
      ),
    );
  }

  Widget _buildModelCard(GeneratedSofaModel model) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Model preview
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                color: kLynxWhite,
              ),
              child: model.thumbnailUrl != null
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        model.thumbnailUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                          );
                        },
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.chair_outlined, size: 40, color: Colors.grey),
                    ),
            ),
          ),

          // Model info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model.name,
                  style: kNunitoSansSemiBold16.copyWith(color: kOffBlack),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Created: ${_formatDate(model.createdAt)}',
                  style: kNunitoSans12Grey.copyWith(color: kGrey),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _viewModelDetails(model),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kSeaGreen,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: Text(
                          'View',
                          style: kNunitoSans14.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _deleteModel(model.id),
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _viewModelDetails(GeneratedSofaModel model) {
    Get.to(() => ModelDetailsScreen(model: model));
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

// Model Details Screen
class ModelDetailsScreen extends StatelessWidget {
  final GeneratedSofaModel model;

  const ModelDetailsScreen({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          model.name,
          style: kNunitoSansSemiBold16.copyWith(color: kOffBlack),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kOffBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Model preview
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: kLynxWhite,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: model.glbUrl != null
                  ? Builder(
                      builder: (context) {
                        print('ModelDetailsScreen: Loading GLB from: ${model.glbUrl}');
                        print('ModelDetailsScreen: GLB URL type: ${model.glbUrl.runtimeType}');
                        print('ModelDetailsScreen: GLB URL length: ${model.glbUrl!.length}');
                        print('ModelDetailsScreen: Is local file: ${model.glbUrl!.startsWith('/') || model.glbUrl!.startsWith('file://')}');
                        return GlbViewer(
                          assetPath: model.glbUrl!,
                          height: 300,
                          width: double.infinity,
                        );
                      },
                    )
                  : model.thumbnailUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            model.thumbnailUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: progress.expectedTotalBytes != null
                                      ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                              );
                            },
                          ),
                        )
                      : const Center(
                          child: Icon(Icons.chair_outlined, size: 60, color: Colors.grey),
                        ),
            ),

            const SizedBox(height: 20),

            // Model details
            Text(
              'Model Details',
              style: kNunitoSansSemiBold16.copyWith(color: kOffBlack),
            ),
            const SizedBox(height: 12),

            _buildDetailRow('Created', _formatDate(model.createdAt)),
            if (model.previewPrompt != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow('Preview Prompt', model.previewPrompt!, maxLines: 3),
            ],
            if (model.refinePrompt != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow('Refine Prompt', model.refinePrompt!, maxLines: 3),
            ],

            const SizedBox(height: 20),

            // Personalization details
            Text(
              'Personalization Settings',
              style: kNunitoSansSemiBold16.copyWith(color: kOffBlack),
            ),
            const SizedBox(height: 12),

            if (model.personalizationData.audienceType != null)
              _buildDetailRow('Audience', model.personalizationData.audienceType.toString().split('.').last),

            if (model.personalizationData.usageStyle?.usagePattern != null)
              _buildDetailRow('Usage Pattern', model.personalizationData.usageStyle!.usagePattern.toString().split('.').last),

            if (model.personalizationData.styleMaterial?.materialType != null)
              _buildDetailRow('Material', model.personalizationData.styleMaterial!.materialType.toString().split('.').last),

            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                if (model.glbUrl != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Show GLB URL for download
                        Get.dialog(AlertDialog(
                          title: const Text('Download 3D Model'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('GLB URL:', style: kNunitoSans14.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              SelectableText(model.glbUrl!, style: kNunitoSans12Grey),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text('Close'),
                            ),
                          ],
                        ));
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('Download GLB'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSeaGreen,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                if (model.thumbnailUrl != null && model.glbUrl != null)
                  const SizedBox(width: 12),
                if (model.thumbnailUrl != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Show thumbnail preview
                        Get.dialog(AlertDialog(
                          title: const Text('Preview Image'),
                          content: Container(
                            constraints: const BoxConstraints(maxHeight: 300),
                            child: Image.network(model.thumbnailUrl!),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text('Close'),
                            ),
                          ],
                        ));
                      },
                      icon: const Icon(Icons.image),
                      label: const Text('View Image'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {int maxLines = 1}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: kNunitoSans14.copyWith(color: kSeaGreen, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: kNunitoSans14.copyWith(color: kOffBlack),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
  }
}
