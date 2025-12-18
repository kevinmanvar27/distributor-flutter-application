// Reset Password View
//
// Screen for entering new password after OTP verification.
// Redirects to login on success.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/dynamic_button.dart';
import '../../core/utils/validators.dart';
import '../../routes/app_routes.dart';
import 'forgot_password_controller.dart';

class ResetPasswordView extends GetView<ForgotPasswordController> {
  const ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.textPrimary,
        // Prevent going back to OTP screen
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Icon(
                        Icons.lock_outline,
                        size: 48,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingLg),

                    // Title
                    Text(
                      'Create New Password',
                      style: AppTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.spacingXs),
                    Text(
                      'Your new password must be different from previously used passwords.',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.spacingXl),

                    // Error message
                    Obx(() {
                      if (controller.errorMessage.value.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Container(
                        padding: const EdgeInsets.all(AppTheme.spacingMd),
                        margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          border: Border.all(
                              color: AppTheme.errorColor.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: AppTheme.errorColor),
                            const SizedBox(width: AppTheme.spacingSm),
                            Expanded(
                              child: Text(
                                controller.errorMessage.value,
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.errorColor,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: controller.clearError,
                              color: AppTheme.errorColor,
                            ),
                          ],
                        ),
                      );
                    }),

                    // New Password field
                    PasswordTextField(
                      controller: passwordController,
                      label: 'New Password',
                      validator: Validators.password,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppTheme.spacingMd),

                    // Confirm Password field
                    PasswordTextField(
                      controller: confirmPasswordController,
                      label: 'Confirm Password',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: AppTheme.spacingLg),

                    // Reset Password button
                    Obx(() => DynamicButton(
                          text: 'Reset Password',
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              final success = await controller.resetPassword(
                                passwordController.text,
                                confirmPasswordController.text,
                              );
                              if (success && context.mounted) {
                                // Show success dialog and navigate to login
                                _showSuccessDialog(context);
                              }
                            }
                          },
                          isLoading: controller.isLoading.value,
                          isFullWidth: true,
                        )),
                    const SizedBox(height: AppTheme.spacingLg),

                    // Cancel link
                    TextButton(
                      onPressed: () {
                        controller.resetState();
                        Get.offAllNamed(Routes.login);
                      },
                      child: Text(
                        'Cancel',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.successColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.check_circle,
                size: 48,
                color: AppTheme.successColor,
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Text(
              'Password Reset Successful',
              style: AppTheme.headingMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'Your password has been reset successfully. Please login with your new password.',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingLg),
            DynamicButton(
              text: 'Login',
              onPressed: () {
                controller.resetState();
                Get.offAllNamed(Routes.login);
              },
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}
