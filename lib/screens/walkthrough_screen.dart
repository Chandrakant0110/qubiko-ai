import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_assets.dart';
import '../widgets/custom_page_indicator.dart';
import '../widgets/custom_buttons.dart';
import '../services/performance/performance.dart';

class OnboardingContent {
  final String title;
  final String description;
  final String imagePath;

  OnboardingContent({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}

class WalkthroughScreen extends StatefulWidget {
  final Widget? nextScreen;

  const WalkthroughScreen({
    super.key,
    this.nextScreen,
  });

  @override
  State<WalkthroughScreen> createState() => _WalkthroughScreenState();
}

class _WalkthroughScreenState extends State<WalkthroughScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingContent> _contents = [
    OnboardingContent(
      title: 'The Best Unparalleled Conversational Brilliance',
      description:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor...',
      imagePath: AppAssets.onboardingImage1,
    ),
    OnboardingContent(
      title: 'Harness the Power of AI Assistants for Productivity',
      description:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor...',
      imagePath: AppAssets.onboardingImage2,
    ),
    OnboardingContent(
      title: 'Diverse AI Helpers to Revolutionize Your Tasks',
      description:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor...',
      imagePath: AppAssets.onboardingImage3,
    ),
  ];

  @override
  void initState() {
    super.initState();
    performance.trackNavigation('WalkthroughScreen');
    performance.startTiming('OnboardingViewDuration');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPage() {
    if (_currentPage < _contents.length - 1) {
      performance.trackButtonClick(
        'next_button',
        screenName: 'WalkthroughScreen',
        additionalParams: {'current_page': _currentPage, 'action': 'next'},
      );

      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      performance.trackButtonClick(
        'get_started_button',
        screenName: 'WalkthroughScreen',
        additionalParams: {'action': 'complete_onboarding'},
      );

      _onSkip();
    }
  }

  void _onSkip() {
    performance.trackButtonClick(
      'skip_button',
      screenName: 'WalkthroughScreen',
      additionalParams: {'current_page': _currentPage, 'action': 'skip'},
    );

    performance.endTimingAndLog(
      'OnboardingViewDuration',
      eventName: 'onboarding_complete',
      additionalParams: {'completed_page': _currentPage},
    );

    if (widget.nextScreen != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => widget.nextScreen!,
          settings: const RouteSettings(name: 'HomeScreen'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            // PageView for sliding content (image and text)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  performance.trackNavigation(
                    'OnboardingPage${index + 1}',
                    previousScreen: 'OnboardingPage${_currentPage + 1}',
                  );

                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _contents.length,
                itemBuilder: (context, index) {
                  return _buildPageContent(context, index);
                },
              ),
            ),
            // Fixed page indicator
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: CustomPageIndicator(
                itemCount: _contents.length,
                currentPage: _currentPage,
                activeColor: AppColors.primaryLightBlue,
                inactiveColor: Colors.grey[300]!,
              ),
            ),
            // Bottom navigation buttons
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  // New method for page content
  Widget _buildPageContent(BuildContext context, int index) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          flex: 6,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color.fromRGBO(255, 255, 255, 0.0),
                  Colors.white
                ],
                stops: const [0.0, 0.8],
              ),
            ),
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.width * 0.7,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromRGBO(0, 0, 0, 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    _contents[index].imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Track image load failures
                      performance.trackButtonClick(
                        'image_error',
                        screenName: 'WalkthroughScreen',
                        additionalParams: {'image_index': index},
                      );

                      // Placeholder in case the image doesn't exist yet
                      return Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: Text(
                            'Image ${index + 1}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _contents[index].title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displayMedium,
                ),
                const SizedBox(height: 20),
                Text(
                  _contents[index].description,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: const Color.fromRGBO(33, 33, 33, 0.7),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey[100]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Skip button
          Expanded(
            child: SecondaryButton(
              text: 'Skip',
              onPressed: _onSkip,
            ),
          ),
          const SizedBox(width: 16),
          // Next/Get Started button
          Expanded(
            child: PrimaryButton(
              text:
                  _currentPage == _contents.length - 1 ? 'Get Started' : 'Next',
              onPressed: _onNextPage,
            ),
          ),
        ],
      ),
    );
  }
}
