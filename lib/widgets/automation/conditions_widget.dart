import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../constants/api_constants.dart';
import '../../providers/automation_providers.dart';

/// Step 5 — Conditions
///
/// Lets the user decide whether the automation should fire for *everyone*
/// who comments, or *only for followers* of the account.
class ConditionsWidget extends ConsumerWidget {
  const ConditionsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final automation = ref.watch(currentAutomationProvider);
    if (automation == null) {
      return const Center(child: Text('No automation data'));
    }

    final onlyFollowers = automation.onlyFollowers;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(UIConstants.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: UIConstants.paddingLarge),
          _buildFollowerToggle(context, ref, onlyFollowers),
          const SizedBox(height: UIConstants.paddingLarge),
          _buildInfoCard(context, onlyFollowers),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Set Conditions',
          style: GoogleFonts.urbanist(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: UIConstants.paddingSmall),
        Text(
          'Control who triggers your automation. '
          'You can restrict it to followers only or let anyone trigger it.',
          style: GoogleFonts.urbanist(
            fontSize: 16,
            color: Colors.grey[600],
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // ── Follower toggle card ───────────────────────────────────────────────────

  Widget _buildFollowerToggle(
      BuildContext context, WidgetRef ref, bool onlyFollowers) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(UIConstants.paddingLarge),
      decoration: BoxDecoration(
        color: onlyFollowers
            ? AppColors.primaryLightBlue.withValues(alpha: 0.08)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
        border: Border.all(
          color: onlyFollowers
              ? AppColors.primaryLightBlue.withValues(alpha: 0.4)
              : Colors.grey[300]!,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon bubble
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: UIConstants.iconSizeXLarge,
                height: UIConstants.iconSizeXLarge,
                decoration: BoxDecoration(
                  color: onlyFollowers
                      ? AppColors.primaryLightBlue.withValues(alpha: 0.18)
                      : Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.people_alt_outlined,
                  size: UIConstants.iconSizeMedium,
                  color: onlyFollowers
                      ? AppColors.primaryLightBlue
                      : Colors.grey[600],
                ),
              ),
              const SizedBox(width: UIConstants.paddingMedium),

              // Label
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Followers only',
                      style: GoogleFonts.urbanist(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      onlyFollowers
                          ? 'DM will be sent only to your followers'
                          : 'DM will be sent to everyone who comments',
                      style: GoogleFonts.urbanist(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Toggle
              Transform.scale(
                scale: 1.15,
                child: Switch(
                  value: onlyFollowers,
                  onChanged: (value) => ref
                      .read(currentAutomationProvider.notifier)
                      .setOnlyFollowers(value),
                  activeThumbColor: AppColors.primaryLightBlue,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),

          // Extra detail row — appears when enabled
          if (onlyFollowers) ...[
            const SizedBox(height: UIConstants.paddingMedium),
            const Divider(height: 1),
            const SizedBox(height: UIConstants.paddingMedium),
            Row(
              children: [
                Icon(Icons.check_circle_rounded,
                    size: 16, color: AppColors.primaryLightBlue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Non-followers who comment will be ignored — '
                    'no DM will be sent to them.',
                    style: GoogleFonts.urbanist(
                      fontSize: 13,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Info card ─────────────────────────────────────────────────────────────

  Widget _buildInfoCard(BuildContext context, bool onlyFollowers) {
    final isRestricted = onlyFollowers;

    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isRestricted
              ? [
                  AppColors.primaryLightBlue.withValues(alpha: 0.08),
                  AppColors.primaryLightBlue.withValues(alpha: 0.03),
                ]
              : [
                  Colors.orange.withValues(alpha: 0.08),
                  Colors.orange.withValues(alpha: 0.03),
                ],
        ),
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
        border: Border.all(
          color: isRestricted
              ? AppColors.primaryLightBlue.withValues(alpha: 0.2)
              : Colors.orange.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isRestricted ? Icons.shield_outlined : Icons.info_outline,
            color: isRestricted ? AppColors.primaryLightBlue : Colors.orange,
            size: UIConstants.iconSizeMedium,
          ),
          const SizedBox(width: UIConstants.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRestricted ? 'Followers-only mode active' : 'Open to everyone',
                  style: GoogleFonts.urbanist(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isRestricted
                        ? AppColors.primaryLightBlue
                        : Colors.orange[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isRestricted
                      ? 'Your automation will check if the commenter '
                        'follows your account before sending a DM. '
                        'This keeps engagement higher quality.'
                      : 'Your automation will respond to all comments '
                        'regardless of follow status. Great for maximum reach.',
                  style: GoogleFonts.urbanist(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
