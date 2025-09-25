class PersonalizationData {
  // Step 1: Audience Selection
  AudienceType? audienceType;
  
  // Step 2: Usage Style
  UsageStyleData? usageStyle;
  
  // Step 3: Style & Material Preferences
  StyleMaterialData? styleMaterial;
  
  // Step 4: Color, Pattern & Details
  PersonalizationDetails? personalizationDetails;
  
  // Additional properties
  String? roomPhotoPath;
  ComfortPreferences? comfortPreferences;
  NiceToHaves? niceToHaves;
  FinalPreferences? finalPreferences;
  
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
    this.roomPhotoPath,
    this.comfortPreferences,
    this.niceToHaves,
    this.finalPreferences,
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
      roomPhotoPath: json['room_photo_path'],
      comfortPreferences: json['comfort_preferences'] != null 
          ? ComfortPreferences.fromJson(json['comfort_preferences'])
          : null,
      niceToHaves: json['nice_to_haves'] != null 
          ? NiceToHaves.fromJson(json['nice_to_haves'])
          : null,
      finalPreferences: json['final_preferences'] != null 
          ? FinalPreferences.fromJson(json['final_preferences'])
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
      'room_photo_path': roomPhotoPath,
      'comfort_preferences': comfortPreferences?.toJson(),
      'nice_to_haves': niceToHaves?.toJson(),
      'final_preferences': finalPreferences?.toJson(),
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
  
  // Pet Health specific (Step 2 - Health)
  PetType? petType;
  String? customPetName;
  PetSize? petSize;
  TemperatureSensitivity? temperatureSensitivity;
  HeightPreference? heightPreference;
  
  // Pet Usage specific (Step 2B - Usage)
  int? numberOfPets;
  PetSeatingStyle? petSeatingStyle;
  PetRelaxLocation? petRelaxLocation;
  WearLevel? wearLevel;
  bool? extraPetFriendly;
  
  UsageStyleData({
    this.usagePattern,
    this.firmnessPreference,
    this.sofaCapacity,
    this.seatSupport,
    this.childUsageType,
    this.familyPriority,
    this.numberOfChildren,
    this.growthAdaptable,
    this.petType,
    this.customPetName,
    this.petSize,
    this.temperatureSensitivity,
    this.heightPreference,
    this.numberOfPets,
    this.petSeatingStyle,
    this.petRelaxLocation,
    this.wearLevel,
    this.extraPetFriendly,
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
      petType: json['pet_type'] != null 
          ? PetType.values.firstWhere((e) => e.toString().split('.').last == json['pet_type'])
          : null,
      customPetName: json['custom_pet_name'],
      petSize: json['pet_size'] != null 
          ? PetSize.values.firstWhere((e) => e.toString().split('.').last == json['pet_size'])
          : null,
      temperatureSensitivity: json['temperature_sensitivity'] != null 
          ? TemperatureSensitivity.values.firstWhere((e) => e.toString().split('.').last == json['temperature_sensitivity'])
          : null,
      heightPreference: json['height_preference'] != null 
          ? HeightPreference.values.firstWhere((e) => e.toString().split('.').last == json['height_preference'])
          : null,
      numberOfPets: json['number_of_pets'],
      petSeatingStyle: json['pet_seating_style'] != null 
          ? PetSeatingStyle.values.firstWhere((e) => e.toString().split('.').last == json['pet_seating_style'])
          : null,
      petRelaxLocation: json['pet_relax_location'] != null 
          ? PetRelaxLocation.values.firstWhere((e) => e.toString().split('.').last == json['pet_relax_location'])
          : null,
      wearLevel: json['wear_level'] != null 
          ? WearLevel.values.firstWhere((e) => e.toString().split('.').last == json['wear_level'])
          : null,
      extraPetFriendly: json['extra_pet_friendly'],
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
      'pet_type': petType?.toString().split('.').last,
      'custom_pet_name': customPetName,
      'pet_size': petSize?.toString().split('.').last,
      'temperature_sensitivity': temperatureSensitivity?.toString().split('.').last,
      'height_preference': heightPreference?.toString().split('.').last,
      'number_of_pets': numberOfPets,
      'pet_seating_style': petSeatingStyle?.toString().split('.').last,
      'pet_relax_location': petRelaxLocation?.toString().split('.').last,
      'wear_level': wearLevel?.toString().split('.').last,
      'extra_pet_friendly': extraPetFriendly,
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

// Pet health enums
enum PetType { dog, cat, other }
enum PetSize { small, medium, large }
enum TemperatureSensitivity { getscold, overheats, normal }
enum HeightPreference { lowRise, plushPremium }

// Pet usage enums
enum PetSeatingStyle { layingDown, sitting, standing }
enum PetRelaxLocation { besideFloor, sofaCushions, armrestsBackrest, bed, hiddenSpace }
enum WearLevel { low, moderate, high }

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

class ComfortPreferences {
  String? cushionFirmness;
  String? seatDepth;
  bool? backSupport;
  bool? armrests;
  bool? headrest;
  bool? tallUsers;
  bool? elderlyFriendly;
  
  ComfortPreferences({
    this.cushionFirmness,
    this.seatDepth,
    this.backSupport,
    this.armrests,
    this.headrest,
    this.tallUsers,
    this.elderlyFriendly,
  });
  
  factory ComfortPreferences.fromJson(Map<String, dynamic> json) {
    return ComfortPreferences(
      cushionFirmness: json['cushion_firmness'],
      seatDepth: json['seat_depth'],
      backSupport: json['back_support'],
      armrests: json['armrests'],
      headrest: json['headrest'],
      tallUsers: json['tall_users'],
      elderlyFriendly: json['elderly_friendly'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'cushion_firmness': cushionFirmness,
      'seat_depth': seatDepth,
      'back_support': backSupport,
      'armrests': armrests,
      'headrest': headrest,
      'tall_users': tallUsers,
      'elderly_friendly': elderlyFriendly,
    };
  }
}

class NiceToHaves {
  List<String>? extras;
  bool? modularExpandable;
  List<String>? features;
  String? additionalRequests;
  
  NiceToHaves({
    this.extras,
    this.modularExpandable,
    this.features,
    this.additionalRequests,
  });
  
  factory NiceToHaves.fromJson(Map<String, dynamic> json) {
    return NiceToHaves(
      extras: json['extras'] != null ? List<String>.from(json['extras']) : null,
      modularExpandable: json['modular_expandable'],
      features: json['features'] != null ? List<String>.from(json['features']) : null,
      additionalRequests: json['additional_requests'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'extras': extras,
      'modular_expandable': modularExpandable,
      'features': features,
      'additional_requests': additionalRequests,
    };
  }
}

class FinalPreferences {
  String? whatMattersMost;
  bool? washableReplaceableCovers;
  String? ecoFriendly;
  String? changePreferencesNote;
  
  FinalPreferences({
    this.whatMattersMost,
    this.washableReplaceableCovers,
    this.ecoFriendly,
    this.changePreferencesNote,
  });
  
  factory FinalPreferences.fromJson(Map<String, dynamic> json) {
    return FinalPreferences(
      whatMattersMost: json['what_matters_most'],
      washableReplaceableCovers: json['washable_replaceable_covers'],
      ecoFriendly: json['eco_friendly'],
      changePreferencesNote: json['change_preferences_note'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'what_matters_most': whatMattersMost,
      'washable_replaceable_covers': washableReplaceableCovers,
      'eco_friendly': ecoFriendly,
      'change_preferences_note': changePreferencesNote,
    };
  }
}
