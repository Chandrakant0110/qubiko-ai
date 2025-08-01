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

/// Screen for managing the automation creation/editing flow
/// This handles the step-by-step process of building automations
class AutomationFlowScreen extends ConsumerStatefulWidget {
  const AutomationFlowScreen({super.key});

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
    
    return postsAsync.when(
      data: (posts) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                if (currentAutomation?.selectedPostId != null) ...[
                  const SizedBox(height: UIConstants.paddingMedium),
                  _buildPostSelectedIndicator(),
                ],
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

  Widget _buildPostSelectedIndicator() {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.primaryLightBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
        border: Border.all(
          color: AppColors.primaryLightBlue.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: AppColors.primaryLightBlue,
            size: UIConstants.iconSizeMedium,
          ),
          const SizedBox(width: UIConstants.paddingSmall),
          Text(
            'Post selected',
            style: GoogleFonts.urbanist(
              color: AppColors.primaryLightBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error, VoidCallback onRetry) {
    String errorMessage = 'An unexpected error occurred';
    
    if (error is AppException) {
      errorMessage = error.message;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: UIConstants.paddingMedium),
          Text(
            'Failed to load posts',
            style: GoogleFonts.urbanist(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: UIConstants.paddingSmall),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: UIConstants.paddingXLarge),
            child: Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.urbanist(
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: UIConstants.paddingLarge),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLightBlue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
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
    return const Center(
      child: Text('Set Trigger Step - Coming Soon'),
    );
  }

  Widget _buildChooseActionsStep() {
    return const Center(
      child: Text('Choose Actions Step - Coming Soon'),
    );
  }

  Widget _buildConfigureScheduleStep() {
    return const Center(
      child: Text('Configure Schedule Step - Coming Soon'),
    );
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