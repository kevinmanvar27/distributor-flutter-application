// Home View - Premium E-Commerce Design
// 
// Flipkart/Amazon style home screen with:
// - Premium AppBar with search
// - Hero banner carousel
// - Category grid (circular icons)
// - Featured products section
// - Latest products section
// - Modern card designs

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../models/Home.dart' hide Image;
import '../../routes/app_routes.dart';
import '../cart/cart_controller.dart';
import '../main/main_controller.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(
      //     'Distributor',
      //     style: TextStyle(
      //       color: Colors.white,
      //       fontSize: 22,
      //       fontWeight: FontWeight.w700,
      //       letterSpacing: -0.5,
      //     ),
      //   ),
      // ),
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          // Premium AppBar
          _buildPremiumAppBar(context),

          // Main Content
          Expanded(
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

              // Content
              return RefreshIndicator(
                onRefresh: controller.refreshHomeData,
                color: AppTheme.primaryColor,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero Banner
                      _buildHeroBanner(),

                      // Categories section
                      if (controller.categories.isNotEmpty)
                        _buildCategoriesSection(),

                      // Featured Products section
                      if (controller.featuredProducts.isNotEmpty)
                        _buildProductSection(
                          title: 'Featured Products',
                          subtitle: 'Handpicked for you',
                          products: controller.featuredProducts,
                          icon: Icons.star_rounded,
                          iconColor: AppTheme.secondaryColor,
                        ),

                      // Latest Products section
                      if (controller.latestProducts.isNotEmpty)
                        _buildProductSection(
                          title: 'New Arrivals',
                          subtitle: 'Fresh from the warehouse',
                          products: controller.latestProducts,
                          icon: Icons.new_releases_rounded,
                          iconColor: AppTheme.accentColor,
                        ),

                      // Bottom padding
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
  
  /// Premium AppBar with search bar
 /* Widget _buildPremiumAppBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Top bar with logo and icons
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              child: Row(
                children: [
                  // Logo/Brand
                  const Text(
                    'Distributor',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  // Notification icon - REMOVED
                  // Cart icon - REMOVED
                ],
              ),
            ),
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: GestureDetector(
                onTap: _navigateToSearch,
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Icon(
                        Icons.search,
                        color: AppTheme.primaryColor,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Search for products...',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textTertiary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        height: 24,
                        width: 1,
                        color: AppTheme.borderColor,
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.mic_none_rounded,
                        color: AppTheme.primaryColor,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }*/
  Widget _buildPremiumAppBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  const Text(
                    'Distributor',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: GestureDetector(
                onTap: _navigateToSearch,
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Icon(
                        Icons.search,
                        color: AppTheme.primaryColor,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Search for products...',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textTertiary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        height: 24,
                        width: 1,
                        color: AppTheme.borderColor,
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.mic_none_rounded,
                        color: AppTheme.primaryColor,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAppBarIcon({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
  
  Widget _buildCartIcon() {
    return Obx(() {
      final cartController = Get.find<CartController>();
      final count = cartController.cartCount;
      
      return Stack(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                try {
                  final mainController = Get.find<MainController>();
                  mainController.changeTab(2);
                } catch (_) {}
              },
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
          if (count > 0)
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: AppTheme.saleGradient,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Text(
                  count > 99 ? '99+' : count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      );
    });
  }
  
  /// Navigate to search screen
  void _navigateToSearch() {
    Get.toNamed(Routes.search);
  }
  
  /// Hero Banner
  Widget _buildHeroBanner() {
    return Container(
      height: 160,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowMd,
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 180,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: const Text(
                    'SPECIAL OFFER',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Get Best Deals',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Exclusive wholesale prices for distributors',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Categories Section - Circular icons grid
  Widget _buildCategoriesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.primarySurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.category_rounded,
                    color: AppTheme.primaryColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Shop by Category',
                  style: AppTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: Obx(() => ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: controller.categories.length,
              itemBuilder: (context, index) {
                final category = controller.categories[index];
                return _buildCategoryItem(category, index);
              },
            )),
          ),
        ],
      ),
    );
  }
  
  /// Single category item - Circular design
  Widget _buildCategoryItem(Category category, int index) {
    // Different colors for categories
    final colors = [
      const Color(0xFFE3F2FD),
      const Color(0xFFFCE4EC),
      const Color(0xFFF3E5F5),
      const Color(0xFFE8F5E9),
      const Color(0xFFFFF3E0),
      const Color(0xFFE0F7FA),
      const Color(0xFFFFF8E1),
      const Color(0xFFEDE7F6),
    ];
    
    final iconColors = [
      const Color(0xFF1976D2),
      const Color(0xFFC2185B),
      const Color(0xFF7B1FA2),
      const Color(0xFF388E3C),
      const Color(0xFFF57C00),
      const Color(0xFF0097A7),
      const Color(0xFFFFA000),
      const Color(0xFF512DA8),
    ];
    
    final bgColor = colors[index % colors.length];
    final iconColor = iconColors[index % iconColors.length];
    final categoryIcon = _getCategoryIcon(category.name);
    
    return GestureDetector(
      onTap: () => _navigateToSubcategories(category),
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Circular icon container
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: iconColor.withValues(alpha: 0.2),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  categoryIcon,
                  color: iconColor,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Category name
            Text(
              category.name,
              style: AppTheme.labelSmall.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.lineThrough,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
  
  /// Navigate to subcategories
  void _navigateToSubcategories(Category category) {
    Get.toNamed(
      '/subcategories/${category.id}',
      arguments: category,
    );
  }
  
  /// Get icon for category
  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    
    if (name.contains('electronic') || name.contains('device')) {
      return Icons.devices_rounded;
    } else if (name.contains('phone') || name.contains('mobile')) {
      return Icons.phone_android_rounded;
    } else if (name.contains('laptop') || name.contains('computer')) {
      return Icons.laptop_mac_rounded;
    } else if (name.contains('tv') || name.contains('television')) {
      return Icons.tv_rounded;
    } else if (name.contains('camera')) {
      return Icons.camera_alt_rounded;
    } else if (name.contains('audio') || name.contains('speaker') || name.contains('headphone')) {
      return Icons.headphones_rounded;
    } else if (name.contains('watch') || name.contains('wearable')) {
      return Icons.watch_rounded;
    } else if (name.contains('home') || name.contains('appliance')) {
      return Icons.home_rounded;
    } else if (name.contains('kitchen')) {
      return Icons.kitchen_rounded;
    } else if (name.contains('fashion') || name.contains('cloth')) {
      return Icons.checkroom_rounded;
    } else if (name.contains('beauty') || name.contains('cosmetic')) {
      return Icons.face_rounded;
    } else if (name.contains('sport') || name.contains('fitness')) {
      return Icons.fitness_center_rounded;
    } else if (name.contains('book') || name.contains('stationery')) {
      return Icons.menu_book_rounded;
    } else if (name.contains('toy') || name.contains('game')) {
      return Icons.toys_rounded;
    } else if (name.contains('food') || name.contains('grocery')) {
      return Icons.local_grocery_store_rounded;
    } else if (name.contains('health') || name.contains('medicine')) {
      return Icons.medical_services_rounded;
    } else if (name.contains('tool') || name.contains('hardware')) {
      return Icons.build_rounded;
    } else if (name.contains('furniture')) {
      return Icons.chair_rounded;
    } else if (name.contains('garden') || name.contains('outdoor')) {
      return Icons.park_rounded;
    } else if (name.contains('pet')) {
      return Icons.pets_rounded;
    } else if (name.contains('baby') || name.contains('kid')) {
      return Icons.child_care_rounded;
    } else if (name.contains('car') || name.contains('auto')) {
      return Icons.directions_car_rounded;
    } else if (name.contains('office')) {
      return Icons.business_center_rounded;
    } else {
      return Icons.category_rounded;
    }
  }
  
  /// Product Section with premium design
  Widget _buildProductSection({
    required String title,
    required String subtitle,
    required List<Product> products,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTheme.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to see all
                    try {
                      final mainController = Get.find<MainController>();
                      mainController.changeTab(1);
                    } catch (_) {}
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View All',
                        style: AppTheme.labelMedium.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: AppTheme.primaryColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Products horizontal list
          SizedBox(
            height: 260,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return _buildProductCard(product);
              },
            ),
          ),
        ],
      ),
    );
  }
  
  /// Premium Product Card
  Widget _buildProductCard(Product product) {
    // Calculate discount percentage if applicable
    double? discountPercent;
    final mrpValue = double.tryParse(product.mrp) ?? 0;
    if (product.discountedPrice is num && mrpValue > 0) {
      final discounted = (product.discountedPrice as num).toDouble();
      if (discounted < mrpValue) {
        discountPercent = ((mrpValue - discounted) / mrpValue * 100);
      }
    }
    
    return GestureDetector(
      onTap: () => _navigateToProductDetail(product.id),
      child: Container(
        width: 165,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.borderColor.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image with badges
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppTheme.radiusMd),
                    ),
                    child: Container(
                      width: double.infinity,
                      color: const Color(0xFFF8F8F8),
                      child: product.mainPhoto?.fullUrl != null
                          ? Image.network(
                              product.mainPhoto!.fullUrl!,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                            )
                          : _buildImagePlaceholder(),
                    ),
                  ),
                  // Discount badge
                  if (discountPercent != null && discountPercent > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${discountPercent.toStringAsFixed(0)}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  // Out of stock overlay
                  if (!product.inStock)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(AppTheme.radiusMd),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'OUT OF STOCK',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Cart quantity badge
                  Obx(() {
                    final cartController = Get.find<CartController>();
                    final qty = cartController.getQuantityInCart(product.id);
                    if (qty > 0) {
                      return Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            '$qty',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
            // Product details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name
                    Text(
                      product.name,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Price section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${_formatPrice(discountPercent != null ? (product.discountedPrice as num).toDouble() : mrpValue)}',
                          style: AppTheme.priceSmall.copyWith(
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        if (discountPercent != null && discountPercent > 0) ...[
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '₹${_formatPrice(mrpValue)}',
                              style: AppTheme.strikePrice,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    // Discount text
                    if (discountPercent != null && discountPercent > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'Save ₹${_formatPrice(mrpValue - (product.discountedPrice as num).toDouble())}',
                          style: AppTheme.discountStyle.copyWith(fontSize: 11),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatPrice(double price) {
    if (price >= 10000000) {
      return '${(price / 10000000).toStringAsFixed(2)} Cr';
    } else if (price >= 100000) {
      return '${(price / 100000).toStringAsFixed(2)} L';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(1)}K';
    }
    return price.toStringAsFixed(0);
  }
  
  Widget _buildImagePlaceholder() {
    return Center(
      child: Icon(
        Icons.image_outlined,
        color: AppTheme.textTertiary,
        size: 40,
      ),
    );
  }
  
  /// Navigate to product detail
  void _navigateToProductDetail(int productId) {
    Get.toNamed(
      Routes.productDetail.replaceFirst(':id', productId.toString()),
    );
  }
  
  /// Loading state with shimmer
  Widget _buildLoadingState() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Banner shimmer
          Container(
            height: 160,
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.shimmerBase,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
          ),
          // Categories shimmer
          Container(
            height: 120,
            margin: const EdgeInsets.symmetric(vertical: 8),
            color: AppTheme.surfaceColor,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(16),
              itemCount: 6,
              itemBuilder: (_, __) => Container(
                width: 70,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppTheme.shimmerBase,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: 50,
                      decoration: BoxDecoration(
                        color: AppTheme.shimmerBase,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Products shimmer
          Container(
            height: 280,
            margin: const EdgeInsets.only(top: 8),
            color: AppTheme.surfaceColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    height: 20,
                    width: 150,
                    decoration: BoxDecoration(
                      color: AppTheme.shimmerBase,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: 4,
                    itemBuilder: (_, __) => Container(
                      width: 165,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.shimmerBase,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Error state
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.errorLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppTheme.errorColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Oops! Something went wrong',
              style: AppTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Obx(() => Text(
              controller.errorMessage.value,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            )),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.loadHomeData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: AppTheme.primaryButtonStyle,
            ),
          ],
        ),
      ),
    );
  }
  
  /// Empty state
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primarySurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 48,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No products available',
              style: AppTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new arrivals',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.refreshHomeData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh'),
              style: AppTheme.primaryButtonStyle,
            ),
          ],
        ),
      ),
    );
  }
}
