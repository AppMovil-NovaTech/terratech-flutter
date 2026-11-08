import 'package:equatable/equatable.dart';

import 'traceability.dart';

/// Domain entity representing an agricultural product in the TerraTech catalog
/// (US39) along with its detailed cultivation and traceability metadata (US40).
class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.originRegion,
    required this.imageUrl,
    required this.images,
    required this.averageRating,
    required this.farmerName,
    required this.cultivationPractices,
    required this.traceability,
    this.reviewCount = 0,
    this.unitType = 'kg',
    this.availableStock = 0,
    this.farmerProfileId = 1,
    this.farmerPhone,
    this.farmerBio,
  });

  /// Unique product identifier.
  final int id;

  /// Commercial product name.
  final String name;

  /// Detailed description of the product and its qualities.
  final String description;

  /// Unit price in local currency (PEN / S/).
  final double price;

  /// Product category (e.g., "Tubérculos", "Granos Andinos", "Frutas", "Hortalizas", "Café y Cacao").
  final String category;

  /// Geographic region of origin (e.g., "Cusco", "Junín", "Arequipa", "Cajamarca", "Ica", "San Martín").
  final String originRegion;

  /// Primary image URL for catalog cards.
  final String imageUrl;

  /// Gallery of product and field image URLs for the detail view.
  final List<String> images;

  /// Average customer rating (1.0 - 5.0).
  final double averageRating;

  /// Number of verified customer reviews contributing to [averageRating].
  final int reviewCount;

  /// Measurement unit (e.g., "kg", " saco", "unidad").
  final String unitType;

  /// Available stock units registered in inventory.
  final int availableStock;

  /// Name of the farmer, producer, or agricultural cooperative.
  final String farmerName;

  /// Backend profile ID of the farmer for direct contact notifications.
  final int farmerProfileId;

  /// Direct phone number of the farmer or cooperative.
  final String? farmerPhone;

  /// Public biography or description of the farmer's cooperative.
  final String? farmerBio;

  /// Registered cultivation practices applied during production (US40 - Scenario 1).
  final List<String> cultivationPractices;

  /// Authorized provenance and production event traceability (US40 - Scenario 1 & 2).
  final TraceabilityInfo traceability;

  @override
  List<Object?> get props => <Object?>[
    id,
    name,
    description,
    price,
    category,
    originRegion,
    imageUrl,
    images,
    averageRating,
    reviewCount,
    unitType,
    availableStock,
    farmerName,
    farmerProfileId,
    farmerPhone,
    farmerBio,
    cultivationPractices,
    traceability,
  ];
}

/// Domain value object representing a completed contact inquiry from the
/// customer to the product's farmer (US40 - Scenario 3).
class FarmerContactResult extends Equatable {
  const FarmerContactResult({
    required this.productId,
    required this.productName,
    required this.farmerName,
    required this.farmerPhone,
    required this.senderEmail,
    required this.senderName,
    required this.message,
    required this.sentAt,
    this.notificationCreated = true,
  });

  final int productId;
  final String productName;
  final String farmerName;
  final String farmerPhone;
  final String senderEmail;
  final String senderName;
  final String message;
  final DateTime sentAt;
  final bool notificationCreated;

  @override
  List<Object?> get props => <Object?>[
    productId,
    productName,
    farmerName,
    farmerPhone,
    senderEmail,
    senderName,
    message,
    sentAt,
    notificationCreated,
  ];
}
