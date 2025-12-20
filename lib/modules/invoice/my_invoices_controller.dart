// My Invoices Controller
// Manages invoice list display and navigation

import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/invoice_list.dart';
import '../../models/cart_invoince.dart' as cart_invoice;
import '../../models/invoice.dart' as api_invoice;
import '../../core/theme/app_theme.dart';
import '../../core/services/api_service.dart';
import '../../routes/app_routes.dart';

class MyInvoicesController extends GetxController {
  // ─────────────────────────────────────────────────────────────────────────────
  // Dependencies
  // ─────────────────────────────────────────────────────────────────────────────

  final ApiService _apiService = Get.find<ApiService>();

  // ─────────────────────────────────────────────────────────────────────────────
  // State
  // ─────────────────────────────────────────────────────────────────────────────

  final isLoading = false.obs;
  final invoices = <InvoiceItem>[].obs;
  final selectedStatus = 'all'.obs; // all, draft, sent, paid, cancelled
  
  // Pagination
  final currentPage = 1.obs;
  final lastPage = 1.obs;
  final total = 0.obs;

  // ─────────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    loadInvoices();
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Data Loading
  // ─────────────────────────────────────────────────────────────────────────────

  Future<void> loadInvoices({bool resetPage = false}) async {
    try {
      isLoading.value = true;
      
      if (resetPage) {
        currentPage.value = 1;
      }
      
      // Build query parameters
      final queryParams = <String, dynamic>{
        'page': currentPage.value,
      };
      
      // Add status filter if not 'all'
      if (selectedStatus.value != 'all') {
        queryParams['status'] = selectedStatus.value;
      }
      
      // Make API call
      final response = await _apiService.get(
        '/my-invoices',
        queryParameters: queryParams,
      );
      
      // Parse response
      final invoiceListResponse = InvoiceListResponse.fromJson(response.data);
      
      if (invoiceListResponse.success) {
        invoices.value = invoiceListResponse.data.data;
        currentPage.value = invoiceListResponse.data.currentPage;
        lastPage.value = invoiceListResponse.data.lastPage;
        total.value = invoiceListResponse.data.total;
      } else {
        throw Exception(invoiceListResponse.message);
      }
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load invoices: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor.withValues(alpha: 0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshInvoices() async {
    await loadInvoices(resetPage: true);
  }
  
  // ─────────────────────────────────────────────────────────────────────────────
  // Filter Management
  // ─────────────────────────────────────────────────────────────────────────────

  void changeStatus(String status) {
    if (selectedStatus.value != status) {
      selectedStatus.value = status;
      loadInvoices(resetPage: true);
    }
  }
  
  String getStatusDisplayName(String status) {
    switch (status) {
      case 'all':
        return 'All';
      case 'draft':
        return 'Draft';
      case 'sent':
        return 'Sent';
      case 'paid':
        return 'Paid';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status.toUpperCase();
    }
  }
  
  int getStatusCount(String status) {
    if (status == 'all') {
      return total.value;
    }
    return invoices.where((inv) => inv.status.toLowerCase() == status).length;
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Formatting Helpers
  // ─────────────────────────────────────────────────────────────────────────────

  String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String formatCurrency(double amount) {
    return NumberFormat.currency(symbol: '₹', decimalDigits: 2).format(amount);
  }

  String formatCurrencyFromString(String amount) {
    final value = double.tryParse(amount) ?? 0.0;
    return formatCurrency(value);
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'all':
        return AppTheme.primaryColor;
      case 'paid':
      case 'approved':
        return AppTheme.successColor;
      case 'sent':
      case 'pending':
        return Colors.orange;
      case 'draft':
        return Colors.blue;
      case 'overdue':
        return AppTheme.errorColor;
      case 'cancelled':
        return AppTheme.textTertiary;
      default:
        return AppTheme.primaryColor;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Navigation
  // ─────────────────────────────────────────────────────────────────────────────

  Future<void> viewInvoiceDetail(InvoiceItem invoice) async {
    try {
      // Show loading indicator
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );
      
      // Fetch invoice details from API
      final response = await _apiService.get('/my-invoices/${invoice.id}');
      
      // Close loading dialog
      Get.back();
      
      // Check if response data is null or empty
      if (response.data == null) {
        Get.snackbar('Error', 'No data received from server',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
      
      // Parse response - API returns ProformaInvoices structure
      // Handle both String and Map responses
      final apiResponse = (response.data is String) 
          ? api_invoice.proformaInvoicesFromJson(response.data)
          : api_invoice.proformaInvoicesFromJson(jsonEncode(response.data));
      
      if (apiResponse.success) {
        // Convert API response to GenerateInvoice structure expected by InvoiceView
        // Note: API structure (ProformaInvoices) differs from InvoiceView expectations
        final generateInvoice = cart_invoice.GenerateInvoice(
          success: true,
          message: apiResponse.message,
          data: cart_invoice.GenerateInvoiceData(
            invoice: cart_invoice.Invoice(
              id: apiResponse.data.id,
              invoiceNumber: apiResponse.data.invoiceNumber,
              userId: apiResponse.data.userId,
              totalAmount: apiResponse.data.totalAmount,
              invoiceData: jsonEncode(apiResponse.data.invoiceData.toJson()),
              status: apiResponse.data.status,
              createdAt: apiResponse.data.createdAt,
              updatedAt: apiResponse.data.updatedAt,
            ),
            invoiceData: cart_invoice.InvoiceData(
              // Convert API cart items to expected format
              cartItems: apiResponse.data.invoiceData.cartItems.map((item) {
                return cart_invoice.CartItem(
                  id: item.productId, // Use productId as id
                  productId: item.productId,
                  productName: item.name,
                  productDescription: '', // API doesn't provide description
                  quantity: item.quantity,
                  price: item.price.toString(),
                  total: (item.quantity * item.price).toDouble(),
                );
              }).toList(),
              total: apiResponse.data.invoiceData.total,
              // Use createdAt as invoiceDate since API doesn't provide separate invoice date
              invoiceDate: apiResponse.data.createdAt,
              // Convert User to Customer
              customer: cart_invoice.Customer(
                id: apiResponse.data.user.id,
                name: apiResponse.data.user.name,
                email: apiResponse.data.user.email,
                address: apiResponse.data.user.address,
                mobileNumber: apiResponse.data.user.mobileNumber,
              ),
            ),
          ),
        );
        
        // Navigate to invoice detail screen
        Get.toNamed(Routes.invoice, arguments: generateInvoice);
      } else {
        throw Exception(apiResponse.message);
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      
      Get.snackbar(
        'Error',
        'Failed to load invoice details: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor.withValues(alpha: 0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }
}
