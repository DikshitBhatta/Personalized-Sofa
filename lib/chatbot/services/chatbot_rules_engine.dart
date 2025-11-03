import 'package:timberr/models/user_onboarding_data.dart';
import 'package:timberr/models/personalization_data.dart';
import 'package:timberr/chatbot/models/sofa_recommendation.dart';

class ChatbotRulesEngine {
  static SofaRecommendation generateRecommendation({
    required UserOnboardingData onboarding,
    required PersonalizationData personalization,
  }) {
    // A) Capacity & form
    final capacityChoice = _determineCapacity(onboarding, personalization);

    // B) Ergonomics
    final ergonomics = _determineErgonomics(onboarding, personalization);

    // C) Pets & durability
    final materialAndPattern = _determineMaterialAndPattern(onboarding, personalization);

    // D) Safety features
    final features = _determineFeatures(onboarding, personalization);

    // E) Legs & stitching by style
    final decorDetails = _determineDecorDetails(onboarding);

    // F) Color family
    final colorData = _determineColor(onboarding, personalization);

    // G) Style tags
    final styleTags = _determineStyleTags(onboarding);

    return SofaRecommendation(
      baseColor: colorData['baseColor']!,
      accentColor: colorData['accentColor']!,
      shade: colorData['shade']!,
      materialChoice: materialAndPattern['material']!,
      featureSet: features,
      patternChoice: materialAndPattern['pattern']!,
      capacityChoice: capacityChoice,
      seatDepthCm: ergonomics['seatDepth']!,
      cushionDensity: ergonomics['cushionDensity']!,
      backSupport: ergonomics['backSupport']!,
      legs: decorDetails['legs']!,
      stitching: decorDetails['stitching']!,
      styleTags: styleTags,
    );
  }

  // A) Capacity & form
  static String _determineCapacity(
    UserOnboardingData onboarding,
    PersonalizationData personalization,
  ) {
    final hosting = onboarding.hostingFrequency?.toLowerCase() ?? '';
    final arrangement = onboarding.livingArrangement?.toLowerCase() ?? '';
    final homeType = onboarding.homeType?.toLowerCase() ?? '';

    // Check personalization capacity first
    final sofaCapacity = personalization.usageStyle?.sofaCapacity;
    if (sofaCapacity != null) {
      switch (sofaCapacity) {
        case SofaCapacity.two:
          return '2-seater';
        case SofaCapacity.three:
          return '3-seater';
        case SofaCapacity.fourPlus:
          return '4+ seater';
        case SofaCapacity.sectional:
          return 'sectional';
      }
    }

    // Fallback to rules
    if (hosting.contains('frequently') || hosting.contains('very often')) {
      if (arrangement.contains('family')) {
        return 'sectional';
      }
      return '3-seater';
    }

    if ((homeType.contains('apartment') || homeType.contains('loft')) &&
        !hosting.contains('frequent')) {
      return '2-seater';
    }

    return '3-seater'; // default
  }

  // B) Ergonomics
  static Map<String, dynamic> _determineErgonomics(
    UserOnboardingData onboarding,
    PersonalizationData personalization,
  ) {
    String cushionDensity = 'medium';
    int seatDepth = 51;
    String backSupport = 'medium';

    // Check personalization firmness preference
    final firmness = personalization.usageStyle?.firmnessPreference;
    if (firmness != null) {
      switch (firmness) {
        case FirmnessPreference.soft:
          cushionDensity = 'soft';
          seatDepth = 54;
          break;
        case FirmnessPreference.balanced:
          cushionDensity = 'medium';
          seatDepth = 51;
          break;
        case FirmnessPreference.firm:
          cushionDensity = 'firm';
          seatDepth = 49;
          break;
      }
    }

    // Adjust based on usage time
    final usageTime = onboarding.sofaUsageTime?.toLowerCase() ?? '';
    if (usageTime.contains('5') || usageTime.contains('more')) {
      seatDepth += 2;
    } else if (usageTime.contains('1') || usageTime.contains('less')) {
      seatDepth -= 2;
    }

    // Comfort words influence
    final comfortWords = onboarding.comfortWords.map((w) => w.toLowerCase()).toList();
    if (comfortWords.any((w) => w.contains('supportive'))) {
      backSupport = 'high';
    }
    if (comfortWords.any((w) => w.contains('cozy'))) {
      cushionDensity = 'soft';
    }

    return {
      'cushionDensity': cushionDensity,
      'seatDepth': seatDepth,
      'backSupport': backSupport,
    };
  }

