import 'package:timberr/models/personalization_data.dart';

class SofaPriceCalculator {
  // Base price for a standard 2-3 seater sofa
  static const double _basePrice = 1200000.0; // 1.2M THB

  /// Calculates the total price for a personalized sofa
  static SofaPricing calculatePrice(PersonalizationData data) {
    double totalPrice = _basePrice;
    List<PriceBreakdown> breakdown = [];
    
    // Add base price to breakdown
    breakdown.add(PriceBreakdown(
      category: 'Base Sofa',
      item: '2-3 seater, standard fabric, standard foam',
      price: _basePrice,
    ));

    // Step 1: Audience Selection
    totalPrice += _calculateAudiencePrice(data.audienceType, breakdown);

    // Step 2: Usage Style/Health
    totalPrice += _calculateUsageStylePrice(data.usageStyle, data.audienceType, breakdown);

    // Step 3: Style & Material
    totalPrice += _calculateStyleMaterialPrice(data.styleMaterial, breakdown);

    // Step 4: Color & Details
    totalPrice += _calculatePersonalizationDetailsPrice(data.personalizationDetails, breakdown);

    // Step 5: Comfort Preferences
    totalPrice += _calculateComfortPreferencesPrice(data.comfortPreferences, data.audienceType, breakdown);

    // Step 7: Final Preferences
    totalPrice += _calculateFinalPreferencesPrice(data.finalPreferences, breakdown);

    // Step 8: Nice to Haves
    totalPrice += _calculateNiceToHavesPrice(data.niceToHaves, breakdown);

    return SofaPricing(
      totalPrice: totalPrice,
      basePrice: _basePrice,
      breakdown: breakdown,
      personalizationData: data,
    );
  }

  /// Step 1: Audience Selection Pricing
  static double _calculateAudiencePrice(AudienceType? audienceType, List<PriceBreakdown> breakdown) {
    double price = 0;
    
    switch (audienceType) {
      case AudienceType.adult:
        // Adult is included in base price
        break;
      case AudienceType.child:
        price = 50000;
        breakdown.add(PriceBreakdown(
          category: 'Audience',
          item: 'Child (extra safety & soft edges)',
          price: price,
        ));
        break;
      case AudienceType.pet:
        price = 80000;
        breakdown.add(PriceBreakdown(
          category: 'Audience',
          item: 'Pet (durable/pet-friendly build)',
          price: price,
        ));
        break;
      case null:
        break;
    }
    
    return price;
  }

  /// Step 2: Usage Style/Health Pricing
  static double _calculateUsageStylePrice(UsageStyleData? usageStyle, AudienceType? audienceType, List<PriceBreakdown> breakdown) {
    if (usageStyle == null) return 0;
    
    double price = 0;
    
    switch (audienceType) {
      case AudienceType.adult:
        price += _calculateAdultUsagePrice(usageStyle, breakdown);
        break;
      case AudienceType.child:
        price += _calculateChildUsagePrice(usageStyle, breakdown);
        break;
      case AudienceType.pet:
        price += _calculatePetUsagePrice(usageStyle, breakdown);
        break;
      case null:
        break;
    }
    
    return price;
  }

