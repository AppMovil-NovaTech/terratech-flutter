import 'package:flutter/material.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.filter_alt_outlined, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Filtrar Catálogo Agrícola',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Combina filtros de categoría y región de origen para encontrar lotes específicos.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Categoría del Producto',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
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
          const SizedBox(height: 18),
          Text(
            'Región de Origen',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
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
          const SizedBox(height: 24),
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
              const SizedBox(width: 12),
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
