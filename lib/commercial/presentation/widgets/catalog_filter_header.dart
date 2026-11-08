import 'package:flutter/material.dart';

import '../catalog_state.dart';

/// Header bar containing the real-time product name search field (US39 Scenario 3)
/// and simultaneous category + origin region dropdown selectors (US39 Scenario 2).
class CatalogFilterHeader extends StatelessWidget {
  const CatalogFilterHeader({
    super.key,
    required this.searchController,
    required this.state,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onCategorySelected,
    required this.onRegionSelected,
    required this.onClearAllFilters,
  });

  final TextEditingController searchController;
  final CatalogState state;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<String?> onCategorySelected;
  final ValueChanged<String?> onRegionSelected;
  final VoidCallback onClearAllFilters;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            key: const Key('catalog_search_textfield'),
            controller: searchController,
            onChanged: onSearchChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText:
                  'Buscar producto por nombre (ej. Papa, Quinua, Café)...',
              prefixIcon: Icon(
                Icons.search_rounded,
                color: colorScheme.primary,
              ),
              suffixIcon: state.searchQuery.isNotEmpty
                  ? IconButton(
                      key: const Key('catalog_clear_search_button'),
                      tooltip: 'Limpiar búsqueda',
                      icon: const Icon(Icons.close_rounded),
                      onPressed: onClearSearch,
                    )
                  : null,
              filled: true,
              fillColor: colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: colorScheme.primary,
                  width: 1.8,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: CatalogFilterDropdownField(
                  fieldKey: const Key('catalog_category_dropdown'),
                  label: 'Categoría',
                  icon: Icons.category_outlined,
                  selectedValue: state.selectedCategory,
                  options: state.availableCategories,
                  allLabel: 'Todas las categorías',
                  onChanged: onCategorySelected,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CatalogFilterDropdownField(
                  fieldKey: const Key('catalog_region_dropdown'),
                  label: 'Región',
                  icon: Icons.location_on_outlined,
                  selectedValue: state.selectedRegion,
                  options: state.availableRegions,
                  allLabel: 'Todas las regiones',
                  onChanged: onRegionSelected,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Icon(
                Icons.verified_outlined,
                size: 15,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Mostrando ${state.filteredProducts.length} de ${state.allProducts.length} productos con trazabilidad TerraTech',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (state.hasActiveFilters)
                TextButton.icon(
                  key: const Key('catalog_clear_filters_button'),
                  onPressed: onClearAllFilters,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
                  label: const Text('Limpiar filtros'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Reusable Material 3 dropdown selector for catalog filter criteria.
class CatalogFilterDropdownField extends StatelessWidget {
  const CatalogFilterDropdownField({
    super.key,
    required this.fieldKey,
    required this.label,
    required this.icon,
    required this.selectedValue,
    required this.options,
    required this.allLabel,
    required this.onChanged,
  });

  final Key fieldKey;
  final String label;
  final IconData icon;
  final String? selectedValue;
  final List<String> options;
  final String allLabel;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveValue =
        (selectedValue != null && options.contains(selectedValue))
        ? selectedValue
        : null;

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: effectiveValue != null
            ? colorScheme.primaryContainer.withValues(alpha: 0.55)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: effectiveValue != null
              ? colorScheme.primary
              : colorScheme.outlineVariant,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          key: fieldKey,
          value: effectiveValue,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
          hint: Row(
            children: <Widget>[
              Icon(icon, size: 16, color: colorScheme.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          items: <DropdownMenuItem<String?>>[
            DropdownMenuItem<String?>(
              value: null,
              child: Text(
                allLabel,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              ),
            ),
            ...options.map(
              (option) => DropdownMenuItem<String?>(
                value: option,
                child: Text(
                  option,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
