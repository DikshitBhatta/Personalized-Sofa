import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:timberr/screens/home.dart';
import 'package:timberr/screens/notification_screen.dart';
import 'package:timberr/screens/profile/profile_screen.dart';
import 'package:timberr/screens/profile/orders_screen.dart';
import 'package:timberr/screens/personalization/personalization_launch.dart';

class CurvedDockItem {
  final dynamic icon; // Can be IconData or String (SVG path)
  final dynamic activeIcon; // Can be IconData or String (SVG path)
  final String? label;
  final VoidCallback onTap;
  final bool active;

  const CurvedDockItem({
    required this.icon,
    required this.onTap,
    this.activeIcon,
    this.label,
    this.active = false,
  });
}

class CurvedDock extends StatelessWidget {
  /// Items placed left of the center cutout.
  final List<CurvedDockItem> leftItems;

  /// Items placed right of the center cutout.
  final List<CurvedDockItem> rightItems;

  /// Height of the dock (total, including curve area).
  final double height;

  /// Background color of the dock.
  final Color color;

  /// Shadow opacity/depth.
  final double elevation;

  /// Corner radius on the top edge.
  final double cornerRadius;

  /// How wide the center valley is (half-width).
  final double valleyWidthHalf;

  /// How deep the center valley dips.
  final double valleyDepth;

  /// Top padding from the very top of the dock to the straight edge.
  final double topY;

  /// Spacing reserved for the center FAB (keeps icons clear of valley).
  final double centerGap;

  /// Icon color (inactive).
  final Color iconColor;

  /// Icon color (active/selected).
  final Color activeIconColor;

