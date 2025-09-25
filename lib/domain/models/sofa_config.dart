import 'package:flutter/foundation.dart';
import 'dart:math' as math;
    
class SofaConfig {
  final String targetUser;
  final String usageStyle;
  final String seatingFeel;
  final String capacity;
  final String material;
  final List<String> features;
  final String color;
  final String pattern;
  final String stitching;
  final String legs;

  SofaConfig({
    required this.targetUser,
    required this.usageStyle,
    required this.seatingFeel,
    required this.capacity,
    required this.material,
    required this.features,
    required this.color,
    required this.pattern,
    required this.stitching,
    required this.legs,
  });

  String toPreviewPrompt() {
    // Convert hex color to English name
    final colorName = _getColorName(color);
    debugPrint('SofaConfig: Converting color "$color" to "$colorName"');
    
    // Generate bullet-point prompt for better structure
    final featuresText = features.isNotEmpty ? features.join(', ') + ' treatment' : 'standard treatment';
    final seatDepth = _getSeatDepthSpec(seatingFeel);
    final patternDesc = _getPatternDescription(pattern);
    final usageDesc = _getUsageStyleDescription(usageStyle);
    
    final prompt = '''Generate a 3D model of a personalized luxury sofa.
- Target: ${_getTargetUserDescription(targetUser)}.
- Usage: $usageDesc, comfortable and spacious.
- Feel: $seatingFeel cushions, $seatDepth seat depth.
- Capacity: $capacity-seater arrangement.
- Material: $colorName $material upholstery.
- Features: $featuresText.
- Color: Base $colorName, applied evenly.
- Pattern: $patternDesc with surface detail.
- Stitching: $stitching seams for detail.
- Legs: $legs, natural and premium.
- Style: Photorealistic, PBR-ready rendering.
- Lighting: Neutral studio, soft shadows.''';
    
    debugPrint('SofaConfig: Generated preview prompt: $prompt');
    
    // Trim to max 600 characters as per Meshy API limit
    final finalPrompt = prompt.length > 600 ? prompt.substring(0, 600) : prompt;
    debugPrint('SofaConfig: Final preview prompt (${finalPrompt.length} chars): $finalPrompt');
    return finalPrompt;
  }

  String toRefineTexturePrompt() {
    // Convert hex color to English name
    final colorName = _getColorName(color);
    debugPrint('SofaConfig: Converting color "$color" to "$colorName" for texture refinement');
    
    // Generate detailed texture refinement prompt
    final featuresText = features.isNotEmpty ? features.join(', ') + ' treatment' : 'standard treatment';
    final patternDesc = _getPatternTextureDescription(pattern);
    final ergonomics = _getErgonomicsDescription(seatingFeel);
    
    final prompt = '''Photorealistic luxury sofa texture refinement.
- Target user: ${_getTargetUserDescription(targetUser)}.
- Ergonomics: $ergonomics with lumbar support.
- Upholstery: Rich $colorName $material with $patternDesc.
- Protective: $featuresText provides protection.
- Stitching: Premium $stitching seams for strength.
- Legs: Solid $legs with natural grain detail.
- Style: Photorealistic, detailed surface quality.
- Lighting: Neutral studio, soft directional shadows to highlight texture.''';
    
    debugPrint('SofaConfig: Generated refine prompt: $prompt');
    
    // Trim to max 600 characters as per Meshy API limit
    final finalPrompt = prompt.length > 600 ? prompt.substring(0, 600) : prompt;
    debugPrint('SofaConfig: Final refine prompt (${finalPrompt.length} chars): $finalPrompt');
    return finalPrompt;
  }

  // Helper methods for better descriptions
  String _getTargetUserDescription(String targetUser) {
    switch (targetUser.toLowerCase()) {
      case 'adult':
        return 'Adult user, balanced sitting habits';
      case 'child':
        return 'Child-friendly design, safety-focused';
      case 'pet':
        return 'Pet-friendly household, durable materials';
      default:
        return 'Adult user, balanced sitting habits';
    }
  }

  String _getSeatDepthSpec(String seatingFeel) {
    switch (seatingFeel.toLowerCase()) {
      case 'soft':
        return 'deep (~55cm)';
      case 'firm':
        return 'medium (~50cm)';
      case 'balanced':
        return 'medium (~52cm)';
      default:
        return 'medium (~52cm)';
    }
  }

  String _getPatternDescription(String pattern) {
    switch (pattern.toLowerCase()) {
      case 'plain':
        return 'plain weave';
      case 'jacquard':
        return 'jacquard weave';
      case 'textured':
        return 'pebbled grain';
      case 'geometric':
        return 'geometric pattern';
      default:
        return pattern;
    }
  }

  String _getPatternTextureDescription(String pattern) {
    switch (pattern.toLowerCase()) {
      case 'plain':
        return 'plain weave with visible texture';
      case 'jacquard':
        return 'jacquard weave with visible thread depth';
      case 'textured':
        return 'pebbled grain with tactile surface';
      case 'geometric':
        return 'geometric pattern with defined edges';
      default:
        return '$pattern texture with surface detail';
    }
  }

