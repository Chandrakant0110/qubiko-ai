import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/api_constants.dart';
import '../../constants/app_colors.dart';

/// Widget that displays the current step in the automation flow
/// This provides visual feedback on progress and current step information
class AutomationStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String stepTitle;
  final String stepDescription;

  const AutomationStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepTitle,
    required this.stepDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.paddingLarge,
        vertical: UIConstants.paddingMedium,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          StepProgressBar(
            currentStep: currentStep,
            totalSteps: totalSteps,
          ),
          const SizedBox(height: UIConstants.paddingMedium),
          StepInfo(
            stepNumber: currentStep + 1,
            stepTitle: stepTitle,
            stepDescription: stepDescription,
          ),
        ],
      ),
    );
  }
}

/// Progress bar showing completion status of all steps
class StepProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isCompleted = index <= currentStep;
        final isLast = index == totalSteps - 1;
        
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
              right: isLast ? 0 : UIConstants.paddingSmall,
            ),
            height: 4,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.primaryLightBlue
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

/// Information section showing current step details
class StepInfo extends StatelessWidget {
  final int stepNumber;
  final String stepTitle;
  final String stepDescription;

  const StepInfo({
    super.key,
    required this.stepNumber,
    required this.stepTitle,
    required this.stepDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        StepNumberIndicator(stepNumber: stepNumber),
        const SizedBox(width: UIConstants.paddingMedium),
        Expanded(
          child: StepTextInfo(
            stepTitle: stepTitle,
            stepDescription: stepDescription,
          ),
        ),
      ],
    );
  }
}

/// Circular indicator showing the current step number
class StepNumberIndicator extends StatelessWidget {
  final int stepNumber;

  const StepNumberIndicator({
    super.key,
    required this.stepNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: UIConstants.iconSizeLarge,
      height: UIConstants.iconSizeLarge,
      decoration: BoxDecoration(
        color: AppColors.primaryLightBlue,
        borderRadius: BorderRadius.circular(UIConstants.iconSizeLarge / 2),
      ),
      child: Center(
        child: Text(
          stepNumber.toString(),
          style: GoogleFonts.urbanist(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

/// Text information about the current step
class StepTextInfo extends StatelessWidget {
  final String stepTitle;
  final String stepDescription;

  const StepTextInfo({
    super.key,
    required this.stepTitle,
    required this.stepDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          stepTitle,
          style: GoogleFonts.urbanist(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          stepDescription,
          style: GoogleFonts.urbanist(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}