  // C) Pets & durability
  static Map<String, String> _determineMaterialAndPattern(
    UserOnboardingData onboarding,
    PersonalizationData personalization,
  ) {
    String material = 'linen';
    String pattern = 'plain';

    final hasPets = onboarding.hasPets ?? false;

    // Check personalization material first
    final materialType = personalization.styleMaterial?.materialType;
    if (materialType != null && !hasPets) {
      material = _mapMaterialEnum(materialType);
    } else if (hasPets) {
      material = 'performance linen';
      pattern = 'herringbone'; // hides hair & marks
    } else {
      final livingStyle = onboarding.livingStyle?.toLowerCase() ?? '';
      if (livingStyle.contains('modern') || livingStyle.contains('minimal')) {
        material = 'linen';
      } else {
        material = 'velvet';
      }
    }

    // Pattern determination
    final comfortWords = onboarding.comfortWords.map((w) => w.toLowerCase()).join(' ');
    final livingStyle = onboarding.livingStyle?.toLowerCase() ?? '';

    if (comfortWords.contains('elegant') ||
        comfortWords.contains('grand') ||
        livingStyle.contains('classic')) {
      pattern = 'jacquard';
    } else if (hasPets || onboarding.hostingFrequency?.toLowerCase().contains('frequent') == true) {
      pattern = 'herringbone';
    } else if (livingStyle.contains('minimal') || livingStyle.contains('modern')) {
      pattern = 'plain';
    }

    // Check personalization pattern
    final personalizationPattern = personalization.personalizationDetails?.patternType;
    if (personalizationPattern != null && !hasPets) {
      pattern = _mapPatternEnum(personalizationPattern);
    }

    return {
      'material': material,
      'pattern': pattern,
    };
  }

  // D) Safety features
  static List<String> _determineFeatures(
    UserOnboardingData onboarding,
    PersonalizationData personalization,
  ) {
    final features = <String>[];

    final hasPets = onboarding.hasPets ?? false;
    if (hasPets) {
      features.addAll(['pet-resistant', 'stain-resistant']);
    }

    // Check personalization functionality types
    final functionalityTypes = personalization.styleMaterial?.functionalityTypes;
    if (functionalityTypes != null) {
      for (var type in functionalityTypes) {
        switch (type) {
          case FunctionalityType.waterproof:
            features.add('waterproof');
            break;
          case FunctionalityType.flameRetardant:
            features.add('flame-retardant');
            break;
          case FunctionalityType.petResistant:
            if (!features.contains('pet-resistant')) {
              features.add('pet-resistant');
            }
            break;
          case FunctionalityType.antibacterial:
            features.add('antibacterial');
            break;
        }
      }
    }

    return features;
  }

  // E) Legs & stitching by style
  static Map<String, String> _determineDecorDetails(UserOnboardingData onboarding) {
    final livingStyle = onboarding.livingStyle?.toLowerCase() ?? '';
    final colorFamily = onboarding.personalTasteWord?.toLowerCase() ?? '';

    String legs;
    String stitching;

    if (livingStyle.contains('classic') || livingStyle.contains('transitional')) {
      legs = (colorFamily.contains('gold') || colorFamily.contains('luxury')) ? 'bronze' : 'oak';
      stitching = 'double';
    } else {
      legs = 'steel';
      stitching = 'single';
    }

    return {
      'legs': legs,
      'stitching': stitching,
    };
  }

