import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// User Story US08: Two-step password recovery flow:
/// 1) Request reset email via `/api/v1/authentication/password-reset-requests`.
/// 2) Confirm reset using the 43-character token and new password via `/password-resets`.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _requestFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _confirmFormKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _showTokenResetStep = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _sendResetRequest() {
    if (_requestFormKey.currentState?.validate() != true) return;
    context.read<AuthBloc>().add(
      AuthPasswordResetRequested(emailAddress: _emailController.text.trim()),
    );
  }

  void _confirmPasswordReset() {
    if (_confirmFormKey.currentState?.validate() != true) return;
    context.read<AuthBloc>().add(
      AuthPasswordResetConfirmed(
        token: _tokenController.text.trim(),
        password: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          (previous.isBusy && !current.isBusy) &&
          (current.lastAction == AuthActionType.passwordResetRequest ||
              current.lastAction == AuthActionType.passwordResetConfirm),
      listener: (context, state) {
        if (state.lastAction == AuthActionType.passwordResetRequest &&
            state.errorMessage == null &&
            state.infoMessage != null) {
          setState(() {
            _showTokenResetStep = true;
          });
        }
        if (state.lastAction == AuthActionType.passwordResetConfirm &&
            state.errorMessage == null &&
            state.infoMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.infoMessage!)),
          );
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        final isRelevantAction =
            state.lastAction == AuthActionType.passwordResetRequest ||
            state.lastAction == AuthActionType.passwordResetConfirm;
        final error = isRelevantAction ? state.errorMessage : null;
        final info = isRelevantAction ? state.infoMessage : null;

        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          appBar: AppBar(title: const Text('Recuperar contraseña')),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        _showTokenResetStep
                            ? 'Restablecer contraseña'
                            : 'Encuentra tu cuenta',
                        style: textTheme.titleLarge?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _showTokenResetStep
                            ? 'Ingresa el token de 43 caracteres recibido en tu correo y define tu nueva contraseña.'
                            : 'Ingresa tu correo registrado para enviarte un enlace de recuperación válido por 1 hora.',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      if (info != null && info.isNotEmpty) ...<Widget>[
                        Container(
                          key: const Key('forgot_password_info_banner'),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                            border: Border.all(color: AppColors.primary),
                          ),
                          child: Text(
                            info,
                            style: const TextStyle(
                              color: AppColors.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                      if (!_showTokenResetStep)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            child: Form(
                              key: _requestFormKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  TextFormField(
                                    key: const Key('forgot_email_field'),
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: const InputDecoration(
                                      labelText: 'Correo electrónico',
                                      hintText: 'campo@example.com',
                                      prefixIcon: Icon(
                                        Icons.mail_outline_rounded,
                                      ),
                                    ),
                                    validator: (value) {
                                      final trimmed = value?.trim() ?? '';
                                      if (trimmed.isEmpty ||
                                          !trimmed.contains('@')) {
                                        return 'Ingresa un correo electrónico válido.';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  FilledButton(
                                    key: const Key(
                                      'forgot_send_request_button',
                                    ),
                                    onPressed: state.isBusy
                                        ? null
                                        : _sendResetRequest,
                                    child: state.isBusy
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text('Enviar enlace'),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  TextButton(
                                    key: const Key('forgot_already_have_token'),
                                    onPressed: state.isBusy
                                        ? null
                                        : () {
                                            setState(() {
                                              _showTokenResetStep = true;
                                            });
                                          },
                                    child: const Text(
                                      'Ya tengo un código de recuperación',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            child: Form(
                              key: _confirmFormKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  TextFormField(
                                    key: const Key('reset_token_field'),
                                    controller: _tokenController,
                                    decoration: const InputDecoration(
                                      labelText: 'Token de recuperación',
                                      helperText:
                                          'Token único de 43 caracteres enviado a tu correo.',
                                      prefixIcon: Icon(Icons.key_rounded),
                                    ),
                                    validator: (value) {
                                      if ((value?.trim().length ?? 0) != 43) {
                                        return 'El token debe tener exactamente 43 caracteres.';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  TextFormField(
                                    key: const Key('reset_new_password_field'),
                                    controller: _newPasswordController,
                                    obscureText: _obscurePassword,
                                    decoration: InputDecoration(
                                      labelText: 'Nueva contraseña',
                                      prefixIcon: const Icon(
                                        Icons.lock_outline_rounded,
                                      ),
                                      suffixIcon: TextButton(
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                        child: Text(
                                          _obscurePassword ? 'Ver' : 'Ocultar',
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      final p = value ?? '';
                                      if (p.length < 6 || p.length > 128) {
                                        return 'La contraseña debe tener entre 6 y 128 caracteres.';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  TextFormField(
                                    key: const Key(
                                      'reset_confirm_password_field',
                                    ),
                                    controller: _confirmPasswordController,
                                    obscureText: _obscurePassword,
                                    decoration: const InputDecoration(
                                      labelText: 'Confirmar nueva contraseña',
                                      prefixIcon: Icon(Icons.lock_reset_rounded),
                                    ),
                                    validator: (value) {
                                      if (value !=
                                          _newPasswordController.text) {
                                        return 'Las contraseñas no coinciden.';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  FilledButton(
                                    key: const Key(
                                      'reset_confirm_submit_button',
                                    ),
                                    onPressed: state.isBusy
                                        ? null
                                        : _confirmPasswordReset,
                                    child: state.isBusy
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text('Restablecer contraseña'),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  TextButton(
                                    onPressed: state.isBusy
                                        ? null
                                        : () {
                                            setState(() {
                                              _showTokenResetStep = false;
                                            });
                                          },
                                    child: const Text('Solicitar nuevo enlace'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (error != null && error.isNotEmpty) ...<Widget>[
                        const SizedBox(height: AppSpacing.md),
                        Container(
                          key: const Key('forgot_password_error_banner'),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusSm,
                            ),
                            border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            error,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
