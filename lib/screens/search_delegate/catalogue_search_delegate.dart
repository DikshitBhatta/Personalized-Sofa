import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/models/generated_sofa_model.dart';
import 'package:timberr/widgets/glb_viewer.dart';

class CatalogueSearchDelegate extends SearchDelegate {
  final List<GeneratedSofaModel> savedModels;
  
  CatalogueSearchDelegate(this.savedModels);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          onPressed: () {
            query = "";
          },
          icon: const Icon(Icons.clear),
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        Get.back();
      },
      icon: const Icon(Icons.arrow_back_ios),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: kTinGrey),
            const SizedBox(height: 16),
            Text(
              'Search for your saved models',
              style: kNunitoSans16.copyWith(color: kGrey),
            ),
          ],
        ),
      );
    }

    // Use regex for flexible searching (case-insensitive)
    final RegExp searchRegex = RegExp(query, caseSensitive: false);
    
    final filteredModels = savedModels.where((model) {
      // Search in model name
      if (searchRegex.hasMatch(model.name)) return true;
      
      // Search in audience type
      if (model.personalizationData.audienceType != null &&
          searchRegex.hasMatch(model.personalizationData.audienceType.toString())) {
        return true;
      }
      
      // Search in material type
      if (model.personalizationData.styleMaterial?.materialType != null &&
          searchRegex.hasMatch(model.personalizationData.styleMaterial!.materialType.toString())) {
        return true;
      }
      
      // Search in usage pattern
      if (model.personalizationData.usageStyle?.usagePattern != null &&
          searchRegex.hasMatch(model.personalizationData.usageStyle!.usagePattern.toString())) {
        return true;
      }
      
      return false;
    }).toList();

    if (filteredModels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: kTinGrey),
            const SizedBox(height: 16),
            Text(
              'No matching models found',
              style: kNunitoSans16.copyWith(color: kGrey),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
              style: kNunitoSans14.copyWith(color: kGrey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredModels.length,
      itemBuilder: (context, index) {
        final model = filteredModels[index];
        return _buildModelCard(model);
      },
    );
  }

  Widget _buildModelCard(GeneratedSofaModel model) {
    return GestureDetector(
      onTap: () {
        // Navigate to detailed view
        _showModelDetails(model);
      },
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Model preview
            Container(
              height: 200,
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
                    style: kNunitoSans12Grey,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _showModelDetails(model),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kSeaGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('View Details'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showModelDetails(GeneratedSofaModel model) {
    Get.to(
      () => _ModelDetailScreen(model: model),
      transition: Transition.cupertino,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Detailed view screen for the model
class _ModelDetailScreen extends StatelessWidget {
  final GeneratedSofaModel model;

  const _ModelDetailScreen({required this.model});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundBeige,
      appBar: AppBar(
        backgroundColor: kBackgroundBeige,
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
                  ? GlbViewer(
                      assetPath: model.glbUrl!,
                      height: 300,
                      width: double.infinity,
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
                                child: Icon(Icons.error, size: 40, color: Colors.red),
                              );
                            },
                          ),
                        )
                      : const Center(
                          child: Icon(Icons.chair_outlined, size: 60, color: Colors.grey),
                        ),
            ),

            const SizedBox(height: 20),

            // Model name and date
            Text(
              model.name,
              style: kNunitoSansBold18.copyWith(color: kOffBlack),
            ),
            const SizedBox(height: 4),
            Text(
              'Created: ${_formatDate(model.createdAt)}',
              style: kNunitoSans14.copyWith(color: kGrey),
            ),

            const SizedBox(height: 20),

            // Personalization details
            Text(
              'Personalization Details',
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
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {int maxLines = 1}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
    return '${date.day}/${date.month}/${date.year}';
  }
}
