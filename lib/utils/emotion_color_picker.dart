import 'package:flutter/material.dart';
import 'package:timberr/models/user_onboarding_data.dart';
import 'package:timberr/models/personalization_data.dart' as personalization;

/// Emotion-based color picker that analyzes user preferences
/// and returns a personalized color scheme
class EmotionColorPicker {
  /// Available hues
  static const String hueWhite = 'white';
  static const String hueBlack = 'black';
  static const String hueGray = 'gray';
  static const String hueBeige = 'beige';
  static const String hueBrown = 'brown';
  static const String hueRed = 'red';
  static const String hueOrange = 'orange';
  static const String hueYellow = 'yellow';
  static const String hueGreen = 'green';
  static const String hueBlue = 'blue';
  static const String huePurple = 'purple';

  /// Available tones
  static const String toneLight = 'light';
  static const String toneMid = 'mid';
  static const String toneDark = 'dark';

  /// Calculate emotion-based color from user data
  static EmotionColor calculateColor({
    UserOnboardingData? onboardingData,
    personalization.PersonalizationData? personalizationData,
  }) {
    // Initialize hue scores
    final Map<String, int> hueScores = {
      hueWhite: 0,
      hueBlack: 0,
      hueGray: 0,
      hueBeige: 0,
      hueBrown: 0,
      hueRed: 0,
      hueOrange: 0,
      hueYellow: 0,
      hueGreen: 0,
      hueBlue: 0,
      huePurple: 0,
    };

    if (onboardingData == null) {
      // Return default if no data
      return EmotionColor(hue: hueBeige, tone: toneMid);
    }

    // A) STYLE PRIORS (big signal)
    _applyStylePriors(hueScores, onboardingData.livingStyle);

    // B) PERSONALITY & ENERGY
    _applyPersonalityEnergy(
      hueScores,
      onboardingData.personalityType,
      onboardingData.socialEnergyPreference,
    );

    // C) DESIRED FEELING
    _applyDesiredFeeling(hueScores, onboardingData.livingRoomFeeling);

    // D) COMFORT WORDS
    _applyComfortWords(hueScores, onboardingData.comfortWords);

    // E) USAGE & HOSTING
    _applyUsageHosting(
      hueScores,
      onboardingData.hostingFrequency,
      onboardingData.sofaUsageTime,
    );

    // F) PRACTICAL CONSTRAINTS
    _applyPracticalConstraints(
      hueScores,
      onboardingData.hasPets,
      personalizationData?.styleMaterial?.materialType,
    );

    // Find winning hue
    String winningHue = _getWinningHue(hueScores);

    // Calculate tone
    String tone = _calculateTone(onboardingData, personalizationData, winningHue);

    // Apply safety filters
    final result = _applySafetyFilters(
      winningHue,
      tone,
      onboardingData,
      hueScores,
    );

    return result;
  }

  /// A) Apply style priors
  static void _applyStylePriors(Map<String, int> scores, String? livingStyle) {
    if (livingStyle == null) return;

    final style = livingStyle.toLowerCase();
    
    if (style.contains('contemporary')) {
      scores[hueGray] = scores[hueGray]! + 2;
      scores[hueBeige] = scores[hueBeige]! + 1;
      scores[hueBlue] = scores[hueBlue]! + 1;
    } else if (style.contains('classic')) {
      scores[hueBeige] = scores[hueBeige]! + 2;
      scores[hueBrown] = scores[hueBrown]! + 1;
      scores[hueGreen] = scores[hueGreen]! + 1;
    } else if (style.contains('minimal')) {
      scores[hueWhite] = scores[hueWhite]! + 2;
      scores[hueGray] = scores[hueGray]! + 2;
    } else if (style.contains('eclectic')) {
      scores[hueOrange] = scores[hueOrange]! + 1;
      scores[hueYellow] = scores[hueYellow]! + 1;
      scores[huePurple] = scores[huePurple]! + 1;
      scores[hueBlue] = scores[hueBlue]! + 1;
    } else if (style.contains('coastal') || style.contains('resort')) {
      scores[hueBlue] = scores[hueBlue]! + 2;
      scores[hueWhite] = scores[hueWhite]! + 1;
      scores[hueBeige] = scores[hueBeige]! + 1;
      scores[hueGreen] = scores[hueGreen]! + 1;
    } else if (style.contains('transitional')) {
      scores[hueBeige] = scores[hueBeige]! + 2;
      scores[hueGray] = scores[hueGray]! + 1;
      scores[hueBlue] = scores[hueBlue]! + 1;
    }
  }

