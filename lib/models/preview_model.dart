class PreviewModel {
  final String taskId;
  final String? thumbnailUrl;
  final String? basicGlbUrl;
  final String prompt;
  final bool isSelected;

  PreviewModel({
    required this.taskId,
    this.thumbnailUrl,
    this.basicGlbUrl,
    required this.prompt,
    this.isSelected = false,
  });

  PreviewModel copyWith({
    String? taskId,
    String? thumbnailUrl,
    String? basicGlbUrl,
    String? prompt,
    bool? isSelected,
  }) {
    return PreviewModel(
      taskId: taskId ?? this.taskId,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      basicGlbUrl: basicGlbUrl ?? this.basicGlbUrl,
      prompt: prompt ?? this.prompt,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class RefinedModel {
  final String? glbUrl;
  final String? thumbnailUrl;
  final String taskId;

  RefinedModel({
    this.glbUrl,
    this.thumbnailUrl,
    required this.taskId,
  });
}