import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/utils/image_assets.dart';
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
     // Neutrals
  '#2C2C2C', '#D3D3D3', '#F5F5F5', '#A0522D', '#8B4513',

  // Earth Tones
  '#CD853F', '#D2691E', '#800000', '#8B0000', '#B22222',

  // Luxe Reds & Wines
  '#DC143C', '#228B22', '#6B8E23', '#556B2F', '#191970',

  // Blues
  '#000080', '#0000CD', '#4169E1', '#9932CC', '#8A2BE2',

  // Purples
  '#4B0082', '#6A5ACD', '#7B68EE', '#B8860B', '#DAA520',
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
      PatternData(
        personalization.PatternType.check,
        "Check",
        "Classic checkered pattern",
        assetPath: ImageAssets.pattern(personalization.PatternType.check),
      ),
      PatternData(
        personalization.PatternType.herringbone,
        "Herringbone",
        "V-shaped weaving pattern",
        assetPath: ImageAssets.pattern(personalization.PatternType.herringbone),
      ),
      PatternData(
        personalization.PatternType.jacquard,
        "Jacquard",
        "Intricate woven design",
        assetPath: ImageAssets.pattern(personalization.PatternType.jacquard),
      ),
      PatternData(
        personalization.PatternType.stripe,
        "Stripe",
        "Linear striped pattern",
        assetPath: ImageAssets.pattern(personalization.PatternType.stripe),
      ),
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
                    if (pattern.assetPath != null)
                      GestureDetector(
                        onLongPress: () => _showImagePreview(context, pattern.assetPath!),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: kChristmasSilver),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              pattern.assetPath!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: kSnowFlakeWhite,
                                child: const Icon(Icons.image_not_supported, color: kTinGrey),
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      Text(
                        pattern.emoji ?? '',
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
                        color: kOffBlack,
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
  final ValueChanged<personalization.StitchingType> onStitchingSelected;
  final ValueChanged<personalization.LegType> onLegSelected;
  
  const DetailsSelector({
    super.key,
    required this.selectedStitching,
    required this.selectedLeg,
    required this.onStitchingSelected,
    required this.onLegSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailSection(
          context,
          "Stitching Type",
          [
            DetailData(
              personalization.StitchingType.double,
              "Double",
              "Extra durability",
              assetPath: ImageAssets.stitching(personalization.StitchingType.double),
            ),
            DetailData(
              personalization.StitchingType.contrast,
              "Contrast",
              "Visible accent stitching",
              assetPath: ImageAssets.stitching(personalization.StitchingType.contrast),
            ),
            DetailData(
              personalization.StitchingType.hand,
              "Hand",
              "Artisan crafted",
              assetPath: ImageAssets.stitching(personalization.StitchingType.hand),
            ),
          ],
          selectedStitching,
          onStitchingSelected,
        ),
        
        const SizedBox(height: 24),
        
        _buildDetailSection(
          context,
          "Leg Material",
          [
            DetailData(
              personalization.LegType.walnut,
              "Walnut",
              "Rich brown wood",
              assetPath: ImageAssets.leg(personalization.LegType.walnut),
            ),
            DetailData(
              personalization.LegType.oak,
              "Oak",
              "Classic hardwood",
              assetPath: ImageAssets.leg(personalization.LegType.oak),
            ),
            DetailData(
              personalization.LegType.ash,
              "Ash",
              "Light colored wood",
              assetPath: ImageAssets.leg(personalization.LegType.ash),
            ),
            DetailData(
              personalization.LegType.steel,
              "Steel",
              "Modern metal",
              assetPath: ImageAssets.leg(personalization.LegType.steel),
            ),
            DetailData(
              personalization.LegType.bronze,
              "Bronze",
              "Warm metallic",
              assetPath: ImageAssets.leg(personalization.LegType.bronze),
            ),
          ],
          selectedLeg,
          onLegSelected,
        ),
        
        const SizedBox(height: 24),
        
        // Finish type removed
      ],
    );
  }
  
  Widget _buildDetailSection<T>(
    BuildContext context,
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? kOffBlack : kChristmasSilver,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected ? const Color(0x14000000) : const Color(0x08000000),
                      offset: const Offset(0, 2),
                      blurRadius: isSelected ? 8 : 4,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (option.assetPath != null)
                      GestureDetector(
                        onLongPress: () => _showImagePreview(context, option.assetPath!),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: kSnowFlakeWhite,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.asset(
                              option.assetPath!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 18),
                            ),
                          ),
                        ),
                      )
                    else
                      Text(
                        option.emoji ?? '',
                        style: const TextStyle(fontSize: 16),
                      ),
                    const SizedBox(width: 8),
                    Text(
                      option.name,
                      style: kNunitoSans14.copyWith(
                        fontWeight: FontWeight.w600,
                        color: kOffBlack,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.check_circle, color: kOffBlack, size: 18),
                    ],
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
  final String? emoji; // fallback
  final String? assetPath; // optional asset image

  PatternData(this.type, this.name, this.description, {this.emoji, this.assetPath});
}

class DetailData<T> {
  final T value;
  final String name;
  final String description;
  final String? emoji; // fallback
  final String? assetPath; // optional asset image

  DetailData(this.value, this.name, this.description, {this.emoji, this.assetPath});
}

// Top-level helper to show a magnified preview of an asset image.
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