  String _getUsageStyleDescription(String usageStyle) {
    switch (usageStyle.toLowerCase()) {
      case 'family':
        return 'family living';
      case 'hosting':
        return 'formal hosting';
      case 'lounging':
        return 'casual lounging';
      case 'work':
        return 'office work';
      default:
        return '$usageStyle living';
    }
  }

  String _getErgonomicsDescription(String seatingFeel) {
    switch (seatingFeel.toLowerCase()) {
      case 'soft':
        return 'Deep seat depth (~55cm), soft cushion density, supportive backrest';
      case 'firm':
        return 'Medium seat depth (~50cm), firm cushion density, structured backrest';
      case 'balanced':
        return 'Medium seat depth (~52cm), balanced cushion density, supportive backrest';
      default:
        return 'Medium seat depth (~52cm), balanced cushion density, supportive backrest';
    }
  }

  String _getColorName(String color) {
    // If it's already an English color name, return as-is
    if (!color.startsWith('#')) {
      return color;
    }

    // First, check for exact matches with preset colors from the UI
    final exactMatches = {
      // Neutrals
      '#2C2C2C': 'charcoal',
      '#D3D3D3': 'light gray',
      '#F5F5F5': 'off white',
      '#A0522D': 'sienna brown',
      '#8B4513': 'saddle brown',
      
      // Earth Tones  
      '#CD853F': 'peru brown',
      '#D2691E': 'chocolate',
      '#800000': 'maroon',
      '#8B0000': 'dark red',
      '#B22222': 'fire brick red',
      
      // Luxe Reds & Wines
      '#DC143C': 'crimson',
      '#228B22': 'forest green',
      '#6B8E23': 'olive drab',
      '#556B2F': 'dark olive green',
      '#191970': 'midnight blue',
      
      // Blues
      '#000080': 'navy',
      '#0000CD': 'medium blue',
      '#4169E1': 'royal blue',
      '#9932CC': 'dark orchid',
      '#8A2BE2': 'blue violet',
      
      // Purples
      '#4B0082': 'indigo',
      '#6A5ACD': 'slate blue',
      '#7B68EE': 'medium slate blue',
      '#B8860B': 'dark goldenrod',
      '#DAA520': 'goldenrod',
    };

    final upperColor = color.toUpperCase();
    if (exactMatches.containsKey(upperColor)) {
      final result = exactMatches[upperColor]!;
      debugPrint('_getColorName: Exact match $color -> $result');
      return result;
    }

    // Convert hex to RGB values for pattern matching
    final hex = color.substring(1); // Remove #
    final int r = int.parse(hex.substring(0, 2), radix: 16);
    final int g = int.parse(hex.substring(2, 4), radix: 16);
    final int b = int.parse(hex.substring(4, 6), radix: 16);

    debugPrint('_getColorName: Pattern matching $color -> R:$r G:$g B:$b');

    // Pattern-based matching for custom colors
    
    // Pure whites and very light colors
    if (r > 240 && g > 240 && b > 240) return 'white';
    if (r > 230 && g > 230 && b > 230) return 'cream';
    
    // Pure blacks and very dark colors
    if (r < 20 && g < 20 && b < 20) return 'black';
    if (r < 50 && g < 50 && b < 50) return 'charcoal';
    
    // Reds - check red dominance first
    if (r > math.max(g, b) + 50) {
      if (r > 200 && g < 100 && b < 100) return 'bright red';
      if (r > 150 && g < 80 && b < 80) return 'red';
      if (r > 100 && g < 50 && b < 50) return 'dark red';
      if (r >= 80 && g <= 30 && b <= 30) return 'maroon';
    }
    
    // Blues - check blue dominance
    if (b > math.max(r, g) + 30) {
      if (b > 200) return 'bright blue';
      if (b > 150) return 'blue';
      if (b > 100) return 'navy blue';
      return 'dark blue';
    }
    
    // Greens - check green dominance
    if (g > math.max(r, b) + 30) {
      if (g > 200) return 'bright green';
      if (g > 150) return 'green';
      if (g > 100) return 'forest green';
      return 'dark green';
    }
    
    // Purples and violets - high red and blue, low green
    if (r > 100 && b > 100 && g < math.min(r, b) - 20) {
      if (r > 150 && b > 150) return 'purple';
      return 'dark purple';
    }
    
    // Yellows and oranges - high red and green
    if (r > 150 && g > 150 && b < 100) {
      if (r > g + 50) return 'orange';
      return 'yellow';
    }
    
    // Browns - red dominance with moderate green
    if (r > g && r > b && g > 50 && g < r - 30) {
      if (r > 160 && g > 120 && b < 80) return 'tan';
      if (r > 130 && g > 80 && b < 80) return 'brown';
      if (r > 100 && g > 70 && b < 70) return 'dark brown';
    }
    
    // Grays - balanced RGB values (check these last)
    final maxDiff = math.max(math.max(abs(r - g), abs(r - b)), abs(g - b));
    if (maxDiff < 30) {
      if (r < 80) return 'dark gray';
      if (r < 150) return 'gray';
      if (r < 220) return 'light gray';
      return 'very light gray';
    }
    
    // Fallback - return the hex code if no match
    debugPrint('_getColorName: No pattern match for $color, returning as-is');
    return color;
  }

  // Helper function for absolute value
  int abs(int value) => value < 0 ? -value : value;
}
