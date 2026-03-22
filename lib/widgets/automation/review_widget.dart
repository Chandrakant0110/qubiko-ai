import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../constants/api_constants.dart';
import '../../providers/automation_providers.dart';

/// Step 6 — Review & Publish
///
/// Shows a read-only summary of every previous step so the user can verify
/// before saving as draft or publishing.
class ReviewWidget extends ConsumerWidget {
  const ReviewWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final automation = ref.watch(currentAutomationProvider);
    final selectedPost = ref.watch(selectedPostProvider);

    if (automation == null) {
      return const Center(child: Text('No automation data'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(UIConstants.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, automation.name),
          const SizedBox(height: UIConstants.paddingLarge),

          // ── Step summaries ────────────────────────────────────────────────
          _SummaryCard(
            stepNumber: 1,
            title: 'Selected Post',
            icon: Icons.image_outlined,
            isConfigured: automation.selectedPostId?.isNotEmpty == true,
            children: [
              if (selectedPost != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    selectedPost.thumbnailUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (e, s, w) => Container(
                      height: 80,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (selectedPost.caption.isNotEmpty)
                  Text(
                    selectedPost.getTruncatedCaption(120),
                    style: GoogleFonts.urbanist(
                        fontSize: 13, color: Colors.grey[700], height: 1.4),
                  ),
              ] else
                _emptyRow('No post selected'),
            ],
          ),

          _SummaryCard(
            stepNumber: 2,
            title: 'Trigger Keywords',
            icon: Icons.tag_rounded,
            isConfigured:
                automation.anyKeyword || automation.triggerKeywords.isNotEmpty,
            children: [
              if (automation.anyKeyword)
                _chip('Any comment triggers the DM', AppColors.successGreen)
              else if (automation.triggerKeywords.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: automation.triggerKeywords
                      .map((k) => _chip(k, AppColors.primaryLightBlue))
                      .toList(),
                )
              else
                _emptyRow('No keywords set'),
            ],
          ),

          _SummaryCard(
            stepNumber: 3,
            title: 'DM Message',
            icon: Icons.send_rounded,
            isConfigured: automation.dmMessage?.isNotEmpty == true &&
                automation.dmButtons.isNotEmpty,
            children: [
              if (automation.dmMessage?.isNotEmpty == true) ...[
                _messageBubble(automation.dmMessage!),
                if (automation.dmButtons.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ...automation.dmButtons.map(
                    (b) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.link, size: 14,
                              color: AppColors.primaryLightBlue),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${b.text}  →  ${b.link}',
                              style: GoogleFonts.urbanist(
                                  fontSize: 13, color: Colors.grey[700]),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ] else
                _emptyRow('No DM message configured'),
            ],
          ),

          _SummaryCard(
            stepNumber: 4,
            title: 'Opening Message',
            icon: Icons.forum_outlined,
            isConfigured: !automation.openingMessageEnabled ||
                (automation.openingMessage?.isNotEmpty == true &&
                    automation.openingButtonText?.isNotEmpty == true),
            children: [
              if (!automation.openingMessageEnabled)
                _statusRow(Icons.skip_next_rounded, 'Skipped — optional step',
                    Colors.grey)
              else if (automation.openingMessage?.isNotEmpty == true) ...[
                _messageBubble(automation.openingMessage!),
                if (automation.openingButtonText?.isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  _chip(automation.openingButtonText!,
                      AppColors.primaryLightBlue),
                ],
              ] else
                _emptyRow('Enabled but message not filled'),
            ],
          ),

          _SummaryCard(
            stepNumber: 5,
            title: 'Conditions',
            icon: Icons.rule_rounded,
            isConfigured: true, // always optional
            children: [
              _statusRow(
                automation.onlyFollowers
                    ? Icons.people_alt_outlined
                    : Icons.public_rounded,
                automation.onlyFollowers
                    ? 'Followers only — non-followers are ignored'
                    : 'Open to everyone who comments',
                automation.onlyFollowers
                    ? AppColors.primaryLightBlue
                    : Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review & Publish',
          style: GoogleFonts.urbanist(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Double-check everything for "$name" before publishing.',
          style: GoogleFonts.urbanist(fontSize: 15, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label,
          style: GoogleFonts.urbanist(
              fontSize: 13, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Widget _messageBubble(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text,
          style: GoogleFonts.urbanist(
              fontSize: 14, color: Colors.black87, height: 1.4)),
    );
  }

  Widget _emptyRow(String label) => _statusRow(
        Icons.warning_amber_rounded, label, Colors.orange);

  Widget _statusRow(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label,
              style: GoogleFonts.urbanist(fontSize: 13, color: Colors.grey[700])),
        ),
      ],
    );
  }
}

// ── Summary card ─────────────────────────────────────────────────────────────

class _SummaryCard extends StatefulWidget {
  final int stepNumber;
  final String title;
  final IconData icon;
  final bool isConfigured;
  final List<Widget> children;

  const _SummaryCard({
    required this.stepNumber,
    required this.title,
    required this.icon,
    required this.isConfigured,
    required this.children,
  });

  @override
  State<_SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<_SummaryCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final statusColor =
        widget.isConfigured ? AppColors.successGreen : Colors.orange;
    final statusIcon =
        widget.isConfigured ? Icons.check_circle_rounded : Icons.warning_rounded;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
          border: Border.all(
            color: widget.isConfigured
                ? Colors.grey[200]!
                : Colors.orange.withValues(alpha: 0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header row
            InkWell(
              borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: UIConstants.paddingMedium, vertical: 12),
                child: Row(
                  children: [
                    // Step badge
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLightBlue.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${widget.stepNumber}',
                          style: GoogleFonts.urbanist(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryLightBlue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(widget.icon, size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: GoogleFonts.urbanist(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Icon(statusIcon, size: 18, color: statusColor),
                    const SizedBox(width: 6),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),

            // Expandable body
            if (_expanded) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(UIConstants.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.children,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
