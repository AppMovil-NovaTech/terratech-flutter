import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'forgot_password_screen.dart';
import 'sign_in_screen.dart';
import 'terms_and_conditions_screen.dart';

/// User Story US06: Sign-Up screen with mandatory Terms and Conditions gate.
/// The submit button remains disabled until the user explicitly accepts the terms.
/// On success, redirects to [SignInScreen] with prefilled registration credentials.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _openTermsAndConditions() async {
    final accepted = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => const TermsAndConditionsScreen(showAcceptButton: true),
      ),
    );
    if (accepted == true && mounted) {
      setState(() {
        _acceptedTerms = true;
      });
    }
  }

  void _submit() {
    if (!_acceptedTerms) return;
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    context.read<AuthBloc>().add(
      AuthSignUpRequested(
        fullName: _fullNameController.text.trim(),
        emailAddress: _emailController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current.lastAction == AuthActionType.signUp &&
          !current.isBusy &&
          current.registeredEmail != null &&
          previous.registeredEmail != current.registeredEmail,
      listener: (context, state) {
        final email = state.registeredEmail;
        final password = state.registeredPassword;
        final banner = state.infoMessage;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => SignInScreen(
              prefilledEmail: email,
              prefilledPassword: password,
              bannerMessage: banner,
            ),
          ),
        );
      },
      builder: (context, state) {
        final hasSignUpError =
            state.lastAction == AuthActionType.signUp &&
            state.errorMessage != null;
        final isDuplicateEmail =
            hasSignUpError &&
            state.errorMessage!.toLowerCase().contains('ya está registrado');

        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          appBar: AppBar(title: const Text('Crear cuenta')),
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
                        'Únete a TerraTech',
                        style: textTheme.titleLarge?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Crea tu cuenta de agricultor o comprador para gestionar alertas y trazabilidad.',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                TextFormField(
                                  key: const Key('sign_up_full_name_field'),
                                  controller: _fullNameController,
                                  textInputAction: TextInputAction.next,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: const InputDecoration(
                                    labelText: 'Nombre completo',
                                    hintText: 'Ej.: Rodolfo Pérez',
                                    prefixIcon: Icon(
                                      Icons.person_outline_rounded,
                                    ),
                                  ),
                                  validator: (value) {
                                    final trimmed = value?.trim() ?? '';
                                    if (trimmed.length < 2) {
                                      return 'Ingresa tu nombre completo (mínimo 2 caracteres).';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: AppSpacing.md),
                                TextFormField(
                                  key: const Key('sign_up_email_field'),
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                    labelText: 'Correo electrónico',
                                    hintText: 'nombre@ejemplo.com',
                                    prefixIcon: Icon(Icons.mail_outline_rounded),
                                  ),
                                  validator: (value) {
                                    final trimmed = value?.trim() ?? '';
                                    if (trimmed.isEmpty) {
                                      return 'Ingresa tu correo electrónico.';
                                    }
                                    if (!trimmed.contains('@') ||
                                        !trimmed.contains('.')) {
                                      return 'Ingresa un correo electrónico válido.';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: AppSpacing.md),
                                TextFormField(
                                  key: const Key('sign_up_password_field'),
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    labelText: 'Contraseña',
                                    hintText: 'Mínimo 6 caracteres',
                                    prefixIcon: const Icon(
                                      Icons.lock_outline_rounded,
                                    ),
                                    suffixIcon: TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                      child: Text(
                                        _obscurePassword ? 'Ver' : 'Ocultar',
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    final password = value ?? '';
                                    if (password.length < 6 ||
                                        password.length > 128) {
                                      return 'La contraseña debe tener entre 6 y 128 caracteres.';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: AppSpacing.md),
                                TextFormField(
                                  key: const Key(
                                    'sign_up_confirm_password_field',
                                  ),
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirmPassword,
                                  textInputAction: TextInputAction.done,
                                  decoration: InputDecoration(
                                    labelText: 'Confirmar contraseña',
                                    hintText: 'Repite tu contraseña',
                                    prefixIcon: const Icon(
                                      Icons.lock_reset_rounded,
                                    ),
                                    suffixIcon: TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _obscureConfirmPassword =
                                              !_obscureConfirmPassword;
                                        });
                                      },
                                      child: Text(
                                        _obscureConfirmPassword
                                            ? 'Ver'
                                            : 'Ocultar',
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value != _passwordController.text) {
                                      return 'Las contraseñas no coinciden.';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: _acceptedTerms
                                        ? AppColors.secondaryContainer
                                              .withValues(alpha: 0.45)
                                        : AppColors.surfaceSubtle,
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusMd,
                                    ),
                                    border: Border.all(
                                      color: _acceptedTerms
                                          ? AppColors.primary
                                          : AppColors.border,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Checkbox(
                                            key: const Key(
                                              'sign_up_terms_checkbox',
                                            ),
                                            value: _acceptedTerms,
                                            onChanged: state.isBusy
                                                ? null
                                                : (value) {
                                                    setState(() {
                                                      _acceptedTerms =
                                                          value ?? false;
                                                    });
                                                  },
                                          ),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: state.isBusy
                                                  ? null
                                                  : () {
                                                      setState(() {
                                                        _acceptedTerms =
                                                            !_acceptedTerms;
                                                      });
                                                    },
                                              child: const Text(
                                                'Acepto los Términos y Condiciones del Servicio de TerraTech.',
                                                style: TextStyle(
                                                  color: AppColors.textPrimary,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: AppSpacing.md,
                                        ),
                                        child: TextButton.icon(
                                          key: const Key(
                                            'sign_up_read_terms_button',
                                          ),
                                          onPressed: _openTermsAndConditions,
                                          icon: const Icon(
                                            Icons.description_outlined,
                                            size: 18,
                                          ),
                                          label: const Text(
                                            'Leer Términos y Condiciones',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (hasSignUpError) ...<Widget>[
                                  const SizedBox(height: AppSpacing.md),
                                  Container(
                                    key: const Key('sign_up_error_banner'),
                                    padding: const EdgeInsets.all(
                                      AppSpacing.md,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withValues(
                                        alpha: 0.08,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusSm,
                                      ),
                                      border: Border.all(
                                        color: AppColors.error.withValues(
                                          alpha: 0.4,
                                        ),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          state.errorMessage!,
                                          style: const TextStyle(
                                            color: AppColors.error,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (isDuplicateEmail) ...<Widget>[
                                          const SizedBox(height: AppSpacing.xs),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute<void>(
                                                  builder: (_) =>
                                                      ForgotPasswordScreen(
                                                        initialEmail:
                                                            _emailController
                                                                .text
                                                                .trim(),
                                                      ),
                                                ),
                                              );
                                            },
                                            child: const Text(
                                              '¿Olvidaste tu contraseña? Recuperar acceso',
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: AppSpacing.lg),
                                FilledButton(
                                  key: const Key('sign_up_submit_button'),
                                  onPressed:
                                      (!_acceptedTerms || state.isBusy)
                                      ? null
                                      : _submit,
                                  child: state.isBusy
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text('Crear cuenta'),
                                ),
                                if (!_acceptedTerms) ...<Widget>[
                                  const SizedBox(height: AppSpacing.sm),
                                  const Text(
                                    'Marca la casilla de Términos y Condiciones para habilitar el registro.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text(
                            '¿Ya tienes cuenta?',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          TextButton(
                            key: const Key('sign_up_go_to_sign_in_button'),
                            onPressed: state.isBusy
                                ? null
                                : () {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute<void>(
                                        builder: (_) => const SignInScreen(),
                                      ),
                                    );
                                  },
                            child: const Text('Inicia sesión'),
                          ),
                        ],
                      ),
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
