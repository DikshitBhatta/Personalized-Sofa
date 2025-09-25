import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class GlbViewerDev extends StatelessWidget {
  final String glbUrl;
  const GlbViewerDev({super.key, required this.glbUrl});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16/9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ModelViewer(
          src: glbUrl,
          autoRotate: true,
          cameraControls: true,
          ar: false,
          disableZoom: false,
          alt: 'Generated 3D Sofa',
          exposure: 1.0,
        ),
      ),
    );
  }
}
