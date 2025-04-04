class AppAssets {
  // Private constructor to prevent instantiation
  AppAssets._();

  // Base paths
  static const String _basePath = 'assets';
  static const String _imagesPath = '$_basePath/images';
  static const String _fontsPath = '$_basePath/fonts';

  // Onboarding images
  static const String onboardingBasePath = '$_imagesPath/onboarding';
  static const String onboardingImage1 =
      '$onboardingBasePath/onboarding_image_1.png';
  static const String onboardingImage2 =
      '$onboardingBasePath/onboarding_image_2.png';
  static const String onboardingImage3 =
      '$onboardingBasePath/onboarding_image_3.png';

  // App logo and branding
  static const String logoPath = '$_imagesPath/logo';
  static const String appLogo = '$logoPath/app_logo.png';
  static const String appIcon = '$logoPath/app_icon.png';

  // Common UI images
  static const String placeholderImage = '$_imagesPath/placeholder.png';
  static const String defaultAvatar = '$_imagesPath/default_avatar.png';

  // Backgrounds and decorative elements
  static const String backgroundPattern = '$_imagesPath/background_pattern.png';

  // Fonts
  static const String urbanistRegular = '$_fontsPath/Urbanist-Regular.ttf';
  static const String urbanistMedium = '$_fontsPath/Urbanist-Medium.ttf';
  static const String urbanistSemiBold = '$_fontsPath/Urbanist-SemiBold.ttf';
  static const String urbanistBold = '$_fontsPath/Urbanist-Bold.ttf';
}
