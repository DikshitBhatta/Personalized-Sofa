import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timberr/models/generated_sofa_model.dart';

class SavedModelsService {
  static const String _savedModelsKey = 'saved_sofa_models';

  // Save a generated sofa model
  static Future<bool> saveModel(GeneratedSofaModel model) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final models = await getSavedModels();

      // Check if model already exists (update if it does)
      final existingIndex = models.indexWhere((m) => m.id == model.id);
      if (existingIndex >= 0) {
        models[existingIndex] = model;
      } else {
        models.add(model);
      }

      final modelsJson = models.map((m) => jsonEncode(m.toJson())).toList();

      // Debug: print what we're saving so we can verify glbUrl/localPath
      try {
        print('SavedModelsService: saving models JSON list: ${modelsJson}');
      } catch (_) {}

      return await prefs.setStringList(_savedModelsKey, modelsJson);
    } catch (e) {
      print('Error saving model: $e');
      return false;
    }
  }

  // Get all saved models
  static Future<List<GeneratedSofaModel>> getSavedModels() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modelsJson = prefs.getStringList(_savedModelsKey) ?? [];

      // Debug: log loaded JSON list
      try {
        print('SavedModelsService: loaded models JSON list: ${modelsJson}');
      } catch (_) {}

      return modelsJson.map((jsonStr) {
        final json = jsonDecode(jsonStr);
        return GeneratedSofaModel.fromJson(json);
      }).toList();
    } catch (e) {
      print('Error loading saved models: $e');
      return [];
    }
  }

  // Delete a specific model
  static Future<bool> deleteModel(String modelId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final models = await getSavedModels();

      models.removeWhere((model) => model.id == modelId);

      final modelsJson = models.map((m) => jsonEncode(m.toJson())).toList();
      return await prefs.setStringList(_savedModelsKey, modelsJson);
    } catch (e) {
      print('Error deleting model: $e');
      return false;
    }
  }

  // Check if a model exists
  static Future<bool> modelExists(String modelId) async {
    final models = await getSavedModels();
    return models.any((model) => model.id == modelId);
  }

  // Clear all saved models
  static Future<bool> clearAllModels() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_savedModelsKey);
    } catch (e) {
      print('Error clearing models: $e');
      return false;
    }
  }
}
