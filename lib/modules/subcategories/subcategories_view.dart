// 
// Subcategories Screen
// Shows ONLY subcategories from /categories/{id} API
// Uses ONLY catagories.dart model (Data class)

import 'package:distributor_app/models/catagories.dart' hide Image;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/dynamic_appbar.dart';
import 'subcategories_controller.dart';

class SubcategoriesView extends GetView<SubcategoriesController> {
  const SubcategoriesView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DynamicAppBar(
        title: controller.displayTitle,
      ),
      body: Obx(() {
        // Loading state
        if (controller.isLoading.value && !controller.hasContent) {
          return const Center(child: CircularProgressIndicator());
        }
        
        // Error state
        if (controller.hasError.value && !controller.hasContent) {
          return _buildErrorState();
        }
        
        // Empty state
        if (!controller.hasContent) {
          return _buildEmptyState();
        }
        
        // Show subcategories grid
        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: _buildSubcategoriesGrid(),
        );
      }),
    );
  }
  
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              'Something went wrong',
              style: AppTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Obx(() => Text(
              controller.errorMessage.value,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            )),
            const SizedBox(height: AppTheme.spacingLg),
            ElevatedButton.icon(
              onPressed: controller.refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 80,
              color: AppTheme.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              'No Subcategories',
              style: AppTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'This category has no subcategories',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingLg),
            ElevatedButton.icon(
              onPressed: controller.refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build grid of subcategories
  Widget _buildSubcategoriesGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.85,
        crossAxisSpacing: AppTheme.spacingMd,
        mainAxisSpacing: AppTheme.spacingMd,
      ),
      itemCount: controller.subcategories.length,
      itemBuilder: (context, index) {
        final subcategory = controller.subcategories[index];
        return _buildSubcategoryItem(subcategory);
      },
    );
  }
  
  /// Build single subcategory item
  Widget _buildSubcategoryItem(Data subcategory) {
    return GestureDetector(
      onTap: () => controller.onSubcategoryTap(subcategory),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Subcategory icon/image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: subcategory.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      child: Image.network(
                        subcategory.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildIconPlaceholder(subcategory.name),
                      ),
                    )
                  : _buildIconPlaceholder(subcategory.name),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            // Subcategory name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXs),
              child: Text(
                subcategory.name,
                style: AppTheme.bodySmall.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Item count
            if (subcategory.productCount != null && subcategory.productCount! > 0)
              Text(
                '${subcategory.productCount} products',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildIconPlaceholder(String name) {
    return Center(
      child: Icon(
        _getCategoryIcon(name),
        color: AppTheme.primaryColor,
        size: 28,
      ),
    );
  }
  
  /// Get icon for category/subcategory based on name
  IconData _getCategoryIcon(String name) {
    final nameLower = name.toLowerCase();
    
    if (nameLower.contains('tool')) return Icons.build_outlined;
    if (nameLower.contains('electric')) return Icons.electrical_services_outlined;
    if (nameLower.contains('plumb')) return Icons.plumbing_outlined;
    if (nameLower.contains('paint')) return Icons.format_paint_outlined;
    if (nameLower.contains('lock')) return Icons.lock_outlined;
    if (nameLower.contains('garden')) return Icons.yard_outlined;
    
    return Icons.category_outlined;
  }
}
