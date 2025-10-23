class UserOnboardingData {
  // Section 1: You & Your Lifestyle
  String? personalityType;
  String? homeType;
  String? livingStyle;
  String? location;
  String? livingRoomFeeling;
  String? relaxationActivity;
  List<String> comfortWords;

  // Section 2: Personality & Ambience
  String? livingRoomPersonality;
  String? guestFeeling;
  String? socialEnergyPreference;
  String? guestImpression;
  String? personalTasteWord;

  // Section 3: Lifestyle Context
  String? livingArrangement;
  bool? hasPets;
  String? hostingFrequency;
  String? sofaUsageTime;

  UserOnboardingData({
    this.personalityType,
    this.homeType,
    this.livingStyle,
    this.location,
    this.livingRoomFeeling,
    this.relaxationActivity,
    this.comfortWords = const [],
    this.livingRoomPersonality,
    this.guestFeeling,
    this.socialEnergyPreference,
    this.guestImpression,
    this.personalTasteWord,
    this.livingArrangement,
    this.hasPets,
    this.hostingFrequency,
    this.sofaUsageTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'personality_type': personalityType,
      'home_type': homeType,
      'living_style': livingStyle,
      'location': location,
      'living_room_feeling': livingRoomFeeling,
      'relaxation_activity': relaxationActivity,
      'comfort_words': comfortWords,
      'living_room_personality': livingRoomPersonality,
      'guest_feeling': guestFeeling,
      'social_energy_preference': socialEnergyPreference,
      'guest_impression': guestImpression,
      'personal_taste_word': personalTasteWord,
      'living_arrangement': livingArrangement,
      'has_pets': hasPets,
      'hosting_frequency': hostingFrequency,
      'sofa_usage_time': sofaUsageTime,
    };
  }

  factory UserOnboardingData.fromJson(Map<String, dynamic> json) {
    return UserOnboardingData(
      personalityType: json['personality_type'],
      homeType: json['home_type'],
      livingStyle: json['living_style'],
      location: json['location'],
      livingRoomFeeling: json['living_room_feeling'],
      relaxationActivity: json['relaxation_activity'],
      comfortWords: List<String>.from(json['comfort_words'] ?? []),
      livingRoomPersonality: json['living_room_personality'],
      guestFeeling: json['guest_feeling'],
      socialEnergyPreference: json['social_energy_preference'],
      guestImpression: json['guest_impression'],
      personalTasteWord: json['personal_taste_word'],
      livingArrangement: json['living_arrangement'],
      hasPets: json['has_pets'],
      hostingFrequency: json['hosting_frequency'],
      sofaUsageTime: json['sofa_usage_time'],
    );
  }
}