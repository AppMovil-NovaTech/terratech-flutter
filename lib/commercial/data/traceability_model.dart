import '../domain/traceability.dart';

/// Data Transfer Object (DTO) for [ProductionEvent] with JSON serialization.
class ProductionEventModel extends ProductionEvent {
  const ProductionEventModel({
    required super.id,
    required super.title,
    required super.stage,
    required super.description,
    required super.timestamp,
    super.sensorCode,
    super.metricsSummary,
    super.isAuthorized = true,
  });

  factory ProductionEventModel.fromJson(Map<String, dynamic> json) {
    final rawDate = json['timestamp'] ?? json['recordedAt'] ?? json['date'];
    final parsedDate = switch (rawDate) {
      final String value => DateTime.tryParse(value) ?? DateTime.now().toUtc(),
      final int millis => DateTime.fromMillisecondsSinceEpoch(
        millis,
        isUtc: true,
      ),
      _ => DateTime.now().toUtc(),
    };

    return ProductionEventModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] as String?)?.trim().isNotEmpty == true
          ? (json['title'] as String).trim()
          : 'Evento de Producción Registrado',
      stage: (json['stage'] as String?)?.trim().isNotEmpty == true
          ? (json['stage'] as String).trim()
          : 'Producción',
      description: (json['description'] as String?)?.trim() ?? '',
      timestamp: parsedDate,
      sensorCode: (json['sensorCode'] as String?)?.trim(),
      metricsSummary: (json['metricsSummary'] as String?)?.trim(),
      isAuthorized: json['isAuthorized'] as bool? ?? true,
    );
  }

  factory ProductionEventModel.fromEntity(ProductionEvent entity) {
    return ProductionEventModel(
      id: entity.id,
      title: entity.title,
      stage: entity.stage,
      description: entity.description,
      timestamp: entity.timestamp,
      sensorCode: entity.sensorCode,
      metricsSummary: entity.metricsSummary,
      isAuthorized: entity.isAuthorized,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'stage': stage,
      'description': description,
      'timestamp': timestamp.toUtc().toIso8601String(),
      if (sensorCode != null) 'sensorCode': sensorCode,
      if (metricsSummary != null) 'metricsSummary': metricsSummary,
      'isAuthorized': isAuthorized,
    };
  }
}

/// Data Transfer Object (DTO) for [TraceabilityInfo] with JSON serialization.
class TraceabilityModel extends TraceabilityInfo {
  const TraceabilityModel({
    required super.batchCode,
    required super.originRegion,
    required super.fieldName,
    required super.soilType,
    required super.cropName,
    required super.farmerName,
    super.fieldId,
    super.profileId,
    super.fieldSizeM2,
    super.latitude,
    super.longitude,
    super.farmerCommunityName,
    super.farmerPhone,
    super.farmerReputationScore,
    super.harvestDate,
    super.sensorNodeCode,
    super.sensorNodeName,
    super.soilMoistureMean,
    super.technicalSummary,
    super.qrVerificationCode,
    super.authorizedInTerraTech = true,
    super.productionEvents = const <ProductionEventModel>[],
  });