  // F) Color family (deterministic map)
  static Map<String, dynamic> _determineColor(
    UserOnboardingData onboarding,
    PersonalizationData personalization,
  ) {
    // Check if user picked a color in personalization
    final userColorHex = personalization.personalizationDetails?.colorHex;
    if (userColorHex != null && userColorHex.isNotEmpty) {
      // User has selected a custom color, use it directly
      final colorName = 'Custom'; // We'll use the hex directly
      final shade = _determineShade(onboarding, colorName);
      return {
        'baseColor': colorName,
        'accentColor': _getAccentColor('Brown'), // Default accent
        'shade': shade,
      };
    }

    // Score-based approach
    final scores = _scoreColors(onboarding);
    final baseColor = scores.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    final shade = _determineShade(onboarding, baseColor);

    return {
      'baseColor': baseColor,
      'accentColor': _getAccentColor(baseColor),
      'shade': shade,
    };
  }

  static Map<String, int> _scoreColors(UserOnboardingData onboarding) {
    final scores = <String, int>{
      'Red': 0,
      'Orange': 0,
      'Yellow': 0,
      'Green': 0,
      'Blue': 0,
      'Purple': 0,
      'Pink': 0,
      'Brown': 0,
      'Silver': 0,
      'Black': 0,
      'White': 0,
      'Gold': 0,
    };

    final feeling = onboarding.livingRoomFeeling?.toLowerCase() ?? '';
    final personality = onboarding.personalityType?.toLowerCase() ?? '';
    final style = onboarding.livingStyle?.toLowerCase() ?? '';
    final comfortWords = onboarding.comfortWords.map((w) => w.toLowerCase()).toList();
    final hasPets = onboarding.hasPets ?? false;

    // Feeling → base
    if (feeling.contains('cozy') || feeling.contains('warm')) {
      scores['Brown'] = scores['Brown']! + 3;
      scores['Gold'] = scores['Gold']! + 2;
    }
    if (feeling.contains('calm') || feeling.contains('minimal')) {
      scores['Blue'] = scores['Blue']! + 3;
      scores['White'] = scores['White']! + 2;
      scores['Silver'] = scores['Silver']! + 1;
    }
    if (feeling.contains('bright') || feeling.contains('lively')) {
      scores['Yellow'] = scores['Yellow']! + 3;
      scores['Orange'] = scores['Orange']! + 2;
    }
    if (feeling.contains('bold') || feeling.contains('expressive')) {
      scores['Red'] = scores['Red']! + 3;
      scores['Purple'] = scores['Purple']! + 2;
    }

    // Personality
    if (personality.contains('introvert')) {
      scores['Blue'] = scores['Blue']! + 2;
      scores['Green'] = scores['Green']! + 1;
      scores['Silver'] = scores['Silver']! + 1;
    }
    if (personality.contains('extrovert')) {
      scores['Red'] = scores['Red']! + 2;
      scores['Orange'] = scores['Orange']! + 1;
      scores['Gold'] = scores['Gold']! + 1;
    }
    if (personality.contains('balanced')) {
      scores['Brown'] = scores['Brown']! + 1;
      scores['Green'] = scores['Green']! + 1;
    }

    // Comfort words
    for (var word in comfortWords) {
      if (word.contains('cozy') || word.contains('inviting')) {
        scores['Brown'] = scores['Brown']! + 2;
      }
      if (word.contains('elegant') || word.contains('grand')) {
        scores['Gold'] = scores['Gold']! + 2;
        scores['Purple'] = scores['Purple']! + 1;
      }
      if (word.contains('supportive') || word.contains('firm')) {
        scores['Blue'] = scores['Blue']! + 2;
        scores['Black'] = scores['Black']! + 1;
      }
    }

    // Pets → avoid ultra-light; boost mid neutrals
    if (hasPets) {
      scores['Brown'] = scores['Brown']! + 1;
      scores['Green'] = scores['Green']! + 1;
      scores['White'] = scores['White']! - 1;
      scores['Pink'] = scores['Pink']! - 1;
    }

    // Living style
    if (style.contains('classic') || style.contains('transitional')) {
      scores['Gold'] = scores['Gold']! + 1;
      scores['Brown'] = scores['Brown']! + 1;
      scores['Purple'] = scores['Purple']! + 1;
    }
    if (style.contains('modern') || style.contains('minimal')) {
      scores['Silver'] = scores['Silver']! + 2;
      scores['Black'] = scores['Black']! + 1;
      scores['Blue'] = scores['Blue']! + 1;
    }

    return scores;
  }

