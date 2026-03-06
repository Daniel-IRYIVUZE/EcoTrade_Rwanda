enum WasteType { uco, glass, cardboard, plastic, metal, organic, ewaste }

extension WasteTypeExtension on WasteType {
  String get label {
    switch (this) {
      case WasteType.uco: return 'Used Cooking Oil';
      case WasteType.glass: return 'Glass';
      case WasteType.cardboard: return 'Cardboard';
      case WasteType.plastic: return 'Plastic';
      case WasteType.metal: return 'Metal';
      case WasteType.organic: return 'Organic Waste';
      case WasteType.ewaste: return 'E-Waste';
    }
  }

  String get icon {
    switch (this) {
      case WasteType.uco: return '🛢️';
      case WasteType.glass: return '🍶';
      case WasteType.cardboard: return '📦';
      case WasteType.plastic: return '♻️';
      case WasteType.metal: return '🔩';
      case WasteType.organic: return '🌿';
      case WasteType.ewaste: return '💻';
    }
  }
}