  factory TraceabilityModel.fromJson(Map<String, dynamic> json) {
    final rawEvents = json['productionEvents'];
    final events = <ProductionEventModel>[];
    if (rawEvents is List) {
      for (final item in rawEvents) {
        if (item is Map<String, dynamic>) {
          events.add(ProductionEventModel.fromJson(item));
        } else if (item is Map) {
          events.add(
            ProductionEventModel.fromJson(
              item.map((k, v) => MapEntry(k.toString(), v)),
            ),
          );
        }
      }
    }

    final rawHarvestDate = json['harvestDate'] ?? json['createdAt'];
    final harvestDate = rawHarvestDate is String
        ? DateTime.tryParse(rawHarvestDate)
        : null;

    return TraceabilityModel(
      batchCode: (json['batchCode'] as String?)?.trim().isNotEmpty == true
          ? (json['batchCode'] as String).trim()
          : 'LOTE-TT-VERIFICADO',
      originRegion: (json['originRegion'] as String?)?.trim().isNotEmpty == true
          ? (json['originRegion'] as String).trim()
          : 'Cusco',
      fieldName: (json['fieldName'] as String?)?.trim().isNotEmpty == true
          ? (json['fieldName'] as String).trim()
          : 'Parcela Certificada TerraTech',
      soilType: (json['soilType'] as String?)?.trim().isNotEmpty == true
          ? (json['soilType'] as String).trim()
          : 'Franco Orgánico',
      cropName: (json['cropName'] as String?)?.trim().isNotEmpty == true
          ? (json['cropName'] as String).trim()
          : 'Cultivo Agroecológico',
      farmerName: (json['farmerName'] as String?)?.trim().isNotEmpty == true
          ? (json['farmerName'] as String).trim()
          : 'Cooperativa Agrícola Valle Andino',
      fieldId: _parseInt(json['fieldId']),
      profileId: _parseInt(json['profileId']),
      fieldSizeM2: _parseDouble(json['fieldSizeM2'] ?? json['sizeM2']),
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      farmerCommunityName: (json['farmerCommunityName'] as String?)?.trim(),
      farmerPhone: (json['farmerPhone'] as String?)?.trim(),
      farmerReputationScore: _parseInt(json['farmerReputationScore']),
      harvestDate: harvestDate,
      sensorNodeCode: (json['sensorNodeCode'] as String?)?.trim(),
      sensorNodeName: (json['sensorNodeName'] as String?)?.trim(),
      soilMoistureMean: _parseDouble(json['soilMoistureMean']),
      technicalSummary: (json['technicalSummary'] as String?)?.trim(),
      qrVerificationCode: (json['qrVerificationCode'] as String?)?.trim(),
      authorizedInTerraTech: json['authorizedInTerraTech'] as bool? ?? true,
      productionEvents: List<ProductionEventModel>.unmodifiable(events),
    );
  }

  factory TraceabilityModel.fromEntity(TraceabilityInfo entity) {
    return TraceabilityModel(
      batchCode: entity.batchCode,
      originRegion: entity.originRegion,
      fieldName: entity.fieldName,
      soilType: entity.soilType,
      cropName: entity.cropName,
      farmerName: entity.farmerName,
      fieldId: entity.fieldId,
      profileId: entity.profileId,
      fieldSizeM2: entity.fieldSizeM2,
      latitude: entity.latitude,
      longitude: entity.longitude,
      farmerCommunityName: entity.farmerCommunityName,
      farmerPhone: entity.farmerPhone,
      farmerReputationScore: entity.farmerReputationScore,
      harvestDate: entity.harvestDate,
      sensorNodeCode: entity.sensorNodeCode,
      sensorNodeName: entity.sensorNodeName,
      soilMoistureMean: entity.soilMoistureMean,
      technicalSummary: entity.technicalSummary,
      qrVerificationCode: entity.qrVerificationCode,
      authorizedInTerraTech: entity.authorizedInTerraTech,
      productionEvents: entity.productionEvents
          .map(ProductionEventModel.fromEntity)
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'batchCode': batchCode,
      'originRegion': originRegion,
      'fieldName': fieldName,
      'soilType': soilType,
      'cropName': cropName,
      'farmerName': farmerName,
      if (fieldId != null) 'fieldId': fieldId,
      if (profileId != null) 'profileId': profileId,
      if (fieldSizeM2 != null) 'fieldSizeM2': fieldSizeM2,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (farmerCommunityName != null)
        'farmerCommunityName': farmerCommunityName,
      if (farmerPhone != null) 'farmerPhone': farmerPhone,
      if (farmerReputationScore != null)
        'farmerReputationScore': farmerReputationScore,
      if (harvestDate != null)
        'harvestDate': harvestDate!.toUtc().toIso8601String(),
      if (sensorNodeCode != null) 'sensorNodeCode': sensorNodeCode,
      if (sensorNodeName != null) 'sensorNodeName': sensorNodeName,
      if (soilMoistureMean != null) 'soilMoistureMean': soilMoistureMean,
      if (technicalSummary != null) 'technicalSummary': technicalSummary,
      if (qrVerificationCode != null) 'qrVerificationCode': qrVerificationCode,
      'authorizedInTerraTech': authorizedInTerraTech,
      'productionEvents': productionEvents
          .map((e) => ProductionEventModel.fromEntity(e).toJson())
          .toList(growable: false),
    };
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
