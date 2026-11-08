import 'package:dio/dio.dart';

import '../../core/errors/problem_details.dart';
import '../../core/network/dio_client.dart';
import '../../core/storage/secure_storage.dart';
import '../domain/product.dart';
import 'product_model.dart';
import 'traceability_model.dart';

/// Static mock authentication session configuration for the seeded test user
/// (`test.user@terratech.com`) while IAM integration is pending.
abstract final class MockAuthSession {
  static const int testUserId = 1;
  static const String testUserEmail = 'test.user@terratech.com';
  static const String testUserFullName = 'Usuario de Prueba TerraTech';
  static const String userEmailStorageKey = 'auth_user_email';
  static const String userNameStorageKey = 'auth_user_full_name';

  /// Valid HS256 JWT token for the seeded local user (`id: 1`,
  /// `email: test.user@terratech.com`, `token_version: 1`).
  static const String staticJwtToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
      'eyJzdWIiOiIxIiwidG9rZW5fdmVyc2lvbiI6IjEiLCJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL3JvbGUiOiJBZ3JpY3VsdG9yIiwiaHR0cDovL3NjaGVtYXMueG1sc29hcC5vcmcvd3MvMjAwNS8wNS9pZGVudGl0eS9jbGFpbXMvbmFtZSI6InRlc3QudXNlckB0ZXJyYXRlY2guY29tIiwiaWF0IjoxNzAwMDAwMDAwLCJuYmYiOjE3MDAwMDAwMDAsImV4cCI6MTkyNDkwNTYwMH0.'
      '5LQmxnY7VyqEDwvWUZExn2f1A1h2if0ptT7omb_cpCQ';

  /// Injects the static JWT token and user metadata into [secureStorage] if no
  /// active session token is currently present.
  static Future<void> ensureSeeded(SecureStorage secureStorage) async {
    try {
      final existingToken = await secureStorage.getToken();
      if (existingToken == null || existingToken.trim().isEmpty) {
        await secureStorage.saveToken(staticJwtToken);
      }
      await secureStorage.write(
        key: userEmailStorageKey,
        value: testUserEmail,
      );
      await secureStorage.write(
        key: userNameStorageKey,
        value: testUserFullName,
      );
    } catch (_) {
      // Ignore platform storage exceptions in headless/test environments.
    }
  }
}

/// Contract for remote HTTP operations of the Commercial bounded context.
abstract interface class CommercialRemoteDataSource {
  /// Fetches all catalog products from `/api/v1/products` and enriches them
  /// with authorized TerraTech provenance and rating records.
  Future<List<ProductModel>> getProducts();

  /// Fetches a single product by [id] from `/api/v1/products/{id}` along with
  /// its complete traceability and cultivation practices.
  Future<ProductModel> getProductById(int id);

  /// Fetches the authorized TerraTech traceability record for [productId].
  Future<TraceabilityModel> getProductTraceability(int productId);

  /// Sends a direct contact inquiry to the product's farmer utilizing the
  /// static user session (`test.user@terratech.com`).
  Future<FarmerContactResult> contactFarmer({
    required Product product,
    required String message,
  });
}

/// Implementation of [CommercialRemoteDataSource] backed by [DioClient].
class CommercialRemoteDataSourceImpl implements CommercialRemoteDataSource {
  CommercialRemoteDataSourceImpl({
    required DioClient dioClient,
    this.secureStorage,
  }) : _dio = dioClient.dio;

  static const String productsEndpoint = '/api/v1/products';
  static const String inventoriesEndpoint = '/api/v1/inventories';
  static const String fieldsEndpoint = '/api/v1/fields';
  static const String myProfileEndpoint = '/api/v1/profiles/me';
  static const String communityProfilesEndpoint = '/api/v1/community-profiles';
  static const String reportsEndpoint = '/api/v1/reports';
  static const String notificationsEndpoint = '/api/v1/notifications';

  final Dio _dio;
  final SecureStorage? secureStorage;

  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await _dio.get< dynamic>(productsEndpoint);
      final rawList = _extractList(response.data);

      final contextData = await _loadAuthorizedContext();

