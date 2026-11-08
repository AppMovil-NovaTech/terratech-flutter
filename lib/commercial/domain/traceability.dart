import 'package:equatable/equatable.dart';

/// Represents an individual production or monitoring event registered and
/// authorized in TerraTech for a product's crop cycle (US40 - Scenario 2).
class ProductionEvent extends Equatable {
  const ProductionEvent({
    required this.id,
    required this.title,
    required this.stage,
    required this.description,
    required this.timestamp,
    this.sensorCode,
    this.metricsSummary,
    this.isAuthorized = true,
  });

  /// Unique identifier of the production event.
  final String id;

  /// Human-readable title of the milestone or agronomic event.
  final String title;

  /// Production stage (e.g., "Siembra", "Monitoreo IoT", "Control Agronómico", "Cosecha").
  final String stage;

  /// Detailed description of the event registered in TerraTech.
  final String description;

  /// Timestamp when the event was recorded.
  final DateTime timestamp;

  /// Optional TerraTech IoT sensor node code that verified this event.
  final String? sensorCode;

  /// Optional telemetry or agronomic metric snapshot (e.g., "Humedad: 44.2% | NPK estable").
  final String? metricsSummary;

  /// Indicates that the event is registered and authorized in TerraTech.
  final bool isAuthorized;

  @override
  List<Object?> get props => <Object?>[
    id,
    title,
    stage,
    description,
    timestamp,
    sensorCode,
    metricsSummary,
    isAuthorized,
  ];
}

/// Domain entity encapsulating the complete provenance, farmer, crop, and
/// production event traceability of an agricultural product (US40).
class TraceabilityInfo extends Equatable {
  const TraceabilityInfo({
    required this.batchCode,
    required this.originRegion,
    required this.fieldName,
    required this.soilType,
    required this.cropName,
    required this.farmerName,
    this.fieldId,
    this.profileId,
    this.fieldSizeM2,
    this.latitude,
    this.longitude,
    this.farmerCommunityName,
    this.farmerPhone,
    this.farmerReputationScore,
    this.harvestDate,
    this.sensorNodeCode,
    this.sensorNodeName,
    this.soilMoistureMean,
    this.technicalSummary,
    this.qrVerificationCode,
    this.authorizedInTerraTech = true,
    this.productionEvents = const <ProductionEvent>[],
  });

  /// Registered inventory lot/batch identifier (e.g., "Lote Cusco-PN-2026-01").
  final String batchCode;

  /// Geographic region of origin (e.g., "Cusco", "Junín", "Arequipa").
  final String originRegion;

  /// Name of the agricultural parcel or fundo registered in TerraTech.
  final String fieldName;

  /// Registered soil classification of the origin parcel.
  final String soilType;

  /// Associated crop name cultivated in the parcel.
  final String cropName;

  /// Name of the producer, farmer, or agricultural cooperative.
  final String farmerName;

  /// Optional backend Field ID associated with the lot.
  final int? fieldId;

  /// Optional backend Farmer Profile ID associated with the lot.
  final int? profileId;

  /// Cultivated parcel area in square meters.
  final double? fieldSizeM2;

  /// Latitude coordinate of the origin parcel.
  final double? latitude;

  /// Longitude coordinate of the origin parcel.
  final double? longitude;

  /// Public community profile nickname of the producer.
  final String? farmerCommunityName;

  /// Producer contact phone registered in TerraTech.
  final String? farmerPhone;

  /// Community reputation score (0-100) of the producer.
  final int? farmerReputationScore;

  /// Date when the lot was harvested or registered in stock.
  final DateTime? harvestDate;

  /// Code of the TerraTech IoT sensor node monitoring the parcel (e.g., "TT-CUS001").
  final String? sensorNodeCode;

  /// Descriptive name of the IoT sensor node.
  final String? sensorNodeName;

  /// Mean soil moisture percentage recorded by the parcel's sensor node.
  final double? soilMoistureMean;

  /// Agronomic technical interpretation registered for the parcel.
  final String? technicalSummary;

  /// Unique verification code for QR traceability lookup.
  final String? qrVerificationCode;

  /// Flag confirming data is previously registered and authorized in TerraTech.
  final bool authorizedInTerraTech;

  /// Chronological list of authorized production events for this product.
  final List<ProductionEvent> productionEvents;

  @override
  List<Object?> get props => <Object?>[
    batchCode,
    originRegion,
    fieldName,
    soilType,
    cropName,
    farmerName,
    fieldId,
    profileId,
    fieldSizeM2,
    latitude,
    longitude,
    farmerCommunityName,
    farmerPhone,
    farmerReputationScore,
    harvestDate,
    sensorNodeCode,
    sensorNodeName,
    soilMoistureMean,
    technicalSummary,
    qrVerificationCode,
    authorizedInTerraTech,
    productionEvents,
  ];
}
