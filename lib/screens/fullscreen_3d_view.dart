import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
class Fullscreen3DView extends StatelessWidget {
  final String assetPath;
  const Fullscreen3DView({super.key, required this.assetPath});

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
            src: assetPath,
            alt: "Fullscreen 3D Sofa",
            ar: false,
            autoRotate: true,
            cameraControls: true,
            backgroundColor: Colors.transparent,
            interactionPrompt: InteractionPrompt.auto,
            fieldOfView: '45deg',
          ),
        ),
      ),
    );
  }
}