  static double _calculateAdultUsagePrice(UsageStyleData usageStyle, List<PriceBreakdown> breakdown) {
    double price = 0;
    
    // Usage Pattern
    switch (usageStyle.usagePattern) {
      case UsagePattern.lounging:
        price += 40000;
        breakdown.add(PriceBreakdown(category: 'Usage Style', item: 'Lounging', price: 40000));
        break;
      case UsagePattern.formalHosting:
        price += 30000;
        breakdown.add(PriceBreakdown(category: 'Usage Style', item: 'Formal Hosting', price: 30000));
        break;
      case UsagePattern.familyLiving:
        price += 50000;
        breakdown.add(PriceBreakdown(category: 'Usage Style', item: 'Family Living', price: 50000));
        break;
      case null:
        break;
    }
    
    // Firmness Preference
    switch (usageStyle.firmnessPreference) {
      case FirmnessPreference.firm:
        // Included in base
        break;
      case FirmnessPreference.balanced:
        price += 20000;
        breakdown.add(PriceBreakdown(category: 'Seating Feel', item: 'Balanced', price: 20000));
        break;
      case FirmnessPreference.soft:
        price += 30000;
        breakdown.add(PriceBreakdown(category: 'Seating Feel', item: 'Soft', price: 30000));
        break;
      case null:
        break;
    }
    
    // Sofa Capacity
    switch (usageStyle.sofaCapacity) {
      case SofaCapacity.two:
        // Included in base
        break;
      case SofaCapacity.three:
        price += 120000;
        breakdown.add(PriceBreakdown(category: 'Capacity', item: '3 people', price: 120000));
        break;
      case SofaCapacity.fourPlus:
        price += 250000;
        breakdown.add(PriceBreakdown(category: 'Capacity', item: '4+ people', price: 250000));
        break;
      case SofaCapacity.sectional:
        price += 300000;
        breakdown.add(PriceBreakdown(category: 'Capacity', item: 'Sectional', price: 300000));
        break;
      case null:
        break;
    }
    
    // Seat Support
    switch (usageStyle.seatSupport) {
      case SeatSupport.lumbarSupport:
        price += 40000;
        breakdown.add(PriceBreakdown(category: 'Seat Support', item: 'Lumbar Support', price: 40000));
        break;
      case SeatSupport.extraDeep:
        price += 30000;
        breakdown.add(PriceBreakdown(category: 'Seat Support', item: 'Extra Deep Seat', price: 30000));
        break;
      case SeatSupport.standard:
        // Included in base
        break;
      case null:
        break;
    }
    
    return price;
  }

  static double _calculateChildUsagePrice(UsageStyleData usageStyle, List<PriceBreakdown> breakdown) {
    double price = 0;
    
    // Child Usage Type
    switch (usageStyle.childUsageType) {
      case ChildUsageType.readingQuiet:
        price += 20000;
        breakdown.add(PriceBreakdown(category: 'Child Usage', item: 'Reading & Quiet Time', price: 20000));
        break;
      case ChildUsageType.playtimeTV:
        price += 30000;
        breakdown.add(PriceBreakdown(category: 'Child Usage', item: 'Playtime & TV', price: 30000));
        break;
      case ChildUsageType.napRest:
        price += 40000;
        breakdown.add(PriceBreakdown(category: 'Child Usage', item: 'Nap & Rest', price: 40000));
        break;
      case null:
        break;
    }
    
    // Family Priority
    switch (usageStyle.familyPriority) {
      case FamilyPriority.easyClean:
        price += 40000;
        breakdown.add(PriceBreakdown(category: 'Family Priority', item: 'Easy to Clean', price: 40000));
        break;
      case FamilyPriority.edgeSoftness:
        price += 50000;
        breakdown.add(PriceBreakdown(category: 'Family Priority', item: 'Extra Edge Softness', price: 50000));
        break;
      case FamilyPriority.standardComfort:
        // Included in base
        break;
      case null:
        break;
    }
    
    // Number of Children
    if (usageStyle.numberOfChildren != null) {
      switch (usageStyle.numberOfChildren!) {
        case 1:
          // Included in base
          break;
        case 2:
          price += 40000;
          breakdown.add(PriceBreakdown(category: 'Children Count', item: '2 children', price: 40000));
          break;
        default: // 3+
          price += 80000;
          breakdown.add(PriceBreakdown(category: 'Children Count', item: '3+ children', price: 80000));
          break;
      }
    }
    
    // Growth Adaptable
    if (usageStyle.growthAdaptable == true) {
      price += 80000;
      breakdown.add(PriceBreakdown(category: 'Growth Feature', item: 'Adaptable design', price: 80000));
    }
    
    return price;
  }

