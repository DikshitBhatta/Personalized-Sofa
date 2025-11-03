import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/utils/image_assets.dart';
import 'package:timberr/models/personalization_data.dart' as personalization;

class ColorPicker extends StatefulWidget {
  final String? selectedColorHex;
  final String? selectedPantoneCode;
  final String? recommendedColorHex; // New: AI-recommended color
  final ValueChanged<String> onColorSelected;
  final ValueChanged<String>? onPantoneCodeChanged;
  
  const ColorPicker({
    super.key,
    required this.selectedColorHex,
    this.selectedPantoneCode,
    this.recommendedColorHex,
    required this.onColorSelected,
    this.onPantoneCodeChanged,
  });

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  double _lightnessValue = 0.5; // 0.0 = dark, 1.0 = light
  String? _baseColorHex; // The base color before lightness adjustment
  String? _lastSelectedColorHex; // Track the last selected color
  
  @override
  void initState() {
    super.initState();
    _baseColorHex = widget.selectedColorHex;
    _lastSelectedColorHex = widget.selectedColorHex;
    
    // Try to detect if the selected color is an adjusted version
    if (widget.selectedColorHex != null) {
      _initializeLightnessFromColor(widget.selectedColorHex!);
    }
  }
  
  @override
  void didUpdateWidget(ColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update base color if user selected a different base color (not from slider adjustment)
    if (widget.selectedColorHex != oldWidget.selectedColorHex && 
        widget.selectedColorHex != null &&
        widget.selectedColorHex != _lastSelectedColorHex) {
      // Check if this is a base color selection (from color swatches)
      final baseColors = [
        '#FAFAF0', '#2D2D2D', '#909090', '#D4B896', '#8B6F47',
        '#D64545', '#E67E22', '#FFD54F', '#66BB6A', '#5DADE2', '#AB47BC'
      ];
      
      if (baseColors.contains(widget.selectedColorHex)) {
        // User selected a new base color, reset lightness
        _baseColorHex = widget.selectedColorHex;
        _lightnessValue = 0.5;
      }
      _lastSelectedColorHex = widget.selectedColorHex;
    }
  }
  
  /// Initialize lightness value from the selected color
  void _initializeLightnessFromColor(String hexColor) {
    try {
      final color = Color(int.parse(hexColor.substring(1), radix: 16) + 0xFF000000);
      final hslColor = HSLColor.fromColor(color);
      _lightnessValue = hslColor.lightness.clamp(0.1, 0.9);
    } catch (e) {
      _lightnessValue = 0.5;
    }
  }
  
  /// Adjust lightness of a hex color
  String _adjustLightness(String hexColor, double lightness) {
    final color = Color(int.parse(hexColor.substring(1), radix: 16) + 0xFF000000);
    final hslColor = HSLColor.fromColor(color);
    final adjustedColor = hslColor.withLightness(lightness.clamp(0.0, 1.0)).toColor();
    return '#${adjustedColor.value.toRadixString(16).substring(2).toUpperCase()}';
  }
  
  /// Get gradient colors for the lightness slider (LIGHTER to DARKER)
  List<Color> _getGradientColors(String hexColor) {
    final baseColor = Color(int.parse(hexColor.substring(1), radix: 16) + 0xFF000000);
    final hslColor = HSLColor.fromColor(baseColor);
    
    return [
      hslColor.withLightness(0.9).toColor(),  // Very light (LEFT)
      hslColor.withLightness(0.7).toColor(),  // Light
      hslColor.withLightness(0.5).toColor(),  // Mid (base)
      hslColor.withLightness(0.3).toColor(),  // Dark
      hslColor.withLightness(0.1).toColor(),  // Very dark (RIGHT)
    ];
  }
  
