import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../constants/api_constants.dart';
import '../../providers/automation_providers.dart';
import '../../models/automation.dart';

/// Widget for setting up keyword triggers in Step 2
/// Provides toggle for "any keyword" and keyword management functionality
class KeywordSetupWidget extends ConsumerStatefulWidget {
  const KeywordSetupWidget({super.key});

  @override
  ConsumerState<KeywordSetupWidget> createState() => _KeywordSetupWidgetState();
}

class _KeywordSetupWidgetState extends ConsumerState<KeywordSetupWidget> {
  final TextEditingController _keywordController = TextEditingController();

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentAutomation = ref.watch(currentAutomationProvider);

    if (currentAutomation == null) {
      return const Center(child: Text('No automation data'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(UIConstants.paddingLarge),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: UIConstants.paddingLarge),
            _buildAnyKeywordToggle(currentAutomation),
            const SizedBox(height: UIConstants.paddingLarge),
            if (!currentAutomation.anyKeyword) ...[
              _buildKeywordSection(currentAutomation),
              const SizedBox(height: UIConstants.paddingMedium),
              _buildAddKeywordSection(currentAutomation),
            ],
            const SizedBox(height: UIConstants.paddingLarge),
            _buildInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Set Keyword Triggers',
          style: GoogleFonts.urbanist(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: UIConstants.paddingSmall),
        Text(
          'Define which keywords will trigger this automation when users comment on your post.',
          style: GoogleFonts.urbanist(
            fontSize: 16,
            color: Colors.grey[600],
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildAnyKeywordToggle(Automation automation) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingLarge),
      decoration: BoxDecoration(
        color: automation.anyKeyword
            ? AppColors.primaryLightBlue.withOpacity(0.1)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
        border: Border.all(
          color: automation.anyKeyword
              ? AppColors.primaryLightBlue.withOpacity(0.3)
              : Colors.grey[300]!,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: UIConstants.iconSizeXLarge,
            height: UIConstants.iconSizeXLarge,
            decoration: BoxDecoration(
              color: automation.anyKeyword
                  ? AppColors.primaryLightBlue.withOpacity(0.2)
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(
                UIConstants.iconSizeXLarge / 2,
              ),
            ),
            child: Icon(
              Icons.all_inclusive,
              color: automation.anyKeyword
                  ? AppColors.primaryLightBlue
                  : Colors.grey[600],
              size: UIConstants.iconSizeMedium,
            ),
          ),
          const SizedBox(width: UIConstants.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trigger on Any Keyword',
                  style: GoogleFonts.urbanist(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Activate automation for any comment or keyword',
                  style: GoogleFonts.urbanist(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 1.2,
            child: Switch(
              value: automation.anyKeyword,
              onChanged: (value) {
                ref
                    .read(currentAutomationProvider.notifier)
                    .updateKeywordSettings(anyKeyword: value);
              },
              activeColor: AppColors.primaryLightBlue,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeywordSection(Automation automation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Specific Keywords',
              style: GoogleFonts.urbanist(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: UIConstants.paddingSmall),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: UIConstants.paddingSmall,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryLightBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  UIConstants.borderRadiusSmall,
                ),
              ),
              child: Text(
                '${automation.triggerKeywords.length}/3',
                style: GoogleFonts.urbanist(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryLightBlue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: UIConstants.paddingSmall),
        Text(
          'Add up to 3 specific keywords that will trigger this automation',
          style: GoogleFonts.urbanist(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: UIConstants.paddingMedium),
        if (automation.triggerKeywords.isNotEmpty)
          _buildKeywordChips(automation)
        else
          const SizedBox.shrink(),
        // _buildEmptyKeywords(),
      ],
    );
  }

  Widget _buildKeywordChips(Automation automation) {
    return Wrap(
      spacing: UIConstants.paddingSmall,
      runSpacing: UIConstants.paddingSmall,
      children: automation.triggerKeywords.map((keyword) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.paddingMedium,
            vertical: UIConstants.paddingSmall,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryLightBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
            border: Border.all(
              color: AppColors.primaryLightBlue.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.tag,
                size: UIConstants.iconSizeSmall,
                color: AppColors.primaryLightBlue,
              ),
              const SizedBox(width: 4),
              Text(
                keyword,
                style: GoogleFonts.urbanist(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryLightBlue,
                ),
              ),
              const SizedBox(width: UIConstants.paddingSmall),
              GestureDetector(
                onTap: () {
                  ref
                      .read(currentAutomationProvider.notifier)
                      .removeTriggerKeyword(keyword);
                },
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(Icons.close, size: 12, color: Colors.red),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Widget _buildEmptyKeywords() {
  //   return Container(
  //     padding: const EdgeInsets.all(UIConstants.paddingLarge),
  //     decoration: BoxDecoration(
  //       color: Colors.grey[50],
  //       borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
  //       border: Border.all(color: Colors.grey[300]!),
  //     ),
  //     child: Column(
  //       children: [
  //         Icon(
  //           Icons.label_outline,
  //           size: 48,
  //           color: Colors.grey[400],
  //         ),
  //         const SizedBox(height: UIConstants.paddingMedium),
  //         Text(
  //           'No keywords added yet',
  //           style: GoogleFonts.urbanist(
  //             fontSize: 16,
  //             fontWeight: FontWeight.w600,
  //             color: Colors.grey[600],
  //           ),
  //         ),
  //         const SizedBox(height: UIConstants.paddingSmall),
  //         Text(
  //           'Add specific keywords to trigger your automation',
  //           style: GoogleFonts.urbanist(
  //             fontSize: 14,
  //             color: Colors.grey[500],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildAddKeywordSection(Automation automation) {
    final canAddMore = automation.triggerKeywords.length < 3;

    return canAddMore
        ? Container(
            padding: const EdgeInsets.all(UIConstants.paddingLarge),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                UIConstants.borderRadiusMedium,
              ),
              border: Border.all(color: Colors.grey[300]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon
                Row(
                  children: [
                    Container(
                      width: UIConstants.iconSizeLarge,
                      height: UIConstants.iconSizeLarge,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLightBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          UIConstants.iconSizeLarge / 2,
                        ),
                      ),
                      child: Icon(
                        Icons.add_circle_outline,
                        color: AppColors.primaryLightBlue,
                        size: UIConstants.iconSizeMedium,
                      ),
                    ),
                    const SizedBox(width: UIConstants.paddingMedium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add Keywords',
                            style: GoogleFonts.urbanist(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            canAddMore
                                ? 'Type & Hit + Enter to add Keyword'
                                : 'Maximum 3 keywords reached',
                            style: GoogleFonts.urbanist(
                              fontSize: 14,
                              color: canAddMore
                                  ? Colors.grey[600]
                                  : Colors.red[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: UIConstants.paddingMedium),

                // Enhanced input field
                TextField(
                  controller: _keywordController,
                  enabled: canAddMore,
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: canAddMore
                        ? 'Type & Hit + Enter to add Keyword'
                        : 'Maximum reached',
                    hintStyle: GoogleFonts.urbanist(color: Colors.grey[400]),
                    filled: true,
                    fillColor: canAddMore ? Colors.grey[50] : Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        UIConstants.borderRadiusMedium,
                      ),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        UIConstants.borderRadiusMedium,
                      ),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        UIConstants.borderRadiusMedium,
                      ),
                      borderSide: BorderSide(
                        color: AppColors.primaryLightBlue,
                        width: 2,
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        UIConstants.borderRadiusMedium,
                      ),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: UIConstants.paddingMedium,
                      vertical: UIConstants.paddingMedium,
                    ),
                    suffixIcon: canAddMore
                        ? GestureDetector(
                            onTap: () => _addKeyword(_keywordController.text),
                            child: Container(
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLightBlue,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          )
                        : null,
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: canAddMore ? _addKeyword : null,
                ),

                if (canAddMore) ...[
                  const SizedBox(height: UIConstants.paddingSmall),
                  Text(
                    'Case-sensitive keywords allowed (e.g., "Link", "link", "LINK" are different)',
                    style: GoogleFonts.urbanist(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryLightBlue.withOpacity(0.1),
            AppColors.primaryLightBlue.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
        border: Border.all(color: AppColors.primaryLightBlue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: UIConstants.iconSizeXLarge,
            height: UIConstants.iconSizeXLarge,
            decoration: BoxDecoration(
              color: AppColors.primaryLightBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(
                UIConstants.iconSizeXLarge / 2,
              ),
            ),
            child: Icon(
              Icons.lightbulb_outline,
              color: AppColors.primaryLightBlue,
              size: UIConstants.iconSizeMedium,
            ),
          ),
          const SizedBox(width: UIConstants.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pro Tip',
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryLightBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose keywords that your audience commonly uses. Keep them simple and relevant to your content.',
                  style: GoogleFonts.urbanist(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addKeyword(String keyword) {
    final trimmedKeyword = keyword.trim(); // Keep original case
    if (trimmedKeyword.isNotEmpty) {
      final currentAutomation = ref.read(currentAutomationProvider);
      if (currentAutomation != null &&
          currentAutomation.triggerKeywords.length < 3 &&
          !currentAutomation.triggerKeywords.contains(trimmedKeyword)) {
        ref
            .read(currentAutomationProvider.notifier)
            .addTriggerKeyword(trimmedKeyword);
        _keywordController.clear();

        // Show success feedback with haptic
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('Keyword "$trimmedKeyword" added successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      } else if (currentAutomation?.triggerKeywords.contains(trimmedKeyword) ==
          true) {
        // Show duplicate keyword message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.warning, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('Keyword "$trimmedKeyword" already exists'),
              ],
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }
}
