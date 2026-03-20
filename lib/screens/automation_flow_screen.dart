import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/api_constants.dart';
import '../providers/automation_providers.dart';
import '../models/automation.dart';
import '../services/exceptions/app_exceptions.dart';

import '../widgets/automation/automation_step_indicator.dart';
import '../widgets/automation/post_selection_grid.dart';
import '../widgets/automation/keyword_setup_widget.dart';
import '../widgets/automation/enhanced_dm_message_widget.dart';
import '../widgets/automation/opening_message_widget.dart';

/// Screen for managing the automation creation/editing flow
/// This handles the step-by-step process of building automations
class AutomationFlowScreen extends ConsumerStatefulWidget {
  /// Optional Instagram URL passed in when the screen was triggered via share intent.
  final String? sharedUrl;

  const AutomationFlowScreen({super.key, this.sharedUrl});

  @override
  ConsumerState<AutomationFlowScreen> createState() => _AutomationFlowScreenState();
}

class _AutomationFlowScreenState extends ConsumerState<AutomationFlowScreen> {
  @override
  void initState() {
    super.initState();
    // Load Instagram posts when entering the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(instagramPostsProvider.notifier).fetchPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentAutomation = ref.watch(currentAutomationProvider);
    
    if (currentAutomation == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(
          child: Text('No automation data found'),
        ),
      );
    }

