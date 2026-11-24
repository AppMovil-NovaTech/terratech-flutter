import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/iam_repository.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

/// User Story US09: View and edit personal and farm profile (`/api/v1/profiles/me`).
/// Completing this profile also unlocks backend US31 category subscriptions
/// and US29/US31/US32 notifications.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.repository,
    this.bloc,
  });

  final IamRepository repository;
  final ProfileBloc? bloc;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final ProfileBloc _bloc;
  late final bool _ownsBloc;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _fundoNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _sizeM2Controller = TextEditingController();
  final TextEditingController _moistureController = TextEditingController();
  final TextEditingController _tempController = TextEditingController();

  bool _hydratedFromSession = false;
  int? _hydratedProfileId;

  @override
  void initState() {
    super.initState();
    _ownsBloc = widget.bloc == null;
    _bloc = widget.bloc ?? ProfileBloc(repository: widget.repository);
    if (_bloc.state.status == ProfileStatus.initial) {
      _bloc.add(const LoadMyProfileRequested());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hydratedFromSession) {
      _hydratedFromSession = true;
      final session = BlocProvider.maybeOf<AuthBloc>(context)?.state.session;
      if (session != null && _fullNameController.text.isEmpty) {
        _fullNameController.text = session.fullName;
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _fundoNameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _sizeM2Controller.dispose();
    _moistureController.dispose();
    _tempController.dispose();
    if (_ownsBloc) {
      _bloc.close();
    }
    super.dispose();
  }

  void _populateFields(UserProfile profile) {
    if (_hydratedProfileId == profile.id) return;
    _hydratedProfileId = profile.id;
    _fullNameController.text = profile.fullName;
    _fundoNameController.text = profile.fundoName;
    _phoneController.text = profile.contactPhone;
    _locationController.text = profile.location;
    _sizeM2Controller.text = profile.sizeM2 > 0
        ? profile.sizeM2.toString()
        : '';
    _moistureController.text = profile.moistureThreshold.toString();
    _tempController.text = profile.tempThreshold.toString();
  }

  void _save() {
    if (_formKey.currentState?.validate() != true) return;
    final sizeM2 = double.parse(_sizeM2Controller.text.trim());
    final moisture = double.tryParse(_moistureController.text.trim());
    final temp = double.tryParse(_tempController.text.trim());

    _bloc.add(
      SaveMyProfileRequested(
        UpsertUserProfileInput(
          fullName: _fullNameController.text.trim(),
          fundoName: _fundoNameController.text.trim(),
          contactPhone: _phoneController.text.trim(),
          location: _locationController.text.trim(),
          sizeM2: sizeM2,
          moistureThreshold: moisture,
          tempThreshold: temp,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.maybeOf<AuthBloc>(context);
    final session = authBloc?.state.session;

    return BlocProvider<ProfileBloc>.value(
      value: _bloc,
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listenWhen: (previous, current) =>
            previous.profile != current.profile ||
            previous.errorMessage != current.errorMessage ||
            previous.successMessage != current.successMessage,
        listener: (context, state) {
          if (state.profile != null) {
            _populateFields(state.profile!);
            if (session != null &&
                state.profile!.fullName.trim().isNotEmpty &&
                state.profile!.fullName.trim() != session.fullName) {
              authBloc?.add(
                AuthSessionUpdated(
                  session.copyWith(fullName: state.profile!.fullName.trim()),
                ),
              );
            }
          }
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: AppColors.primaryDark,
              ),
            );
          } else if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.profile != null) {
            _populateFields(state.profile!);
          }
          final emailText =
              state.profile?.emailAddress.isNotEmpty == true
              ? state.profile!.emailAddress
              : (session?.emailAddress ?? '');

          return Scaffold(
            backgroundColor: AppColors.scaffoldBackground,
            appBar: AppBar(
              title: const Text('Mi Perfil'),
              actions: <Widget>[
                IconButton(
                  key: const Key('profile_refresh_button'),
                  tooltip: 'Actualizar perfil',
                  onPressed: state.isSaving
                      ? null
                      : () {
                          _hydratedProfileId = null;
                          _bloc.add(const LoadMyProfileRequested());
                        },
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            body: state.status == ProfileStatus.loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          if (state.status == ProfileStatus.empty)
                            Container(
                              key: const Key('profile_incomplete_banner'),
                              margin: const EdgeInsets.only(
                                bottom: AppSpacing.lg,
                              ),
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.warningBackground,
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusMd,
                                ),
                                border: Border.all(
                                  color: AppColors.warningBorder,
                                ),
                              ),
                              child: const Text(
                                'Completa y guarda tu perfil agrícola para habilitar suscripciones de preferencias (US31) y notificaciones personalizadas.',
                                style: TextStyle(
                                  color: AppColors.warningForeground,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Cuenta verificada',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  TextFormField(
                                    key: const Key('profile_email_readonly'),
                                    initialValue: emailText,
                                    enabled: false,
                                    decoration: const InputDecoration(
                                      labelText: 'Correo electrónico',
                                      prefixIcon: Icon(
                                        Icons.mail_outline_rounded,
                                      ),
                                    ),
                                  ),
                                  if (state.profile?.registeredAt != null)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: AppSpacing.sm,
                                      ),
                                      child: Text(
                                        'Fecha de registro: ${state.profile!.registeredAt!.toLocal().toString().split('.').first}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Text(
                                    'Datos personales y de finca',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  TextFormField(
                                    key: const Key('profile_full_name_field'),
                                    controller: _fullNameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Nombre completo',
                                    ),
                                    validator: (value) {
                                      if ((value?.trim().length ?? 0) < 2) {
                                        return 'El nombre requiere al menos 2 caracteres.';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  TextFormField(
                                    key: const Key('profile_fundo_name_field'),
                                    controller: _fundoNameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Nombre del fundo o empresa',
                                    ),
                                    validator: (value) {
                                      if ((value?.trim().isEmpty ?? true)) {
                                        return 'Ingresa el nombre del fundo.';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  TextFormField(
                                    key: const Key('profile_phone_field'),
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    decoration: const InputDecoration(
                                      labelText: 'Teléfono de contacto',
                                    ),
                                    validator: (value) {
                                      if ((value?.trim().isEmpty ?? true)) {
                                        return 'Ingresa un número de teléfono.';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  TextFormField(
                                    key: const Key('profile_location_field'),
                                    controller: _locationController,
                                    decoration: const InputDecoration(
                                      labelText: 'Ubicación (ciudad / región)',
                                    ),
                                    validator: (value) {
                                      if ((value?.trim().isEmpty ?? true)) {
                                        return 'Ingresa tu ubicación.';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  TextFormField(
                                    key: const Key('profile_size_m2_field'),
                                    controller: _sizeM2Controller,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    decoration: const InputDecoration(
                                      labelText: 'Tamaño del terreno (m²)',
                                    ),
                                    validator: (value) {
                                      final parsed = double.tryParse(
                                        value?.trim() ?? '',
                                      );
                                      if (parsed == null || parsed <= 0) {
                                        return 'El tamaño del terreno debe ser mayor a 0.';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: TextFormField(
                                          key: const Key(
                                            'profile_moisture_field',
                                          ),
                                          controller: _moistureController,
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                          decoration: const InputDecoration(
                                            labelText: 'Umbral humedad (%)',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: TextFormField(
                                          key: const Key('profile_temp_field'),
                                          controller: _tempController,
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                          decoration: const InputDecoration(
                                            labelText: 'Umbral temp (°C)',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  FilledButton.icon(
                                    key: const Key('profile_save_button'),
                                    onPressed: state.isSaving ? null : _save,
                                    icon: const Icon(Icons.save_outlined),
                                    label: Text(
                                      state.isSaving
                                          ? 'Guardando...'
                                          : 'Guardar cambios',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (authBloc != null) ...<Widget>[
                            const SizedBox(height: AppSpacing.xl),
                            OutlinedButton.icon(
                              key: const Key('profile_sign_out_button'),
                              onPressed: () {
                                authBloc.add(const AuthSignOutRequested());
                                Navigator.of(
                                  context,
                                ).popUntil((route) => route.isFirst);
                              },
                              icon: const Icon(
                                Icons.logout_rounded,
                                color: AppColors.error,
                              ),
                              label: const Text(
                                'Cerrar sesión',
                                style: TextStyle(color: AppColors.error),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
