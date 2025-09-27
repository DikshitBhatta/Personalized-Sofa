import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/services/sofa_price_calculator.dart';
import 'package:timberr/controllers/personalization_controller.dart';

class SofaPriceDisplay extends StatelessWidget {
  final bool showBreakdown;
  final bool showFullBreakdown;
  final EdgeInsets? padding;
  
  const SofaPriceDisplay({
    super.key,
    this.showBreakdown = true,
    this.showFullBreakdown = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PersonalizationController>(
      builder: (controller) {
        final pricing = SofaPriceCalculator.calculatePrice(controller.personalizationData);
        
        return Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            // Cool gradient background similar to the button
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                kOffBlack,
                kOffBlack.withOpacity(0.9),
                Colors.black87,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            // Enhanced shadow like CustomElevatedButton
            boxShadow: const [
              BoxShadow(
                color: Color(0x80303030),
                offset: Offset(0, 10),
                blurRadius: 20,
              ),
              BoxShadow(
                color: Color(0x40000000),
                offset: Offset(0, 4),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with cool styling
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white24, Colors.white10],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.calculate,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Estimated Price',
                    style: kNunitoSansSemiBold16.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Total price with enhanced styling
              Text(
                SofaPriceCalculator.formatPrice(pricing.totalPrice),
                style: kNunitoSansBold24.copyWith(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              
              if (showBreakdown) ...[
                const SizedBox(height: 8),
                
                // Base price with white text
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Base Sofa',
                      style: kNunitoSans14.copyWith(color: Colors.white70),
                    ),
                    Text(
                      SofaPriceCalculator.formatPrice(pricing.basePrice),
                      style: kNunitoSans14.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
                
                // Options price with enhanced styling
                if (pricing.optionsPrice > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Customizations',
                        style: kNunitoSans14.copyWith(color: Colors.white70),
                      ),
                      Text(
                        '+${SofaPriceCalculator.formatPrice(pricing.optionsPrice)}',
                        style: kNunitoSans14.copyWith(
                          color: const Color(0xFF4CAF50), // Light green for dark background
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
                
                if (showFullBreakdown && pricing.breakdown.length > 1) ...[
                  const SizedBox(height: 12),
                  Divider(color: Colors.white24),
                  const SizedBox(height: 8),
                  
                  // Full breakdown
                  ...pricing.groupedBreakdown.entries.map((entry) {
                    if (entry.key == 'Base Sofa') return const SizedBox.shrink();
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: kNunitoSans14.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...entry.value.map((item) => Padding(
                          padding: const EdgeInsets.only(left: 12, bottom: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.item,
                                  style: kNunitoSans12Grey.copyWith(color: Colors.white60),
                                ),
                              ),
                              Text(
                                '+${SofaPriceCalculator.formatPrice(item.price)}',
                                style: kNunitoSans12Grey.copyWith(color: const Color(0xFF4CAF50)),
                              ),
                            ],
                          ),
                        )),
                        const SizedBox(height: 8),
                      ],
                    );
                  }),
                ],
              ],
              
              // Note with updated styling for dark background
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 14,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Final price may vary based on manufacturing requirements',
                        style: kNunitoSans10Grey.copyWith(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CompactPriceDisplay extends StatelessWidget {
  final Color? backgroundColor;
  final Color? textColor;
  
  const CompactPriceDisplay({
    super.key,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PersonalizationController>(
      builder: (controller) {
        final pricing = SofaPriceCalculator.calculatePrice(controller.personalizationData);
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor ?? kSeaGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kSeaGreen.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.price_check,
                size: 16,
                color: textColor ?? kSeaGreen,
              ),
              const SizedBox(width: 6),
              Text(
                SofaPriceCalculator.formatPrice(pricing.totalPrice),
                style: kNunitoSans14.copyWith(
                  color: textColor ?? kSeaGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class PriceBreakdownDialog extends StatelessWidget {
  const PriceBreakdownDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const PriceBreakdownDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PersonalizationController>(
      builder: (controller) {
        final pricing = SofaPriceCalculator.calculatePrice(controller.personalizationData);
        
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.receipt_long,
                      color: kSeaGreen,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Price Breakdown',
                        style: kNunitoSansBold18.copyWith(color: kOffBlack),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: kTinGrey),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                const Divider(color: kChristmasSilver),
                const SizedBox(height: 16),
                
                // Total at top
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kSeaGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Price',
                        style: kNunitoSansBold16.copyWith(color: kSeaGreen),
                      ),
                      Text(
                        SofaPriceCalculator.formatPrice(pricing.totalPrice),
                        style: kNunitoSansBold18.copyWith(color: kSeaGreen),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Breakdown list
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Base price
                        _buildBreakdownItem(
                          'Base Sofa',
                          'Standard 2-3 seater with basic features',
                          pricing.basePrice,
                          isBase: true,
                        ),
                        
                        if (pricing.breakdown.length > 1) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Customizations',
                            style: kNunitoSansSemiBold16.copyWith(color: kOffBlack),
                          ),
                          const SizedBox(height: 8),
                          
                          // Group items by category
                          ...pricing.groupedBreakdown.entries.map((entry) {
                            if (entry.key == 'Base Sofa') return const SizedBox.shrink();
                            
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 12, bottom: 4),
                                  child: Text(
                                    entry.key,
                                    style: kNunitoSans14.copyWith(
                                      color: kTinGrey,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                ...entry.value.map((item) => _buildBreakdownItem(
                                  item.item,
                                  '',
                                  item.price,
                                  isIndented: true,
                                )),
                              ],
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Footer note
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This is an estimate. Final price may vary based on manufacturing requirements and availability.',
                          style: kNunitoSans12Grey.copyWith(color: Colors.orange.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBreakdownItem(String title, String subtitle, double price, {bool isBase = false, bool isIndented = false}) {
    return Padding(
      padding: EdgeInsets.only(
        left: isIndented ? 16 : 0,
        bottom: 8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: kNunitoSans14.copyWith(
                    color: isBase ? kSeaGreen : kOffBlack,
                    fontWeight: isBase ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: kNunitoSans12Grey.copyWith(color: kTinGrey),
                  ),
                ],
              ],
            ),
          ),
          Text(
            isBase 
                ? SofaPriceCalculator.formatPrice(price)
                : '+${SofaPriceCalculator.formatPrice(price)}',
            style: kNunitoSans14.copyWith(
              color: isBase ? kSeaGreen : kOffBlack,
              fontWeight: isBase ? FontWeight.w600 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact price display widget with cool styling like CustomElevatedButton
class CompactPriceTag extends StatelessWidget {
  final bool showBreakdown;
  final double? height;
  
  const CompactPriceTag({
    super.key,
    this.showBreakdown = false,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PersonalizationController>(
      builder: (controller) {
        final pricing = SofaPriceCalculator.calculatePrice(controller.personalizationData);
        
        return Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            // Same styling as CustomElevatedButton
            color: kOffBlack,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Color(0x80303030),
                offset: Offset(0, 10),
                blurRadius: 20,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cool price icon
              Icon(
                Icons.local_offer,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              // Price text with same style as button text
              Text(
                SofaPriceCalculator.formatPriceCompact(pricing.totalPrice),
                style: kNunitoSansSemiBold20White.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (showBreakdown) ...[
                const SizedBox(width: 12),
                Icon(
                  Icons.info_outline,
                  color: Colors.white70,
                  size: 16,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}