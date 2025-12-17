// Invoice Controller
//
// Manages invoice display and actions:
// - Receives invoice data from cart
// - Formats dates and currency
// - Handles PDF download (placeholder)
// - Implements mobile download functionality

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/cart_invoince.dart';
import '../../core/theme/app_theme.dart';

class InvoiceController extends GetxController {
  // ─────────────────────────────────────────────────────────────────────────────
  // State
  // ─────────────────────────────────────────────────────────────────────────────

  late final GenerateInvoice invoiceResponse;

  // ─────────────────────────────────────────────────────────────────────────────
  // Getters
  // ─────────────────────────────────────────────────────────────────────────────

  Invoice get invoice => invoiceResponse.data.invoice;
  InvoiceData get invoiceData => invoiceResponse.data.invoiceData;
  Customer get customer => invoiceData.customer;
  List<CartItem> get items => invoiceData.cartItems;

  // ─────────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    // Get invoice data from arguments
    final args = Get.arguments;
    if (args is GenerateInvoice) {
      invoiceResponse = args;
    } else {
      // Handle error - no invoice data
      Get.back();
      Get.snackbar(
        'Error',
        'No invoice data available',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Formatting Helpers
  // ─────────────────────────────────────────────────────────────────────────────

  String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy HH:mm').format(date);
  }

  String formatCurrency(double amount) {
    return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount);
  }

  String formatCurrencyFromString(String amount) {
    final value = double.tryParse(amount) ?? 0.0;
    return formatCurrency(value);
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return AppTheme.successColor;
      case 'pending':
        return Colors.orange;
      case 'overdue':
        return AppTheme.errorColor;
      case 'cancelled':
        return AppTheme.textTertiary;
      default:
        return AppTheme.primaryColor;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Actions
  // ─────────────────────────────────────────────────────────────────────────────

  void downloadPdf() async {
    try {
      // Create a PDF document
      final pdf = pw.Document();
      
      // Add a page to the document
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Text(
                    'INVOICE',
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Invoice #: ${invoice.invoiceNumber}'),
                        pw.Text('Date: ${formatDate(invoiceData.invoiceDate)}'),
                        pw.Text('Status: ${invoice.status}'),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(customer.name),
                        pw.Text(customer.email),
                        if (customer.address != null) pw.Text(customer.address.toString()),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),
                pw.Table.fromTextArray(
                  headers: ['Product', 'Quantity', 'Price', 'Total'],
                  data: [
                    ...items.map((item) => [
                      item.productName,
                      item.quantity.toString(),
                      formatCurrencyFromString(item.price),
                      formatCurrency(item.total),
                    ]),
                  ],
                  cellAlignment: pw.Alignment.centerLeft,
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  rowDecoration: pw.BoxDecoration(
                    border: pw.Border.all(), // Fixed: Use Border.all() instead of BoxBorder.all()
                  ),
                  headerDecoration: pw.BoxDecoration(
                    color: PdfColors.grey300,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Subtotal: \$${invoiceData.total.toStringAsFixed(2)}'),
                        pw.Text('Total: \$${double.tryParse(invoice.totalAmount)?.toStringAsFixed(2) ?? '0.00'}'),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );

      // Save and share the PDF
      await Printing.layoutPdf(onLayout: (_) async => pdf.save());
      
      Get.snackbar(
        'Success',
        'Invoice downloaded successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.successColor.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to download invoice: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    }
  }

  void shareInvoice() {
    Get.snackbar(
      'Coming Soon',
      'Share feature will be available soon',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.surfaceColor,
      colorText: AppTheme.textPrimary,
    );
  }

  void goBack() {
    Get.back();
  }
}