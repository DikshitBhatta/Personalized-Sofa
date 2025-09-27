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
      MaterialData(personalization.MaterialType.fullGrain, "Full-grain", "Premium leather, ages beautifully", 'assets/fabrics/Full_grain_leather.jpg'),
      MaterialData(personalization.MaterialType.semiAniline, "Semi-aniline", "Soft touch, natural grain", 'assets/fabrics/Semi_aniline.png'),
      MaterialData(personalization.MaterialType.nubuck, "Nubuck", "Velvety texture, durable", 'assets/fabrics/nubuck.jpg'),
      MaterialData(personalization.MaterialType.pu, "PU Leather", "Easy care, budget-friendly", 'assets/fabrics/PU_leather.jpg'),
      MaterialData(personalization.MaterialType.cotton, "Cotton", "Breathable, comfortable", 'assets/fabrics/cotton.jpg'),
      MaterialData(personalization.MaterialType.linen, "Linen", "Natural, relaxed feel", 'assets/fabrics/Linen.jpg'),
      MaterialData(personalization.MaterialType.velvet, "Velvet", "Luxurious, soft touch", 'assets/fabrics/velvet.jpg'),
      MaterialData(personalization.MaterialType.alcantara, "Alcantara", "Premium microfiber", 'assets/fabrics/alcantara.jpeg'),
      MaterialData(personalization.MaterialType.ecoFabric, "Eco Fabric", "Sustainable choice", 'assets/fabrics/eco_fabric.jpg'),
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
            padding: const EdgeInsets.all(12),
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
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onLongPress: () => _showImagePreview(context, material.assetPath),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: kSnowFlakeWhite,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            material.assetPath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: kSnowFlakeWhite,
                              alignment: Alignment.center,
                              child: const Icon(Icons.image_not_supported, color: kTinGrey),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (isSelected)
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: kOffBlack,
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
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    material.name,
                    style: kNunitoSansSemiBold16.copyWith(
                      color: isSelected ? kOffBlack : kTinGrey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    material.description,
                    style: kNunitoSans14.copyWith(
                      color: kGrey,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
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
  final String assetPath;

  MaterialData(this.type, this.name, this.description, this.assetPath);
}

class FunctionalityData {
  final personalization.FunctionalityType type;
  final String name;
  final String emoji;

  FunctionalityData(this.type, this.name, this.emoji);
}

// Top-level helper to preview an asset image in an InteractiveViewer dialog.
void _showImagePreview(BuildContext context, String assetPath) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          width: double.infinity,
          height: 360,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: InteractiveViewer(
              panEnabled: true,
              scaleEnabled: true,
              maxScale: 4.0,
              minScale: 1.0,
              child: Image.asset(
                assetPath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: kSnowFlakeWhite,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.image_not_supported, size: 48, color: kTinGrey),
                      SizedBox(height: 8),
                      Text('Preview not available')
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
