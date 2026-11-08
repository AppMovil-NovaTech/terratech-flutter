import 'package:flutter/material.dart';

import 'core/network/dio_client.dart';
import 'core/storage/secure_storage.dart';

/// Named route constants for the application and its bounded contexts.
abstract final class AppRoutes {
  static const String home = '/';
  static const String commercial = '/commercial';
  static const String community = '/community';
}

/// Root widget configuring the global [MaterialApp] theme and routing table.
class TerraTechApp extends StatelessWidget {
  const TerraTechApp({
    super.key,
    required this.secureStorage,
    required this.dioClient,
  });

  final SecureStorage secureStorage;
  final DioClient dioClient;

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
      onGenerateRoute: _onGenerateRoute,
    );
  }

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    return switch (settings.name) {
      AppRoutes.home => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const _AppShellPlaceholder(title: 'TerraTech Home'),
      ),
      AppRoutes.commercial => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const _AppShellPlaceholder(title: 'Commercial Module'),
      ),
      AppRoutes.community => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const _AppShellPlaceholder(title: 'Community Module'),
      ),
      _ => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const _AppShellPlaceholder(title: 'Not Found'),
      ),
    };
  }
}

class _AppShellPlaceholder extends StatelessWidget {
  const _AppShellPlaceholder({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}
