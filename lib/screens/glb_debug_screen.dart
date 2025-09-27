import 'dart:io';
import 'package:flutter/material.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/services/glb_cache_service.dart';
import 'package:timberr/services/saved_models_service.dart';
import 'package:timberr/models/generated_sofa_model.dart';
import 'package:timberr/screens/glb_cache_test_screen.dart';

class GlbDebugScreen extends StatefulWidget {
  const GlbDebugScreen({super.key});

  @override
  State<GlbDebugScreen> createState() => _GlbDebugScreenState();
}

class _GlbDebugScreenState extends State<GlbDebugScreen> {
  List<String> _cachedFiles = [];
  List<GeneratedSofaModel> _savedModels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDebugInfo();
  }

  Future<void> _loadDebugInfo() async {
    setState(() => _isLoading = true);
    
    try {
      final cachedFiles = await GlbCacheService.listCachedFiles();
      final savedModels = await SavedModelsService.getSavedModels();
      
      setState(() {
        _cachedFiles = cachedFiles;
        _savedModels = savedModels;
        _isLoading = false;
      });
    } catch (e) {
      print('GlbDebugScreen: Error loading debug info: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearCache() async {
    final success = await GlbCacheService.clearCache();
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cache cleared successfully')),
      );
      await _loadDebugInfo(); // Refresh the list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to clear cache')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GLB Debug Info'),
        backgroundColor: kSeaGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDebugInfo,
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _clearCache,
          ),
          IconButton(
            icon: const Icon(Icons.science),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GlbCacheTestScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cached Files Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cached GLB Files (${_cachedFiles.length})',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (_cachedFiles.isEmpty)
                            const Text('No cached files found')
                          else
                            ..._cachedFiles.map((file) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Text(
                                    file,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 12,
                                    ),
                                  ),
                                )),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Saved Models Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Saved Models (${_savedModels.length})',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (_savedModels.isEmpty)
                            const Text('No saved models found')
                          else
                            ..._savedModels.map((model) => Card(
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  color: Colors.grey[50],
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          model.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text('ID: ${model.id}'),
                                        Text('Created: ${model.createdAt}'),
                                        const SizedBox(height: 4),
                                        Text(
                                          'GLB URL: ${model.glbUrl ?? "null"}',
                                          style: TextStyle(
                                            color: model.glbUrl?.startsWith('/') == true 
                                                ? Colors.green 
                                                : Colors.orange,
                                            fontFamily: 'monospace',
                                            fontSize: 11,
                                          ),
                                        ),
                                        Text(
                                          'Thumbnail: ${model.thumbnailUrl ?? "null"}',
                                          style: const TextStyle(
                                            fontFamily: 'monospace',
                                            fontSize: 11,
                                          ),
                                        ),
                                        if (model.glbUrl?.startsWith('/') == true)
                                          Text(
                                            'Local file exists: ${_fileExists(model.glbUrl!)}',
                                            style: TextStyle(
                                              color: _fileExists(model.glbUrl!) 
                                                  ? Colors.green 
                                                  : Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  bool _fileExists(String path) {
    try {
      return File(path).existsSync();
    } catch (e) {
      return false;
    }
  }
}