  static double _calculatePetUsagePrice(UsageStyleData usageStyle, List<PriceBreakdown> breakdown) {
    double price = 0;
    
    // Pet Type
    switch (usageStyle.petType) {
      case PetType.dog:
        price += 40000;
        breakdown.add(PriceBreakdown(category: 'Pet Type', item: 'Dog', price: 40000));
        break;
      case PetType.cat:
        price += 30000;
        breakdown.add(PriceBreakdown(category: 'Pet Type', item: 'Cat', price: 30000));
        break;
      case PetType.other:
        price += 20000;
        breakdown.add(PriceBreakdown(category: 'Pet Type', item: 'Other pet', price: 20000));
        break;
      case null:
        break;
    }
    
    // Pet Size
    switch (usageStyle.petSize) {
      case PetSize.small:
        // Included in base
        break;
      case PetSize.medium:
        price += 20000;
        breakdown.add(PriceBreakdown(category: 'Pet Size', item: 'Medium pet', price: 20000));
        break;
      case PetSize.large:
        price += 40000;
        breakdown.add(PriceBreakdown(category: 'Pet Size', item: 'Large pet', price: 40000));
        break;
      case null:
        break;
    }
    
    // Temperature Sensitivity
    switch (usageStyle.temperatureSensitivity) {
      case TemperatureSensitivity.getscold:
        price += 20000;
        breakdown.add(PriceBreakdown(category: 'Temperature', item: 'Gets cold easily', price: 20000));
        break;
      case TemperatureSensitivity.overheats:
        price += 20000;
        breakdown.add(PriceBreakdown(category: 'Temperature', item: 'Overheats easily', price: 20000));
        break;
      case TemperatureSensitivity.normal:
        // Included in base
        break;
      case null:
        break;
    }
    
    // Height Preference
    switch (usageStyle.heightPreference) {
      case HeightPreference.lowRise:
        price += 40000;
        breakdown.add(PriceBreakdown(category: 'Height', item: 'Low-rise', price: 40000));
        break;
      case HeightPreference.plushPremium:
        price += 60000;
        breakdown.add(PriceBreakdown(category: 'Height', item: 'Plush premium', price: 60000));
        break;
      case null:
        break;
    }
    
    // Pet Usage (Step 2B)
    
    // Number of pets
    if (usageStyle.numberOfPets != null) {
      switch (usageStyle.numberOfPets!) {
        case 1:
          // Included in base
          break;
        case 2:
          price += 30000;
          breakdown.add(PriceBreakdown(category: 'Pet Count', item: '2 pets', price: 30000));
          break;
        default: // 3+
          price += 60000;
          breakdown.add(PriceBreakdown(category: 'Pet Count', item: '3+ pets', price: 60000));
          break;
      }
    }
    
    // Pet Seating Style
    switch (usageStyle.petSeatingStyle) {
      case PetSeatingStyle.layingDown:
        price += 20000;
        breakdown.add(PriceBreakdown(category: 'Pet Seating', item: 'Laying down', price: 20000));
        break;
      case PetSeatingStyle.sitting:
        price += 15000;
        breakdown.add(PriceBreakdown(category: 'Pet Seating', item: 'Sitting', price: 15000));
        break;
      case PetSeatingStyle.standing:
        // Included in base
        break;
      case null:
        break;
    }
    
    // Pet Relax Location
    switch (usageStyle.petRelaxLocation) {
      case PetRelaxLocation.besideFloor:
        // Included in base
        break;
      case PetRelaxLocation.sofaCushions:
        price += 20000;
        breakdown.add(PriceBreakdown(category: 'Pet Location', item: 'On sofa cushions', price: 20000));
        break;
      case PetRelaxLocation.armrestsBackrest:
        price += 30000;
        breakdown.add(PriceBreakdown(category: 'Pet Location', item: 'On armrests/backrest', price: 30000));
        break;
      case PetRelaxLocation.bed:
        price += 25000;
        breakdown.add(PriceBreakdown(category: 'Pet Location', item: 'On bed', price: 25000));
        break;
      case PetRelaxLocation.hiddenSpace:
        price += 15000;
        breakdown.add(PriceBreakdown(category: 'Pet Location', item: 'Hidden space', price: 15000));
        break;
      case null:
        break;
    }
    
    // Wear Level
    switch (usageStyle.wearLevel) {
      case WearLevel.low:
        // Included in base
        break;
      case WearLevel.moderate:
        price += 30000;
        breakdown.add(PriceBreakdown(category: 'Wear Level', item: 'Moderate wear', price: 30000));
        break;
      case WearLevel.high:
        price += 60000;
        breakdown.add(PriceBreakdown(category: 'Wear Level', item: 'High wear', price: 60000));
        break;
      case null:
        break;
    }
    
    // Extra Pet-Friendly
    if (usageStyle.extraPetFriendly == true) {
      price += 80000;
      breakdown.add(PriceBreakdown(category: 'Pet Features', item: 'Extra pet-friendly', price: 80000));
    }
    
    return price;
  }

