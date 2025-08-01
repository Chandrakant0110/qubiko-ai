/// API endpoints and configuration constants
/// Centralized location for all API-related constants to improve maintainability
class ApiConstants {
  // Private constructor to prevent instantiation
  ApiConstants._();

  /// Base URL for the automation service
  static const String baseUrl = 'https://chandrakant-s4-n8n-duplicate.hf.space';
  
  /// Instagram posts endpoint
  static const String instagramPostsEndpoint = '/webhook/fetch-insta-posts';
  
  /// Complete URL for fetching Instagram posts
  static const String instagramPostsUrl = '$baseUrl$instagramPostsEndpoint';
  
  /// HTTP timeout duration for API calls
  static const Duration timeout = Duration(seconds: 30);
  
  /// Maximum retry attempts for failed requests
  static const int maxRetryAttempts = 3;
  
  /// Delay between retry attempts
  static const Duration retryDelay = Duration(seconds: 2);
  
  /// HTTP headers for API requests
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}

/// UI-related constants for consistency across the app
class UIConstants {
  UIConstants._();
  
  /// Standard padding values
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  /// Border radius values
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  
  /// Icon sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;
  
  /// Animation durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  
  /// Grid layout constants
  static const int postsGridCrossAxisCount = 2;
  static const double postsGridSpacing = 12.0;
  static const double postsGridAspectRatio = 0.8;
  
  /// Text limits
  static const int maxCaptionLength = 50;
  static const int maxAutomationNameLength = 50;
}

/// Automation workflow constants
class AutomationConstants {
  AutomationConstants._();
  
  /// Total number of steps in automation flow
  static const int totalSteps = 6;
  
  /// Default automation name
  static const String defaultAutomationName = 'New Automation';
  
  /// Step titles for the automation flow
  static const List<String> stepTitles = [
    'Select Post',
    'Set Trigger',
    'Choose Actions',
    'Configure Schedule',
    'Set Conditions',
    'Review & Save',
  ];
  
  /// Step descriptions for the automation flow
  static const List<String> stepDescriptions = [
    'Choose an Instagram post to automate',
    'Define when this automation should run',
    'Set what actions to perform',
    'Configure timing and frequency',
    'Add conditions and filters',
    'Review and activate your automation',
  ];
  
  /// Validation rules
  static const int minNameLength = 1;
  static const int maxNameLength = 100;
  
  /// Storage keys for local persistence
  static const String automationsStorageKey = 'saved_automations';
  static const String draftsStorageKey = 'automation_drafts';
}

/// Error message constants for consistent user communication
class ErrorConstants {
  ErrorConstants._();
  
  /// Network-related errors
  static const String networkError = 'Unable to connect to the server. Please check your internet connection.';
  static const String timeoutError = 'Request timed out. Please try again.';
  static const String serverError = 'Server error occurred. Please try again later.';
  
  /// Data-related errors
  static const String noPostsFound = 'No Instagram posts found. Please try again later.';
  static const String invalidPostData = 'Invalid post data received from server.';
  static const String loadingPostsError = 'Failed to load Instagram posts.';
  
  /// Validation errors
  static const String nameRequired = 'Automation name is required.';
  static const String nameTooLong = 'Automation name is too long.';
  static const String postSelectionRequired = 'Please select a post to continue.';
  
  /// Generic errors
  static const String unexpectedError = 'An unexpected error occurred. Please try again.';
  static const String savingError = 'Failed to save automation. Please try again.';
}

/// Success message constants
class SuccessConstants {
  SuccessConstants._();
  
  static const String automationCreated = 'Automation created successfully!';
  static const String automationSaved = 'Automation saved successfully!';
  static const String automationUpdated = 'Automation updated successfully!';
  static const String postSelected = 'Post selected successfully!';
}