// OTP Verification View
//
// Screen for entering OTP received via email.
// Navigates to reset password on success.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/dynamic_button.dart';
import '../../routes/app_routes.dart';
import 'forgot_password_controller.dart';

class OtpVerificationView extends GetView<ForgotPasswordController> {
  const OtpVerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final otpControllers = List.generate(6, (_) => TextEditingController());
    final focusNodes = List.generate(6, (_) => FocusNode());

    // Dispose controllers and focus nodes when view is disposed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Clear any previous messages
      controller.clearMessages();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.textPrimary,
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
                        Icons.mark_email_read,
                        size: 48,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingLg),

                    // Title
                    Text(
                      'Enter OTP',
                      style: AppTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.spacingXs),
                    Obx(() => Text(
                          'We\'ve sent a 6-digit OTP to\n${controller.email.value}',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        )),
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

                    // Success message
                    Obx(() {
                      if (controller.successMessage.value.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Container(
                        padding: const EdgeInsets.all(AppTheme.spacingMd),
                        margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          border: Border.all(
                              color: AppTheme.successColor.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline,
                                color: AppTheme.successColor),
                            const SizedBox(width: AppTheme.spacingSm),
                            Expanded(
                              child: Text(
                                controller.successMessage.value,
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.successColor,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: controller.clearSuccess,
                              color: AppTheme.successColor,
                            ),
                          ],
                        ),
                      );
                    }),

                    // OTP input fields
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (index) {
                        return SizedBox(
                          width: 45,
                          child: TextFormField(
                            controller: otpControllers[index],
                            focusNode: focusNodes[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            style: AppTheme.headingMedium,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              counterText: '',
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: AppTheme.spacingMd,
                              ),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusMd),
                                borderSide:
                                    const BorderSide(color: AppTheme.borderColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusMd),
                                borderSide:
                                    const BorderSide(color: AppTheme.borderColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusMd),
                                borderSide: const BorderSide(
                                    color: AppTheme.primaryColor, width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty && index < 5) {
                                focusNodes[index + 1].requestFocus();
                              } else if (value.isEmpty && index > 0) {
                                focusNodes[index - 1].requestFocus();
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '';
                              }
                              return null;
                            },
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: AppTheme.spacingLg),

                    // Verify OTP button
                    Obx(() => DynamicButton(
                          text: 'Verify OTP',
                          onPressed: () async {
                            final otp = otpControllers
                                .map((c) => c.text)
                                .join();
                            
                            if (otp.length != 6) {
                              controller.errorMessage.value = 'Please enter complete OTP';
                              return;
                            }
                            
                            final success = await controller.verifyOtp(otp);
                            if (success) {
                              Get.toNamed(Routes.resetPassword);
                            }
                          },
                          isLoading: controller.isLoading.value,
                          isFullWidth: true,
                        )),
                    const SizedBox(height: AppTheme.spacingLg),

                    // Resend OTP section
                    Obx(() => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Didn't receive the OTP?",
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            TextButton(
                              onPressed: controller.canResendOtp.value
                                  ? () async {
                                      final success = await controller.resendOtp();
                                      if (success) {
                                        // Clear OTP fields
                                        for (var c in otpControllers) {
                                          c.clear();
                                        }
                                        focusNodes[0].requestFocus();
                                      }
                                    }
                                  : null,
                              child: Text(
                                controller.canResendOtp.value
                                    ? 'Resend OTP'
                                    : 'Resend in ${controller.resendCooldown.value}s',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: controller.canResendOtp.value
                                      ? AppTheme.primaryColor
                                      : AppTheme.textTertiary,
                                ),
                              ),
                            ),
                          ],
                        )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
