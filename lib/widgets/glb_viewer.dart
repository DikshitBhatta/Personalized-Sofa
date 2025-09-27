import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/screens/fullscreen_3d_view.dart';
import 'dart:io';

class GlbViewer extends StatefulWidget {
  final String assetPath;
  final double? height;
  final double? width;
  final String? cameraOrbit;
  
  const GlbViewer({
    super.key, 
    required this.assetPath,
    this.height,
    this.width,
  this.cameraOrbit,
  });

  @override
  State<GlbViewer> createState() => _GlbViewerState();
}

class _GlbViewerState extends State<GlbViewer> with TickerProviderStateMixin {
  bool _isLoading = true;
  bool _hasError = false;
  late AnimationController _rotationController;
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    debugPrint("GlbViewer: Initializing with asset path: ${widget.assetPath}");
    _rotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
    
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    // Check if this is a remote URL (likely to have CORS issues)
    if (widget.assetPath.startsWith('http')) {
      debugPrint("GlbViewer: Remote URL detected, may have CORS issues: ${widget.assetPath}");
      // Shorter timeout for remote URLs since they likely won't work
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isLoading) {
          debugPrint("GlbViewer: Remote URL timeout reached, showing error fallback");
          setState(() {
            _hasError = true;
            _isLoading = false;
          });
        }
      });
    } else {
      // Give local files more time to load
      Future.delayed(const Duration(seconds: 8), () {
        if (mounted && _isLoading) {
          debugPrint("GlbViewer: Local file timeout reached, showing error fallback for: ${widget.assetPath}");
          setState(() {
            _hasError = true;
            _isLoading = false;
          });
        }
      });
    }
  }

  String _getModelViewerSrc() {
    debugPrint("GlbViewer: Processing asset path: ${widget.assetPath}");
    
    // Immediately reject remote URLs to avoid CORS issues
    if (widget.assetPath.startsWith('http')) {
      debugPrint("GlbViewer: Remote URL detected, will show error fallback due to CORS restrictions");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _hasError = true;
            _isLoading = false;
          });
        }
      });
      return widget.assetPath; // Return something to avoid null issues
    }
    
    // Check if this is a local file path
    if (widget.assetPath.startsWith('/') || widget.assetPath.startsWith('file://')) {
      final filePath = widget.assetPath.startsWith('file://') 
          ? widget.assetPath.substring(7) 
          : widget.assetPath;
      
      if (File(filePath).existsSync()) {
        final fileSize = File(filePath).lengthSync();
        debugPrint("GlbViewer: Local file exists (${fileSize} bytes), converting to file URI: $filePath");
        return 'file://$filePath';
      } else {
        debugPrint("GlbViewer: Local file does not exist: $filePath");
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
        return widget.assetPath; // Return original to avoid null issues
      }
    }
    
    // For URLs, use as-is
    debugPrint("GlbViewer: Using remote URL: ${widget.assetPath}");
    return widget.assetPath;
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _openFullscreen() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Fullscreen3DView(assetPath: widget.assetPath),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? 300,
      height: widget.height ?? 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: kLynxWhite,
        boxShadow: [
          BoxShadow(
            color: kGrey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: GestureDetector(
        onDoubleTap: _openFullscreen,
        child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Try to load 3D Model Viewer first (render slightly smaller to avoid overflow)
            if (!_hasError)
              Center(
                child: FractionallySizedBox(
                  widthFactor: 0.9,
                  heightFactor: 0.9,
                  child: ModelViewer(
                    backgroundColor: Colors.white,
                    src: _getModelViewerSrc(),
                    alt: "Personalized 3D Sofa Model",
                    ar: false,
                    autoRotate: true,
                    autoRotateDelay: 1000,
                    rotationPerSecond: '20deg',
                    cameraControls: true,
                    touchAction: TouchAction.panY,
                    interactionPrompt: InteractionPrompt.auto,
                    loading: Loading.eager,
                    // Tune camera to be slightly further back so the whole model fits
                    fieldOfView: '28deg',
                    // Allow override from widget; default moves camera back on Z axis
                    cameraOrbit: widget.cameraOrbit ?? '0deg 1.6m 3.0m',
                    minCameraOrbit: 'auto 0deg 2.0m',
                    maxCameraOrbit: 'auto 180deg 4.0m',
                    onWebViewCreated: (controller) {
                      debugPrint("GlbViewer: ModelViewer WebView created for: ${widget.assetPath}");
                      setState(() {
                        _isLoading = false;
                      });
                    },
                  ),
                ),
              ),
            
            // Enhanced fallback when model fails to load
            if (_hasError)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      kLynxWhite,
                      kSeaGreen.withOpacity(0.05),
                      kLynxWhite,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Show different messages based on error type
                      if (widget.assetPath.startsWith('http')) ...[
                        Icon(
                          Icons.cloud_off,
                          size: 48,
                          color: Colors.orange.withOpacity(0.7),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Unable to load remote model",
                          style: kNunitoSansSemiBold16.copyWith(
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Model needs to be cached locally",
                          style: kNunitoSans14.copyWith(
                            color: kGrey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ] else ...[
                        // Animated 3D sofa representation for local file errors
                        AnimatedBuilder(
                          animation: _floatController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _floatController.value * 10 - 5),
                              child: AnimatedBuilder(
                                animation: _rotationController,
                                builder: (context, child) {
                                  return Transform.rotate(
                                  angle: _rotationController.value * 0.5,
                                  child: Container(
                                    width: 120,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          kSeaGreen.withOpacity(0.8),
                                          kSeaGreen,
                                          kSeaGreen.withOpacity(0.6),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: kSeaGreen.withOpacity(0.3),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      children: [
                                        // Sofa backrest
                                        Positioned(
                                          top: 8,
                                          left: 8,
                                          right: 8,
                                          child: Container(
                                            height: 25,
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                        // Sofa seat
                                        Positioned(
                                          bottom: 12,
                                          left: 8,
                                          right: 8,
                                          child: Container(
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.3),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                          ),
                                        ),
                                        // Armrests
                                        Positioned(
                                          top: 12,
                                          left: 4,
                                          child: Container(
                                            width: 8,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 12,
                                          right: 4,
                                          child: Container(
                                            width: 8,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "3D Sofa Preview",
                        style: kNunitoSansSemiBold16.copyWith(
                          color: kOffBlack,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Your personalized design",
                        style: kNunitoSans14.copyWith(
                          color: kGrey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: kSeaGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: kSeaGreen,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Interactive 3D Model",
                              style: kNunitoSans14.copyWith(
                                color: kSeaGreen,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ], // Close the else block
                    ],
                  ),
                ),
              ),
            
            // Loading overlay (only show for first few seconds)
            if (_isLoading && !_hasError)
              Container(
                decoration: BoxDecoration(
                  color: kLynxWhite,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: kSeaGreen,
                        strokeWidth: 3,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Loading 3D Model...",
                        style: TextStyle(
                          color: kGrey,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Please wait",
                        style: TextStyle(
                          color: kGrey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            // Interaction hint overlay (only show when model is loaded and no error)
            if (!_isLoading && !_hasError)
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: kOffBlack.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "Drag to rotate • Pinch to zoom",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
    );
  }
}
