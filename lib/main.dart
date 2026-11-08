import 'package:flutter/material.dart';

import 'app.dart';
import 'commercial/data/commercial_remote_datasource.dart';
import 'core/config/env_config.dart';
import 'core/network/dio_client.dart';
import 'core/storage/secure_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Fail fast at startup if API_BASE_URL is invalid.
  EnvConfig.validate();

  final SecureStorage secureStorage = FlutterSecureStorageImpl();

  // Temporary Auth Bypass (Mock): Inject static JWT token for the seeded
  // test user (test.user@terratech.com) into SecureStorage while IAM is pending.
  await MockAuthSession.ensureSeeded(secureStorage);

  final DioClient dioClient = DioClient(secureStorage: secureStorage);

  runApp(
    TerraTechApp(
      secureStorage: secureStorage,
      dioClient: dioClient,
    ),
  );
}
