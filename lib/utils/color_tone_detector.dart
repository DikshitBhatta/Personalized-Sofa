import 'package:flutter/material.dart';

class ColorToneResult {
  final String colorName;
  final String tone; // 'light', 'mid', 'dark'
  
  ColorToneResult({required this.colorName, required this.tone});
  
  @override
  String toString() => '$tone $colorName';
}

class ColorToneDetector {
  // Base hue colors (11 main colors from emotion algorithm)
  static final Map<String, Map<String, String>> baseHues = {
    'white': {
      'light': '#FFFFF5',
      'mid': '#FAFAF0',
      'dark': '#F0F0E8',
    },
    'black': {
      'light': '#4A4A4A',
      'mid': '#2D2D2D',
      'dark': '#1A1A1A',
    },
    'gray': {
      'light': '#D0D0D0',
      'mid': '#909090',
      'dark': '#505050',
    },
    'beige': {
      'light': '#F5E6D3',
      'mid': '#D4B896',
      'dark': '#A68A64',
    },
    'brown': {
      'light': '#D7B49E',
      'mid': '#8B6F47',
      'dark': '#5D4E37',
    },
    'red': {
      'light': '#FFB3B3',
      'mid': '#D64545',
      'dark': '#8B2F2F',
    },
    'orange': {
      'light': '#FFD4A3',
      'mid': '#E67E22',
      'dark': '#A85A1A',
    },
    'yellow': {
      'light': '#FFF9C4',
      'mid': '#FFD54F',
      'dark': '#B8941F',
    },
    'green': {
      'light': '#C8E6C9',
      'mid': '#66BB6A',
      'dark': '#2E7D32',
    },
    'blue': {
      'light': '#B3D9E6',
      'mid': '#5DADE2',
      'dark': '#2874A6',
    },
    'purple': {
      'light': '#E1BEE7',
      'mid': '#AB47BC',
      'dark': '#6A1B9A',
    },
  };
  
  /// Detect the base color name and tone from a hex color
  static ColorToneResult detectColorAndTone(String hexColor) {
    if (!hexColor.startsWith('#') || hexColor.length != 7) {
      return ColorToneResult(colorName: 'gray', tone: 'mid');
    }
    
    // First, try exact match with base colors
    final upperHex = hexColor.toUpperCase();
    for (var entry in baseHues.entries) {
      final colorName = entry.key;
      final tones = entry.value;
      
      if (tones['light']!.toUpperCase() == upperHex) {
        return ColorToneResult(colorName: colorName, tone: 'light');
      }
      if (tones['mid']!.toUpperCase() == upperHex) {
        return ColorToneResult(colorName: colorName, tone: 'mid');
      }
      if (tones['dark']!.toUpperCase() == upperHex) {
        return ColorToneResult(colorName: colorName, tone: 'dark');
      }
    }
    
    // No exact match, find closest base color and determine tone
    final color = Color(int.parse(hexColor.substring(1), radix: 16) + 0xFF000000);
    final hslColor = HSLColor.fromColor(color);
    
    // Find closest base color by hue
    String closestColorName = _findClosestColorByHue(hslColor);
    
    // Determine tone based on lightness
    String tone;
    if (hslColor.lightness < 0.35) {
      tone = 'dark';
    } else if (hslColor.lightness > 0.65) {
      tone = 'light';
    } else {
      tone = 'mid';
    }
    
    return ColorToneResult(colorName: closestColorName, tone: tone);
  }
  
  /// Find the closest base color by hue similarity
  static String _findClosestColorByHue(HSLColor targetColor) {
    // Special handling for achromatic colors (white, black, gray)
    if (targetColor.saturation < 0.1) {
      if (targetColor.lightness > 0.85) return 'white';
      if (targetColor.lightness < 0.25) return 'black';
      return 'gray';
    }
    
    // For chromatic colors, find closest hue
    final targetHue = targetColor.hue;
    
    // Define approximate hue ranges for each color
    // Hue is 0-360 degrees
    if (targetHue >= 0 && targetHue < 15) return 'red';        // Red
    if (targetHue >= 15 && targetHue < 45) return 'orange';    // Orange
    if (targetHue >= 45 && targetHue < 70) return 'yellow';    // Yellow
    if (targetHue >= 70 && targetHue < 150) return 'green';    // Green
    if (targetHue >= 150 && targetHue < 260) return 'blue';    // Blue
    if (targetHue >= 260 && targetHue < 330) return 'purple';  // Purple
    if (targetHue >= 330) return 'red';                         // Red (wraps around)
    
    // Check for beige/brown (low saturation oranges/yellows)
    if (targetHue >= 20 && targetHue < 50 && targetColor.saturation < 0.5) {
      if (targetColor.lightness > 0.6) return 'beige';
      return 'brown';
    }
    
    return 'gray'; // Fallback
  }
  
  /// Get a descriptive string for Meshy AI (e.g., "light blue", "dark brown")
  static String getColorDescription(String hexColor) {
    final result = detectColorAndTone(hexColor);
    return result.toString();
  }
}
