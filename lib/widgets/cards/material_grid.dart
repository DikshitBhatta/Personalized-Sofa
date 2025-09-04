import 'package:flutter/material.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/models/personalization_data.dart' as personalization;

class MaterialGrid extends StatelessWidget {
  final personalization.MaterialType? selectedMaterial;
  final ValueChanged<personalization.MaterialType> onMaterialSelected;
  
  const MaterialGrid({
    super.key,
    required this.selectedMaterial,
    required this.onMaterialSelected,
  });

  @override
  Widget build(BuildContext context) {
    final materials = [
      MaterialData(personalization.MaterialType.fullGrain, "Full-grain", "Premium leather, ages beautifully", "🐄"),
      MaterialData(personalization.MaterialType.semiAniline, "Semi-aniline", "Soft touch, natural grain", "✨"),
      MaterialData(personalization.MaterialType.nubuck, "Nubuck", "Velvety texture, durable", "🎨"),
      MaterialData(personalization.MaterialType.pu, "PU Leather", "Easy care, budget-friendly", "🛡️"),
      MaterialData(personalization.MaterialType.cotton, "Cotton", "Breathable, comfortable", "🌿"),
      MaterialData(personalization.MaterialType.linen, "Linen", "Natural, relaxed feel", "🌾"),
      MaterialData(personalization.MaterialType.velvet, "Velvet", "Luxurious, soft touch", "👑"),
      MaterialData(personalization.MaterialType.alcantara, "Alcantara", "Premium microfiber", "⭐"),
      MaterialData(personalization.MaterialType.ecoFabric, "Eco Fabric", "Sustainable choice", "♻️"),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: materials.length,
      itemBuilder: (context, index) {
        final material = materials[index];
        final isSelected = selectedMaterial == material.type;
        
        return GestureDetector(
          onTap: () => onMaterialSelected(material.type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? kOffBlack : kChristmasSilver,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected ? const Color(0x20303030) : const Color(0x10000000),
                  offset: const Offset(0, 4),
                  blurRadius: isSelected ? 20 : 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      material.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const Spacer(),
                    if (isSelected)
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: kSeaGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  material.name,
                  style: kNunitoSansSemiBold16.copyWith(
                    color: isSelected ? kOffBlack : kTinGrey,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  material.description,
                  style: kNunitoSans14.copyWith(
                    color: kGrey,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class FunctionalityChips extends StatelessWidget {
  final List<personalization.FunctionalityType> selectedFunctionalities;
  final ValueChanged<List<personalization.FunctionalityType>> onSelectionChanged;
  
  const FunctionalityChips({
    super.key,
    required this.selectedFunctionalities,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final functionalities = [
      FunctionalityData(personalization.FunctionalityType.waterproof, "Waterproof", "💧"),
      FunctionalityData(personalization.FunctionalityType.flameRetardant, "Flame-retardant", "🔥"),
      FunctionalityData(personalization.FunctionalityType.antibacterial, "Antibacterial", "🦠"),
      FunctionalityData(personalization.FunctionalityType.petResistant, "Pet-resistant", "🐾"),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: functionalities.map((functionality) {
        final isSelected = selectedFunctionalities.contains(functionality.type);
        
        return GestureDetector(
          onTap: () {
            final newSelection = List<personalization.FunctionalityType>.from(selectedFunctionalities);
            if (isSelected) {
              newSelection.remove(functionality.type);
            } else {
              newSelection.add(functionality.type);
            }
            onSelectionChanged(newSelection);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? kOffBlack : Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected ? kOffBlack : kChristmasSilver,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  functionality.emoji,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  functionality.name,
                  style: kNunitoSans14.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : kOffBlack,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class MaterialData {
  final personalization.MaterialType type;
  final String name;
  final String description;
  final String emoji;

  MaterialData(this.type, this.name, this.description, this.emoji);
}

class FunctionalityData {
  final personalization.FunctionalityType type;
  final String name;
  final String emoji;

  FunctionalityData(this.type, this.name, this.emoji);
}
