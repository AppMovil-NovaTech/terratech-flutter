import 'package:flutter/material.dart';

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

  static const Color primaryGreen = Color(0xFF2E7D32);
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
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: viewInsets.bottom + 20,
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
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
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
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Cerrar',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Interactive Star Picker
              StarPickerWidget(
                rating: _rating,
                onRatingChanged: (newRating) {
                  setState(() => _rating = newRating);
                },
              ),
              const SizedBox(height: 20),
              // Review content input
              TextFormField(
                key: const Key('review_content_input'),
                controller: _contentController,
                maxLines: 4,
                maxLength: ReviewInputBottomSheet.maxChars,
                decoration: InputDecoration(
                  hintText:
                      'Cuéntanos tu experiencia con este producto (calidad, rendimiento, etc.)...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: ReviewInputBottomSheet.primaryGreen,
                      width: 1.5,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
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
                const SizedBox(height: 8),
                Text(
                  _inlineError!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              // Submit button
              FilledButton(
                key: const Key('review_submit_button'),
                style: FilledButton.styleFrom(
                  backgroundColor: ReviewInputBottomSheet.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isSubmitting ? null : _handleSubmit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isEditing ? 'Guardar cambios' : 'Publicar reseña',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
