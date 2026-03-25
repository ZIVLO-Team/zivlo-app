import 'package:flutter/material.dart';

import 'package:zivlo/core/theme/app_theme.dart';
/// Category Filter Chip Widget
///
/// Filter chip for category selection
///
/// Features:
/// - Chip con nombre de categoría
/// - Selected state con colorAccent
/// - onTap actualiza filtro de categoría en CatalogBloc
/// - Opción "Todas" para mostrar todos los productos
class CategoryFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spacing16,
          vertical: AppSpacing.spacing8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.colorAccent
              : AppColors.colorSurfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(AppRadius.radiusFull),
          border: Border.all(
            color: isSelected
                ? AppColors.colorAccent
                : AppColors.colorOnSurfaceMuted.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.textTheme.labelMedium?.copyWith(
            color: isSelected
                ? AppColors.colorOnSurface
                : AppColors.colorOnSurfaceMuted,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