  const CurvedDock({
    super.key,
    required this.leftItems,
    required this.rightItems,
    this.height = 108,
    this.color = Colors.white,
    this.elevation = 16,
    this.cornerRadius = 28,
    this.valleyWidthHalf = 100,
    this.valleyDepth = 80,
    this.topY = 18,
    this.centerGap = 90,
    this.iconColor = Colors.grey,
    this.activeIconColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        height: height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Painted background with curve + shadow
            Positioned.fill(
              child: CustomPaint(
                painter: _BottomBarPainter(
                  color: color,
                  cornerRadius: cornerRadius,
                  topY: topY,
                  valleyWidthHalf: valleyWidthHalf,
                  valleyDepth: valleyDepth,
                  elevation: elevation,
                ),
              ),
            ),
            // Icons
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, topY + 6, 20, 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _IconsRow(
                      items: leftItems,
                      iconColor: iconColor,
                      activeIconColor: activeIconColor,
                    ),
                    SizedBox(width: centerGap),
                    _IconsRow(
                      items: rightItems,
                      iconColor: iconColor,
                      activeIconColor: activeIconColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconsRow extends StatelessWidget {
  final List<CurvedDockItem> items;
  final Color iconColor;
  final Color activeIconColor;

  const _IconsRow({
    required this.items,
    required this.iconColor,
    required this.activeIconColor,
  });

  Widget _buildIcon(CurvedDockItem item) {
    final iconToShow = item.active && item.activeIcon != null ? item.activeIcon : item.icon;

    if (iconToShow is IconData) {
      return Icon(
        iconToShow,
        size: 26,
        color: item.active ? activeIconColor : iconColor,
      );
    } else if (iconToShow is String) {
      return SvgPicture.asset(
        iconToShow,
        width: 26,
        height: 26,
        colorFilter: ColorFilter.mode(
          item.active ? activeIconColor : iconColor,
          BlendMode.srcIn,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: items
          .map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: GestureDetector(
                onTap: e.onTap,
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildIcon(e),
                    if (e.label != null && e.label!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        e.label!,
                        style: TextStyle(
                          fontSize: 11,
                          color: e.active ? activeIconColor : iconColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _BottomBarPainter extends CustomPainter {
  final Color color;
  final double cornerRadius;
  final double topY;
  final double valleyWidthHalf;
  final double valleyDepth;
  final double elevation;

  _BottomBarPainter({
    required this.color,
    required this.cornerRadius,
    required this.topY,
    required this.valleyWidthHalf,
    required this.valleyDepth,
    required this.elevation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;

    final path = Path()
      ..moveTo(0, topY + cornerRadius)
      ..quadraticBezierTo(0, topY, cornerRadius, topY)
      ..lineTo(centerX - valleyWidthHalf, topY)
      ..cubicTo(
        centerX - (valleyWidthHalf * 0.45), topY,
        centerX - (valleyWidthHalf * 0.55), valleyDepth,
        centerX, valleyDepth,
      )
      ..cubicTo(
        centerX + (valleyWidthHalf * 0.55), valleyDepth,
        centerX + (valleyWidthHalf * 0.45), topY,
        centerX + valleyWidthHalf, topY,
      )
      ..lineTo(size.width - cornerRadius, topY)
      ..quadraticBezierTo(size.width, topY, size.width, topY + cornerRadius)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    // Draw shadow with multiple layers for depth
    if (elevation > 0) {
      // Main shadow
      canvas.drawShadow(path, Colors.black.withOpacity(0.15), elevation, true);
      
      // Additional depth shadow
      final shadowPath = Path.from(path);
      shadowPath.shift(const Offset(0, 2));
      canvas.drawShadow(shadowPath, Colors.black.withOpacity(0.08), elevation * 0.5, true);
    }

    // Draw the main background with gradient
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white,
        Colors.grey.shade50,
      ],
    );

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(path, paint);

    // Add inner shadow effect for more depth
    final innerShadowPaint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final innerPath = Path()
      ..moveTo(2, topY + cornerRadius)
      ..quadraticBezierTo(2, topY + 2, cornerRadius, topY + 2)
      ..lineTo(centerX - valleyWidthHalf, topY + 2)
      ..cubicTo(
        centerX - (valleyWidthHalf * 0.45), topY + 2,
        centerX - (valleyWidthHalf * 0.55), valleyDepth + 2,
        centerX, valleyDepth + 2,
      )
      ..cubicTo(
        centerX + (valleyWidthHalf * 0.55), valleyDepth + 2,
        centerX + (valleyWidthHalf * 0.45), topY + 2,
        centerX + valleyWidthHalf, topY + 2,
      )
      ..lineTo(size.width - cornerRadius, topY + 2)
      ..quadraticBezierTo(size.width - 2, topY + 2, size.width - 2, topY + cornerRadius);

    canvas.drawPath(innerPath, innerShadowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CurvedBottomNavBar extends StatelessWidget {
  final int selectedPos;

  const CurvedBottomNavBar({
    super.key,
    required this.selectedPos,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Curved dock background
        CurvedDock(
          leftItems: [
            CurvedDockItem(
              icon: 'assets/icons/home_icon.svg',
              activeIcon: 'assets/icons/home_selected_icon.svg',
              onTap: () {
                if (selectedPos != 0) {
                  Get.off(() => Home(), transition: Transition.fadeIn);
                }
              },
              active: selectedPos == 0,
            ),
            CurvedDockItem(
              icon: 'assets/icons/shopping_bag_icon.svg',
              activeIcon: 'assets/icons/shopping_bag_icon_black.svg',
              onTap: () {
                if (selectedPos != 1) {
                  Get.to(() => const OrdersScreen(), transition: Transition.fadeIn);
                }
              },
              active: selectedPos == 1,
            ),
          ],
          rightItems: [
            CurvedDockItem(
              icon: 'assets/icons/notification_icon.svg',
              activeIcon: 'assets/icons/notification_selected_icon.svg',
              onTap: () {
                if (selectedPos != 2) {
                  Get.to(() => const NotificationScreen(), transition: Transition.fadeIn);
                }
              },
              active: selectedPos == 2,
            ),
            CurvedDockItem(
              icon: 'assets/icons/person_icon.svg',
              activeIcon: 'assets/icons/person_selected_icon.svg',
              onTap: () {
                if (selectedPos != 3) {
                  Get.to(() => ProfileScreen(), transition: Transition.fadeIn);
                }
              },
              active: selectedPos == 3,
            ),
          ],
        ),

        // Floating Action Button in the center
        Positioned(
          bottom: 45,
          left: MediaQuery.of(context).size.width / 2 - 28,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Colors.black87, Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.4),
                  spreadRadius: 0,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  spreadRadius: 0,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: () {
                // Launch personalization flow
                Get.to(
                  () => const PersonalizationLaunchScreen(),
                  transition: Transition.fade,
                );
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  // gradient: LinearGradient(
                  //   colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
                  //   begin: Alignment.topLeft,
                  //   end: Alignment.bottomRight,
                  // ),
                ),
                child: SvgPicture.asset(
                  "assets/icons/armchair_icon.svg",
                  width: 22,
                  height: 22,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
