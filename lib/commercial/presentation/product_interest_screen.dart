import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/product_interest_auth_service.dart';
import '../domain/commercial_repository.dart';
import 'product_interest_bloc.dart';
import 'product_interest_event.dart';
import 'product_interest_state.dart';

/// US29: owner-only interest dashboard for a product ID.
/// Requires a valid user JWT; the server checks product ownership.
class ProductInterestScreen extends StatefulWidget {
  const ProductInterestScreen({
    super.key,
    required this.repository,
    required this.authService,
  });

  final CommercialRepository repository;
  final ProductInterestAuthService authService;

  @override
  State<ProductInterestScreen> createState() => _ProductInterestScreenState();
}

class _ProductInterestScreenState extends State<ProductInterestScreen> {
  final TextEditingController _productIdController = TextEditingController();
  final TextEditingController _thresholdController = TextEditingController();
  late ProductInterestBloc _bloc;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  int? _signedInUserId;
  String? _signedInEmail;
  String? _signInError;
  bool _checkingSession = true;
  bool _signingIn = false;

  @override
  void initState() {
    super.initState();
    _bloc = ProductInterestBloc(repository: widget.repository);
    _restoreSession();
  }

  @override
  void dispose() {
    _productIdController.dispose();
    _thresholdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();

    _bloc.close();
    super.dispose();
  }

  void _load() {
    final id = int.tryParse(_productIdController.text.trim());
    if (id == null || id <= 0) {
      _showMessage('Ingresa un identificador de producto válido.');
      return;
    }
    _bloc.add(LoadProductInterestRequested(productId: id));
  }

