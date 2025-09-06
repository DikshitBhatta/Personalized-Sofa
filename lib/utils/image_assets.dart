import 'package:timberr/models/personalization_data.dart' as personalization;

/// Centralized image asset helpers for materials, patterns and finishing details.
/// Example: ImageAssets.pattern(personalization.PatternType.check)
class ImageAssets {
  // Patterns
  static String pattern(personalization.PatternType type) {
    switch (type) {
      case personalization.PatternType.check:
        return 'assets/materials/pattern/check_pattern.jpeg';
      case personalization.PatternType.herringbone:
        return 'assets/materials/pattern/Herringbone_pattern.jpg';
      case personalization.PatternType.jacquard:
        return 'assets/materials/pattern/jacquard_pattern.jpg';
      case personalization.PatternType.stripe:
        return 'assets/materials/pattern/stripe_pattern.jpg';
    }
  }

  // Stitching
  static String stitching(personalization.StitchingType type) {
    switch (type) {
      case personalization.StitchingType.double:
        return 'assets/materials/stetching/double_stitching.jpg';
      case personalization.StitchingType.contrast:
        return 'assets/materials/stetching/contrast.jpg';
      case personalization.StitchingType.hand:
        return 'assets/materials/stetching/hand_stitching.jpg';
    }
  }

  // Legs
  static String leg(personalization.LegType type) {
    switch (type) {
      case personalization.LegType.walnut:
        return 'assets/materials/legs/walnut_leg.jpeg';
      case personalization.LegType.oak:
        return 'assets/materials/legs/oak_leg.jpg';
      case personalization.LegType.ash:
        return 'assets/materials/legs/Ash_leg.jpg';
      case personalization.LegType.steel:
        return 'assets/materials/legs/steel_leg.jpg';
      case personalization.LegType.bronze:
        return 'assets/materials/legs/bronze_leg.jpg';
    }
  }

  // Finish
  static String finish(personalization.FinishType type) {
    switch (type) {
      case personalization.FinishType.matte:
        return 'assets/materials/finish/matte_finish.jpg';
      case personalization.FinishType.gloss:
        return 'assets/materials/finish/gloss_finish.png';
      case personalization.FinishType.oil:
        return 'assets/materials/finish/oil_finish.jpeg';
    }
  }

  // Fabrics (used in MaterialGrid)
  static String fabric(personalization.MaterialType type) {
    switch (type) {
      case personalization.MaterialType.fullGrain:
        return 'assets/fabrics/Full_grain_leather.jpg';
      case personalization.MaterialType.semiAniline:
        return 'assets/fabrics/Semi_aniline.png';
      case personalization.MaterialType.nubuck:
        return 'assets/fabrics/nubuck.jpg';
      case personalization.MaterialType.pu:
        return 'assets/fabrics/PU_leather.jpg';
      case personalization.MaterialType.cotton:
        return 'assets/fabrics/cotton.jpg';
      case personalization.MaterialType.linen:
        return 'assets/fabrics/Linen.jpg';
      case personalization.MaterialType.velvet:
        return 'assets/fabrics/velvet.jpg';
      case personalization.MaterialType.alcantara:
        return 'assets/fabrics/alcantara.jpeg';
      case personalization.MaterialType.ecoFabric:
        return 'assets/fabrics/eco_fabric.jpg';
    }
  }
}