  /// Step 3: Style & Material Pricing
  static double _calculateStyleMaterialPrice(StyleMaterialData? styleMaterial, List<PriceBreakdown> breakdown) {
    if (styleMaterial == null) return 0;
    
    double price = 0;
    
    // Material pricing
    switch (styleMaterial.materialType) {
      case MaterialType.fullGrain:
        price += 400000;
        breakdown.add(PriceBreakdown(category: 'Material', item: 'Full-grain Leather', price: 400000));
        break;
      case MaterialType.semiAniline:
        price += 300000;
        breakdown.add(PriceBreakdown(category: 'Material', item: 'Semi-aniline Leather', price: 300000));
        break;
      case MaterialType.nubuck:
        price += 280000;
        breakdown.add(PriceBreakdown(category: 'Material', item: 'Nubuck Leather', price: 280000));
        break;
      case MaterialType.pu:
        price += 150000;
        breakdown.add(PriceBreakdown(category: 'Material', item: 'PU Leather', price: 150000));
        break;
      case MaterialType.cotton:
        price += 100000;
        breakdown.add(PriceBreakdown(category: 'Material', item: 'Cotton Fabric', price: 100000));
        break;
      case MaterialType.linen:
        price += 180000;
        breakdown.add(PriceBreakdown(category: 'Material', item: 'Linen Fabric', price: 180000));
        break;
      case MaterialType.velvet:
        price += 350000;
        breakdown.add(PriceBreakdown(category: 'Material', item: 'Velvet Fabric', price: 350000));
        break;
      case MaterialType.alcantara:
        price += 400000;
        breakdown.add(PriceBreakdown(category: 'Material', item: 'Alcantara', price: 400000));
        break;
      case MaterialType.ecoFabric:
        price += 250000;
        breakdown.add(PriceBreakdown(category: 'Material', item: 'Eco-friendly Fabric', price: 250000));
        break;
      case null:
        break;
    }
    
    // Additional Features
    if (styleMaterial.functionalityTypes != null) {
      for (FunctionalityType functionality in styleMaterial.functionalityTypes!) {
        switch (functionality) {
          case FunctionalityType.waterproof:
            price += 60000;
            breakdown.add(PriceBreakdown(category: 'Material Feature', item: 'Waterproof', price: 60000));
            break;
          case FunctionalityType.flameRetardant:
            price += 80000;
            breakdown.add(PriceBreakdown(category: 'Material Feature', item: 'Flame Retardant', price: 80000));
            break;
          case FunctionalityType.antibacterial:
            price += 60000;
            breakdown.add(PriceBreakdown(category: 'Material Feature', item: 'Antibacterial', price: 60000));
            break;
          case FunctionalityType.petResistant:
            price += 120000;
            breakdown.add(PriceBreakdown(category: 'Material Feature', item: 'Pet Resistant', price: 120000));
            break;
        }
      }
    }
    
    return price;
  }

  /// Step 4: Color & Details Pricing
  static double _calculatePersonalizationDetailsPrice(PersonalizationDetails? details, List<PriceBreakdown> breakdown) {
    if (details == null) return 0;
    
    double price = 0;
    
    // Pattern pricing
    switch (details.patternType) {
      case PatternType.check:
        price += 60000;
        breakdown.add(PriceBreakdown(category: 'Pattern', item: 'Check', price: 60000));
        break;
      case PatternType.herringbone:
        price += 80000;
        breakdown.add(PriceBreakdown(category: 'Pattern', item: 'Herringbone', price: 80000));
        break;
      case PatternType.jacquard:
        price += 120000;
        breakdown.add(PriceBreakdown(category: 'Pattern', item: 'Jacquard', price: 120000));
        break;
      case PatternType.stripe:
        price += 80000;
        breakdown.add(PriceBreakdown(category: 'Pattern', item: 'Stripe', price: 80000));
        break;
      case null:
        break;
    }
    
    // Stitching pricing
    switch (details.stitchingType) {
      case StitchingType.double:
        price += 20000;
        breakdown.add(PriceBreakdown(category: 'Stitching', item: 'Double Stitch', price: 20000));
        break;
      case StitchingType.contrast:
        price += 30000;
        breakdown.add(PriceBreakdown(category: 'Stitching', item: 'Contrast Stitch', price: 30000));
        break;
      case StitchingType.hand:
        price += 50000;
        breakdown.add(PriceBreakdown(category: 'Stitching', item: 'Hand Stitching', price: 50000));
        break;
      case null:
        break;
    }
    
    // Leg pricing
    switch (details.legType) {
      case LegType.walnut:
        // Included in base
        break;
      case LegType.oak:
        price += 10000;
        breakdown.add(PriceBreakdown(category: 'Legs', item: 'Oak', price: 10000));
        break;
      case LegType.ash:
        price += 15000;
        breakdown.add(PriceBreakdown(category: 'Legs', item: 'Ash', price: 15000));
        break;
      case LegType.steel:
        price += 30000;
        breakdown.add(PriceBreakdown(category: 'Legs', item: 'Steel', price: 30000));
        break;
      case LegType.bronze:
        price += 40000;
        breakdown.add(PriceBreakdown(category: 'Legs', item: 'Bronze', price: 40000));
        break;
      case null:
        break;
    }
    
    return price;
  }

