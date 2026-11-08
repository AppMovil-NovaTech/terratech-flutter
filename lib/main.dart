import 'package:flutter/material.dart';

import 'app.dart';
import 'core/config/env_config.dart';
import 'core/network/dio_client.dart';
import 'core/storage/secure_storage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Fail fast at startup if API_BASE_URL was not supplied via --dart-define.
  EnvConfig.validate();

  final SecureStorage secureStorage = FlutterSecureStorageImpl();
  final DioClient dioClient = DioClient(secureStorage: secureStorage);

  runApp(
    TerraTechApp(
      secureStorage: secureStorage,
      dioClient: dioClient,
    ),
  );
}
