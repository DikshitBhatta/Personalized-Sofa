import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/screens/personalization/personalization_launch.dart';

class PersonalizationPromptSection extends StatelessWidget {
  const PersonalizationPromptSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kSeaGreen.withOpacity(0.1),
            kSeaGreen.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kSeaGreen.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: kSeaGreen,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  Icons.chair,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Create Your Perfect Sofa",
                      style: kNunitoSansBold18.copyWith(color: kOffBlack),
                    ),
                    Text(
                      "Personalized just for you",
                      style: kNunitoSans14.copyWith(color: kTinGrey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            "Get a sofa designed specifically for your needs, style, and space. Our personalization process takes just a few minutes and ensures you get exactly what you're looking for.",
            style: kNunitoSans14.copyWith(
              color: kGrey,
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: kSeaGreen,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x40000000),
                        offset: Offset(0, 4),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        Get.to(() => const PersonalizationLaunchScreen());
                      },
                      child: Center(
                        child: Text(
                          "Start Personalization",
                          style: kNunitoSans16.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "3 min",
                style: kNunitoSans14.copyWith(
                  color: kSeaGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
