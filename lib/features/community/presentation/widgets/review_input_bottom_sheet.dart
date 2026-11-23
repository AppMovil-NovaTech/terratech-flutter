import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/comment.dart';
import 'star_picker_widget.dart';

/// Modal bottom sheet form for creating or editing a product review (US35).
class ReviewInputBottomSheet extends StatefulWidget {
  const ReviewInputBottomSheet({
    super.key,
    this.initialComment,
    required this.onSubmit,
  });

  final Comment? initialComment;
  final Future<bool> Function({
    required String content,
    required int rating,
  }) onSubmit;

  static const Color primaryGreen = AppColors.primary;
  static const int minChars = 10;
  static const int maxChars = 500;

  /// Convenience helper to display this bottom sheet.
  static Future<bool?> show(
    BuildContext context, {
    Comment? initialComment,
    required Future<bool> Function({
      required String content,
      required int rating,
    }) onSubmit,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => ReviewInputBottomSheet(
        initialComment: initialComment,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<ReviewInputBottomSheet> createState() => _ReviewInputBottomSheetState();
}

class _ReviewInputBottomSheetState extends State<ReviewInputBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _contentController;
  late int _rating;
  bool _isSubmitting = false;
  String? _inlineError;

  bool get isEditing => widget.initialComment != null;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialComment?.rating ?? 5;
    _contentController = TextEditingController(
      text: widget.initialComment?.content ?? '',
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    setState(() => _inlineError = null);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await widget.onSubmit(
      content: _contentController.text.trim(),
      rating: _rating,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _isSubmitting = false;
        _inlineError = 'No se pudo guardar la reseña. Inténtalo nuevamente.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.lg,
        bottom: viewInsets.bottom + AppSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(AppSpacing.xxs),
                  ),
                ),
              ),
              // Header title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Editar tu opinión' : 'Escribe tu opinión',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Cerrar',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              // Interactive Star Picker
              StarPickerWidget(
                rating: _rating,
                onRatingChanged: (newRating) {
                  setState(() => _rating = newRating);
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              // Review content input
              TextFormField(
                key: const Key('review_content_input'),
                controller: _contentController,
                maxLines: 4,
                maxLength: ReviewInputBottomSheet.maxChars,
                decoration: InputDecoration(
                  hintText:
                      'Cuéntanos tu experiencia con este producto (calidad, rendimiento, etc.)...',
                  hintStyle: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    borderSide: const BorderSide(
                      color: ReviewInputBottomSheet.primaryGreen,
                      width: 1.5,
                    ),
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceSubtle,
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.length < ReviewInputBottomSheet.minChars) {
                    return 'La reseña debe contener al menos 10 caracteres para ser publicada.';
                  }
                  if (text.length > ReviewInputBottomSheet.maxChars) {
                    return 'La reseña no debe exceder los 500 caracteres.';
                  }
                  return null;
                },
              ),
              if (_inlineError != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _inlineError!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              // Submit button
              FilledButton(
                key: const Key('review_submit_button'),
                style: FilledButton.styleFrom(
                  backgroundColor: ReviewInputBottomSheet.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                onPressed: _isSubmitting ? null : _handleSubmit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.surface,
                        ),
                      )
                    : Text(
                        isEditing ? 'Guardar cambios' : 'Publicar reseña',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.surface,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
