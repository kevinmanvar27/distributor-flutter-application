// 
// Subcategories Controller
// Shows ONLY subcategories from /categories/{id} API
// Uses ONLY catagories.dart model for API response

import 'package:flutter/foundation.dart' hide Category;
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../models/catagories.dart';
import '../../models/Home.dart' show Category;

class SubcategoriesController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  // Current category info
  final RxInt categoryId = 0.obs;
  final RxString categoryName = ''.obs;
  
  // Subcategories list - using Data from catagories.dart
  final RxList<Data> subcategories = <Data>[].obs;
  
  // State
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    
    final args = Get.arguments;
    debugPrint('SubcategoriesController: args type: ${args.runtimeType}');
    
    if (args is Category) {
      // Coming from Home screen - Category from Home.dart
      categoryId.value = args.id;
      categoryName.value = args.name;
      loadSubcategories();
    } else if (args is Map) {
      categoryId.value = args['id'] ?? 0;
      categoryName.value = args['name'] ?? '';
      loadSubcategories();
    }
  }
  
  /// Load subcategories from /categories/{id}
  Future<void> loadSubcategories() async {
    if (categoryId.value == 0) return;
    
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      
      final endpoint = '/categories/${categoryId.value}';
      debugPrint('SubcategoriesController: Fetching $endpoint');
      
      final response = await _apiService.get(endpoint);
      
      if (response.statusCode == 200 && response.data != null) {
        final result = Categories.fromJson(response.data);
        
        if (result.success && result.data.subCategories != null) {
          subcategories.assignAll(result.data.subCategories!);
          debugPrint('SubcategoriesController: Loaded ${subcategories.length} subcategories');
        } else {
          subcategories.clear();
          debugPrint('SubcategoriesController: No subcategories found');
        }
      } else {
        throw Exception('Failed to load: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('SubcategoriesController: Error: $e');
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Navigate to products screen when subcategory is tapped
  void onSubcategoryTap(Data subcategory) {
    debugPrint('SubcategoriesController: Tapped "${subcategory.name}" (ID: ${subcategory.id})');
    debugPrint('SubcategoriesController: Parent category ID: ${categoryId.value}');
    
    // Navigate to products screen with both category and subcategory data
    Get.toNamed(
      '/subcategory-products/${subcategory.id}',
      arguments: {
        'subcategory': subcategory,
        'categoryId': categoryId.value,
        'categoryName': categoryName.value,
      },
    );
  }
  
  /// Refresh
  @override
  Future<void> refresh() async {
    await loadSubcategories();
  }
  
  /// Check if has content
  bool get hasContent => subcategories.isNotEmpty;
  
  /// Display title
  String get displayTitle => categoryName.value.isNotEmpty ? categoryName.value : 'Subcategories';
}
