import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'dart:io';
class Fullscreen3DView extends StatelessWidget {
  final String assetPath;
  const Fullscreen3DView({super.key, required this.assetPath});

  String _getModelViewerSrc() {
    // Check if this is a local file path
    if (File(assetPath).existsSync()) {
      // For local files, ModelViewer needs a file:// URI
      return 'file://$assetPath';
    }
    // For URLs, use as-is
    return assetPath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SizedBox.expand(
          child: ModelViewer(
            src: _getModelViewerSrc(),
            alt: "Fullscreen 3D Sofa",
            ar: false,
            autoRotate: true,
            cameraControls: true,
            backgroundColor: Colors.transparent,
            interactionPrompt: InteractionPrompt.auto,
            fieldOfView: '28deg',
            // Tuned to show whole model in fullscreen: slightly further back
            cameraOrbit: '0deg 15deg 6.0m',
            minCameraOrbit: 'auto 0deg 4.0m',
            maxCameraOrbit: 'auto 180deg 10.0m',
          ),
        ),
      ),
    );
  }
}