  static int _determineShade(UserOnboardingData onboarding, String color) {
    int shade = 40; // default

    final feeling = onboarding.livingRoomFeeling?.toLowerCase() ?? '';
    final social = onboarding.socialEnergyPreference?.toLowerCase() ?? '';
    final usageTime = onboarding.sofaUsageTime?.toLowerCase() ?? '';
    final hasPets = onboarding.hasPets ?? false;

    if (feeling.contains('minimal') || feeling.contains('calm')) {
      shade = social.contains('quiet') ? 25 : 70;
    }
    if (feeling.contains('cozy') || feeling.contains('warm')) {
      shade = 45;
    }
    if (hasPets && (color == 'Brown' || color == 'Green' || color == 'Gold')) {
      shade = shade < 35 ? 35 : shade;
    }
    if (usageTime.contains('5') || usageTime.contains('more')) {
      shade += 5;
    }

    return shade.clamp(10, 85);
  }

  static String _getAccentColor(String baseColor) {
    const accentMap = {
      'Red': 'Gold',
      'Orange': 'Brown',
      'Yellow': 'White',
      'Green': 'Brown',
      'Blue': 'Silver',
      'Purple': 'Gold',
      'Pink': 'White',
      'Brown': 'Gold',
      'Silver': 'Blue',
      'Black': 'White',
      'White': 'Blue',
      'Gold': 'Brown',
    };

    return accentMap[baseColor] ?? 'White';
  }

  // G) Style tags
  static List<String> _determineStyleTags(UserOnboardingData onboarding) {
    final tags = <String>[];
    final style = onboarding.livingStyle?.toLowerCase() ?? '';
    final feeling = onboarding.livingRoomFeeling?.toLowerCase() ?? '';
    final comfortWords = onboarding.comfortWords.map((w) => w.toLowerCase()).join(' ');

    if (style.contains('classic')) tags.add('Classic');
    if (style.contains('modern')) tags.add('Modern');
    if (style.contains('minimal')) tags.add('Minimal');
    if (feeling.contains('cozy') || comfortWords.contains('cozy')) tags.add('Cozy');
    if (comfortWords.contains('elegant') || comfortWords.contains('grand')) tags.add('Luxury');
    if (style.contains('transitional')) tags.add('Transitional');

    return tags.isEmpty ? ['Contemporary'] : tags;
  }

  // Helper mappers
  static String _mapMaterialEnum(MaterialType materialType) {
    switch (materialType) {
      case MaterialType.linen:
        return 'linen';
      case MaterialType.velvet:
        return 'velvet';
      case MaterialType.fullGrain:
      case MaterialType.semiAniline:
      case MaterialType.nubuck:
      case MaterialType.pu:
        return 'leather';
      case MaterialType.cotton:
        return 'cotton';
      case MaterialType.alcantara:
        return 'alcantara';
      case MaterialType.ecoFabric:
        return 'eco-friendly fabric';
    }
  }

  static String _mapPatternEnum(PatternType pattern) {
    switch (pattern) {
      case PatternType.jacquard:
        return 'jacquard';
      case PatternType.herringbone:
        return 'herringbone';
      case PatternType.stripe:
        return 'striped';
      case PatternType.check:
        return 'checked';
    }
  }
}
