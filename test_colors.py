# Test the color mappings we just implemented
preset_colors = [
    '#2C2C2C',  # Should be charcoal
    '#D3D3D3',  # Should be light gray
    '#F5F5F5',  # Should be off white
    '#A0522D',  # Should be sienna brown
    '#8B4513',  # Should be saddle brown
    '#CD853F',  # Should be peru brown
    '#D2691E',  # Should be chocolate
    '#800000',  # Should be maroon
    '#8B0000',  # Should be dark red
    '#B22222',  # Should be fire brick red
    '#DC143C',  # Should be crimson
    '#228B22',  # Should be forest green
    '#6B8E23',  # Should be olive drab
    '#556B2F',  # Should be dark olive green
    '#191970',  # Should be midnight blue
    '#000080',  # Should be navy
    '#0000CD',  # Should be medium blue
    '#4169E1',  # Should be royal blue
    '#9932CC',  # Should be dark orchid
    '#8A2BE2',  # Should be blue violet
    '#4B0082',  # Should be indigo
    '#6A5ACD',  # Should be slate blue
    '#7B68EE',  # Should be medium slate blue
    '#B8860B',  # Should be dark goldenrod
    '#DAA520',  # Should be goldenrod
]

expected_names = [
    'charcoal', 'light gray', 'off white', 'sienna brown', 'saddle brown',
    'peru brown', 'chocolate', 'maroon', 'dark red', 'fire brick red',
    'crimson', 'forest green', 'olive drab', 'dark olive green', 'midnight blue',
    'navy', 'medium blue', 'royal blue', 'dark orchid', 'blue violet',
    'indigo', 'slate blue', 'medium slate blue', 'dark goldenrod', 'goldenrod'
]

print("Color Mapping Test:")
print("===================")
for i, (color, expected) in enumerate(zip(preset_colors, expected_names)):
    print(f"{color} -> Expected: {expected}")

print(f"\nTotal colors tested: {len(preset_colors)}")
