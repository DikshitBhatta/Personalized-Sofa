import 'package:timberr/models/personalization_data.dart';

class GeneratedSofaModel {
  final String id;
  final String name;
  final String? glbUrl;
  final String? thumbnailUrl;
  final PersonalizationData personalizationData;
  final DateTime createdAt;
  final String? previewPrompt;
  final String? refinePrompt;

  GeneratedSofaModel({
    required this.id,
    required this.name,
    this.glbUrl,
    this.thumbnailUrl,
    required this.personalizationData,
    required this.createdAt,
    this.previewPrompt,
    this.refinePrompt,
  });

  factory GeneratedSofaModel.fromJson(Map<String, dynamic> json) {
    return GeneratedSofaModel(
      id: json['id'],
      name: json['name'],
      glbUrl: json['glb_url'],
      thumbnailUrl: json['thumbnail_url'],
      personalizationData: PersonalizationData.fromJson(json['personalization_data']),
      createdAt: DateTime.parse(json['created_at']),
      previewPrompt: json['preview_prompt'],
      refinePrompt: json['refine_prompt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'glb_url': glbUrl,
      'thumbnail_url': thumbnailUrl,
      'personalization_data': personalizationData.toJson(),
      'created_at': createdAt.toIso8601String(),
      'preview_prompt': previewPrompt,
      'refine_prompt': refinePrompt,
    };
  }

  // Create a copy with updated fields
  GeneratedSofaModel copyWith({
    String? id,
    String? name,
    String? glbUrl,
    String? thumbnailUrl,
    PersonalizationData? personalizationData,
    DateTime? createdAt,
    String? previewPrompt,
    String? refinePrompt,
  }) {
    return GeneratedSofaModel(
      id: id ?? this.id,
      name: name ?? this.name,
      glbUrl: glbUrl ?? this.glbUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      personalizationData: personalizationData ?? this.personalizationData,
      createdAt: createdAt ?? this.createdAt,
      previewPrompt: previewPrompt ?? this.previewPrompt,
      refinePrompt: refinePrompt ?? this.refinePrompt,
    );
  }
}