  void _save(int productId) {
    final threshold = int.tryParse(_thresholdController.text.trim());
    if (threshold == null || threshold <= 0) {
      _showMessage('El umbral debe ser un entero mayor que cero.');
      return;
    }
    _bloc.add(
      UpdateProductInterestThresholdRequested(
        productId: productId,
        threshold: threshold,
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _restoreSession() async {
    try {
      final id = await widget.authService.currentUserId();
      final email = await widget.authService.currentEmail();
      if (!mounted) return;
      setState(() {
        _signedInUserId = id;
        _signedInEmail = id == null ? null : email;
        _checkingSession = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _checkingSession = false);
    }
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _signInError = 'Ingresa tu correo y contraseña.');
      return;
    }
    setState(() {
      _signingIn = true;
      _signInError = null;
    });
    try {
      final id = await widget.authService.signIn(
        email: email,
        password: password,
      );
      if (!mounted) return;
      _passwordController.clear();
      setState(() {
        _signedInUserId = id;
        _signedInEmail = email;
        _signingIn = false;
      });
    } on DioException catch (error) {
      if (!mounted) return;
      setState(() {
        _signingIn = false;
        _signInError = error.response?.statusCode == 401
            ? 'Credenciales incorrectas.'
            : 'No fue posible conectar con la autenticación del backend.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _signingIn = false;
        _signInError =
            'No se pudo iniciar sesión. Revisa los datos e inténtalo otra vez.';
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await widget.authService.signOut();
      if (!mounted) return;
      final oldBloc = _bloc;
      setState(() {
        _signedInUserId = null;
        _signedInEmail = null;
        _signInError = null;
        _thresholdController.clear();
        _bloc = ProductInterestBloc(repository: widget.repository);
      });
      await oldBloc.close();
    } catch (_) {
      if (mounted) _showMessage('No se pudo cerrar la sesión.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductInterestBloc>.value(
      value: _bloc,
      child: BlocConsumer<ProductInterestBloc, ProductInterestState>(
        listenWhen: (previous, current) =>
            previous.interest != current.interest ||
            previous.message != current.message ||
            previous.errorMessage != current.errorMessage,
        listener: (context, state) {
          final interest = state.interest;
          if (interest != null &&
              state.status == ProductInterestStatus.ready &&
              state.errorMessage == null) {
            _thresholdController.text = '${interest.interestThreshold}';
          }
          final message = state.errorMessage ?? state.message;
          if (message != null) {
            _showMessage(message);
          }
        },
        builder: (context, state) {
          final interest = state.interest;
          final busy =
              state.status == ProductInterestStatus.loading ||
              state.status == ProductInterestStatus.saving ||
              state.status == ProductInterestStatus.checking;

          return Scaffold(
            appBar: AppBar(title: const Text('Alertas de interés · US29')),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Consulta únicamente tus productos como proveedor. Necesitas una sesión autenticada.',
                  ),
                  const SizedBox(height: 16),
                  if (_checkingSession) const LinearProgressIndicator(),
                  if (!_checkingSession && _signedInUserId == null) ...<Widget>[
                    const Text(
                      'Inicia sesión como proveedor para gestionar tus productos.',
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      key: const Key('us29_sign_in_email'),
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const <String>[AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      key: const Key('us29_sign_in_password'),
                      controller: _passwordController,
                      obscureText: true,
                      autofillHints: const <String>[AutofillHints.password],
                      decoration: const InputDecoration(
                        labelText: 'Contraseña',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      key: const Key('us29_sign_in_button'),
                      onPressed: _signingIn ? null : _signIn,
                      icon: const Icon(Icons.login),
                      label: Text(
                        _signingIn ? 'Ingresando...' : 'Iniciar sesión',
                      ),
                    ),
                    if (_signInError != null) ...<Widget>[
                      const SizedBox(height: 8),
                      Text(
                        _signInError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                  if (_signedInUserId != null) ...<Widget>[
                    Text('Proveedor autenticado: usuario $_signedInUserId'),
                    if (_signedInEmail != null) Text(_signedInEmail!),
                    TextButton.icon(
                      key: const Key('us29_sign_out_button'),
                      onPressed: _signOut,
                      icon: const Icon(Icons.logout),
                      label: const Text('Cerrar sesión'),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (_signedInUserId != null)
                    TextField(
                      key: const Key('us29_product_id'),
                      controller: _productIdController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'ID de tu producto',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  const SizedBox(height: 12),
                  if (_signedInUserId != null)
                    FilledButton.icon(
                      key: const Key('us29_load_interest'),
                      onPressed: busy ? null : _load,
                      icon: const Icon(Icons.analytics_outlined),
                      label: const Text('Consultar estadísticas'),
                    ),
                  if (_signedInUserId != null && busy) ...<Widget>[
                    const SizedBox(height: 16),
                    const LinearProgressIndicator(),
                  ],
                  if (_signedInUserId != null &&
                      state.status ==
                          ProductInterestStatus.failure) ...<Widget>[
                    const SizedBox(height: 12),
                    Text(
                      state.errorMessage ??
                          'No se pudieron cargar las estadísticas.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  if (_signedInUserId != null && interest != null) ...<Widget>[
                    const SizedBox(height: 20),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Producto #${interest.productId}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Consultas del mes: ${interest.monthlyConsultations}',
                            ),
                            Text(
                              'Umbral actual: ${interest.interestThreshold}',
                            ),
                            Text(
                              'Periodo: ${interest.consultationMonth}/${interest.consultationYear}',
                            ),
                            Text(
                              interest.lastConsultationAt == null
                                  ? 'Todavía no hay consultas registradas.'
                                  : 'Última consulta: ${interest.lastConsultationAt!.toLocal()}',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      key: const Key('us29_interest_threshold'),
                      controller: _thresholdController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Nuevo umbral mensual',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      key: const Key('us29_save_threshold'),
                      onPressed: busy ? null : () => _save(interest.productId),
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Guardar umbral'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      key: const Key('us29_check_inactivity'),
                      onPressed: busy
                          ? null
                          : () => _bloc.add(
                              CheckProductInactivityRequested(
                                productId: interest.productId,
                              ),
                            ),
                      icon: const Icon(Icons.schedule_outlined),
                      label: const Text('Comprobar 30 días sin consultas'),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'La comprobación de inactividad es manual. El backend aún no dispone de una tarea periódica automática.',
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