  /// B) Apply personality & energy
  static void _applyPersonalityEnergy(
    Map<String, int> scores,
    String? personality,
    String? energy,
  ) {
    final p = personality?.toLowerCase() ?? '';
    final e = energy?.toLowerCase() ?? '';

    if (p.contains('introvert') || e.contains('quiet')) {
      scores[hueGreen] = scores[hueGreen]! + 1;
      scores[hueBlue] = scores[hueBlue]! + 1;
      scores[hueBeige] = scores[hueBeige]! + 1;
    } else if (p.contains('extrovert') || e.contains('lively')) {
      scores[hueOrange] = scores[hueOrange]! + 1;
      scores[hueYellow] = scores[hueYellow]! + 1;
      scores[hueRed] = scores[hueRed]! + 1;
      scores[huePurple] = scores[huePurple]! + 1;
    } else if (p.contains('balanced')) {
      scores[hueGray] = scores[hueGray]! + 1;
      scores[hueBeige] = scores[hueBeige]! + 1;
    }
  }

  /// C) Apply desired feeling
  static void _applyDesiredFeeling(Map<String, int> scores, String? feeling) {
    if (feeling == null) return;

    final f = feeling.toLowerCase();

    if (f.contains('cozy') || f.contains('relaxed')) {
      scores[hueBeige] = scores[hueBeige]! + 2;
      scores[hueBrown] = scores[hueBrown]! + 1;
      scores[hueGreen] = scores[hueGreen]! + 1;
    } else if (f.contains('elegant') || f.contains('grand')) {
      scores[hueBlack] = scores[hueBlack]! + 1;
      scores[huePurple] = scores[huePurple]! + 1;
      scores[hueBeige] = scores[hueBeige]! + 1;
    } else if (f.contains('bright') || f.contains('lively')) {
      scores[hueYellow] = scores[hueYellow]! + 2;
      scores[hueOrange] = scores[hueOrange]! + 1;
      scores[hueGreen] = scores[hueGreen]! + 1;
    } else if (f.contains('calm') || f.contains('balanced')) {
      scores[hueBlue] = scores[hueBlue]! + 2;
      scores[hueGreen] = scores[hueGreen]! + 1;
      scores[hueGray] = scores[hueGray]! + 1;
    }
  }

  /// D) Apply comfort words
  static void _applyComfortWords(Map<String, int> scores, List<String> words) {
    for (final word in words) {
      final w = word.toLowerCase();

      if (w.contains('cozy')) {
        scores[hueBeige] = scores[hueBeige]! + 1;
        scores[hueBrown] = scores[hueBrown]! + 1;
      } else if (w.contains('elegant')) {
        scores[hueBeige] = scores[hueBeige]! + 1;
        scores[hueBlack] = scores[hueBlack]! + 1;
        scores[huePurple] = scores[huePurple]! + 1;
      } else if (w.contains('supportive') || w.contains('firm')) {
        scores[hueGray] = scores[hueGray]! + 1;
        scores[hueBrown] = scores[hueBrown]! + 1;
      } else if (w.contains('inviting')) {
        scores[hueGreen] = scores[hueGreen]! + 1;
        scores[hueBeige] = scores[hueBeige]! + 1;
      } else if (w.contains('grand')) {
        scores[huePurple] = scores[huePurple]! + 1;
        scores[hueBlack] = scores[hueBlack]! + 1;
      }
    }
  }

