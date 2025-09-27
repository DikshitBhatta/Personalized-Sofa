import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/controllers/personalization_controller.dart';
import 'package:timberr/widgets/pricing/sofa_price_display.dart';
import 'package:timberr/extensions/personalization_pricing_extension.dart';
import 'package:timberr/models/personalization_data.dart' as pdata;

class PricingDemoScreen extends StatelessWidget {
  const PricingDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundBeige,
      appBar: AppBar(
        backgroundColor: kBackgroundBeige,
        elevation: 0,
        title: Text(
          'Pricing Demo',
          style: kMerriweatherBold16.copyWith(color: kOffBlack),
        ),
        centerTitle: true,
      ),
      body: GetBuilder<PersonalizationController>(
        builder: (controller) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  'Sofa Pricing System Demo',
                  style: kNunitoSansBold24.copyWith(color: kOffBlack),
                ),
                const SizedBox(height: 8),
                Text(
                  'See how personalization options affect the price',
                  style: kNunitoSans18.copyWith(color: kTinGrey),
                ),
                
                const SizedBox(height: 24),
                
                // Current price display
                const SofaPriceDisplay(
                  showBreakdown: true,
                  showFullBreakdown: false,
                ),
                
                const SizedBox(height: 24),
                
                // Pricing tier and delivery info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kChristmasSilver),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: kSeaGreen,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Pricing Tier: ${controller.pricingTierDescription}',
                            style: kNunitoSansSemiBold16.copyWith(color: kSeaGreen),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            color: kTinGrey,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Estimated Delivery: ${controller.estimatedDeliveryTime}',
                            style: kNunitoSans14.copyWith(color: kTinGrey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.trending_up,
                            color: kTinGrey,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Price Increase: ${controller.priceIncreasePercentage.toStringAsFixed(1)}% from base',
                            style: kNunitoSans14.copyWith(color: kTinGrey),
                          ),
                        ],
                      ),
                      if (controller.mostExpensiveCategory != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.category,
                              color: kTinGrey,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Most Expensive: ${controller.mostExpensiveCategory}',
                              style: kNunitoSans14.copyWith(color: kTinGrey),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Quick test buttons
                Text(
                  'Quick Test Options',
                  style: kNunitoSansSemiBold18.copyWith(color: kOffBlack),
                ),
                const SizedBox(height: 12),
                
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildTestButton(
                      'Adult Luxury',
                      () => _setAdultLuxuryConfig(controller),
                    ),
                    _buildTestButton(
                      'Child Safe',
                      () => _setChildSafeConfig(controller),
                    ),
                    _buildTestButton(
                      'Pet Friendly',
                      () => _setPetFriendlyConfig(controller),
                    ),
                    _buildTestButton(
                      'Reset',
                      () => _resetConfig(controller),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Full breakdown button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => PriceBreakdownDialog.show(context),
                    icon: const Icon(Icons.receipt_long),
                    label: const Text('View Detailed Breakdown'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kSeaGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTestButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: kOffBlack,
        side: const BorderSide(color: kChristmasSilver),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(label),
    );
  }

  void _setAdultLuxuryConfig(PersonalizationController controller) {
    // Adult with luxury options
    controller.setAudienceType(pdata.AudienceType.adult);
    
    controller.setUsageStyle(pdata.UsageStyleData(
      usagePattern: pdata.UsagePattern.familyLiving,
      firmnessPreference: pdata.FirmnessPreference.soft,
      sofaCapacity: pdata.SofaCapacity.fourPlus,
      seatSupport: pdata.SeatSupport.lumbarSupport,
    ));
    
    controller.setStyleMaterial(pdata.StyleMaterialData(
      materialType: pdata.MaterialType.fullGrain,
      functionalityTypes: [
        pdata.FunctionalityType.antibacterial,
        pdata.FunctionalityType.flameRetardant,
      ],
    ));
    
    controller.setPersonalizationDetails(pdata.PersonalizationDetails(
      colorHex: '#8B4513',
      patternType: pdata.PatternType.jacquard,
      stitchingType: pdata.StitchingType.hand,
      legType: pdata.LegType.bronze,
    ));
    
    controller.setComfortPreferences(pdata.ComfortPreferences(
      cushionFirmness: 'soft',
      seatDepth: 'deep',
      backSupport: true,
      armrests: true,
      headrest: true,
      tallUsers: true,
      elderlyFriendly: true,
    ));
    
    controller.setFinalPreferences(pdata.FinalPreferences(
      whatMattersMost: 'Durability',
      ecoFriendly: 'Important',
      washableReplaceableCovers: true,
    ));
    
    controller.setNiceToHaves(pdata.NiceToHaves(
      extras: [
        'built_in_speakers',
        'wireless_charging',
        'hidden_storage',
        'led_lighting',
      ],
      modularExpandable: true,
    ));
  }

  void _setChildSafeConfig(PersonalizationController controller) {
    // Simple child configuration
    controller.setAudienceType(pdata.AudienceType.child);
    Get.snackbar('Config Set', 'Child-safe configuration applied');
  }

  void _setPetFriendlyConfig(PersonalizationController controller) {
    // Simple pet configuration
    controller.setAudienceType(pdata.AudienceType.pet);
    Get.snackbar('Config Set', 'Pet-friendly configuration applied');
  }

  void _resetConfig(PersonalizationController controller) {
    // Simple reset
    controller.setAudienceType(pdata.AudienceType.adult);
    Get.snackbar('Reset', 'Configuration reset to adult default');
    controller.update();
  }
}