  /// Step 5: Comfort Preferences Pricing
  static double _calculateComfortPreferencesPrice(ComfortPreferences? comfort, AudienceType? audienceType, List<PriceBreakdown> breakdown) {
    if (comfort == null) return 0;
    
    double price = 0;
    
    // Cushion Firmness
    switch (comfort.cushionFirmness) {
      case 'soft':
        price += 30000;
        breakdown.add(PriceBreakdown(category: 'Comfort', item: 'Soft cushions', price: 30000));
        break;
      case 'medium':
        price += 20000;
        breakdown.add(PriceBreakdown(category: 'Comfort', item: 'Medium cushions', price: 20000));
        break;
      case 'firm':
        // Included in base
        break;
    }
    
    // Seat Depth (for adults)
    if (audienceType == AudienceType.adult) {
      switch (comfort.seatDepth) {
        case 'shallow':
          // Included in base
          break;
        case 'medium':
          price += 20000;
          breakdown.add(PriceBreakdown(category: 'Comfort', item: 'Medium seat depth', price: 20000));
          break;
        case 'deep':
          price += 30000;
          breakdown.add(PriceBreakdown(category: 'Comfort', item: 'Deep seat', price: 30000));
          break;
      }
    }
    
    // Additional comfort features
    if (comfort.backSupport == true) {
      price += 40000;
      breakdown.add(PriceBreakdown(category: 'Comfort', item: 'Extra back support', price: 40000));
    }
    
    if (comfort.armrests == true) {
      price += 30000;
      breakdown.add(PriceBreakdown(category: 'Comfort', item: 'Armrests', price: 30000));
    }
    
    if (comfort.headrest == true) {
      price += 50000;
      breakdown.add(PriceBreakdown(category: 'Comfort', item: 'Adjustable headrest', price: 50000));
    }
    
    if (comfort.tallUsers == true) {
      price += 60000;
      breakdown.add(PriceBreakdown(category: 'Comfort', item: 'Tall user friendly', price: 60000));
    }
    
    if (comfort.elderlyFriendly == true) {
      price += 80000;
      breakdown.add(PriceBreakdown(category: 'Comfort', item: 'Elderly friendly', price: 80000));
    }
    
    return price;
  }

  /// Step 7: Final Preferences Pricing
  static double _calculateFinalPreferencesPrice(FinalPreferences? finalPrefs, List<PriceBreakdown> breakdown) {
    if (finalPrefs == null) return 0;
    
    double price = 0;
    
    // What matters most
    switch (finalPrefs.whatMattersMost) {
      case 'Easy Cleaning':
        price += 40000;
        breakdown.add(PriceBreakdown(category: 'Priority', item: 'Easy Cleaning', price: 40000));
        break;
      case 'Durability':
        price += 60000;
        breakdown.add(PriceBreakdown(category: 'Priority', item: 'Durability', price: 60000));
        break;
      case 'Low Maintenance':
        price += 40000;
        breakdown.add(PriceBreakdown(category: 'Priority', item: 'Low Maintenance', price: 40000));
        break;
    }
    
    // Eco-friendly importance
    if (finalPrefs.ecoFriendly == 'Important') {
      price += 80000;
      breakdown.add(PriceBreakdown(category: 'Eco-friendly', item: 'Important eco-friendliness', price: 80000));
    }
    
    // Washable/Replaceable covers
    if (finalPrefs.washableReplaceableCovers == true) {
      price += 50000;
      breakdown.add(PriceBreakdown(category: 'Features', item: 'Washable/Replaceable covers', price: 50000));
    }
    
    return price;
  }

