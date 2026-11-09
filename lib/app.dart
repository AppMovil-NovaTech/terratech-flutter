import 'package:flutter/material.dart';

import 'commercial/data/commercial_remote_datasource.dart';
import 'commercial/data/commercial_repository_impl.dart';
import 'commercial/domain/commercial_repository.dart';
import 'core/network/dio_client.dart';
import 'core/router/app_routes.dart';
import 'core/storage/secure_storage.dart';

export 'core/router/app_routes.dart';

/// Root widget configuring the global [MaterialApp] theme, dependency wiring,
/// and routing table.
class TerraTechApp extends StatefulWidget {
  const TerraTechApp({
    super.key,
    required this.secureStorage,
    required this.dioClient,
    this.commercialRepository,
  });

  final SecureStorage secureStorage;
  final DioClient dioClient;
  final CommercialRepository? commercialRepository;

  @override
  State<TerraTechApp> createState() => _TerraTechAppState();
}

class _TerraTechAppState extends State<TerraTechApp> {
  late final CommercialRepository _commercialRepository;

  @override
  void initState() {
    super.initState();
    _commercialRepository =
        widget.commercialRepository ??
        CommercialRepositoryImpl(
          remoteDataSource: CommercialRemoteDataSourceImpl(
            dioClient: widget.dioClient,
            secureStorage: widget.secureStorage,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TerraTech',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.home,
      onGenerateRoute: (settings) => AppRouter.onGenerateRoute(
        settings,
        commercialRepository: _commercialRepository,
        dioClient: widget.dioClient,
      ),
    );
  }
}
