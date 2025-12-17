// Invoice View
//
// Displays generated invoice with:
// - Invoice header (number, date, status)
// - Customer information
// - Line items table
// - Total summary
// - Action buttons (download, share)

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/dynamic_button.dart';
import '../../core/widgets/dynamic_appbar.dart';
import '../../models/cart_invoince.dart';
import 'invoice_controller.dart';

class InvoiceView extends GetView<InvoiceController> {
  const InvoiceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DynamicAppBar(
        title: 'Invoice',
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: controller.shareInvoice,
            tooltip: 'Share',
          ),
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: controller.downloadPdf,
            tooltip: 'Download PDF',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Invoice Header
            _buildInvoiceHeader(),
            const SizedBox(height: AppTheme.spacingLG),
            // Customer Info
            _buildCustomerInfo(),
            const SizedBox(height: AppTheme.spacingLG),
            // Line Items
            _buildLineItems(),
            const SizedBox(height: AppTheme.spacingLG),
            // Total Summary
            _buildTotalSummary(),
            const SizedBox(height: AppTheme.spacingXL),
            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Invoice Header
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildInvoiceHeader() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        boxShadow: AppTheme.shadowSM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Invoice number and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Invoice',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '#${controller.invoice.invoiceNumber}',
                    style: AppTheme.headingMedium,
                  ),
                ],
              ),
              _buildStatusBadge(controller.invoice.status),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMD),
          const Divider(height: 1),
          const SizedBox(height: AppTheme.spacingMD),
          // Dates
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Invoice Date',
                  controller.formatDate(controller.invoiceData.invoiceDate),
                  Icons.calendar_today_outlined,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'Created',
                  controller.formatDateTime(controller.invoice.createdAt),
                  Icons.access_time_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = controller.getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSM,
        vertical: AppTheme.spacingXS,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: AppTheme.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTheme.textTertiary,
        ),
        const SizedBox(width: AppTheme.spacingXS),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textTertiary,
              ),
            ),
            Text(
              value,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Customer Info
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildCustomerInfo() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        boxShadow: AppTheme.shadowSM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bill To',
            style: AppTheme.labelLarge.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSM),
          Text(
            controller.customer.name,
            style: AppTheme.headingSmall,
          ),
          const SizedBox(height: AppTheme.spacingXS),
          _buildCustomerDetail(Icons.email_outlined, controller.customer.email),
          if (controller.customer.mobileNumber != null)
            _buildCustomerDetail(
              Icons.phone_outlined,
              controller.customer.mobileNumber.toString(),
            ),
          if (controller.customer.address != null)
            _buildCustomerDetail(
              Icons.location_on_outlined,
              controller.customer.address.toString(),
            ),
        ],
      ),
    );
  }

  Widget _buildCustomerDetail(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: AppTheme.spacingXS),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppTheme.textTertiary,
          ),
          const SizedBox(width: AppTheme.spacingSM),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Line Items
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildLineItems() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        boxShadow: AppTheme.shadowSM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMD),
            child: Text(
              'Items',
              style: AppTheme.labelLarge.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          const Divider(height: 1),
          // Header row
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMD,
              vertical: AppTheme.spacingSM,
            ),
            color: AppTheme.backgroundColor,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Product',
                    style: AppTheme.labelSmall.copyWith(
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Qty',
                    style: AppTheme.labelSmall.copyWith(
                      color: AppTheme.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Price',
                    style: AppTheme.labelSmall.copyWith(
                      color: AppTheme.textTertiary,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Total',
                    style: AppTheme.labelSmall.copyWith(
                      color: AppTheme.textTertiary,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          // Item rows
          ...controller.items.map((item) => _buildLineItemRow(item)),
        ],
      ),
    );
  }

  Widget _buildLineItemRow(CartItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMD,
        vertical: AppTheme.spacingSM,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.borderColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              '${item.quantity}',
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              controller.formatCurrencyFromString(item.price),
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            child: Text(
              controller.formatCurrency(item.total),
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Total Summary
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildTotalSummary() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        boxShadow: AppTheme.shadowSM,
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            'Subtotal',
            controller.formatCurrency(controller.invoiceData.total),
          ),
          const SizedBox(height: AppTheme.spacingSM),
          const Divider(height: 1),
          const SizedBox(height: AppTheme.spacingSM),
          _buildSummaryRow(
            'Total',
            controller.formatCurrencyFromString(controller.invoice.totalAmount),
            isBold: true,
            isLarge: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    bool isLarge = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isLarge
              ? AppTheme.headingSmall
              : AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
        ),
        Text(
          value,
          style: isLarge
              ? AppTheme.headingMedium.copyWith(
                  color: AppTheme.primaryColor,
                )
              : AppTheme.bodyMedium.copyWith(
                  fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
                ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Action Buttons
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildActionButtons() {
    return Column(
      children: [
        DynamicButton(
          text: 'Download PDF',
          onPressed: controller.downloadPdf,
          isFullWidth: true,
          leadingIcon: Icons.picture_as_pdf_outlined,
        ),
        const SizedBox(height: AppTheme.spacingSM),
        DynamicButton(
          text: 'Back to Cart',
          onPressed: controller.goBack,
          isFullWidth: true,
          variant: ButtonVariant.outlined,
          leadingIcon: Icons.arrow_back,
        ),
      ],
    );
  }
}