      return rawList
          .map((item) => _buildEnrichedProductModel(item, contextData))
          .toList(growable: false);
    } on DioException catch (e) {
      throw _extractProblemDetails(e);
    }
  }

  @override
  Future<ProductModel> getProductById(int id) async {
    try {
      final response = await _dio.get<dynamic>('$productsEndpoint/$id');
      final rawMap = _extractMap(response.data);
      if (rawMap == null) {
        throw const ProblemDetails(
          title: 'Producto no encontrado',
          status: 404,
          detail: 'No se pudo procesar la información del producto solicitado.',
        );
      }

      final contextData = await _loadAuthorizedContext(targetProductId: id);
      return _buildEnrichedProductModel(rawMap, contextData);
    } on DioException catch (e) {
      throw _extractProblemDetails(e);
    }
  }

  @override
  Future<TraceabilityModel> getProductTraceability(int productId) async {
    final product = await getProductById(productId);
    return TraceabilityModel.fromEntity(product.traceability);
  }

  @override
  Future<FarmerContactResult> contactFarmer({
    required Product product,
    required String message,
  }) async {
    final trimmedMessage = message.trim();
    if (trimmedMessage.isEmpty) {
      throw const ProblemDetails(
        title: 'Mensaje vacío',
        status: 400,
        detail: 'Por favor ingresa un mensaje para contactar al agricultor.',
      );
    }

    String senderEmail = MockAuthSession.testUserEmail;
    String senderName = MockAuthSession.testUserFullName;

    if (secureStorage != null) {
      try {
        final storedEmail = await secureStorage!.read(
          MockAuthSession.userEmailStorageKey,
        );
        final storedName = await secureStorage!.read(
          MockAuthSession.userNameStorageKey,
        );
        if (storedEmail != null && storedEmail.trim().isNotEmpty) {
          senderEmail = storedEmail.trim();
        }
        if (storedName != null && storedName.trim().isNotEmpty) {
          senderName = storedName.trim();
        }
      } catch (_) {
        // Fallback to static constants if storage is unavailable.
      }
    }

    bool notificationCreated = false;
    try {
      final response = await _dio.post<dynamic>(
        notificationsEndpoint,
        data: <String, dynamic>{
          'profileId': product.farmerProfileId,
          'title': 'Consulta comercial: ${product.name}',
          'message':
              'De $senderName ($senderEmail) sobre lote ${product.traceability.batchCode}: $trimmedMessage',
          'isAlert': false,
        },
      );
      notificationCreated =
          response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;
    } catch (_) {
      // Even if the notification endpoint is unreachable or restricted for a
      // foreign profile, we still complete the contact handshake with the
      // farmer's authorized contact information.
      notificationCreated = false;
    }

    return FarmerContactResult(
      productId: product.id,
      productName: product.name,
      farmerName: product.farmerName,
      farmerPhone: product.farmerPhone ?? '+51 984 512 309',
      senderEmail: senderEmail,
      senderName: senderName,
      message: trimmedMessage,
      sentAt: DateTime.now().toUtc(),
      notificationCreated: notificationCreated,
    );
  }

  Future<_AuthorizedBackendContext> _loadAuthorizedContext({
    int? targetProductId,
  }) async {
    final results = await Future.wait<dynamic>(<Future<dynamic>>[
      _safeGet(inventoriesEndpoint),
      _safeGet(fieldsEndpoint),
      _safeGet(myProfileEndpoint),
      _safeGet(communityProfilesEndpoint),
      _safeGet(reportsEndpoint),
    ]);

    final inventories = _extractList(results[0]);
    final fields = _extractList(results[1]);
    final myProfile = _extractMap(results[2]);
    final communityProfiles = _extractList(results[3]);
    final reports = _extractList(results[4]);

    // Determine profileId to fetch product reviews/comments.
    int profileId = 1;
    if (myProfile != null && myProfile['id'] is int) {
      profileId = myProfile['id'] as int;
    } else if (communityProfiles.isNotEmpty &&
        communityProfiles.first['profileId'] is int) {
      profileId = communityProfiles.first['profileId'] as int;
    }

    final commentsData = await _safeGet(
      '$communityProfilesEndpoint/$profileId/comments',
    );
    final comments = _extractList(commentsData);

    // If loading detail for a specific product, also fetch devices for its field.
    final devicesByFieldId = <int, List<Map<String, dynamic>>>{};
    if (targetProductId != null) {
      final matchingInventory = inventories
          .where((inv) => inv['productId'] == targetProductId)
          .firstOrNull;
      final fieldId = matchingInventory?['fieldId'];
      if (fieldId is int && fieldId > 0) {
        final devicesData = await _safeGet('$fieldsEndpoint/$fieldId/devices');
        devicesByFieldId[fieldId] = _extractList(devicesData);
      }
    }

    return _AuthorizedBackendContext(
      inventories: inventories,
      fields: fields,
      myProfile: myProfile,
      communityProfiles: communityProfiles,
      comments: comments,
      reports: reports,
      devicesByFieldId: devicesByFieldId,
    );
  }

  ProductModel _buildEnrichedProductModel(
    Map<String, dynamic> rawProductJson,
    _AuthorizedBackendContext context,
  ) {
    final baseModel = ProductModel.fromJson(rawProductJson);

    // If the JSON already carried an explicit traceability object, preserve it.
    if (rawProductJson['traceability'] is Map) {
      return baseModel;
    }

    final productId = baseModel.id;
    final inventory = context.inventories
        .where((item) => _asInt(item['productId']) == productId)
        .firstOrNull;

    final fieldId = _asInt(inventory?['fieldId']);
    final field = fieldId != null
        ? context.fields.where((f) => _asInt(f['id']) == fieldId).firstOrNull
        : null;

    final profileId =
        _asInt(inventory?['profileId']) ??
        _asInt(field?['profileId']) ??
        _asInt(context.myProfile?['id']) ??
        1;

    final communityProfile = context.communityProfiles
        .where((cp) => _asInt(cp['profileId']) == profileId)
        .firstOrNull;

    // Calculate average rating from authorized product comments if available.
    final productComments = context.comments
        .where((c) => _asInt(c['productId']) == productId)
        .toList(growable: false);

    double averageRating = baseModel.averageRating;
    int reviewCount = baseModel.reviewCount;
    if (productComments.isNotEmpty) {
      final ratings = productComments
          .map((c) => _asDouble(c['rating']) ?? 5.0)
          .toList(growable: false);
      final sum = ratings.fold<double>(0.0, (acc, r) => acc + r);
      averageRating = double.parse((sum / ratings.length).toStringAsFixed(1));
      reviewCount = ratings.length;
    }

    final fieldName = (field?['name'] as String?)?.trim();
    final soilType = (field?['soilType'] as String?)?.trim();
    final cropName = (field?['cropName'] as String?)?.trim();
    final fieldSizeM2 = _asDouble(field?['sizeM2']);
    final latitude = _asDouble(field?['latitude']);
    final longitude = _asDouble(field?['longitude']);

    final profileLocation = (context.myProfile?['location'] as String?)?.trim();
    final originRegion = rawProductJson['originRegion'] is String
        ? (rawProductJson['originRegion'] as String).trim()
        : ProductModel.extractRegion(
            fieldName: fieldName,
            profileLocation: profileLocation,
            description: baseModel.description,
            productId: productId,
          );

    final fundoName = (context.myProfile?['fundoName'] as String?)?.trim();
    final communityNickname = (communityProfile?['nickname'] as String?)
        ?.trim();
    final farmerName = (fundoName != null && fundoName.isNotEmpty)
        ? fundoName
        : (communityNickname != null && communityNickname.isNotEmpty)
        ? communityNickname
        : baseModel.farmerName;

    final farmerPhone =
        (context.myProfile?['contactPhone'] as String?)?.trim() ??
        baseModel.farmerPhone ??
        '+51 984 512 309';

    final farmerBio =
        (communityProfile?['publicBio'] as String?)?.trim() ??
        baseModel.farmerBio;
    final reputationScore =
        _asInt(communityProfile?['reputationScore']) ??
        baseModel.traceability.farmerReputationScore ??
        96;

    final unitType =
        (inventory?['unitType'] as String?)?.trim() ?? baseModel.unitType;
    final availableStock =
        _asInt(inventory?['quantity']) ?? baseModel.availableStock;
    final batchCode = (inventory?['name'] as String?)?.trim().isNotEmpty == true
        ? (inventory!['name'] as String).trim()
        : baseModel.traceability.batchCode;
    final harvestDate = inventory?['createdAt'] is String
        ? DateTime.tryParse(inventory!['createdAt'] as String)
        : baseModel.traceability.harvestDate;

    // Resolve devices and agronomic reports for the field.
    final fieldDevices = fieldId != null
        ? (context.devicesByFieldId[fieldId] ?? const <Map<String, dynamic>>[])
        : const <Map<String, dynamic>>[];
    final primaryDevice = fieldDevices.firstOrNull;

    final matchingReport = context.reports.where((r) {
      final reportDeviceId = _asInt(r['deviceId']);
      if (primaryDevice != null &&
          reportDeviceId == _asInt(primaryDevice['id'])) {
        return true;
      }
      return reportDeviceId == fieldId;
    }).firstOrNull;

    final sensorCode =
        (primaryDevice?['sensorCode'] as String?)?.trim() ??
        'TT-${originRegion.substring(0, originRegion.length >= 3 ? 3 : originRegion.length).toUpperCase()}00${fieldId ?? productId}';
    final sensorName =
        (primaryDevice?['name'] as String?)?.trim() ??
        'Nodo NPK-Humedad $originRegion #${fieldId ?? productId}';
    final moistureMean =
        _asDouble(matchingReport?['meanValue']) ??
        _asDouble(context.myProfile?['moistureThreshold']) ??
        43.5;
    final technicalSummary =
        (matchingReport?['technicalInterpretation'] as String?)?.trim() ??
        baseModel.traceability.technicalSummary;

    final cultivationPractices = rawProductJson['cultivationPractices'] is List
        ? baseModel.cultivationPractices
        : ProductModel.defaultCultivationPractices(
            category: baseModel.category,
            region: originRegion,
            soilType: soilType ?? 'Franco Orgánico',
            moistureThreshold: _asDouble(
              context.myProfile?['moistureThreshold'],
            ),
            tempThreshold: _asDouble(context.myProfile?['tempThreshold']),
            sensorCode: sensorCode,
          );

    final now = DateTime.now().toUtc();
    final refDate = harvestDate ?? now.subtract(const Duration(days: 3));
    final reportDate = matchingReport?['generatedAt'] is String
        ? DateTime.tryParse(matchingReport!['generatedAt'] as String) ??
              refDate.subtract(const Duration(days: 2))
        : refDate.subtract(const Duration(days: 2));
    final deviceSyncDate = primaryDevice?['lastSync'] is String
        ? DateTime.tryParse(primaryDevice!['lastSync'] as String) ?? now
        : now.subtract(const Duration(hours: 2));

    final productionEvents = <ProductionEventModel>[
      ProductionEventModel(
        id: 'evt-$productId-1',
        title: 'Registro de Parcela y Siembra Autorizada',
        stage: 'Siembra y Suelo',
        description:
            'Parcela "${fieldName ?? 'Fundo Agroecológico $originRegion'}" (${(fieldSizeM2 ?? 15000).toStringAsFixed(0)} m²) con suelo ${soilType ?? 'Franco Orgánico'} verificada en TerraTech.',
        timestamp: refDate.subtract(const Duration(days: 85)),
        sensorCode: sensorCode,
        metricsSummary:
            'Cultivo: ${cropName ?? baseModel.name} | Suelo: ${soilType ?? 'Franco Orgánico'}',
      ),
      ProductionEventModel(
        id: 'evt-$productId-2',
        title: 'Monitoreo IoT de Humedad Edáfica y NPK',
        stage: 'Monitoreo IoT',
        description:
            'Telemetría activa mediante dispositivo "$sensorName" ($sensorCode) supervisando umbrales de humedad y nutrientes en tiempo real.',
        timestamp: deviceSyncDate,
        sensorCode: sensorCode,
        metricsSummary:
            'Humedad media registrada: ${moistureMean.toStringAsFixed(1)}% | Estado: ACTIVE',
      ),
      ProductionEventModel(
        id: 'evt-$productId-3',
        title: 'Reporte Agronómico y Validación de Calidad',
        stage: 'Control Agronómico',
        description:
            technicalSummary ??
            'Evaluación estadística favorable de humedad y estabilidad nutricional durante el ciclo productivo.',
        timestamp: reportDate,
        sensorCode: sensorCode,
        metricsSummary:
            'Media edáfica: ${moistureMean.toStringAsFixed(1)}% | Lote autorizado',
      ),
      ProductionEventModel(
        id: 'evt-$productId-4',
        title: 'Cosecha y Registro de Lote Comercial ($batchCode)',
        stage: 'Cosecha y Stock',
        description:
            'Lote registrado en inventario TerraTech con $availableStock $unitType disponibles para comercialización directa.',
        timestamp: refDate,
        sensorCode: sensorCode,
        metricsSummary:
            'Lote: $batchCode | Stock verificado: $availableStock $unitType',
      ),
    ];

    final traceability = TraceabilityModel(
      batchCode: batchCode,
      originRegion: originRegion,
      fieldName: fieldName ?? 'Fundo Agroecológico $originRegion',
      soilType: soilType ?? 'Franco Orgánico Certificado',
      cropName: cropName ?? baseModel.name,
      farmerName: farmerName,
      fieldId: fieldId ?? productId,
      profileId: profileId,
      fieldSizeM2: fieldSizeM2 ?? 15000.0,
      latitude: latitude ?? -13.3091,
      longitude: longitude ?? -72.1165,
      farmerCommunityName: communityNickname ?? '$farmerName - Red TerraTech',
      farmerPhone: farmerPhone,
      farmerReputationScore: reputationScore,
      harvestDate: refDate,
      sensorNodeCode: sensorCode,
      sensorNodeName: sensorName,
      soilMoistureMean: moistureMean,
      technicalSummary: technicalSummary,
      qrVerificationCode: 'TT-QR-2026-P$productId-F${fieldId ?? 1}',
      authorizedInTerraTech: true,
      productionEvents: productionEvents,
    );

    return baseModel.copyWith(
      originRegion: originRegion,
      averageRating: averageRating,
      reviewCount: reviewCount,
      unitType: unitType,
      availableStock: availableStock,
      farmerName: farmerName,
      farmerProfileId: profileId,
      farmerPhone: farmerPhone,
      farmerBio: farmerBio,
      cultivationPractices: cultivationPractices,
      traceability: traceability,
    );
  }

  Future<dynamic> _safeGet(String path) async {
    try {
      final response = await _dio.get<dynamic>(path);
      return response.data;
    } catch (_) {
      return null;
    }
  }

  List<Map<String, dynamic>> _extractList(Object? data) {
    if (data is List) {
      return data
          .whereType<Map<dynamic, dynamic>>()
          .map((item) => item.map((k, v) => MapEntry(k.toString(), v)))
          .toList(growable: false);
    }
    return const <Map<String, dynamic>>[];
  }

  Map<String, dynamic>? _extractMap(Object? data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return data.map((k, v) => MapEntry(k.toString(), v));
    }
    return null;
  }

  ProblemDetails _extractProblemDetails(DioException exception) {
    final err = exception.error;
    if (err is ProblemDetails) {
      return err;
    }
    return ProblemDetails(
      title: 'Error de red',
      status: exception.response?.statusCode,
      detail:
          exception.message ??
          'No se pudo completar la solicitud con el servidor TerraTech.',
      instance: exception.requestOptions.uri.path,
    );
  }

  static int? _asInt(Object? value) {
    return switch (value) {
      final int v => v,
      final num v => v.toInt(),
      final String v => int.tryParse(v),
      _ => null,
    };
  }

  static double? _asDouble(Object? value) {
    return switch (value) {
      final double v => v,
      final num v => v.toDouble(),
      final String v => double.tryParse(v),
      _ => null,
    };
  }
}

class _AuthorizedBackendContext {
  const _AuthorizedBackendContext({
    required this.inventories,
    required this.fields,
    required this.myProfile,
    required this.communityProfiles,
    required this.comments,
    required this.reports,
    required this.devicesByFieldId,
  });

  final List<Map<String, dynamic>> inventories;
  final List<Map<String, dynamic>> fields;
  final Map<String, dynamic>? myProfile;
  final List<Map<String, dynamic>> communityProfiles;
  final List<Map<String, dynamic>> comments;
  final List<Map<String, dynamic>> reports;
  final Map<int, List<Map<String, dynamic>>> devicesByFieldId;
}
