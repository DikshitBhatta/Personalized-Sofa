import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timberr/constants.dart';

class AudienceCard extends StatelessWidget {
  final String title;
  final String description;
  final String iconPath;
  final bool isSelected;
  final VoidCallback onTap;
  
  const AudienceCard({
    super.key,
    required this.title,
    required this.description,
    required this.iconPath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? kOffBlack : kChristmasSilver,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? const Color(0x20303030) : const Color(0x10000000),
              offset: const Offset(0, 4),
              blurRadius: isSelected ? 20 : 10,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: isSelected ? kOffBlack : kSnowFlakeWhite,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: SvgPicture.asset(
                  iconPath,
                  height: 40,
                  width: 40,
                  color: isSelected ? Colors.white : kTinGrey,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: kNunitoSansBold20.copyWith(
                color: isSelected ? kOffBlack : kTinGrey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: kNunitoSans14.copyWith(
                color: kGrey,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
