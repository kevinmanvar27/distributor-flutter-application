// Subcategories Screen - Premium UI
// Shows ONLY subcategories from /categories/{id} API
// Uses ONLY catagories.dart model (Data class)

import 'package:distributor_app/models/catagories.dart' hide Image;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import 'subcategories_controller.dart';

class SubcategoriesView extends GetView<SubcategoriesController> {
  const SubcategoriesView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Premium Gradient AppBar
          _buildSliverAppBar(),
          
          // Content
          SliverToBoxAdapter(
            child: Obx(() {
              // Loading state
              if (controller.isLoading.value && !controller.hasContent) {
                return _buildLoadingState();
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
              return _buildSubcategoriesContent();
            }),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Premium Sliver AppBar with Gradient
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppTheme.dynamicPrimaryColor,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
        onPressed: () => Get.back(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.dynamicPrimaryColor,
                AppTheme.dynamicPrimaryColor.withValues(alpha: 0.8),
                AppTheme.dynamicSecondaryColor.withValues(alpha: 0.6),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        ),
                        child: const Icon(
                          Icons.category_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.displayTitle,
                              style: AppTheme.headingMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Obx(() => Text(
                              '${controller.subcategories.length} subcategories',
                              style: AppTheme.bodySmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            )),
                          ],
                        ),
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
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Loading State
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildLoadingState() {
    return SizedBox(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.dynamicPrimaryColor),
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              'Loading subcategories...',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Error State - Premium Design
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingXl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          // Error icon with gradient background
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.errorColor.withValues(alpha: 0.1),
                  AppTheme.errorColor.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppTheme.errorColor.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          Text(
            'Oops! Something went wrong',
            style: AppTheme.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Obx(() => Text(
            controller.errorMessage.value,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          )),
          const SizedBox(height: AppTheme.spacingXl),
          // Premium retry button
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.dynamicPrimaryColor,
                  AppTheme.dynamicSecondaryColor,
                ],
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.dynamicPrimaryColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: controller.refresh,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingXl,
                    vertical: AppTheme.spacingMd,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.refresh, color: Colors.white, size: 20),
                      const SizedBox(width: AppTheme.spacingSm),
                      Text(
                        'Try Again',
                        style: AppTheme.labelLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Empty State - Premium Design
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingXl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          // Empty icon with gradient background
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.dynamicPrimaryColor.withValues(alpha: 0.1),
                  AppTheme.dynamicSecondaryColor.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.category_outlined,
              size: 56,
              color: AppTheme.dynamicPrimaryColor.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          Text(
            'No Subcategories',
            style: AppTheme.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'This category doesn\'t have any subcategories yet',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingXl),
          // Refresh button
          OutlinedButton.icon(
            onPressed: controller.refresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.dynamicPrimaryColor,
              side: BorderSide(color: AppTheme.dynamicPrimaryColor),
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingLg,
                vertical: AppTheme.spacingMd,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Subcategories Content
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildSubcategoriesContent() {
    return RefreshIndicator(
      onRefresh: controller.refresh,
      color: AppTheme.dynamicPrimaryColor,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppTheme.dynamicPrimaryColor,
                          AppTheme.dynamicSecondaryColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  Text(
                    'Browse Subcategories',
                    style: AppTheme.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.82,
                crossAxisSpacing: AppTheme.spacingMd,
                mainAxisSpacing: AppTheme.spacingMd,
              ),
              itemCount: controller.subcategories.length,
              itemBuilder: (context, index) {
                final subcategory = controller.subcategories[index];
                return _buildSubcategoryItem(subcategory, index);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Single Subcategory Item - Premium Card
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildSubcategoryItem(Data subcategory, int index) {
    // Alternate colors for visual interest
    final isEven = index % 2 == 0;
    final accentColor = isEven 
        ? AppTheme.dynamicPrimaryColor 
        : AppTheme.dynamicSecondaryColor;
    
    return GestureDetector(
      onTap: () => controller.onSubcategoryTap(subcategory),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: AppTheme.borderColor.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Subcategory icon/image with gradient border
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accentColor.withValues(alpha: 0.15),
                    accentColor.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: subcategory.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd - 2),
                      child: Image.network(
                        subcategory.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildIconPlaceholder(
                          subcategory.name, 
                          accentColor,
                        ),
                      ),
                    )
                  : _buildIconPlaceholder(subcategory.name, accentColor),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            // Subcategory name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXs),
              child: Text(
                subcategory.name,
                style: AppTheme.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Product count badge
            if (subcategory.productCount != null && subcategory.productCount! > 0)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${subcategory.productCount} items',
                  style: AppTheme.bodySmall.copyWith(
                    color: accentColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconPlaceholder(String name, Color accentColor) {
    return Center(
      child: Icon(
        _getCategoryIcon(name),
        color: accentColor,
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
    if (nameLower.contains('light')) return Icons.lightbulb_outlined;
    if (nameLower.contains('wire')) return Icons.cable_outlined;
    if (nameLower.contains('switch')) return Icons.toggle_on_outlined;
    if (nameLower.contains('fan')) return Icons.air_outlined;
    
    return Icons.category_outlined;
  }
}
