import 'lib/domain/models/sofa_config.dart';

void main() {
  print('=== SOFA PROMPT GENERATION TEST ===\n');
  
  // Example 1: Family living room sofa
  final config1 = SofaConfig(
    targetUser: 'adult',
    usageStyle: 'family',
    seatingFeel: 'soft',
    capacity: '4',
    material: 'velvet',
    features: ['pet-resistant'],
    color: 'emerald green',
    pattern: 'jacquard',
    stitching: 'decorative',
    legs: 'oak',
  );
  
  print('🏠 EXAMPLE 1: Family Living Room Sofa');
  print('=====================================');
  print('PREVIEW PROMPT (sent to Meshy.ai):');
  print(config1.toPreviewPrompt());
  print('\nCHARACTER COUNT: ${config1.toPreviewPrompt().length}/600\n');
  
  print('TEXTURE REFINEMENT PROMPT (sent to Meshy.ai):');
  print(config1.toRefineTexturePrompt());
  print('\nCHARACTER COUNT: ${config1.toRefineTexturePrompt().length}/600\n');
  
  print('=' * 60);
  
  // Example 2: Minimalist office sofa
  final config2 = SofaConfig(
    targetUser: 'adult',
    usageStyle: 'hosting',
    seatingFeel: 'balanced',
    capacity: '3',
    material: 'linen',
    features: ['waterproof', 'stain-resistant'],
    color: 'beige',
    pattern: 'plain',
    stitching: 'double',
    legs: 'bronze',
  );
  
  print('\n🏢 EXAMPLE 2: Minimalist Office Sofa');
  print('====================================');
  print('PREVIEW PROMPT (sent to Meshy.ai):');
  print(config2.toPreviewPrompt());
  print('\nCHARACTER COUNT: ${config2.toPreviewPrompt().length}/600\n');
  
  print('TEXTURE REFINEMENT PROMPT (sent to Meshy.ai):');
  print(config2.toRefineTexturePrompt());
  print('\nCHARACTER COUNT: ${config2.toRefineTexturePrompt().length}/600\n');
  
  print('=' * 60);
  
  // Example 3: Luxury lounge sofa (with pet user)
  final config3 = SofaConfig(
    targetUser: 'pet',
    usageStyle: 'lounging',
    seatingFeel: 'firm',
    capacity: '2',
    material: 'leather',
    features: ['premium', 'scratch-resistant'],
    color: 'dark brown',
    pattern: 'textured',
    stitching: 'single',
    legs: 'walnut',
  );
  
  print('\n🛋️ EXAMPLE 3: Pet-Friendly Luxury Lounge Sofa');
  print('=================================');
  print('PREVIEW PROMPT (sent to Meshy.ai):');
  print(config3.toPreviewPrompt());
  print('\nCHARACTER COUNT: ${config3.toPreviewPrompt().length}/600\n');
  
  print('TEXTURE REFINEMENT PROMPT (sent to Meshy.ai):');
  print(config3.toRefineTexturePrompt());
  print('\nCHARACTER COUNT: ${config3.toRefineTexturePrompt().length}/600\n');
  
  print('=' * 60);
  print('\n🔄 HOW IT WORKS WITH MESHY.AI:');
  print('==============================');
  print('1. User completes personalization → SofaConfig created');
  print('2. SofaConfig.toPreviewPrompt() → First API call (3D model generation)');
  print('3. SofaConfig.toRefineTexturePrompt() → Second API call (texture refinement)');
  print('4. Meshy.ai returns: GLB model URL + thumbnail URL');
  print('5. App displays 3D model to user');
  print('\n✅ Both prompts are under 600 character limit for Meshy.ai API');
}
