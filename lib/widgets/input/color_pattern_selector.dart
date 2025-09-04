import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/models/personalization_data.dart' as personalization;

class ColorPicker extends StatelessWidget {
  final String? selectedColorHex;
  final String? selectedPantoneCode;
  final ValueChanged<String> onColorSelected;
  final ValueChanged<String>? onPantoneCodeChanged;
  
  const ColorPicker({
    super.key,
    required this.selectedColorHex,
    this.selectedPantoneCode,
    required this.onColorSelected,
    this.onPantoneCodeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final presetColors = [
      '#2C2C2C', '#8B4513', '#CD853F', '#D2691E', '#A0522D', 
      '#800000', '#8B0000', '#DC143C', '#B22222', '#FF4500',
      '#228B22', '#32CD32', '#9ACD32', '#6B8E23', '#556B2F',
      '#4169E1', '#0000CD', '#191970', '#000080', '#1E90FF',
      '#9932CC', '#8A2BE2', '#4B0082', '#6A5ACD', '#7B68EE',
      '#FFD700', '#FFA500', '#FF8C00', '#DAA520', '#B8860B',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Choose Color",
          style: kNunitoSansSemiBold16.copyWith(color: kOffBlack),
        ),
        const SizedBox(height: 16),
        
        // Preset color swatches
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: presetColors.map((colorHex) {
            final isSelected = selectedColorHex == colorHex;
            return GestureDetector(
              onTap: () => onColorSelected(colorHex),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Color(int.parse(colorHex.substring(1), radix: 16) + 0xFF000000),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? kOffBlack : kChristmasSilver,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: isSelected 
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : null,
              ),
            );
          }).toList(),
        ),
        
        const SizedBox(height: 24),
        
        // Custom color input
        if (onPantoneCodeChanged != null) ...[
          Text(
            "Custom Color (Optional)",
            style: kNunitoSansSemiBold16.copyWith(color: kOffBlack),
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: "Pantone Code",
                    hintText: "e.g., PANTONE 18-1664",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: kChristmasSilver),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: kOffBlack, width: 2),
                    ),
                  ),
                  onChanged: onPantoneCodeChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: "Hex Code",
                    hintText: "#FF5733",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: kChristmasSilver),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: kOffBlack, width: 2),
                    ),
                  ),
                  onChanged: (value) {
                    if (value.startsWith('#') && value.length == 7) {
                      onColorSelected(value);
                    }
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[#0-9A-Fa-f]')),
                    LengthLimitingTextInputFormatter(7),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class PatternSelector extends StatelessWidget {
  final personalization.PatternType? selectedPattern;
  final ValueChanged<personalization.PatternType?> onPatternSelected;
  
  const PatternSelector({
    super.key,
    required this.selectedPattern,
    required this.onPatternSelected,
  });

  @override
  Widget build(BuildContext context) {
    final patterns = [
      PatternData(personalization.PatternType.check, "Check", "Classic checkered pattern", "🔲"),
      PatternData(personalization.PatternType.herringbone, "Herringbone", "V-shaped weaving pattern", "🔷"),
      PatternData(personalization.PatternType.jacquard, "Jacquard", "Intricate woven design", "🎨"),
      PatternData(personalization.PatternType.stripe, "Stripe", "Linear striped pattern", "📏"),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Pattern (Optional)",
              style: kNunitoSansSemiBold16.copyWith(color: kOffBlack),
            ),
            if (selectedPattern != null)
              TextButton(
                onPressed: () => onPatternSelected(null),
                child: Text(
                  "Clear",
                  style: kNunitoSans14.copyWith(color: kGrey),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: patterns.length,
          itemBuilder: (context, index) {
            final pattern = patterns[index];
            final isSelected = selectedPattern == pattern.type;
            
            return GestureDetector(
              onTap: () => onPatternSelected(pattern.type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? kOffBlack : kChristmasSilver,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected ? const Color(0x20303030) : const Color(0x10000000),
                      offset: const Offset(0, 2),
                      blurRadius: isSelected ? 10 : 5,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(
                      pattern.emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            pattern.name,
                            style: kNunitoSans14.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isSelected ? kOffBlack : kTinGrey,
                              height: 1.1,
                            ),
                          ),
                          Text(
                            pattern.description,
                            style: kNunitoSans10Grey.copyWith(
                              fontWeight: FontWeight.w500,
                              height: 1.0,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: kSeaGreen,
                        size: 20,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class DetailsSelector extends StatelessWidget {
  final personalization.StitchingType? selectedStitching;
  final personalization.LegType? selectedLeg;
  final personalization.FinishType? selectedFinish;
  final ValueChanged<personalization.StitchingType> onStitchingSelected;
  final ValueChanged<personalization.LegType> onLegSelected;
  final ValueChanged<personalization.FinishType> onFinishSelected;
  
  const DetailsSelector({
    super.key,
    required this.selectedStitching,
    required this.selectedLeg,
    required this.selectedFinish,
    required this.onStitchingSelected,
    required this.onLegSelected,
    required this.onFinishSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailSection(
          "Stitching Type",
          [
            DetailData(personalization.StitchingType.double, "Double", "Extra durability", "🧵"),
            DetailData(personalization.StitchingType.contrast, "Contrast", "Visible accent stitching", "🎯"),
            DetailData(personalization.StitchingType.hand, "Hand", "Artisan crafted", "✋"),
          ],
          selectedStitching,
          onStitchingSelected,
        ),
        
        const SizedBox(height: 24),
        
        _buildDetailSection(
          "Leg Material",
          [
            DetailData(personalization.LegType.walnut, "Walnut", "Rich brown wood", "🌰"),
            DetailData(personalization.LegType.oak, "Oak", "Classic hardwood", "🌳"),
            DetailData(personalization.LegType.ash, "Ash", "Light colored wood", "🍃"),
            DetailData(personalization.LegType.steel, "Steel", "Modern metal", "⚡"),
            DetailData(personalization.LegType.bronze, "Bronze", "Warm metallic", "🥉"),
          ],
          selectedLeg,
          onLegSelected,
        ),
        
        const SizedBox(height: 24),
        
        _buildDetailSection(
          "Finish Type",
          [
            DetailData(personalization.FinishType.matte, "Matte", "Non-reflective surface", "🎨"),
            DetailData(personalization.FinishType.gloss, "Gloss", "High-shine finish", "✨"),
            DetailData(personalization.FinishType.oil, "Oil", "Natural protection", "🌿"),
          ],
          selectedFinish,
          onFinishSelected,
        ),
      ],
    );
  }
  
  Widget _buildDetailSection<T>(
    String title,
    List<DetailData<T>> options,
    T? selectedValue,
    ValueChanged<T> onSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: kNunitoSansSemiBold16.copyWith(color: kOffBlack),
        ),
        const SizedBox(height: 12),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedValue == option.value;
            
            return GestureDetector(
              onTap: () => onSelected(option.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? kOffBlack : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? kOffBlack : kChristmasSilver,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      option.emoji,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      option.name,
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
        ),
      ],
    );
  }
}

class PatternData {
  final personalization.PatternType type;
  final String name;
  final String description;
  final String emoji;

  PatternData(this.type, this.name, this.description, this.emoji);
}

class DetailData<T> {
  final T value;
  final String name;
  final String description;
  final String emoji;

  DetailData(this.value, this.name, this.description, this.emoji);
}
