import 'package:flutter/foundation.dart';
import 'package:timberr/utils/color_tone_detector.dart';
    
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
    // Convert hex color to color name with tone (e.g., "light blue", "dark brown")
    final colorDescription = ColorToneDetector.getColorDescription(color);
    debugPrint('SofaConfig: Converting color "$color" to "$colorDescription"');
    
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
- Material: $colorDescription $material upholstery.
- Features: $featuresText.
- Color: Base $colorDescription, applied evenly.
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
    // Convert hex color to color name with tone (e.g., "light blue", "dark brown")
    final colorDescription = ColorToneDetector.getColorDescription(color);
    debugPrint('SofaConfig: Converting color "$color" to "$colorDescription" for texture refinement');
    
    // Generate detailed texture refinement prompt
    final featuresText = features.isNotEmpty ? features.join(', ') + ' treatment' : 'standard treatment';
    final patternDesc = _getPatternTextureDescription(pattern);
    final ergonomics = _getErgonomicsDescription(seatingFeel);
    
    final prompt = '''Photorealistic luxury sofa texture refinement.
- Target user: ${_getTargetUserDescription(targetUser)}.
- Ergonomics: $ergonomics with lumbar support.
- Upholstery: Rich $colorDescription $material with $patternDesc.
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
}
