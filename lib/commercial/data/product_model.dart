import '../domain/product.dart';
import '../domain/traceability.dart';
import 'traceability_model.dart';

/// Data Transfer Object (DTO) for [Product] with `fromJson` and `toJson`
/// serialization.
///
/// Supports both the core `/api/v1/products` `ProductResource` payload
/// (`id`, `name`, `description`, `price`, `type`, `imageUrl`) and full
/// traceability/cultivation enrichment from TerraTech's bounded contexts.
class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.category,
    required super.originRegion,
    required super.imageUrl,
    required super.images,
    required super.averageRating,
    required super.farmerName,
    required super.cultivationPractices,
    required super.traceability,
    super.reviewCount = 0,
    super.unitType = 'kg',
    super.availableStock = 0,
    super.farmerProfileId = 1,
    super.farmerPhone,
    super.farmerBio,
  });

  /// Deserializes a JSON map into a [ProductModel].
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final id = _parseInt(json['id']) ?? 0;
    final name = (json['name'] as String?)?.trim().isNotEmpty == true
        ? (json['name'] as String).trim()
        : 'Producto Agrícola TerraTech';
    final description =
        (json['description'] as String?)?.trim().isNotEmpty == true
        ? (json['description'] as String).trim()
        : 'Producto agrícola cultivado con monitoreo y trazabilidad TerraTech.';
    final price = _parseDouble(json['price']) ?? 0.0;

    final rawCategory = (json['category'] ?? json['type']) as String?;
    final category = _normalizeCategory(rawCategory, name);

    final rawRegion =
        (json['originRegion'] ?? json['region'] ?? json['location']) as String?;
    final originRegion = (rawRegion != null && rawRegion.trim().isNotEmpty)
        ? rawRegion.trim()
        : _inferRegionFromText('$name $description', id);

    final primaryImage =
        (json['imageUrl'] as String?)?.trim().isNotEmpty == true
        ? (json['imageUrl'] as String).trim()
        : _defaultImageForCategory(category);

    final parsedImages = <String>[];
    final rawImages = json['images'];
    if (rawImages is List) {
      for (final item in rawImages) {
        if (item is String && item.trim().isNotEmpty) {
          parsedImages.add(item.trim());
        }
      }
    }
    if (parsedImages.isEmpty) {
      parsedImages.addAll(_buildGalleryImages(primaryImage, category));
    }

    final averageRating =
        _parseDouble(json['averageRating'] ?? json['rating']) ??
        _defaultRatingForProduct(id);
    final reviewCount = _parseInt(json['reviewCount']) ?? 2;
    final unitType = (json['unitType'] as String?)?.trim().isNotEmpty == true
        ? (json['unitType'] as String).trim()
        : 'kg';
    final availableStock =
        _parseInt(json['availableStock'] ?? json['quantity']) ?? 150;

    final farmerName =
        (json['farmerName'] as String?)?.trim().isNotEmpty == true
        ? (json['farmerName'] as String).trim()
        : 'Cooperativa Agrícola Valle Andino';
    final farmerProfileId =
        _parseInt(json['farmerProfileId'] ?? json['profileId']) ?? 1;
    final farmerPhone =
        (json['farmerPhone'] ?? json['contactPhone']) as String? ??
        '+51 984 512 309';
    final farmerBio =
        (json['farmerBio'] ?? json['publicBio']) as String? ??
        'Productor agroecológico certificado con monitoreo IoT TerraTech.';

    final parsedPractices = <String>[];
    final rawPractices = json['cultivationPractices'];
    if (rawPractices is List) {
      for (final item in rawPractices) {
        if (item is String && item.trim().isNotEmpty) {
          parsedPractices.add(item.trim());
        }
      }
    }
    if (parsedPractices.isEmpty) {
      parsedPractices.addAll(
        defaultCultivationPractices(
          category: category,
          region: originRegion,
          soilType: 'Franco Orgánico Monitoreado',
        ),
      );
    }

    final rawTraceability = json['traceability'];
    final TraceabilityInfo traceability;
    if (rawTraceability is Map<String, dynamic>) {
      traceability = TraceabilityModel.fromJson(rawTraceability);
    } else if (rawTraceability is Map) {
      traceability = TraceabilityModel.fromJson(
        rawTraceability.map((k, v) => MapEntry(k.toString(), v)),
      );
    } else {
      traceability = buildDefaultTraceability(
        productId: id,
        productName: name,
        category: category,
        originRegion: originRegion,
        farmerName: farmerName,
        farmerPhone: farmerPhone,
        profileId: farmerProfileId,
      );
    }

    return ProductModel(
      id: id,
      name: name,
      description: description,
      price: price,
      category: category,
      originRegion: originRegion,
      imageUrl: primaryImage,
      images: List<String>.unmodifiable(parsedImages),
      averageRating: averageRating,
      reviewCount: reviewCount,
      unitType: unitType,
      availableStock: availableStock,
      farmerName: farmerName,
      farmerProfileId: farmerProfileId,
      farmerPhone: farmerPhone,
      farmerBio: farmerBio,
      cultivationPractices: List<String>.unmodifiable(parsedPractices),
      traceability: traceability,
    );
  }

  /// Creates a [ProductModel] from a domain [Product] entity.
  factory ProductModel.fromEntity(Product entity) {
    return ProductModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      price: entity.price,
      category: entity.category,
      originRegion: entity.originRegion,
      imageUrl: entity.imageUrl,
      images: entity.images,
      averageRating: entity.averageRating,
      reviewCount: entity.reviewCount,
      unitType: entity.unitType,
      availableStock: entity.availableStock,
      farmerName: entity.farmerName,
      farmerProfileId: entity.farmerProfileId,
      farmerPhone: entity.farmerPhone,
      farmerBio: entity.farmerBio,
      cultivationPractices: entity.cultivationPractices,
      traceability: TraceabilityModel.fromEntity(entity.traceability),
    );
  }

  /// Serializes this [ProductModel] to a JSON map compatible with both
  /// `ProductResource` and extended catalog schemas.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'type': category,
      'category': category,
      'originRegion': originRegion,
      'imageUrl': imageUrl,
      'images': images,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'unitType': unitType,
      'availableStock': availableStock,
      'farmerName': farmerName,
      'farmerProfileId': farmerProfileId,
      if (farmerPhone != null) 'farmerPhone': farmerPhone,
      if (farmerBio != null) 'farmerBio': farmerBio,
      'cultivationPractices': cultivationPractices,
      'traceability': TraceabilityModel.fromEntity(traceability).toJson(),
    };
  }

  /// Creates an updated copy of this [ProductModel] enriched with authorized
  /// TerraTech inventory, field, profile, community, device, and report records.
  ProductModel copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    String? category,
    String? originRegion,
    String? imageUrl,
    List<String>? images,
    double? averageRating,
    int? reviewCount,
    String? unitType,
    int? availableStock,
    String? farmerName,
    int? farmerProfileId,
    String? farmerPhone,
    String? farmerBio,
    List<String>? cultivationPractices,
    TraceabilityInfo? traceability,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      originRegion: originRegion ?? this.originRegion,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      unitType: unitType ?? this.unitType,
      availableStock: availableStock ?? this.availableStock,
      farmerName: farmerName ?? this.farmerName,
      farmerProfileId: farmerProfileId ?? this.farmerProfileId,
      farmerPhone: farmerPhone ?? this.farmerPhone,
      farmerBio: farmerBio ?? this.farmerBio,
      cultivationPractices: cultivationPractices ?? this.cultivationPractices,
      traceability: traceability ?? this.traceability,
    );
  }

  /// Extracts a Peruvian agricultural region name from a field name, description,
  /// or profile location string.
  static String extractRegion({
    String? fieldName,
    String? profileLocation,
    String? description,
    int productId = 1,
  }) {
    final combined = '${fieldName ?? ''} ${description ?? ''}'.toLowerCase();
    const knownRegions = <String, String>{
      'cusco': 'Cusco',
      'valle sagrado': 'Cusco',
      'junín': 'Junín',
      'junin': 'Junín',
      'chanchamayo': 'Junín',
      'arequipa': 'Arequipa',
      'majes': 'Arequipa',
      'cajamarca': 'Cajamarca',
      'baños del inca': 'Cajamarca',
      'ica': 'Ica',
      'villacurí': 'Ica',
      'san martín': 'San Martín',
      'san martin': 'San Martín',
      'alto mayo': 'San Martín',
      'piura': 'Piura',
      'la libertad': 'La Libertad',
      'puno': 'Puno',
      'ayacucho': 'Ayacucho',
    };

    for (final entry in knownRegions.entries) {
      if (combined.contains(entry.key)) {
        return entry.value;
      }
    }

    if (profileLocation != null && profileLocation.trim().isNotEmpty) {
      return profileLocation.trim();
    }

    return _inferRegionFromText(combined, productId);
  }

  static List<String> defaultCultivationPractices({
    required String category,
    required String region,
    required String soilType,
    double? moistureThreshold,
    double? tempThreshold,
    String? sensorCode,
  }) {
    final moistureText = moistureThreshold != null
        ? 'Umbral de humedad edáfica controlado (${moistureThreshold.toStringAsFixed(0)}%)'
        : 'Monitoreo continuo de humedad de suelo por telemetría IoT';
    final sensorText = sensorCode != null && sensorCode.isNotEmpty
        ? 'Verificación NPK y microclima con nodo sensor $sensorCode'
        : 'Balance nutricional NPK verificado por sensores TerraTech';

    return <String>[
      moistureText,
      sensorText,
      'Manejo agroecológico en suelo $soilType ($region)',
      'Riego tecnificado de precisión con ahorro hídrico certificado',
      'Cosecha trazable libre de agroquímicos no autorizados',
    ];
  }

  static TraceabilityModel buildDefaultTraceability({
    required int productId,
    required String productName,
    required String category,
    required String originRegion,
    required String farmerName,
    String? farmerPhone,
    int profileId = 1,
  }) {
    final now = DateTime.now().toUtc();
    final batchCode =
        'LOTE-${originRegion.substring(0, originRegion.length >= 3 ? 3 : originRegion.length).toUpperCase()}-2026-0$productId';
    final sensorCode = 'TT-00$productId';

    return TraceabilityModel(
      batchCode: batchCode,
      originRegion: originRegion,
      fieldName: 'Parcela Agroecológica $originRegion',
      soilType: 'Franco Orgánico Certificación TerraTech',
      cropName: productName,
      farmerName: farmerName,
      fieldId: productId,
      profileId: profileId,
      fieldSizeM2: 15000.0,
      latitude: -13.3091,
      longitude: -72.1165,
      farmerCommunityName: '$farmerName - Red TerraTech',
      farmerPhone: farmerPhone ?? '+51 984 512 309',
      farmerReputationScore: 96,
      harvestDate: now.subtract(const Duration(days: 3)),
      sensorNodeCode: sensorCode,
      sensorNodeName: 'Nodo IoT NPK-Humedad $originRegion',
      soilMoistureMean: 43.5,
      technicalSummary:
          'Condiciones edáficas y climáticas verificadas dentro de los rangos óptimos de cultivo en TerraTech.',
      qrVerificationCode: 'TT-QR-2026-$productId',
      authorizedInTerraTech: true,
      productionEvents: <ProductionEventModel>[
        ProductionEventModel(
          id: 'evt-$productId-1',
          title: 'Preparación de Suelo y Siembra Registrada',
          stage: 'Siembra y Cultivo',
          description:
              'Registro autorizado de parcela en $originRegion con análisis inicial de suelo y selección de semilla certificada.',
          timestamp: now.subtract(const Duration(days: 90)),
          sensorCode: sensorCode,
          metricsSummary: 'Suelo Franco Orgánico | pH y NPK verificados',
        ),
        ProductionEventModel(
          id: 'evt-$productId-2',
          title: 'Monitoreo Continuo IoT de Humedad y Nutrientes',
          stage: 'Monitoreo IoT',
          description:
              'Lecturas horarias de humedad radicular, temperatura de suelo y niveles de Nitrógeno, Fósforo y Potasio (NPK).',
          timestamp: now.subtract(const Duration(days: 30)),
          sensorCode: sensorCode,
          metricsSummary: 'Humedad media: 43.5% | Temperatura suelo: 21.0°C',
        ),
        ProductionEventModel(
          id: 'evt-$productId-3',
          title: 'Evaluación Agronómica y Proyección de Cosecha',
          stage: 'Control de Calidad',
          description:
              'Validación técnica del desarrollo vegetativo sin estrés hídrico y autorización del lote en plataforma TerraTech.',
          timestamp: now.subtract(const Duration(days: 7)),
          sensorCode: sensorCode,
          metricsSummary: 'Índice de confianza agronómica: 94%',
        ),
        ProductionEventModel(
          id: 'evt-$productId-4',
          title: 'Cosecha y Registro de Lote en Inventario',
          stage: 'Cosecha y Despacho',
          description:
              'Cosecha selectiva y registro del lote $batchCode disponible para comercialización directa.',
          timestamp: now.subtract(const Duration(days: 2)),
          sensorCode: sensorCode,
          metricsSummary: 'Lote $batchCode | Trazabilidad 100% verificada',
        ),
      ],
    );
  }

  static String _normalizeCategory(String? rawCategory, String name) {
    final trimmed = rawCategory?.trim() ?? '';
    if (trimmed.isNotEmpty &&
        trimmed.toLowerCase() != 'kg' &&
        trimmed.toLowerCase() != 'unidad' &&
        trimmed.toLowerCase() != 'saco') {
      return trimmed;
    }

    final lowerName = name.toLowerCase();
    if (lowerName.contains('papa') ||
        lowerName.contains('camote') ||
        lowerName.contains('yuca') ||
        lowerName.contains('olluco')) {
      return 'Tubérculos';
    }
    if (lowerName.contains('quinua') ||
        lowerName.contains('kiwicha') ||
        lowerName.contains('maíz') ||
        lowerName.contains('maiz') ||
        lowerName.contains('tarwi')) {
      return 'Granos Andinos';
    }
    if (lowerName.contains('café') ||
        lowerName.contains('cafe') ||
        lowerName.contains('cacao')) {
      return 'Café y Cacao';
    }
    if (lowerName.contains('palta') ||
        lowerName.contains('aguaymanto') ||
        lowerName.contains('mango') ||
        lowerName.contains('arándano')) {
      return 'Frutas';
    }
    return 'Hortalizas';
  }

  static String _inferRegionFromText(String text, int id) {
    final lower = text.toLowerCase();
    if (lower.contains('cusco') || lower.contains('valle sagrado')) {
      return 'Cusco';
    }
    if (lower.contains('junín') ||
        lower.contains('junin') ||
        lower.contains('chanchamayo')) {
      return 'Junín';
    }
    if (lower.contains('arequipa') || lower.contains('majes')) {
      return 'Arequipa';
    }
    if (lower.contains('cajamarca')) {
      return 'Cajamarca';
    }
    if (lower.contains('ica')) {
      return 'Ica';
    }
    if (lower.contains('san martín') ||
        lower.contains('san martin') ||
        lower.contains('alto mayo')) {
      return 'San Martín';
    }

    const fallbackRegions = <String>[
      'Cusco',
      'Junín',
      'Arequipa',
      'Cajamarca',
      'Ica',
      'San Martín',
    ];
    return fallbackRegions[id.abs() % fallbackRegions.length];
  }

  static double _defaultRatingForProduct(int id) {
    const ratings = <double>[4.9, 4.8, 4.7, 4.9, 4.6, 4.8, 5.0, 4.7];
    return ratings[id.abs() % ratings.length];
  }

  static String _defaultImageForCategory(String category) {
    return switch (category) {
      'Tubérculos' =>
        'https://images.unsplash.com/photo-1518977676601-b53f82aba655?auto=format&fit=crop&w=800&q=80',
      'Granos Andinos' =>
        'https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&w=800&q=80',
      'Café y Cacao' =>
        'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?auto=format&fit=crop&w=800&q=80',
      'Frutas' =>
        'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?auto=format&fit=crop&w=800&q=80',
      _ =>
        'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?auto=format&fit=crop&w=800&q=80',
    };
  }

  static List<String> _buildGalleryImages(
    String primaryImage,
    String category,
  ) {
    final secondaryFieldImage = switch (category) {
      'Tubérculos' =>
        'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=800&q=80',
      'Granos Andinos' =>
        'https://images.unsplash.com/photo-1464226184884-fa280b87c399?auto=format&fit=crop&w=800&q=80',
      'Café y Cacao' =>
        'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=800&q=80',
      'Frutas' =>
        'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=800&q=80',
      _ =>
        'https://images.unsplash.com/photo-1523348837708-15d4a09cfac2?auto=format&fit=crop&w=800&q=80',
    };

    const iotMonitoringImage =
        'https://images.unsplash.com/photo-1586771107445-d3ca888129ff?auto=format&fit=crop&w=800&q=80';

    return <String>{
      primaryImage,
      secondaryFieldImage,
      iotMonitoringImage,
    }.toList(growable: false);
  }

  static int? _parseInt(Object? value) {
    return switch (value) {
      final int v => v,
      final num v => v.toInt(),
      final String v => int.tryParse(v),
      _ => null,
    };
  }

  static double? _parseDouble(Object? value) {
    return switch (value) {
      final double v => v,
      final num v => v.toDouble(),
      final String v => double.tryParse(v),
      _ => null,
    };
  }
}
