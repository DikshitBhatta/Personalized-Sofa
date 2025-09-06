class PersonalizationData {
  // Step 1: Audience Selection
  AudienceType? audienceType;
  
  // Step 2: Usage Style
  UsageStyleData? usageStyle;
  
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
    this.usageStyle,
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
      usageStyle: json['usage_style'] != null 
          ? UsageStyleData.fromJson(json['usage_style'])
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
      'usage_style': usageStyle?.toJson(),
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

class UsageStyleData {
  // Adult specific
  UsagePattern? usagePattern;
  FirmnessPreference? firmnessPreference;
  SofaCapacity? sofaCapacity;
  SeatSupport? seatSupport;
  
  // Child specific
  ChildUsageType? childUsageType;
  FamilyPriority? familyPriority;
  int? numberOfChildren;
  bool? growthAdaptable;
  
  // Pet specific
  PetRelaxLocation? petRelaxLocation;
  WearLevel? wearLevel;
  AllergySensitivity? allergySensitivity;
  PetFriendlyFeature? petFriendlyFeature;
  
  UsageStyleData({
    this.usagePattern,
    this.firmnessPreference,
    this.sofaCapacity,
    this.seatSupport,
    this.childUsageType,
    this.familyPriority,
    this.numberOfChildren,
    this.growthAdaptable,
    this.petRelaxLocation,
    this.wearLevel,
    this.allergySensitivity,
    this.petFriendlyFeature,
  });
  
  factory UsageStyleData.fromJson(Map<String, dynamic> json) {
    return UsageStyleData(
      usagePattern: json['usage_pattern'] != null 
          ? UsagePattern.values.firstWhere((e) => e.toString().split('.').last == json['usage_pattern'])
          : null,
      firmnessPreference: json['firmness_preference'] != null 
          ? FirmnessPreference.values.firstWhere((e) => e.toString().split('.').last == json['firmness_preference'])
          : null,
      sofaCapacity: json['sofa_capacity'] != null 
          ? SofaCapacity.values.firstWhere((e) => e.toString().split('.').last == json['sofa_capacity'])
          : null,
      seatSupport: json['seat_support'] != null 
          ? SeatSupport.values.firstWhere((e) => e.toString().split('.').last == json['seat_support'])
          : null,
      childUsageType: json['child_usage_type'] != null 
          ? ChildUsageType.values.firstWhere((e) => e.toString().split('.').last == json['child_usage_type'])
          : null,
      familyPriority: json['family_priority'] != null 
          ? FamilyPriority.values.firstWhere((e) => e.toString().split('.').last == json['family_priority'])
          : null,
      numberOfChildren: json['number_of_children'],
      growthAdaptable: json['growth_adaptable'],
      petRelaxLocation: json['pet_relax_location'] != null 
          ? PetRelaxLocation.values.firstWhere((e) => e.toString().split('.').last == json['pet_relax_location'])
          : null,
      wearLevel: json['wear_level'] != null 
          ? WearLevel.values.firstWhere((e) => e.toString().split('.').last == json['wear_level'])
          : null,
      allergySensitivity: json['allergy_sensitivity'] != null 
          ? AllergySensitivity.values.firstWhere((e) => e.toString().split('.').last == json['allergy_sensitivity'])
          : null,
      petFriendlyFeature: json['pet_friendly_feature'] != null 
          ? PetFriendlyFeature.values.firstWhere((e) => e.toString().split('.').last == json['pet_friendly_feature'])
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'usage_pattern': usagePattern?.toString().split('.').last,
      'firmness_preference': firmnessPreference?.toString().split('.').last,
      'sofa_capacity': sofaCapacity?.toString().split('.').last,
      'seat_support': seatSupport?.toString().split('.').last,
      'child_usage_type': childUsageType?.toString().split('.').last,
      'family_priority': familyPriority?.toString().split('.').last,
      'number_of_children': numberOfChildren,
      'growth_adaptable': growthAdaptable,
      'pet_relax_location': petRelaxLocation?.toString().split('.').last,
      'wear_level': wearLevel?.toString().split('.').last,
      'allergy_sensitivity': allergySensitivity?.toString().split('.').last,
      'pet_friendly_feature': petFriendlyFeature?.toString().split('.').last,
    };
  }
}

// Adult usage enums
enum UsagePattern { lounging, formalHosting, familyLiving }
enum FirmnessPreference { firm, balanced, soft }
enum SofaCapacity { two, three, fourPlus, sectional }
enum SeatSupport { lumbarSupport, extraDeep, standard }

// Child usage enums
enum ChildUsageType { readingQuiet, playtimeTV, napRest }
enum FamilyPriority { easyClean, edgeSoftness, standardComfort }

// Pet usage enums
enum PetRelaxLocation { besideFloor, sofaCushions, armrestsBackrest }
enum WearLevel { low, moderate, high }
enum AllergySensitivity { low, medium, high }
enum PetFriendlyFeature { scratchResistant, easyClean, standardDurability }

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