  /// Build circular color swatch
  Widget _buildCircularColorSwatch(String colorName, String colorHex) {
    final isSelected = widget.selectedColorHex == colorHex;
    final isRecommended = widget.recommendedColorHex == colorHex;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _baseColorHex = colorHex;
          _lightnessValue = 0.5; // Reset to mid-tone
        });
        widget.onColorSelected(colorHex);
      },
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Color(int.parse(colorHex.substring(1), radix: 16) + 0xFF000000),
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected 
                ? kOffBlack 
                : isRecommended 
                    ? kSeaGreen 
                    : kChristmasSilver,
            width: isSelected ? 3 : isRecommended ? 2.5 : 1.5,
          ),
          boxShadow: [
            if (isRecommended)
              BoxShadow(
                color: kSeaGreen.withOpacity(0.3),
                spreadRadius: 0,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (isSelected)
              Center(
                child: Icon(
                  Icons.check_circle,
                  color: _getContrastColor(colorHex),
                  size: 28,
                ),
              ),
            if (isRecommended && !isSelected)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.stars,
                    color: kSeaGreen,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Base hue colors (11 main colors from emotion algorithm)
    final Map<String, Map<String, String>> baseHues = {
      'White': {
        'light': '#FFFFF5',
        'mid': '#FAFAF0',
        'dark': '#F0F0E8',
      },
      'Black': {
        'light': '#4A4A4A',
        'mid': '#2D2D2D',
        'dark': '#1A1A1A',
      },
      'Gray': {
        'light': '#D0D0D0',
        'mid': '#909090',
        'dark': '#505050',
      },
      'Beige': {
        'light': '#F5E6D3',
        'mid': '#D4B896',
        'dark': '#A68A64',
      },
      'Brown': {
        'light': '#D7B49E',
        'mid': '#8B6F47',
        'dark': '#5D4E37',
      },
      'Red': {
        'light': '#FFB3B3',
        'mid': '#D64545',
        'dark': '#8B2F2F',
      },
      'Orange': {
        'light': '#FFD4A3',
        'mid': '#E67E22',
        'dark': '#A85A1A',
      },
      'Yellow': {
        'light': '#FFF9C4',
        'mid': '#FFD54F',
        'dark': '#B8941F',
      },
      'Green': {
        'light': '#C8E6C9',
        'mid': '#66BB6A',
        'dark': '#2E7D32',
      },
      'Blue': {
        'light': '#B3D9E6',
        'mid': '#5DADE2',
        'dark': '#2874A6',
      },
      'Purple': {
        'light': '#E1BEE7',
        'mid': '#AB47BC',
        'dark': '#6A1B9A',
      },
    };

    // Get mid-tone colors as the primary selector
    final primaryColors = baseHues.map((name, tones) => MapEntry(name, tones['mid']!));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Choose Color",
              style: kNunitoSansSemiBold16.copyWith(color: kOffBlack),
            ),
            if (widget.recommendedColorHex != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kIvoryGradientLight, kIvoryGradientDark],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kSeaGreen, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.stars, size: 14, color: kSeaGreen),
                    const SizedBox(width: 4),
                    Text(
                      "AI Recommended",
                      style: kNunitoSans14.copyWith(
                        color: kOffBlack,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        
        // Main color swatches in circular shape - 4, 4, 3 layout
        Column(
          children: [
            // Row 1: First 4 colors
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: primaryColors.entries.take(4).map((entry) {
                return _buildCircularColorSwatch(
                  entry.key,
                  entry.value,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            
            // Row 2: Next 4 colors
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: primaryColors.entries.skip(4).take(4).map((entry) {
                return _buildCircularColorSwatch(
                  entry.key,
                  entry.value,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            
            // Row 3: Last 3 colors
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(width: 56), // Spacer for centering
                ...primaryColors.entries.skip(8).take(3).map((entry) {
                  return _buildCircularColorSwatch(
                    entry.key,
                    entry.value,
                  );
                }).toList(),
                const SizedBox(width: 56), // Spacer for centering
              ],
            ),
          ],
        ),
        
        // Tone/Shade Slider - only show if a color is selected
        if (_baseColorHex != null) ...[
          const SizedBox(height: 32),
          
          Text(
            "Fine-tune Shade",
            style: kNunitoSansSemiBold16.copyWith(color: kOffBlack),
          ),
          const SizedBox(height: 12),
          
          // Gradient preview bar
          Container(
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _getGradientColors(_baseColorHex!),
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: kChristmasSilver, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Slider with smooth visual feedback
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.transparent,
              inactiveTrackColor: Colors.transparent,
              trackHeight: 50,
              thumbColor: kOffBlack,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
              overlayColor: kOffBlack.withOpacity(0.15),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
            ),
            child: Slider(
              value: 0.9 - _lightnessValue + 0.1, // Invert: left=light(0.9), right=dark(0.1)
              min: 0.1,
              max: 0.9,
              // Update visual preview smoothly while sliding
              onChanged: (value) {
                final invertedValue = 0.9 - value + 0.1;
                setState(() {
                  _lightnessValue = invertedValue;
                });
                // Don't call widget.onColorSelected here - just update the preview!
              },
              // Only update the actual selected color when user finishes sliding
              onChangeEnd: (value) {
                final invertedValue = 0.9 - value + 0.1;
                final adjustedColor = _adjustLightness(_baseColorHex!, invertedValue);
                _lastSelectedColorHex = adjustedColor; // Track this adjustment
                widget.onColorSelected(adjustedColor);
              },
            ),
          ),
          
          // Labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Lighter",
                  style: kNunitoSans14.copyWith(
                    color: kGraniteGrey,
                    fontSize: 12,
                  ),
                ),
                // Current color preview
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(int.parse(
                      _adjustLightness(_baseColorHex!, _lightnessValue).substring(1), 
                      radix: 16,
                    ) + 0xFF000000),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: kChristmasSilver),
                  ),
                  child: Text(
                    _adjustLightness(_baseColorHex!, _lightnessValue).substring(0, 7),
                    style: kNunitoSans14.copyWith(
                      color: _getContrastColor(_adjustLightness(_baseColorHex!, _lightnessValue)),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  "Darker",
                  style: kNunitoSans14.copyWith(
                    color: kGraniteGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
        
        const SizedBox(height: 24),
        
        // Custom color input
        if (widget.onPantoneCodeChanged != null) ...[
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
                  onChanged: widget.onPantoneCodeChanged,
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
                      widget.onColorSelected(value);
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
  
  /// Get contrasting color for check icon (white or black based on background)
  Color _getContrastColor(String hexColor) {
    final color = Color(int.parse(hexColor.substring(1), radix: 16) + 0xFF000000);
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
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
