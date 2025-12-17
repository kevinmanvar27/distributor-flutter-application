// Splash Controller
// 
// Handles app initialization and authentication check on startup.
// Navigates to login or main screen based on auth state.

import 'package:get/get.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/Setting.dart' as settings_model;

class SplashController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final ApiService _apiService = Get.find<ApiService>();
  
  final RxBool isLoading = true.obs;
  final RxString statusMessage = 'Initializing...'.obs;
  
  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }
  
  Future<void> _initializeApp() async {
    try {
      // Simulate minimum splash duration for branding
      // Calculate remaining time after fetching settings
      final startTime = DateTime.now();
      
      statusMessage.value = 'Loading settings...';
      await _fetchAppSettings();

      final elapsedTime = DateTime.now().difference(startTime);
      final remainingTime = const Duration(milliseconds: 1500) - elapsedTime;
      if (remainingTime.isNegative == false) {
        await Future.delayed(remainingTime);
      }
      
      statusMessage.value = 'Checking authentication...';
      
      // Check if user is authenticated
      final isAuthenticated = _storageService.isAuthenticated();
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (isAuthenticated) {
        // User is logged in, navigate to main screen
        Get.offAllNamed('/main');
      } else {
        // User is not logged in, navigate to login
        Get.offAllNamed('/login');
      }
    } catch (e) {
      // On error, default to login screen
      Get.offAllNamed('/login');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchAppSettings() async {
    try {
      final response = await _apiService.get('/app-settings');
      if (response.statusCode == 200 && response.data != null) {
        final setting = settings_model.Setting.fromJson(response.data);
        if (setting.success) {
          // Save settings
          await _storageService.saveSettings(setting.data);
          
          // Apply theme
          final theme = AppTheme.createThemeFromSettings(setting.data);
          Get.changeTheme(theme);
        }
      }
    } catch (e) {
      // If fetching fails, checks if we have cached settings
      final cachedSettings = _storageService.getSettings();
      if (cachedSettings != null) {
        final theme = AppTheme.createThemeFromSettings(cachedSettings);
        Get.changeTheme(theme);
      }
      // Otherwise continue with default theme
      print('Failed to fetch app settings: $e');
    }
  }
}