  /// E) Apply usage & hosting
  static void _applyUsageHosting(
    Map<String, int> scores,
    String? hosting,
    String? usage,
  ) {
    final h = hosting?.toLowerCase() ?? '';

    if (h.contains('frequently') || h.contains('very often')) {
      scores[hueBeige] = scores[hueBeige]! + 1;
      scores[hueGray] = scores[hueGray]! + 1;
    }

    final u = usage?.toLowerCase() ?? '';

    if (u.contains('family') || u.contains('kids')) {
      scores[hueBeige] = scores[hueBeige]! + 1;
      scores[hueGray] = scores[hueGray]! + 1;
      scores[hueBrown] = scores[hueBrown]! + 1;
    } else if (u.contains('lounging')) {
      scores[hueGreen] = scores[hueGreen]! + 1;
      scores[hueBlue] = scores[hueBlue]! + 1;
    }
  }

  /// F) Apply practical constraints
  static void _applyPracticalConstraints(
    Map<String, int> scores,
    bool? hasPets,
    personalization.MaterialType? material,
  ) {
    // Pets constraint
    if (hasPets == true) {
      scores[hueWhite] = scores[hueWhite]! - 3;
      scores[hueYellow] = scores[hueYellow]! - 1;
      scores[hueBrown] = scores[hueBrown]! + 1;
      scores[hueGray] = scores[hueGray]! + 1;
      scores[hueBeige] = scores[hueBeige]! + 1;
    }

    // Material constraint
    if (material != null) {
      final materialName = material.toString().split('.').last.toLowerCase();

      if (materialName.contains('linen')) {
        scores[hueGreen] = scores[hueGreen]! + 1;
        scores[hueBeige] = scores[hueBeige]! + 1;
        scores[hueBlue] = scores[hueBlue]! + 1;
      } else if (materialName.contains('velvet')) {
        scores[huePurple] = scores[huePurple]! + 1;
        scores[hueBlue] = scores[hueBlue]! + 1;
        scores[hueGreen] = scores[hueGreen]! + 1;
      } else if (materialName.contains('leather')) {
        scores[hueBrown] = scores[hueBrown]! + 2;
        scores[hueBlack] = scores[hueBlack]! + 1;
        scores[hueGray] = scores[hueGray]! + 1;
      }
    }
  }

  /// Get winning hue from scores
  static String _getWinningHue(Map<String, int> scores) {
    int maxScore = scores.values.reduce((a, b) => a > b ? a : b);
    
    // Find all hues with max score
    final winners = scores.entries
        .where((e) => e.value == maxScore)
        .map((e) => e.key)
        .toList();

    // If tie, prefer neutrals unless it's vibrant context
    if (winners.length > 1) {
      for (final neutral in [hueBeige, hueGray, hueBrown]) {
        if (winners.contains(neutral)) {
          return neutral;
        }
      }
    }

    return winners.first;
  }

  /// Calculate tone based on context
  static String _calculateTone(
    UserOnboardingData onboarding,
    personalization.PersonalizationData? personalizationData,
    String hue,
  ) {
    final feeling = onboarding.livingRoomFeeling?.toLowerCase() ?? '';
    final material = personalizationData?.styleMaterial?.materialType
        .toString()
        .split('.')
        .last
        .toLowerCase();

    // Bright & lively → light
    if (feeling.contains('bright') || feeling.contains('lively')) {
      return toneLight;
    }

    // Elegant/Grand OR leather → dark
    if (feeling.contains('elegant') ||
        feeling.contains('grand') ||
        material?.contains('leather') == true) {
      return toneDark;
    }

    // Default to mid
    String tone = toneMid;

    // Clamp for pets/kids on light hues
    if (onboarding.hasPets == true && (hue == hueWhite || hue == hueYellow)) {
      tone = toneDark;
    }

    return tone;
  }

