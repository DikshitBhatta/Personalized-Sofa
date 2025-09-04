import 'package:flutter/material.dart';
import 'dart:async';

class ImageSliderWidget extends StatefulWidget {
  const ImageSliderWidget({super.key});

  @override
  State<ImageSliderWidget> createState() => _ImageSliderWidgetState();
}

class _ImageSliderWidgetState extends State<ImageSliderWidget> {
  PageController? _pageController;
  Timer? _timer;
  int _currentPage = 0;
  bool _isInitialized = false;

  final List<SliderItem> _sliderItems = [
    SliderItem(
      imagePath: 'assets/slider/sofa.jpg',
      title: 'Luxury Sofas',
      subtitle: 'Comfort meets style',
      buttonText: 'Shop Now',
      gradientColors: [
        Color(0xFF6366F1),
        Color(0xFF8B5CF6),
      ],
    ),
    SliderItem(
      imagePath: 'assets/slider/kid_section.jpg',
      title: 'Kids Collection',
      subtitle: 'Fun & colorful designs',
      buttonText: 'Explore',
      gradientColors: [
        Color(0xFFEC4899),
        Color(0xFFEF4444),
      ],
    ),
    SliderItem(
      imagePath: 'assets/slider/pet_section.jpg',
      title: 'Pet Furniture',
      subtitle: 'Comfort for your pets',
      buttonText: 'Discover',
      gradientColors: [
        Color(0xFF10B981),
        Color(0xFF059669),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSlider();
    });
  }

  void _initializeSlider() {
    if (!mounted) return;
    
    setState(() {
      _pageController = PageController(initialPage: 1000);
      _isInitialized = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController?.hasClients == true && mounted) {
        _pageController?.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });

    _preloadImages();
  }

  void _preloadImages() {
    if (!mounted) return;
    for (SliderItem item in _sliderItems) {
      precacheImage(AssetImage(item.imagePath), context);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _pageController == null) {
      return Container(
        height: 200,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        children: [
          // Main PageView with infinite scroll
          PageView.builder(
            controller: _pageController!,
            onPageChanged: (index) {
              if (mounted) {
                setState(() {
                  _currentPage = index % _sliderItems.length;
                });
              }
            },
            itemBuilder: (context, index) {
              final itemIndex = index % _sliderItems.length;
              return _buildSliderCard(_sliderItems[itemIndex]);
            },
          ),
          
          // Page Indicators
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _sliderItems.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index 
                        ? Colors.white 
                        : Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderCard(SliderItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image with error handling
            Image.asset(
              item.imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade300,
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: Colors.grey,
                  ),
                );
              },
            ),
            
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    item.gradientColors[0].withOpacity(0.8),
                    item.gradientColors[1].withOpacity(0.6),
                  ],
                ),
              ),
            ),
            
            // Content
            Positioned(
              left: 24,
              top: 0,
              bottom: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Gelasio',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.subtitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 0,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      item.buttonText,
                      style: TextStyle(
                        color: item.gradientColors[0],
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SliderItem {
  final String imagePath;
  final String title;
  final String subtitle;
  final String buttonText;
  final List<Color> gradientColors;

  SliderItem({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.gradientColors,
  });
}
