// 
// Subcategories Controller
// Simple logic:
// 1. Load subcategories for sidebar
// 2. Load ALL products for the category (shown when "All" selected)
// 3. Filter products when subcategory selected

import 'package:flutter/foundation.dart' hide Category;
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../models/catagories.dart';
import '../../models/Home.dart' show Category;
import '../cart/cart_controller.dart';
import '../../models/category.dart' show ProductItem, ProductImage;

class SubcategoriesController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  // Current category info
  final RxInt categoryId = 0.obs;
  final RxString categoryName = ''.obs;
  
  // Selected subcategory for filtering (null = "All")
  final Rx<Data?> selectedSubcategory = Rx<Data?>(null);
  
  // Subcategories list
  final RxList<Data> subcategories = <Data>[].obs;
  
  // Products list
  final RxList<Product> allProducts = <Product>[].obs;
  final RxList<Product> filteredProducts = <Product>[].obs;
  
  // State
  final RxBool isLoading = false.obs;
  final RxBool isLoadingProducts = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    
    final args = Get.arguments;
    debugPrint('SubcategoriesController: args type: ${args.runtimeType}');
    
    if (args is Category) {
      categoryId.value = args.id;
      categoryName.value = args.name;
      _initializeData();
    } else if (args is Map) {
      categoryId.value = args['id'] ?? 0;
      categoryName.value = args['name'] ?? '';
      _initializeData();
    }
  }
  
  /// Initialize - load both subcategories and products
  Future<void> _initializeData() async {
    if (categoryId.value == 0) return;
    
    isLoading.value = true;
    hasError.value = false;
    
    try {
      // Load subcategories and products in parallel
      await Future.wait([
        _loadSubcategories(),
        _loadAllProducts(),
      ]);
    } catch (e) {
      debugPrint('SubcategoriesController: Error initializing: $e');
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Load subcategories from API
  Future<void> _loadSubcategories() async {
    try {
      final endpoint = '/customer/categories/${categoryId.value}/subcategories';
      debugPrint('SubcategoriesController: Fetching subcategories from $endpoint');
      
      final response = await _apiService.get(endpoint);
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        
        if (data['success'] == true && data['data'] != null) {
          final innerData = data['data'];
          
          // Try different key names for subcategories
          List<dynamic>? subCatJson;
          if (innerData['subcategories'] is List) {
            subCatJson = innerData['subcategories'];
          } else if (innerData['sub_categories'] is List) {
            subCatJson = innerData['sub_categories'];
          } else if (innerData['children'] is List) {
            subCatJson = innerData['children'];
          }
          
          if (subCatJson != null) {
            final subCatList = subCatJson.map((json) => Data.fromJson(json)).toList();
            subcategories.assignAll(subCatList);
            debugPrint('SubcategoriesController: Loaded ${subcategories.length} subcategories');
          }
          
          // Also check if products are included in this response
          if (innerData['products'] is List && (innerData['products'] as List).isNotEmpty) {
            final productList = (innerData['products'] as List)
                .map((json) => Product.fromJson(json))
                .toList();
            allProducts.assignAll(productList);
            filteredProducts.assignAll(productList);
            debugPrint('SubcategoriesController: Loaded ${allProducts.length} products from subcategories response');
          }
        }
      }
    } catch (e) {
      debugPrint('SubcategoriesController: Error loading subcategories: $e');
    }
  }
  
  /// Load ALL products for this category
  Future<void> _loadAllProducts() async {
    // Skip if we already loaded products from subcategories response
    if (allProducts.isNotEmpty) {
      debugPrint('SubcategoriesController: Products already loaded, skipping');
      return;
    }
    
    try {
      final endpoint = '/customer/categories/${categoryId.value}/products';
      debugPrint('SubcategoriesController: Fetching products from $endpoint');
      
      final response = await _apiService.get(endpoint);
      debugPrint('SubcategoriesController: Products response status: ${response.statusCode}');
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        debugPrint('SubcategoriesController: Products response keys: ${data.keys.toList()}');
        
        List<dynamic>? productsJson;
        
        if (data['success'] == true && data['data'] != null) {
          final innerData = data['data'];
          debugPrint('SubcategoriesController: Inner data type: ${innerData.runtimeType}');
          
          if (innerData is List) {
            productsJson = innerData;
          } else if (innerData is Map) {
            debugPrint('SubcategoriesController: Inner data keys: ${innerData.keys.toList()}');
            if (innerData['products'] is List) {
              productsJson = innerData['products'];
            } else if (innerData['data'] is List) {
              productsJson = innerData['data'];
            }
          }
        } else if (data['data'] is List) {
          productsJson = data['data'];
        } else if (data['products'] is List) {
          productsJson = data['products'];
        }
        
        if (productsJson != null && productsJson.isNotEmpty) {
          final productList = productsJson.map((json) => Product.fromJson(json)).toList();
          allProducts.assignAll(productList);
          filteredProducts.assignAll(productList);
          debugPrint('SubcategoriesController: Loaded ${allProducts.length} products');
        } else {
          debugPrint('SubcategoriesController: No products found in response');
          allProducts.clear();
          filteredProducts.clear();
        }
      }
    } catch (e) {
      debugPrint('SubcategoriesController: Error loading products: $e');
    }
  }
  
  /// Select subcategory - filter products
  void selectSubcategory(Data? subcategory) {
    selectedSubcategory.value = subcategory;
    
    if (subcategory == null) {
      // "All" selected - show all products
      filteredProducts.assignAll(allProducts);
      debugPrint('SubcategoriesController: Showing all ${allProducts.length} products');
    } else {
      // Filter products by subcategory ID
      isLoadingProducts.value = true;
      
      // Filter from existing products
      final filtered = allProducts.where((product) {
        // Check if product belongs to this subcategory using the model's method
        return product.belongsToCategory(subcategory.id) || 
               product.belongsToSubcategory(categoryId.value, subcategory.id);
      }).toList();
      
      if (filtered.isNotEmpty) {
        filteredProducts.assignAll(filtered);
        debugPrint('SubcategoriesController: Filtered to ${filtered.length} products for "${subcategory.name}"');
        isLoadingProducts.value = false;
      } else {
        // No local matches - try loading from API
        _loadSubcategoryProducts(subcategory);
      }
    }
  }
  
  /// Load products for specific subcategory from API
  Future<void> _loadSubcategoryProducts(Data subcategory) async {
    try {
      final endpoint = '/customer/categories/${subcategory.id}/products';
      debugPrint('SubcategoriesController: Fetching subcategory products from $endpoint');
      
      final response = await _apiService.get(endpoint);
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        List<dynamic>? productsJson;
        
        if (data['success'] == true && data['data'] != null) {
          final innerData = data['data'];
          if (innerData is List) {
            productsJson = innerData;
          } else if (innerData is Map) {
            productsJson = innerData['products'] ?? innerData['data'];
          }
        } else if (data['data'] is List) {
          productsJson = data['data'];
        }
        
        if (productsJson != null && productsJson.isNotEmpty) {
          final productList = productsJson.map((json) => Product.fromJson(json)).toList();
          filteredProducts.assignAll(productList);
          debugPrint('SubcategoriesController: Loaded ${productList.length} subcategory products from API');
        } else {
          filteredProducts.clear();
          debugPrint('SubcategoriesController: No products for this subcategory');
        }
      }
    } catch (e) {
      debugPrint('SubcategoriesController: Error loading subcategory products: $e');
      filteredProducts.clear();
    } finally {
      isLoadingProducts.value = false;
    }
  }
  
  /// Navigate to product detail
  void onProductTap(Product product) {
    debugPrint('SubcategoriesController: Tapped "${product.name}" (ID: ${product.id})');
    Get.toNamed('/product/${product.id}', arguments: product);
  }
  
  /// Refresh all data
  @override
  Future<void> refresh() async {
    selectedSubcategory.value = null;
    await _initializeData();
  }
  
  /// Check if has content
  bool get hasContent => subcategories.isNotEmpty || allProducts.isNotEmpty;
  
  /// Display title
  String get displayTitle => categoryName.value.isNotEmpty ? categoryName.value : 'Products';
  
  /// Get selected subcategory name for display
  String get selectedSubcategoryName => selectedSubcategory.value?.name ?? 'All Products';
  
  /// Add to cart
  Future<void> addToCart(Product product, {int quantity = 1}) async {
    try {
      final cartController = Get.find<CartController>();
      final item = ProductItem(
        id: product.id,
        name: product.name,
        slug: product.slug,
        description: product.description,
        mrp: product.mrp,
        sellingPrice: product.sellingPrice,
        inStock: product.inStock,
        stockQuantity: product.stockQuantity,
        status: product.status,
        mainPhotoId: product.mainPhotoId,
        productGallery: product.productGallery,
        productCategories: product.productCategories,
        metaTitle: product.metaTitle,
        metaDescription: product.metaDescription,
        metaKeywords: product.metaKeywords,
        createdAt: product.createdAt,
        updatedAt: product.updatedAt,
        discountedPrice: product.sellingPrice,
        mainPhoto: ProductImage(
          id: product.mainPhoto.id,
          name: product.mainPhoto.name,
          fileName: product.mainPhoto.fileName,
          mimeType: product.mainPhoto.mimeType,
          path: product.mainPhoto.path,
          size: product.mainPhoto.size,
          createdAt: product.mainPhoto.createdAt,
          updatedAt: product.mainPhoto.updatedAt,
        ),
      );
      await cartController.addToCart(item, quantity: quantity);
    } catch (e) {
      debugPrint('SubcategoriesController: Error adding to cart: $e');
    }
  }
}