  /// Step 8: Nice to Haves Pricing
  static double _calculateNiceToHavesPrice(NiceToHaves? niceToHaves, List<PriceBreakdown> breakdown) {
    if (niceToHaves == null) return 0;
    
    double price = 0;
    
    // Extra features
    if (niceToHaves.extras != null) {
      for (String extra in niceToHaves.extras!) {
        switch (extra) {
          case 'usb_charging':
            price += 25000;
            breakdown.add(PriceBreakdown(category: 'Extra Feature', item: 'USB charging ports', price: 25000));
            break;
          case 'cup_holders':
            price += 20000;
            breakdown.add(PriceBreakdown(category: 'Extra Feature', item: 'Cup holders', price: 20000));
            break;
          case 'hidden_storage':
            price += 60000;
            breakdown.add(PriceBreakdown(category: 'Extra Feature', item: 'Hidden storage', price: 60000));
            break;
          case 'wireless_charging':
            price += 25000;
            breakdown.add(PriceBreakdown(category: 'Extra Feature', item: 'Wireless charging pad', price: 25000));
            break;
          case 'built_in_speakers':
            price += 50000;
            breakdown.add(PriceBreakdown(category: 'Extra Feature', item: 'Built-in speakers', price: 50000));
            break;
          case 'led_lighting':
            price += 30000;
            breakdown.add(PriceBreakdown(category: 'Extra Feature', item: 'LED lighting', price: 30000));
            break;
        }
      }
    }
    
    // Modular/Expandable
    if (niceToHaves.modularExpandable == true) {
      price += 100000;
      breakdown.add(PriceBreakdown(category: 'Design Feature', item: 'Modular/Expandable', price: 100000));
    }
    
    return price;
  }

  /// Format price in Thai Baht with commas
  static String formatPrice(double price) {
    return '฿${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  /// Format price in compact format (e.g., ฿1.2M instead of ฿1,200,000)
  static String formatPriceCompact(double price) {
    if (price >= 1000000) {
      // Convert to millions with 1 decimal place if needed
      double millions = price / 1000000;
      if (millions == millions.round()) {
        return '฿${millions.round()}M';
      } else {
        return '฿${millions.toStringAsFixed(1)}M';
      }
    } else if (price >= 1000) {
      // Convert to thousands
      double thousands = price / 1000;
      if (thousands == thousands.round()) {
        return '฿${thousands.round()}K';
      } else {
        return '฿${thousands.toStringAsFixed(0)}K';
      }
    } else {
      return '฿${price.toStringAsFixed(0)}';
    }
  }

  /// Get price summary for display
  static String getPriceSummary(SofaPricing pricing) {
    return 'Total: ${formatPrice(pricing.totalPrice)} (Base: ${formatPrice(pricing.basePrice)} + Options: ${formatPrice(pricing.totalPrice - pricing.basePrice)})';
  }
}

/// Model for price breakdown
class PriceBreakdown {
  final String category;
  final String item;
  final double price;
  
  PriceBreakdown({
    required this.category,
    required this.item,
    required this.price,
  });
}

/// Model for complete sofa pricing
class SofaPricing {
  final double totalPrice;
  final double basePrice;
  final List<PriceBreakdown> breakdown;
  final PersonalizationData personalizationData;
  
  SofaPricing({
    required this.totalPrice,
    required this.basePrice,
    required this.breakdown,
    required this.personalizationData,
  });
  
  double get optionsPrice => totalPrice - basePrice;
  
  /// Group breakdown by category
  Map<String, List<PriceBreakdown>> get groupedBreakdown {
    Map<String, List<PriceBreakdown>> grouped = {};
    for (PriceBreakdown item in breakdown) {
      if (!grouped.containsKey(item.category)) {
        grouped[item.category] = [];
      }
      grouped[item.category]!.add(item);
    }
    return grouped;
  }
  
  /// Get total price for a specific category
  double getCategoryTotal(String category) {
    return breakdown
        .where((item) => item.category == category)
        .fold(0.0, (sum, item) => sum + item.price);
  }
}