    final currentStep = currentAutomation.currentStep;
    final stepTitle = AutomationConstants.stepTitles[currentStep];
    final stepDescription = AutomationConstants.stepDescriptions[currentStep];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _handleBackPressed(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currentAutomation.name,
              style: GoogleFonts.urbanist(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Step ${currentStep + 1} of ${AutomationConstants.totalSteps}',
              style: GoogleFonts.urbanist(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _saveDraft,
            child: Text(
              'Save Draft',
              style: GoogleFonts.urbanist(
                color: AppColors.primaryLightBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          AutomationStepIndicator(
            currentStep: currentStep,
            totalSteps: AutomationConstants.totalSteps,
            stepTitle: stepTitle,
            stepDescription: stepDescription,
          ),
          Expanded(
            child: _buildStepContent(currentStep),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(currentAutomation),
    );
  }

  void _handleBackPressed() {
    final currentAutomation = ref.read(currentAutomationProvider);
    if (currentAutomation != null && currentAutomation.currentStep > 0) {
      ref.read(currentAutomationProvider.notifier).previousStep();
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _saveDraft() async {
    try {
      // The draft is automatically saved in the provider, but we can trigger a manual save here
      _showSuccessMessage('Draft saved successfully');
    } catch (e) {
      _showErrorMessage('Failed to save draft');
    }
  }

  Widget _buildStepContent(int currentStep) {
    switch (currentStep) {
      case 0:
        return _buildSelectPostStep();
      case 1:
        return _buildSetTriggerStep();
      case 2:
        return _buildChooseActionsStep();
      case 3:
        return _buildConfigureScheduleStep();
      case 4:
        return _buildSetConditionsStep();
      case 5:
        return _buildReviewStep();
      default:
        return const Center(child: Text('Invalid step'));
    }
  }

  Widget _buildSelectPostStep() {
    final postsAsync = ref.watch(instagramPostsProvider);
    final currentAutomation = ref.watch(currentAutomationProvider);
    final sharedUrl = widget.sharedUrl;

    return postsAsync.when(
      data: (posts) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Shared URL banner (only when entered via share intent) ────
          if (sharedUrl != null && sharedUrl.isNotEmpty)
            Container(
              margin: const EdgeInsets.fromLTRB(
                UIConstants.paddingLarge,
                UIConstants.paddingLarge,
                UIConstants.paddingLarge,
                0,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF90CAF9)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link, size: 16, color: Color(0xFF1565C0)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      sharedUrl,
                      style: GoogleFonts.urbanist(
                        fontSize: 12,
                        color: const Color(0xFF1565C0),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(UIConstants.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select a Post to Automate',
                  style: GoogleFonts.urbanist(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: UIConstants.paddingSmall),
                Text(
                  'Choose which Instagram post you want to create automation for. You can select any of your recent posts.',
                  style: GoogleFonts.urbanist(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PostSelectionGrid(
              posts: posts,
              selectedPostId: currentAutomation?.selectedPostId,
              onPostSelected: _onPostSelected,
            ),
          ),
        ],
      ),
      loading: () => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: UIConstants.paddingMedium),
            Text('Loading Instagram posts...'),
          ],
        ),
      ),
      error: (error, stackTrace) => _buildErrorState(error, () {
        ref.read(instagramPostsProvider.notifier).fetchPosts();
      }),
    );
  }


  Widget _buildErrorState(Object error, VoidCallback onRetry) {
    // Determine whether this is a connectivity issue
    final isNoInternet = error is NetworkException &&
        error.code == 'NETWORK_NO_INTERNET';
    final isTimeout = error is NetworkException &&
        error.code == 'NETWORK_TIMEOUT';
    final isNetworkError = error is NetworkException;

    final IconData icon = isNoInternet
        ? Icons.wifi_off_rounded
        : isTimeout
            ? Icons.timer_off_outlined
            : isNetworkError
                ? Icons.cloud_off_rounded
                : Icons.error_outline_rounded;

    final Color iconColor = isNoInternet || isTimeout || isNetworkError
        ? Colors.orange.shade400
        : Colors.red.shade400;

    final String title = isNoInternet
        ? 'No Internet Connection'
        : isTimeout
            ? 'Request Timed Out'
            : isNetworkError
                ? 'Connection Failed'
                : 'Something Went Wrong';

    final String message = error is AppException
        ? error.message
        : 'An unexpected error occurred. Please try again.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.paddingXLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: iconColor),
            ),
            const SizedBox(height: UIConstants.paddingMedium),
            Text(
              title,
              style: GoogleFonts.urbanist(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: UIConstants.paddingSmall),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.urbanist(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: UIConstants.paddingLarge),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                isNoInternet ? 'Retry' : 'Try Again',
                style: GoogleFonts.urbanist(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLightBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onPostSelected(String? postId) {
    if (postId != null) {
      try {
        ref.read(automationOperationsProvider).selectPost(postId);
        _showSuccessMessage('Post selected successfully');
      } catch (e) {
        _showErrorMessage('Failed to select post');
      }
    } else {
      // Deselect post
      ref.read(currentAutomationProvider.notifier).selectPost('');
    }
  }

  Widget _buildSetTriggerStep() {
    return const KeywordSetupWidget();
  }

  Widget _buildChooseActionsStep() {
    return const EnhancedDMMessageWidget();
  }

  Widget _buildConfigureScheduleStep() {
    return const OpeningMessageWidget();
  }

  Widget _buildSetConditionsStep() {
    return const Center(
      child: Text('Set Conditions Step - Coming Soon'),
    );
  }

  Widget _buildReviewStep() {
    return const Center(
      child: Text('Review Step - Coming Soon'),
    );
  }

  Widget _buildBottomNavigation(Automation automation) {
    final canGoNext = ref.watch(canProceedToNextStepProvider);
    final isLastStep = automation.currentStep >= AutomationConstants.totalSteps - 1;
    
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (automation.currentStep > 0)
            Expanded(
              child: TextButton(
                onPressed: () => ref.read(currentAutomationProvider.notifier).previousStep(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: UIConstants.paddingMedium),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: Text(
                  'Previous',
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ),
          if (automation.currentStep > 0) const SizedBox(width: UIConstants.paddingMedium),
          Expanded(
            child: ElevatedButton(
              onPressed: canGoNext ? () => _handleNextPressed(isLastStep) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLightBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: UIConstants.paddingMedium),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
                ),
                elevation: 0,
              ),
              child: Text(
                isLastStep ? 'Save Automation' : 'Next',
                style: GoogleFonts.urbanist(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleNextPressed(bool isLastStep) async {
    if (isLastStep) {
      await _saveAutomation();
    } else {
      ref.read(currentAutomationProvider.notifier).nextStep();
    }
  }

  Future<void> _saveAutomation() async {
    try {
      await ref.read(currentAutomationProvider.notifier).saveAutomation();
      if (mounted) {
        _showSuccessMessage('Automation saved successfully!');
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showErrorMessage('Failed to save automation');
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}