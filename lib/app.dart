import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'commercial/data/commercial_remote_datasource.dart';
import 'commercial/data/commercial_repository_impl.dart';
import 'commercial/domain/commercial_repository.dart';
import 'core/network/dio_client.dart';
import 'core/router/app_routes.dart';
import 'core/storage/secure_storage.dart';
import 'core/theme/app_theme.dart';
import 'iam/data/datasources/auth_session_local_datasource.dart';
import 'iam/data/datasources/iam_remote_datasource.dart';
import 'iam/data/repositories/iam_repository_impl.dart';
import 'iam/domain/repositories/iam_repository.dart';
import 'iam/presentation/bloc/auth_bloc.dart';
import 'iam/presentation/bloc/auth_event.dart';
import 'iam/presentation/bloc/auth_state.dart';
import 'iam/presentation/screens/welcome_screen.dart';

export 'core/router/app_routes.dart';

/// Root widget configuring the global [MaterialApp] theme, [AuthBloc],
/// dependency wiring, and bounded-context routing table.
class TerraTechApp extends StatefulWidget {
  const TerraTechApp({
    super.key,
    required this.secureStorage,
    required this.dioClient,
    this.commercialRepository,
    this.iamRepository,
    this.authBloc,
  });

  final SecureStorage secureStorage;
  final DioClient dioClient;
  final CommercialRepository? commercialRepository;
  final IamRepository? iamRepository;
  final AuthBloc? authBloc;

  @override
  State<TerraTechApp> createState() => _TerraTechAppState();
}

class _TerraTechAppState extends State<TerraTechApp> {
  late final CommercialRepository _commercialRepository;
  late final IamRepository _iamRepository;
  late final AuthBloc _authBloc;
  late final bool _ownsAuthBloc;

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

    _iamRepository =
        widget.iamRepository ??
        IamRepositoryImpl(
          remoteDataSource: IamRemoteDataSourceImpl(dioClient: widget.dioClient),
          localDataSource: AuthSessionLocalDataSource(
            secureStorage: widget.secureStorage,
          ),
        );

    _ownsAuthBloc = widget.authBloc == null;
    _authBloc = widget.authBloc ?? AuthBloc(repository: _iamRepository);

    widget.dioClient.onUnauthorized = () {
      if (!_authBloc.isClosed) {
        _authBloc.add(const AuthSessionExpired());
      }
    };

    if (_authBloc.state.status == AuthStatus.initial) {
      _authBloc.add(const AuthRestoreRequested());
    }
  }

  @override
  void dispose() {
    widget.dioClient.onUnauthorized = null;
    if (_ownsAuthBloc) {
      _authBloc.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>.value(
      value: _authBloc,
      child: MaterialApp(
        title: 'TerraTech',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const _AuthGate(),
        onGenerateRoute: (settings) => AppRouter.onGenerateRoute(
          settings,
          commercialRepository: _commercialRepository,
          iamRepository: _iamRepository,
          dioClient: widget.dioClient,
          secureStorage: widget.secureStorage,
        ),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return switch (state.status) {
          AuthStatus.initial || AuthStatus.loading => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          AuthStatus.authenticated => const TerraTechHomeShell(),
          AuthStatus.unauthenticated => const WelcomeScreen(),
        };
      },
    );
  }
}
