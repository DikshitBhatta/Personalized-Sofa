class PersonalizationData {
  // Step 1: Audience Selection
  AudienceType? audienceType;
  
  // Step 2: Health & Ergonomics
  HealthErgonomicsData? healthErgonomics;
  
  // Step 3: Style & Material Preferences
  StyleMaterialData? styleMaterial;
  
  // Step 4: Color, Pattern & Details
  PersonalizationDetails? personalizationDetails;
  
  // Metadata
  String? sessionId;
  DateTime? createdAt;
  DateTime? updatedAt;
  bool isCompleted;
  
  PersonalizationData({
    this.audienceType,
    this.healthErgonomics,
    this.styleMaterial,
    this.personalizationDetails,
    this.sessionId,
    this.createdAt,
    this.updatedAt,
    this.isCompleted = false,
  });
  
  factory PersonalizationData.fromJson(Map<String, dynamic> json) {
    return PersonalizationData(
      audienceType: json['audience_type'] != null 
          ? AudienceType.values.firstWhere((e) => e.toString().split('.').last == json['audience_type'])
          : null,
      healthErgonomics: json['health_ergonomics'] != null 
          ? HealthErgonomicsData.fromJson(json['health_ergonomics'])
          : null,
      styleMaterial: json['style_material'] != null 
          ? StyleMaterialData.fromJson(json['style_material'])
          : null,
      personalizationDetails: json['personalization_details'] != null 
          ? PersonalizationDetails.fromJson(json['personalization_details'])
          : null,
      sessionId: json['session_id'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      isCompleted: json['is_completed'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'audience_type': audienceType?.toString().split('.').last,
      'health_ergonomics': healthErgonomics?.toJson(),
      'style_material': styleMaterial?.toJson(),
      'personalization_details': personalizationDetails?.toJson(),
      'session_id': sessionId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_completed': isCompleted,
    };
  }
}

enum AudienceType { adult, child, pet }

class HealthErgonomicsData {
  // Adult specific
  double? heightCm;
  double? weightKg;
  SittingHabit? sittingHabit;
  bool? hasBackPain;
  
  // Child specific
  int? ageYears;
  bool? growthConsideration;
  
  // Pet specific
  String? species;
  bool? clawingBehavior;
  bool? allergySensitive;
  
  HealthErgonomicsData({
    this.heightCm,
    this.weightKg,
    this.sittingHabit,
    this.hasBackPain,
    this.ageYears,
    this.growthConsideration,
    this.species,
    this.clawingBehavior,
    this.allergySensitive,
  });
  
  factory HealthErgonomicsData.fromJson(Map<String, dynamic> json) {
    return HealthErgonomicsData(
      heightCm: json['height_cm']?.toDouble(),
      weightKg: json['weight_kg']?.toDouble(),
      sittingHabit: json['sitting_habit'] != null 
          ? SittingHabit.values.firstWhere((e) => e.toString().split('.').last == json['sitting_habit'])
          : null,
      hasBackPain: json['has_back_pain'],
      ageYears: json['age_years'],
      growthConsideration: json['growth_consideration'],
      species: json['species'],
      clawingBehavior: json['clawing_behavior'],
      allergySensitive: json['allergy_sensitive'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'sitting_habit': sittingHabit?.toString().split('.').last,
      'has_back_pain': hasBackPain,
      'age_years': ageYears,
      'growth_consideration': growthConsideration,
      'species': species,
      'clawing_behavior': clawingBehavior,
      'allergy_sensitive': allergySensitive,
    };
  }
}

enum SittingHabit { lounge, balanced, upright }

class StyleMaterialData {
  MaterialType? materialType;
  List<FunctionalityType>? functionalityTypes;
  
  StyleMaterialData({
    this.materialType,
    this.functionalityTypes,
  });
  
  factory StyleMaterialData.fromJson(Map<String, dynamic> json) {
    return StyleMaterialData(
      materialType: json['material_type'] != null 
          ? MaterialType.values.firstWhere((e) => e.toString().split('.').last == json['material_type'])
          : null,
      functionalityTypes: json['functionality_types'] != null 
          ? (json['functionality_types'] as List).map((e) => 
              FunctionalityType.values.firstWhere((type) => type.toString().split('.').last == e)
            ).toList()
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'material_type': materialType?.toString().split('.').last,
      'functionality_types': functionalityTypes?.map((e) => e.toString().split('.').last).toList(),
    };
  }
}

enum MaterialType { 
  fullGrain, 
  semiAniline, 
  nubuck, 
  pu, 
  cotton, 
  linen, 
  velvet, 
  alcantara, 
  ecoFabric 
}

enum FunctionalityType { 
  waterproof, 
  flameRetardant, 
  antibacterial, 
  petResistant 
}

class PersonalizationDetails {
  String? colorHex;
  String? pantoneCode;
  PatternType? patternType;
  StitchingType? stitchingType;
  LegType? legType;
  FinishType? finishType;
  
  PersonalizationDetails({
    this.colorHex,
    this.pantoneCode,
    this.patternType,
    this.stitchingType,
    this.legType,
    this.finishType,
  });
  
  factory PersonalizationDetails.fromJson(Map<String, dynamic> json) {
    return PersonalizationDetails(
      colorHex: json['color_hex'],
      pantoneCode: json['pantone_code'],
      patternType: json['pattern_type'] != null 
          ? PatternType.values.firstWhere((e) => e.toString().split('.').last == json['pattern_type'])
          : null,
      stitchingType: json['stitching_type'] != null 
          ? StitchingType.values.firstWhere((e) => e.toString().split('.').last == json['stitching_type'])
          : null,
      legType: json['leg_type'] != null 
          ? LegType.values.firstWhere((e) => e.toString().split('.').last == json['leg_type'])
          : null,
      finishType: json['finish_type'] != null 
          ? FinishType.values.firstWhere((e) => e.toString().split('.').last == json['finish_type'])
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'color_hex': colorHex,
      'pantone_code': pantoneCode,
      'pattern_type': patternType?.toString().split('.').last,
      'stitching_type': stitchingType?.toString().split('.').last,
      'leg_type': legType?.toString().split('.').last,
      'finish_type': finishType?.toString().split('.').last,
    };
  }
}

enum PatternType { check, herringbone, jacquard, stripe }
enum StitchingType { double, contrast, hand }
enum LegType { walnut, oak, ash, steel, bronze }
enum FinishType { matte, gloss, oil }
