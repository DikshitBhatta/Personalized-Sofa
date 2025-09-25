import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

/// Simple test widget to compare local asset vs remote URL loading in ModelViewer
class ModelViewerTest extends StatelessWidget {
  final String testUrl;
  
  const ModelViewerTest({super.key, required this.testUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ModelViewer Test')),
      body: Column(
        children: [
          Text('Testing URL: $testUrl', style: TextStyle(fontSize: 12)),
          SizedBox(height: 16),
          Expanded(
            child: ModelViewer(
              src: testUrl,
              alt: "Test Model",
              ar: false,
              autoRotate: true,
              cameraControls: true,
              backgroundColor: Colors.grey.shade200,
              loading: Loading.eager,
              onWebViewCreated: (controller) {
                debugPrint("ModelViewer Test: WebView created for $testUrl");
              },
            ),
          ),
        ],
      ),
    );
  }
}