  /// Apply safety filters
  static EmotionColor _applySafetyFilters(
    String hue,
    String tone,
    UserOnboardingData onboarding,
    Map<String, int> scores,
  ) {
    String finalHue = hue;
    String finalTone = tone;

    final style = onboarding.livingStyle?.toLowerCase() ?? '';
    final hosting = onboarding.hostingFrequency?.toLowerCase() ?? '';

    // If white and (pets OR frequent hosting), fallback to beige
    if (finalHue == hueWhite &&
        (onboarding.hasPets == true ||
            hosting.contains('frequently') ||
            hosting.contains('very often'))) {
      finalHue = hueBeige;
      if (finalTone == toneDark) finalTone = toneMid;
    }

    // If black and coastal/minimal, fallback to gray
    if (finalHue == hueBlack &&
        (style.contains('coastal') || style.contains('minimal'))) {
      finalHue = hueGray;
      finalTone = toneDark;
    }

    return EmotionColor(hue: finalHue, tone: finalTone);
  }

  /// Convert emotion color to Flutter Color
  static Color getFlutterColor(EmotionColor emotionColor) {
    return _hueToColor(emotionColor.hue, emotionColor.tone);
  }

  /// Get gradient colors for the section
  static List<Color> getGradientColors(EmotionColor emotionColor) {
    final baseColor = getFlutterColor(emotionColor);
    
    return [
      _lighten(baseColor, 0.2),
      baseColor,
      _darken(baseColor, 0.2),
    ];
  }

  /// Convert hue and tone to Color
  static Color _hueToColor(String hue, String tone) {
    // Base colors for each hue
    final Map<String, Map<String, Color>> colorMap = {
      hueWhite: {
        toneLight: const Color(0xFFFFFFF5),
        toneMid: const Color(0xFFFAFAF0),
        toneDark: const Color(0xFFF0F0E8),
      },
      hueBlack: {
        toneLight: const Color(0xFF4A4A4A),
        toneMid: const Color(0xFF2D2D2D),
        toneDark: const Color(0xFF1A1A1A),
      },
      hueGray: {
        toneLight: const Color(0xFFD0D0D0),
        toneMid: const Color(0xFF909090),
        toneDark: const Color(0xFF505050),
      },
      hueBeige: {
        toneLight: const Color(0xFFF5E6D3),
        toneMid: const Color(0xFFD4B896),
        toneDark: const Color(0xFFA68A64),
      },
      hueBrown: {
        toneLight: const Color(0xFFD7B49E),
        toneMid: const Color(0xFF8B6F47),
        toneDark: const Color(0xFF5D4E37),
      },
      hueRed: {
        toneLight: const Color(0xFFFFB3B3),
        toneMid: const Color(0xFFD64545),
        toneDark: const Color(0xFF8B2F2F),
      },
      hueOrange: {
        toneLight: const Color(0xFFFFD4A3),
        toneMid: const Color(0xFFE67E22),
        toneDark: const Color(0xFFA85A1A),
      },
      hueYellow: {
        toneLight: const Color(0xFFFFF9C4),
        toneMid: const Color(0xFFFFD54F),
        toneDark: const Color(0xFFB8941F),
      },
      hueGreen: {
        toneLight: const Color(0xFFC8E6C9),
        toneMid: const Color(0xFF66BB6A),
        toneDark: const Color(0xFF2E7D32),
      },
      hueBlue: {
        toneLight: const Color(0xFFB3D9E6),
        toneMid: const Color(0xFF5DADE2),
        toneDark: const Color(0xFF2874A6),
      },
      huePurple: {
        toneLight: const Color(0xFFE1BEE7),
        toneMid: const Color(0xFFAB47BC),
        toneDark: const Color(0xFF6A1B9A),
      },
    };

    return colorMap[hue]?[tone] ?? const Color(0xFFD4B896); // Default beige mid
  }

  /// Lighten a color
  static Color _lighten(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  /// Darken a color
  static Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }
}

/// Represents an emotion-based color with hue and tone
class EmotionColor {
  final String hue;
  final String tone;

  EmotionColor({
    required this.hue,
    required this.tone,
  });

  @override
  String toString() => 'Base color: $hue ($tone)';
}
