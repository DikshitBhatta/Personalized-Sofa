import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:timberr/constants.dart';
import 'dart:io';

/// Fullscreen 3D model viewer - standalone without circular dependencies
class Fullscreen3DView extends StatefulWidget {
  final String assetPath;
  const Fullscreen3DView({super.key, required this.assetPath});

  @override
  State<Fullscreen3DView> createState() => _Fullscreen3DViewState();
}

class _Fullscreen3DViewState extends State<Fullscreen3DView> {
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    debugPrint("Fullscreen3DView: Initializing with asset path: ${widget.assetPath}");
    
    // Timeout for loading
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted && _isLoading) {
        debugPrint("Fullscreen3DView: Timeout reached, showing error fallback");
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    });
  }

  String _getModelViewerSrc() {
    debugPrint("Fullscreen3DView: Processing asset path: ${widget.assetPath}");
    
    // Reject remote URLs (CORS issues)
    if (widget.assetPath.startsWith('http')) {
      debugPrint("Fullscreen3DView: Remote URL detected, will show error due to CORS");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _hasError = true;
            _isLoading = false;
          });
        }
      });
      return widget.assetPath;
    }
    
    // Check if this is a local file path
    if (widget.assetPath.startsWith('/') || widget.assetPath.startsWith('file://')) {
      final filePath = widget.assetPath.startsWith('file://') 
          ? widget.assetPath.substring(7) 
          : widget.assetPath;
      
      if (File(filePath).existsSync()) {
        final fileSize = File(filePath).lengthSync();
        debugPrint("Fullscreen3DView: Local file exists (${fileSize} bytes): $filePath");
        return 'file://$filePath';
      } else {
        debugPrint("Fullscreen3DView: Local file does not exist: $filePath");
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
        return widget.assetPath;
      }
    }
    
    return widget.assetPath;
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
        title: const Text('3D Model Viewer', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // White background
          Container(color: Colors.white),
          
          // Model Viewer
          if (!_hasError)
            Center(
              child: ModelViewer(
                backgroundColor: Colors.white,
                src: _getModelViewerSrc(),
                alt: "Fullscreen 3D Sofa",
                ar: false,
                autoRotate: true,
                autoRotateDelay: 1000,
                rotationPerSecond: '20deg',
                cameraControls: true,
                interactionPrompt: InteractionPrompt.auto,
                loading: Loading.eager,
                fieldOfView: '28deg',
                cameraOrbit: '0deg 1.6m 3.5m',
                minCameraOrbit: 'auto 0deg 2.0m',
                maxCameraOrbit: 'auto 180deg 5.0m',
                onWebViewCreated: (controller) {
                  debugPrint("Fullscreen3DView: ModelViewer WebView created");
                  setState(() {
                    _isLoading = false;
                  });
                },
              ),
            ),
          
          // Loading overlay
          if (_isLoading && !_hasError)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(kSeaGreen),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading 3D Model...',
                      style: kNunitoSans14.copyWith(color: kGrey),
                    ),
                  ],
                ),
              ),
            ),
          
          // Error fallback
          if (_hasError)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.view_in_ar, size: 80, color: kTinGrey),
                    const SizedBox(height: 16),
                    Text(
                      '3D Sofa Preview',
                      style: kNunitoSansBold18.copyWith(color: kOffBlack),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'Your personalized design',
                        style: kNunitoSans14.copyWith(color: kGrey),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: kSeaGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info_outline, size: 16, color: kSeaGreen),
                          const SizedBox(width: 8),
                          Text(
                            'Interactive 3D Model',
                            style: kNunitoSans12Grey.copyWith(color: kSeaGreen),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
