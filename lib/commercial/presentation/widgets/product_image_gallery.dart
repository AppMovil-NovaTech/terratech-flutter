import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Interactive image carousel and thumbnail selector for the product detail
/// screen (US40 - Scenario 1).
class ProductImageGallery extends StatelessWidget {
  const ProductImageGallery({
    super.key,
    required this.images,
    required this.category,
    required this.pageController,
    required this.currentIndex,
    required this.onPageChanged,
  });

  final List<String> images;
  final String category;
  final PageController pageController;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: <Widget>[
        SizedBox(
          height: 250,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              PageView.builder(
                key: const Key('product_detail_image_carousel'),
                controller: pageController,
                itemCount: images.length,
                onPageChanged: onPageChanged,
                itemBuilder: (context, index) {
                  final imageUrl = images[index];
                  return Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: colorScheme.primaryContainer.withValues(
                        alpha: 0.4,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.eco_rounded,
                            size: 64,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$category • Imagen ${index + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                bottom: AppSpacing.md,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(images.length, (index) {
                    final isSelected = index == currentIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: isSelected ? 22 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.surface
                            : AppColors.whiteSoft,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusPill,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        if (images.length > 1)
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            color: AppColors.surfaceSubtle,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final isSelected = index == currentIndex;
                return GestureDetector(
                  onTap: () {
                    pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    width: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary
                            : AppColors.borderSubtle,
                        width: isSelected ? 2.2 : 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      images[index],
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Icon(
                        Icons.image_outlined,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
