class SofaRecommendation {
  final String baseColor;
  final String accentColor;
  final int shade; // 0-100
  final String materialChoice;
  final List<String> featureSet;
  final String patternChoice;
  final String capacityChoice;
  final int seatDepthCm;
  final String cushionDensity;
  final String backSupport; // low/med/high
  final String legs;
  final String stitching;
  final List<String> styleTags;

  SofaRecommendation({
    required this.baseColor,
    required this.accentColor,
    required this.shade,
    required this.materialChoice,
    required this.featureSet,
    required this.patternChoice,
    required this.capacityChoice,
    required this.seatDepthCm,
    required this.cushionDensity,
    required this.backSupport,
    required this.legs,
    required this.stitching,
    required this.styleTags,
  });

  Map<String, dynamic> toJson() {
    return {
      'base_color': baseColor,
      'accent_color': accentColor,
      'shade': shade,
      'material_choice': materialChoice,
      'feature_set': featureSet,
      'pattern_choice': patternChoice,
      'capacity_choice': capacityChoice,
      'seat_depth_cm': seatDepthCm,
      'cushion_density': cushionDensity,
      'back_support': backSupport,
      'legs': legs,
      'stitching': stitching,
      'style_tags': styleTags,
    };
  }

  String generatePreviewPrompt() {
    return '''Generate a 3D model of a personalized sofa.
- Capacity: $capacityChoice; cushion density: $cushionDensity, seat depth ~${seatDepthCm}cm.
- Material: $materialChoice.
- Base color: $baseColor (shade $shade/100); pattern: $patternChoice.
- Legs: $legs; stitching: $stitching.
- Style: photorealistic, clean studio lighting, white background.''';
  }

  String generateRefinePrompt() {
    return '''Photorealistic PBR texture.
- Upholstery: $materialChoice with $patternChoice, realistic weave depth.
- Color: $baseColor shade $shade/100; avoid plastic/flat look.
- Features: ${featureSet.join(", ")}.
- Legs: $legs finish; seams: $stitching.
- Neutral studio lighting; soft shadows to reveal texture.''';
  }
}
