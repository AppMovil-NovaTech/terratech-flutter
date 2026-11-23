import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Modal bottom sheet allowing the user to select and apply category and
/// origin region filters simultaneously (US39 - Scenario 2).
class SimultaneousFilterSheet extends StatefulWidget {
  const SimultaneousFilterSheet({
    super.key,
    required this.availableCategories,
    required this.availableRegions,
    required this.initialCategory,
    required this.initialRegion,
    required this.onApply,
    required this.onClear,
  });

  final List<String> availableCategories;
  final List<String> availableRegions;
  final String? initialCategory;
  final String? initialRegion;
  final void Function(String? category, String? region) onApply;
  final VoidCallback onClear;

  @override
  State<SimultaneousFilterSheet> createState() =>
      _SimultaneousFilterSheetState();
}

class _SimultaneousFilterSheetState extends State<SimultaneousFilterSheet> {
  String? _selectedCategory;
  String? _selectedRegion;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _selectedRegion = widget.initialRegion;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xs,
        AppSpacing.xl,
        AppSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.filter_alt_outlined, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Filtrar Catálogo Agrícola',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Combina filtros de categoría y región de origen para encontrar lotes específicos.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Categoría del Producto',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              ChoiceChip(
                label: const Text('Todas'),
                selected: _selectedCategory == null,
                onSelected: (_) => setState(() => _selectedCategory = null),
              ),
              ...widget.availableCategories.map(
                (category) => ChoiceChip(
                  key: Key('sheet_category_chip_$category'),
                  label: Text(category),
                  selected: _selectedCategory == category,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = selected ? category : null;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Región de Origen',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              ChoiceChip(
                label: const Text('Todas'),
                selected: _selectedRegion == null,
                onSelected: (_) => setState(() => _selectedRegion = null),
              ),
              ...widget.availableRegions.map(
                (region) => ChoiceChip(
                  key: Key('sheet_region_chip_$region'),
                  label: Text(region),
                  selected: _selectedRegion == region,
                  onSelected: (selected) {
                    setState(() {
                      _selectedRegion = selected ? region : null;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  key: const Key('sheet_reset_filters_button'),
                  onPressed: () {
                    widget.onClear();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Restablecer'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FilledButton.icon(
                  key: const Key('sheet_apply_filters_button'),
                  onPressed: () {
                    widget.onApply(_selectedCategory, _selectedRegion);
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Aplicar filtros'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
