import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/screens/catalogue_screen.dart';
import 'package:timberr/controllers/personalization_controller.dart';

class RenovateInteriorSection extends StatelessWidget {
  const RenovateInteriorSection({super.key});

  // Helper method to calculate gradient from hex color
  List<Color> _calculateGradientColors(String hexColor) {
    try {
      final cleanHex = hexColor.replaceAll('#', '');
      final color = Color(int.parse('FF$cleanHex', radix: 16));
      final hslColor = HSLColor.fromColor(color);
      
      return [
        hslColor.withLightness((hslColor.lightness + 0.2).clamp(0.0, 1.0)).toColor(),
        color,
        hslColor.withLightness((hslColor.lightness - 0.2).clamp(0.0, 1.0)).toColor(),
      ];
    } catch (e) {
      print('Error calculating gradient: $e');
      return [
        const Color(0xFFD7B49E),
        const Color(0xFF8B6F47),
        const Color(0xFF5D4E37),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    // Default gradient colors
    final defaultGradientColors = [
      const Color(0xFFD7B49E),
      const Color(0xFF8B6F47),
      const Color(0xFF5D4E37),
    ];
    
    return GetBuilder<PersonalizationController>(
      builder: (controller) {
        // Calculate gradient colors from controller's recommended color
        // This will automatically update when the color changes
        final gradientColors = controller.recommendedColorHex.isNotEmpty
            ? _calculateGradientColors(controller.recommendedColorHex)
            : defaultGradientColors;
        
        // Use cached style tags from controller
        final styleTag1 = controller.styleTag1;
        final styleTag2 = controller.styleTag2;
        
        return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 0,
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.4),
                  ],
                ),
              ),
            ),
          ),
          
          // Decorative vertical lines pattern (like in the screenshot)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
              ),
              child: CustomPaint(
                painter: VerticalLinesPainter(),
              ),
            ),
          ),
          
          // Main content
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(28), // Reduced from 32
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center, // Center vertically
                children: [
                  const Spacer(flex: 1),
                  
                  // Main text
                  Text(
                    'This is',
                    style: kGelasio18.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 32, // Reduced from 36
                      height: 1.1,
                    ),
                  ),
                  Text(
                    'my Space',
                    style: kGelasio18.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                      fontSize: 32, // Reduced from 36
                      height: 1.1,
                    ),
                  ),
                  
                  const SizedBox(height: 16), // Reduced from 24
                  
                  // Style tags (Classic · Cozy)
                  Text(
                    '$styleTag1 · $styleTag2',
                    style: kNunitoSans14.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                      fontSize: 14, // Reduced from 16
                      letterSpacing: 0.5,
                    ),
                  ),
                  
                  const SizedBox(height: 12), // Reduced from 16
                  
                  // Tag chips row
                  Row(
                    children: [
                      _buildChip(Icons.chair_outlined, styleTag1),
                      const SizedBox(width: 12),
                      _buildChip(Icons.local_fire_department_outlined, styleTag2),
                    ],
                  ),
                  
                  const SizedBox(height: 16), // Reduced from 24
                  
                  // Call to action button
                  GestureDetector(
                    onTap: () {
                      Get.to(() => const CatalogueScreen());
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24, // Reduced from 28
                        vertical: 12,   // Reduced from 14
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 0,
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Text(
                        'Go to catalog',
                        style: kNunitoSans14.copyWith(
                          color: Colors.brown.shade800,
                          fontWeight: FontWeight.w600,
                          fontSize: 14, // Reduced from 16
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Decorative furniture/sofa silhouette on the bottom right
          Positioned(
            right: 10,
            bottom: 10,
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                // Use a darker shade for the silhouette effect
                gradientColors.length > 2 
                    ? gradientColors[2].withOpacity(0.8)
                    : const Color(0xFF5D4E37).withOpacity(0.8),
                BlendMode.srcIn,
              ),
              child: Image.asset(
                'assets/icon/image.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
      },
    );
  }
  
  // Helper method to build chip widgets
  Widget _buildChip(IconData icon, String label) {
    // Extract only the first word for the chip to prevent overflow
    final firstWord = label.split(' ').first;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.brown.shade800),
          const SizedBox(width: 6),
          Text(
            firstWord,
            style: kNunitoSans14.copyWith(
              color: Colors.brown.shade800,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for vertical lines pattern
class VerticalLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..strokeWidth = 2;

    for (double x = 10; x < size.width; x += 15) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
