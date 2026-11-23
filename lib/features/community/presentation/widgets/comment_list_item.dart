import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/comment.dart';
import 'star_rating_bar.dart';

/// Presentation card item representing a single customer review/comment.
///
/// If [currentUserId] matches [comment.userId], provides edit and delete actions (US35 Scenario 3).
class CommentListItem extends StatelessWidget {
  const CommentListItem({
    super.key,
    required this.comment,
    this.currentUserId,
    this.onEdit,
    this.onDelete,
  });

  final Comment comment;
  final int? currentUserId;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  static const Color primaryGreen = AppColors.primary;

  bool get isOwner => currentUserId != null && comment.userId == currentUserId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initial = comment.authorName.trim().isNotEmpty
        ? comment.authorName.trim()[0].toUpperCase()
        : '?';

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with initial
              CircleAvatar(
                radius: 20,
                backgroundColor: primaryGreen.withValues(alpha: 0.12),
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Author, stars & date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.authorName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Row(
                      children: [
                        StarRatingBar(
                          rating: comment.rating.toDouble(),
                          starSize: 14,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          _formatRelativeDate(comment.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Owner action menu
              if (isOwner)
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    size: 20,
                    color: AppColors.textMuted,
                  ),
                  tooltip: 'Opciones de mi reseña',
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit?.call();
                    } else if (value == 'delete') {
                      _confirmDelete(context);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: AppSpacing.sm),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: AppColors.error,
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Text(
                            'Eliminar',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Comment body text
          Text(
            comment.content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar reseña'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar tu reseña? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onDelete?.call();
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  String _formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays >= 365) {
      final years = (difference.inDays / 365).floor();
      return 'Hace $years ${years == 1 ? "año" : "años"}';
    } else if (difference.inDays >= 30) {
      final months = (difference.inDays / 30).floor();
      return 'Hace $months ${months == 1 ? "mes" : "meses"}';
    } else if (difference.inDays >= 1) {
      return 'Hace ${difference.inDays} ${difference.inDays == 1 ? "día" : "días"}';
    } else if (difference.inHours >= 1) {
      return 'Hace ${difference.inHours} ${difference.inHours == 1 ? "hora" : "horas"}';
    } else if (difference.inMinutes >= 1) {
      return 'Hace ${difference.inMinutes} ${difference.inMinutes == 1 ? "minuto" : "minutos"}';
    } else {
      return 'Hace unos instantes';
    }
  }
}
