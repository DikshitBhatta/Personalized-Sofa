import 'package:timberr/controllers/personalization_controller.dart';
import 'package:timberr/services/sofa_price_calculator.dart';
import 'package:timberr/models/personalization_data.dart';

extension PersonalizationPricing on PersonalizationController {
  /// Get the current pricing for the personalization data
  SofaPricing get currentPricing {
    return SofaPriceCalculator.calculatePrice(personalizationData);
  }
  
  /// Get the formatted total price
  String get formattedTotalPrice {
    return SofaPriceCalculator.formatPrice(currentPricing.totalPrice);
  }
  
  /// Get the formatted base price
  String get formattedBasePrice {
    return SofaPriceCalculator.formatPrice(currentPricing.basePrice);
  }
  
  /// Get the formatted options price
  String get formattedOptionsPrice {
    return SofaPriceCalculator.formatPrice(currentPricing.optionsPrice);
  }
  
  /// Get price summary string
  String get priceSummary {
    return SofaPriceCalculator.getPriceSummary(currentPricing);
  }
  
  /// Check if the current price is above a certain threshold
  bool isPriceAbove(double threshold) {
    return currentPricing.totalPrice > threshold;
  }
  
  /// Get the price difference from base price
  double get priceIncrease {
    return currentPricing.optionsPrice;
  }
  
  /// Get percentage increase from base price
  double get priceIncreasePercentage {
    if (currentPricing.basePrice == 0) return 0;
    return (currentPricing.optionsPrice / currentPricing.basePrice) * 100;
  }
  
  /// Get the most expensive category in breakdown
  String? get mostExpensiveCategory {
    if (currentPricing.breakdown.isEmpty) return null;
    
    final grouped = currentPricing.groupedBreakdown;
    String? maxCategory;
    double maxPrice = 0;
    
    for (final entry in grouped.entries) {
      if (entry.key == 'Base Sofa') continue;
      
      final categoryTotal = currentPricing.getCategoryTotal(entry.key);
      if (categoryTotal > maxPrice) {
        maxPrice = categoryTotal;
        maxCategory = entry.key;
      }
    }
    
    return maxCategory;
  }
  
  /// Get price breakdown for a specific category
  List<PriceBreakdown> getPriceBreakdownForCategory(String category) {
    return currentPricing.breakdown
        .where((item) => item.category == category)
        .toList();
  }
  
  /// Get all categories with their totals
  Map<String, double> get categoryTotals {
    final Map<String, double> totals = {};
    
    for (final item in currentPricing.breakdown) {
      totals[item.category] = (totals[item.category] ?? 0) + item.price;
    }
    
    return totals;
  }
  
  /// Check if any premium materials are selected
  bool get hasPremiumMaterials {
    final styleMaterial = personalizationData.styleMaterial;
    if (styleMaterial?.materialType == null) return false;
    
    final premiumMaterials = [
      MaterialType.fullGrain,
      MaterialType.alcantara,
      MaterialType.velvet,
    ];
    
    return premiumMaterials.contains(styleMaterial!.materialType);
  }
  
  /// Check if any luxury features are selected
  bool get hasLuxuryFeatures {
    final niceToHaves = personalizationData.niceToHaves;
    if (niceToHaves?.extras == null) return false;
    
    const luxuryFeatures = [
      'built_in_speakers',
      'wireless_charging',
      'led_lighting',
    ];
    
    return niceToHaves!.extras!.any((extra) => luxuryFeatures.contains(extra));
  }
  
  /// Get pricing tier based on total price
  PricingTier get pricingTier {
    final total = currentPricing.totalPrice;
    
    if (total < 1500000) {
      return PricingTier.budget;
    } else if (total < 2500000) {
      return PricingTier.mid;
    } else if (total < 4000000) {
      return PricingTier.premium;
    } else {
      return PricingTier.luxury;
    }
  }
  
  /// Get pricing tier description
  String get pricingTierDescription {
    switch (pricingTier) {
      case PricingTier.budget:
        return 'Essential';
      case PricingTier.mid:
        return 'Comfort';
      case PricingTier.premium:
        return 'Premium';
      case PricingTier.luxury:
        return 'Luxury';
    }
  }
  
  /// Get estimated delivery time based on options complexity
  String get estimatedDeliveryTime {
    final complexity = _calculateComplexityScore();
    
    if (complexity < 5) {
      return '6-8 weeks';
    } else if (complexity < 10) {
      return '8-12 weeks';
    } else if (complexity < 15) {
      return '12-16 weeks';
    } else {
      return '16-20 weeks';
    }
  }
  
  /// Calculate complexity score based on selected options
  int _calculateComplexityScore() {
    int score = 0;
    
    // Base complexity
    if (personalizationData.audienceType == AudienceType.pet) score += 2;
    if (personalizationData.audienceType == AudienceType.child) score += 1;
    
    // Material complexity
    final styleMaterial = personalizationData.styleMaterial;
    if (styleMaterial?.materialType != null) {
      switch (styleMaterial!.materialType!) {
        case MaterialType.fullGrain:
        case MaterialType.alcantara:
          score += 3;
          break;
        case MaterialType.velvet:
        case MaterialType.semiAniline:
          score += 2;
          break;
        default:
          score += 1;
      }
    }
    
    // Additional features complexity
    if (styleMaterial?.functionalityTypes?.isNotEmpty == true) {
      score += styleMaterial!.functionalityTypes!.length;
    }
    
    // Custom details complexity
    final details = personalizationData.personalizationDetails;
    if (details?.patternType != null) score += 1;
    if (details?.stitchingType == StitchingType.hand) score += 2;
    if (details?.stitchingType == StitchingType.contrast) score += 1;
    
    // Nice to haves complexity
    final niceToHaves = personalizationData.niceToHaves;
    if (niceToHaves?.extras?.isNotEmpty == true) {
      score += niceToHaves!.extras!.length;
    }
    if (niceToHaves?.modularExpandable == true) score += 2;
    
    return score;
  }
}

enum PricingTier {
  budget,
  mid,
  premium,
  luxury,
}