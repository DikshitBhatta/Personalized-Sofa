import 'package:flutter/material.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/services/glb_cache_service.dart';

class GlbCacheTestScreen extends StatefulWidget {
  const GlbCacheTestScreen({super.key});

  @override
  State<GlbCacheTestScreen> createState() => _GlbCacheTestScreenState();
}

class _GlbCacheTestScreenState extends State<GlbCacheTestScreen> {
  String? _testResult;
  bool _isLoading = false;
  final TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill with a sample GLB URL for testing
    _urlController.text = 'https://assets.meshy.ai/sample.glb';
  }

  Future<void> _testCaching() async {
    if (_urlController.text.isEmpty) {
      setState(() {
        _testResult = 'Please enter a GLB URL to test';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _testResult = 'Testing GLB caching...';
    });

    try {
      final url = _urlController.text.trim();
      print('GlbCacheTestScreen: Testing caching for: $url');
      
      final localPath = await GlbCacheService.downloadAndCache(
        url,
        fileName: 'test_${DateTime.now().millisecondsSinceEpoch}.glb',
      );

      if (localPath != null) {
        setState(() {
          _testResult = 'SUCCESS! GLB cached at:\n$localPath';
        });
      } else {
        setState(() {
          _testResult = 'FAILED: GLB could not be cached.\nCheck console for error details.';
        });
      }
    } catch (e) {
      setState(() {
        _testResult = 'ERROR: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _listCachedFiles() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Listing cached files...';
    });

    try {
      final cachedFiles = await GlbCacheService.listCachedFiles();
      setState(() {
        _testResult = cachedFiles.isEmpty 
            ? 'No cached GLB files found' 
            : 'Cached files:\n${cachedFiles.join('\n')}';
      });
    } catch (e) {
      setState(() {
        _testResult = 'Error listing files: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearCache() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Clearing cache...';
    });

    try {
      final success = await GlbCacheService.clearCache();
      setState(() {
        _testResult = success 
            ? 'Cache cleared successfully!' 
            : 'Failed to clear cache';
      });
    } catch (e) {
      setState(() {
        _testResult = 'Error clearing cache: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GLB Cache Test'),
        backgroundColor: kSeaGreen,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Test GLB Caching',
              style: kNunitoSansSemiBold16.copyWith(color: kOffBlack),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'GLB URL to test',
                border: OutlineInputBorder(),
                hintText: 'https://example.com/model.glb',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testCaching,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kSeaGreen,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Test Cache'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _listCachedFiles,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('List Files'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _clearCache,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Clear Cache'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Test Result:',
              style: kNunitoSansSemiBold16.copyWith(color: kOffBlack),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Text(
                          _testResult ?? 'No test run yet. Click "Test Cache" to begin.',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How to use:',
                    style: kNunitoSansSemiBold16.copyWith(color: Colors.blue[800]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1. Enter a GLB URL or use the pre-filled sample\n'
                    '2. Click "Test Cache" to download and cache the file\n'
                    '3. Click "List Files" to see all cached GLB files\n'
                    '4. Click "Clear Cache" to remove all cached files\n'
                    '5. Check console output for detailed debug info',
                    style: kNunitoSans14.copyWith(color: Colors.blue[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}