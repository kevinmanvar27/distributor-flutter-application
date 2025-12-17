// Cart Controller
// 
// Manages shopping cart state and operations:
// - Fetch cart items from API
// - Update cart item quantity
// - Delete cart item
// - Cart totals calculation

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import '../../core/services/storage_service.dart';
import '../../models/cart_item.dart';
import '../../models/category.dart';
import '../../models/cart_invoince.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_routes.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'dart:convert';
import 'package:file_saver/file_saver.dart'; // For invoice download
import 'dart:typed_data'; // For Uint8List

class CartController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // ─────────────────────────────────────────────────────────────────────────────
  // Reactive State
  // ─────────────────────────────────────────────────────────────────────────────

  final RxList<Item> cartItems = <Item>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isCheckingOut = false.obs;
  final RxBool isGeneratingInvoice = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isUpdating = false.obs;
  final RxString cartTotal = '0'.obs;
  
  late Razorpay _razorpay;
  final StorageService _storageService = Get.find<StorageService>();

  // Tax rate (configurable)
  final double taxRate = 0.10; // 10%

  // ─────────────────────────────────────────────────────────────────────────────
  // Computed Properties
  // ─────────────────────────────────────────────────────────────────────────────

  /// Total number of items in cart (sum of quantities)
  int get cartCount => cartItems.fold(0, (sum, item) => sum + item.quantity);

  /// Reactive cart count for badge updates
  RxInt get cartCountRx => cartCount.obs;

  /// Number of unique products in cart
  int get uniqueItemsCount => cartItems.length;

  /// Cart subtotal (before tax)
  double get subtotal => cartItems.fold(
    0.0, 
    (sum, item) => sum + item.totalPrice,
  );

  /// Tax amount
  double get taxAmount => subtotal * taxRate;

  /// Total discount applied
  double get totalDiscount => cartItems.fold(
    0.0,
    (sum, item) => sum + item.discountAmount,
  );

  /// Cart total (after tax)
  double get total => subtotal + taxAmount;

  /// Check if cart is empty
  bool get isEmpty => cartItems.isEmpty;

  /// Check if cart has items
  bool get hasItems => cartItems.isNotEmpty;

  // ─────────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    fetchCart();
    
    // Initialize Razorpay
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Razorpay Handlers
  // ─────────────────────────────────────────────────────────────────────────────

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _showSnackbar('Payment Successful', 'Transaction ID: ${response.paymentId}');
    // Generate Invoice with 'paid' status
    _generateAndSaveInvoice(status: 'paid', paymentId: response.paymentId);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _showSnackbar('Payment Failed', 'Error: ${response.message}', isError: true);
    isCheckingOut.value = false;
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _showSnackbar('External Wallet', 'Wallet: ${response.walletName}');
    // Allow to proceed? Usually treat as success or specific handling.
    // For now, let's treat it as a success for invoice generation
    _generateAndSaveInvoice(status: 'paid');
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // API Operations
  // ─────────────────────────────────────────────────────────────────────────────

  /// Fetch cart items from API
  /// GET https://hardware.rektech.work/api/v1/cart
  Future<void> fetchCart() async {
    if (isLoading.value) {
      debugPrint('CartController: Already loading, skipping duplicate call');
      return;
    }
    
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';
    
    try {
      final response = await _apiService.get('/cart');
      
      debugPrint('CartController: API Response: ${response.data}');
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        
        List<Item> items = [];
        
        if (data is Map<String, dynamic>) {
          // Parse using CartItem model
          if (data['success'] == true && data['data'] != null) {
            final cartData = data['data'];
            
            if (cartData is Map<String, dynamic>) {
              // Get total from API response
              cartTotal.value = cartData['total']?.toString() ?? '0';
              
              if (cartData['items'] is List) {
                final itemsList = cartData['items'] as List;
                items = _parseItemsList(itemsList);
              }
            }
          } else if (data['items'] is List) {
            items = _parseItemsList(data['items'] as List);
          }
        }
        
        cartItems.clear();
        cartItems.addAll(items);
        cartItems.refresh();
        debugPrint('CartController: Loaded ${cartItems.length} items from API');
      }
    } catch (e, stackTrace) {
      debugPrint('CartController: Error fetching cart: $e');
      debugPrint('Stack trace: $stackTrace');
      hasError.value = true;
      errorMessage.value = 'Failed to load cart: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Alias for fetchCart (backward compatibility)
  Future<void> loadCartFromAPI() async {
    await fetchCart();
  }

  /// Refresh cart from API
  Future<void> refreshCart() async {
    await fetchCart();
  }

  /// Add a product to the cart
  /// Creates a new cart item or increases quantity if already exists
  Future<void> addToCart(ProductItem product, {int quantity = 1}) async {
    try {
      // Check if product already exists in cart
      final existingItemIndex = cartItems.indexWhere((item) => item.productId == product.id);
      
      if (existingItemIndex != -1) {
        // Product already in cart, increase quantity
        final existingItem = cartItems[existingItemIndex];
        final newQuantity = existingItem.quantity + quantity;
        
        // Update quantity via API
        await updateCartItem(existingItem.id, newQuantity);
        
        // Update local state
        cartItems[existingItemIndex] = existingItem.copyWith(quantity: newQuantity);
      } else {
        // New product, add to cart via API
        final newItem = await _addNewItemToCart(product, quantity);
        cartItems.add(newItem);
      }
      
      cartItems.refresh();
      
      // Show success message
      _showSnackbar(
        'Added to Cart',
        '${product.name} added to your cart',
      );
      
      // Refresh cart to get updated totals
      await fetchCart();
    } catch (e) {
      debugPrint('Error adding to cart: $e');
      _showSnackbar('Error', 'Failed to add item to cart', isError: true);
    }
  }

  /// Helper method to add a new item to cart via API
  /// POST https://hardware.rektech.work/api/v1/cart/add
  Future<Item> _addNewItemToCart(ProductItem product, int quantity) async {
    final payload = {
      'product_id': product.id,
      'quantity': quantity,
    };
    
    final response = await _apiService.post('/cart/add', data: payload);
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      // Parse the response to create a new Item
      final itemData = response.data['data'] ?? response.data;
      return Item.fromJson(itemData);
    } else {
      throw Exception('Failed to add item to cart: ${response.data['message']}');
    }
  }

  /// Parse a list of items from the API response
  List<Item> _parseItemsList(List itemsList) {
    final List<Item> items = [];
    
    for (int i = 0; i < itemsList.length; i++) {
      debugPrint('CartController: Processing item $i: ${itemsList[i]}');
      if (itemsList[i] is Map<String, dynamic>) {
        final itemMap = itemsList[i] as Map<String, dynamic>;
        debugPrint('CartController: Item $i keys: ${itemMap.keys.toList()}');
        
        // Try to create an Item from this data
        try {
          final item = Item.fromJson(itemMap);
          debugPrint('CartController: Successfully created item: ${item.name}, quantity: ${item.quantity}');
          items.add(item);
        } catch (e) {
          debugPrint('CartController: Error creating item from data: $e');
          // Try alternative parsing
          items.add(_parseItemFromMap(itemMap));
        }
      }
    }
    
    return items;
  }

  /// Parse item from map with more flexible approach
  Item _parseItemFromMap(Map<String, dynamic> json) {
    debugPrint('CartController: Parsing item with flexible approach: $json');
    
    // Try to extract product information
    ProductItem? product;
    if (json['product'] is Map<String, dynamic>) {
      try {
        product = ProductItem.fromJson(json['product'] as Map<String, dynamic>);
      } catch (e) {
        debugPrint('CartController: Error parsing product: $e');
      }
    }
    
    // If no product, create a minimal one from flat data
    if (product == null) {
      // Try to get product info from flat structure (not nested in 'product' key)
      product = ProductItem(
        id: json['product_id'] ?? json['productId'] ?? json['id'] ?? 0,
        name: json['product_name'] ?? json['productName'] ?? json['name'] ?? 'Unknown Product',
        slug: json['slug'] ?? '',
        description: json['description'] ?? '',
        mrp: json['mrp']?.toString() ?? json['original_price']?.toString() ?? json['price']?.toString() ?? '0',
        sellingPrice: json['selling_price']?.toString() ?? json['price']?.toString() ?? '0',
        inStock: json['in_stock'] ?? json['inStock'] ?? true,
        stockQuantity: json['stock_quantity'] ?? json['stockQuantity'] ?? json['quantity'] ?? 999,
        status: json['status'] ?? 'active',
        productGallery: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        discountedPrice: json['discounted_price']?.toString() ?? json['price']?.toString() ?? '0',
      );
    }
    
    return Item(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? json['userId'] ?? 0,
      sessionId: json['session_id'] ?? json['sessionId'],
      productId: json['product_id'] ?? json['productId'] ?? product.id,
      quantity: json['quantity'] ?? 1,
      price: json['price']?.toString() ?? product.sellingPrice,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
      product: product,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Cart Item Operations (using cart item id)
  // ─────────────────────────────────────────────────────────────────────────────

  /// Update cart item quantity
  Future<void> updateCartItem(int cartItemId, int newQuantity) async {
    if (isUpdating.value) {
      debugPrint('CartController: Already updating cart, skipping duplicate call');
      return;
    }
    
    if (newQuantity <= 0) {
      await deleteCartItem(cartItemId);
      return;
    }
    
    isUpdating.value = true;
    
    try {
      final response = await _apiService.put(
        '/cart/$cartItemId',
        data: {'quantity': newQuantity},
      );
      
      if (response.statusCode == 200) {
        await fetchCart(); // Refresh cart
      } else {
        throw Exception('Failed to update cart item');
      }
    } catch (e) {
      debugPrint('CartController: Error updating cart item: $e');
      _showSnackbar(
        'Error',
        'Failed to update item quantity',
        isError: true,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  /// Delete cart item
  Future<void> deleteCartItem(int cartItemId) async {
    if (isUpdating.value) {
      debugPrint('CartController: Already updating cart, skipping duplicate call');
      return;
    }
    
    isUpdating.value = true;
    
    try {
      final response = await _apiService.delete('/cart/$cartItemId');
      
      if (response.statusCode == 200) {
        await fetchCart(); // Refresh cart
      } else {
        throw Exception('Failed to delete cart item');
      }
    } catch (e) {
      debugPrint('CartController: Error deleting cart item: $e');
      _showSnackbar(
        'Error',
        'Failed to remove item',
        isError: true,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  /// Increment item quantity by 1 (uses cart item id)
  Future<void> incrementQuantity(int cartItemId) async {
    final item = cartItems.firstWhereOrNull((item) => item.id == cartItemId);
    if (item != null) {
      await updateCartItem(cartItemId, item.quantity + 1);
    }
  }

  /// Decrement item quantity by 1 (uses cart item id)
  Future<void> decrementQuantity(int cartItemId) async {
    final item = cartItems.firstWhereOrNull((item) => item.id == cartItemId);
    if (item != null) {
      if (item.quantity <= 1) {
        await deleteCartItem(cartItemId);
      } else {
        await updateCartItem(cartItemId, item.quantity - 1);
      }
    }
  }

  /// Remove from cart by product ID (for backward compatibility)
  Future<void> removeFromCart(int productId) async {
    final item = cartItems.firstWhereOrNull((item) => item.productId == productId);
    if (item != null) {
      await deleteCartItem(item.id);
    }
  }

  /// Clear entire cart
  Future<void> clearCart() async {
    if (isUpdating.value) {
      debugPrint('CartController: Already updating cart, skipping clear');
      return;
    }
    
    isUpdating.value = true;
    
    try {
      // Delete all items one by one
      for (final item in cartItems.toList()) {
        await _apiService.delete('/cart/${item.id}');
      }
      
      cartItems.clear();
      cartItems.refresh();
      _showSnackbar('Cart Cleared', 'All items have been removed');
    } catch (e) {
      debugPrint('CartController: Error clearing cart: $e');
      _showSnackbar(
        'Error',
        'Failed to clear cart',
        isError: true,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  /// Check if product is in cart
  bool isInCart(int productId) {
    return cartItems.any((item) => item.productId == productId);
  }

  /// Get quantity of specific product in cart
  int getQuantityInCart(int productId) {
    final item = cartItems.firstWhereOrNull((item) => item.productId == productId);
    return item?.quantity ?? 0;
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Checkout
  // ─────────────────────────────────────────────────────────────────────────────

  /// Initiate checkout process with options
  void checkout() {
    if (isEmpty) {
      _showSnackbar('Empty Cart', 'Add items to your cart first', isError: true);
      return;
    }

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppTheme.spacingMD),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLG)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Select Checkout Method',
              style: AppTheme.headingSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingLG),
            
            // COD Option
            ElevatedButton.icon(
              onPressed: () {
                Get.back(); // Close sheet
                _processCOD();
              },
              icon: const Icon(Icons.money),
              label: const Text('Cash on Delivery (COD)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMD),
            
            // Payment Option
            ElevatedButton.icon(
              onPressed: () {
                Get.back();
                _processRazorpayPayment();
              },
              icon: const Icon(Icons.payment),
              label: const Text('Online Payment (Razorpay)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
             const SizedBox(height: AppTheme.spacingMD),
            
            // Invoice Option
            ElevatedButton.icon(
              onPressed: () {
                Get.back();
                _processDirectInvoice();
              },
              icon: const Icon(Icons.description),
              label: const Text('Generate Invoice Only'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: AppTheme.spacingLG),
          ],
        ),
      ),
    );
  }

  /// Process direct invoice generation
  Future<void> _processDirectInvoice() async {
    await _generateAndSaveInvoice(status: 'draft', isDirectInvoice: true);
  }

  /// Process COD
  Future<void> _processCOD() async {
    // For COD, we basically just generate the invoice as 'draft' or 'pending' and place order
    await _generateAndSaveInvoice(status: 'draft');
  }

  /// Process Razorpay Payment
  void _processRazorpayPayment() {
    isCheckingOut.value = true;
    
    // Calculate amount in paise (multiply by 100)
    final amountInPaise = (total * 100).toInt();

    var options = {
      'key': 'rzp_test_Go3jN8rdNmRJ7P',
      'amount': amountInPaise,
      'name': 'Hardware Distributor',
      'description': 'Hardware Supplies',
      // 'prefill': {
      //   'contact': '8888888888',
      //   'email': 'test@razorpay.com'
      // }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
      isCheckingOut.value = false;
      _showSnackbar('Error', 'Unable to start payment', isError: true);
    }
  }

  /// Core method to generate invoice via API and save to DB
  Future<void> _generateAndSaveInvoice({required String status, String? paymentId, bool isDirectInvoice = false}) async {
    isCheckingOut.value = true;
    
    try {
      // 1. Get User ID
      final user = _storageService.getUser();
      final userId = user?['id'] ?? 1; // Default to 1 if not found
      
      // 2. Generate Invoice Number (Mock logic if not provided by backend)
      final invoiceNumber = 'INV-${DateTime.now().millisecondsSinceEpoch}';
      
      // 3. Prepare Payload as requested
      final payload = {
        "user_id": userId,
        "invoice_number": invoiceNumber,
        "total_amount": total,
        "status": status,
        if (paymentId != null) "payment_id": paymentId,
      };

      debugPrint('Generating Invoice: $payload');

      // 4. Call API - Using the correct endpoint as specified
      final response = await _apiService.post(
        '/proforma-invoices', // Changed from '/cart/generate-invoice' to match the requirement
        data: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success
        _showSnackbar('Invoice Generated', 'Invoice #$invoiceNumber created successfully');
        
        // 5. Show Invoice / Download Option
        _showInvoiceSuccessDialog(invoiceNumber, payload);
        
        if (!isDirectInvoice) {
            // Clear cart if it was a checkout flow
            // For COD and Payment flows, clear the cart
            cartItems.clear(); // Assume we clear cart on successful order/invoice
            Get.offAllNamed(Routes.main); 
        }
      } else {
        throw Exception('Failed to generate invoice API response: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error generating invoice: $e');
      _showSnackbar('Error', 'Failed to generate invoice', isError: true);
    } finally {
      isCheckingOut.value = false;
    }
  }

  void _showInvoiceSuccessDialog(String invoiceId, Map<String, dynamic> data) {
    Get.dialog(
      AlertDialog(
        title: const Text('Invoice Generated'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Invoice #: $invoiceId'),
            Text('Amount: ₹${data['total_amount']}'),
            Text('Status: ${data['status']}'),
            const SizedBox(height: 10),
            const Text('Invoice has been saved to your account.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
               Get.back();
               // Implement actual download logic if API returns file URL
               // For now, mock download
               _downloadInvoice(data);
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.download),
                SizedBox(width: 4),
                Text('Download'),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadInvoice(Map<String, dynamic> data) async {
    try {
        // Simulate file creation from data
        List<int> bytes = utf8.encode(jsonEncode(data));
        await FileSaver.instance.saveFile(
            name: 'Invoice_${data['invoice_number']}',
            bytes: Uint8List.fromList(bytes),
            ext: 'txt', // Or pdf if we had one
            mimeType: MimeType.text,
        );
        _showSnackbar('Downloaded', 'Invoice saved to device');
    } catch (e) {
        _showSnackbar('Error', 'Failed to download', isError: true);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Invoice Generation
  // ─────────────────────────────────────────────────────────────────────────────

  /// Generate invoice from current cart (existing method, kept for backward compatibility)
  Future<void> generateInvoice() async {
    if (isEmpty) {
      _showSnackbar('Empty Cart', 'Add items to your cart first', isError: true);
      return;
    }

    isGeneratingInvoice.value = true;

    try {
      final response = await _apiService.post('/cart/generate-invoice');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final invoice = GenerateInvoice.fromJson(data);
        
        if (invoice.success) {
          Get.toNamed(Routes.invoice, arguments: invoice);
        } else {
          throw Exception(invoice.message);
        }
      } else {
        throw Exception('Failed to generate invoice');
      }
    } catch (e) {
      debugPrint('CartController: Error generating invoice: $e');
      _showSnackbar(
        'Error',
        'Failed to generate invoice',
        isError: true,
      );
    } finally {
      isGeneratingInvoice.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────────

  void _showSnackbar(String title, String message, {bool isError = false}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError 
          ? AppTheme.errorColor.withValues(alpha: 0.9)
          : AppTheme.successColor.withValues(alpha: 0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(AppTheme.spacingMD),
      borderRadius: AppTheme.radiusMD,
      duration: const Duration(seconds: 2),
      icon: Icon(
        isError ? Icons.error_outline : Icons.check_circle_outline,
        color: Colors.white,
      ),
    );
  }
}