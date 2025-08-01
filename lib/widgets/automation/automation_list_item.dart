import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/automation.dart';
import '../../constants/app_colors.dart';
import '../../constants/api_constants.dart';

/// Widget representing a single automation item in the list
/// This provides a consistent UI for displaying automation information
class AutomationListItem extends StatelessWidget {
  final Automation automation;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AutomationListItem({
    super.key,
    required this.automation,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: UIConstants.paddingMedium),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
      ),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(UIConstants.paddingMedium),
          child: Row(
            children: [
              AutomationIcon(status: automation.status),
              const SizedBox(width: UIConstants.paddingMedium),
              Expanded(
                child: AutomationDetails(automation: automation),
              ),
              AutomationMenu(
                onEdit: onEdit,
                onDelete: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Icon representing the automation status
class AutomationIcon extends StatelessWidget {
  final AutomationStatus status;

  const AutomationIcon({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: UIConstants.iconSizeXLarge,
      height: UIConstants.iconSizeXLarge,
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(UIConstants.iconSizeXLarge / 2),
      ),
      child: Icon(
        _getStatusIcon(),
        color: _getStatusColor(),
        size: UIConstants.iconSizeMedium,
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case AutomationStatus.active:
        return Colors.green;
      case AutomationStatus.paused:
        return Colors.orange;
      case AutomationStatus.error:
        return Colors.red;
      case AutomationStatus.completed:
        return Colors.blue;
      case AutomationStatus.draft:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case AutomationStatus.active:
        return Icons.play_arrow;
      case AutomationStatus.paused:
        return Icons.pause;
      case AutomationStatus.error:
        return Icons.error;
      case AutomationStatus.completed:
        return Icons.check_circle;
      case AutomationStatus.draft:
        return Icons.edit;
    }
  }
}

/// Details section showing automation name, description, and metadata
class AutomationDetails extends StatelessWidget {
  final Automation automation;

  const AutomationDetails({
    super.key,
    required this.automation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Automation name and status
        Row(
          children: [
            Expanded(
              child: Text(
                automation.name,
                style: GoogleFonts.urbanist(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            AutomationStatusChip(status: automation.status),
          ],
        ),
        const SizedBox(height: 4),
        
        // Description (if available)
        if (automation.description?.isNotEmpty == true) ...[
          Text(
            automation.description!,
            style: GoogleFonts.urbanist(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
        ],
        
        // Metadata
        Row(
          children: [
            Icon(
              Icons.schedule,
              size: UIConstants.iconSizeSmall,
              color: Colors.grey[500],
            ),
            const SizedBox(width: 4),
            Text(
              'Created ${automation.formattedCreatedDate}',
              style: GoogleFonts.urbanist(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(width: UIConstants.paddingMedium),
            Icon(
              Icons.layers,
              size: UIConstants.iconSizeSmall,
              color: Colors.grey[500],
            ),
            const SizedBox(width: 4),
            Text(
              'Step ${automation.currentStep + 1}/${automation.stepCount}',
              style: GoogleFonts.urbanist(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        
        // Progress bar (if not draft)
        if (automation.status != AutomationStatus.draft) ...[
          const SizedBox(height: UIConstants.paddingSmall),
          AutomationProgressBar(progress: automation.progressPercentage),
        ],
      ],
    );
  }
}

/// Status chip showing the current automation status
class AutomationStatusChip extends StatelessWidget {
  final AutomationStatus status;

  const AutomationStatusChip({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.paddingSmall,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
        border: Border.all(
          color: _getStatusColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        status.displayName,
        style: GoogleFonts.urbanist(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _getStatusColor(),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case AutomationStatus.active:
        return Colors.green;
      case AutomationStatus.paused:
        return Colors.orange;
      case AutomationStatus.error:
        return Colors.red;
      case AutomationStatus.completed:
        return Colors.blue;
      case AutomationStatus.draft:
        return Colors.grey;
    }
  }
}

/// Progress bar showing automation completion
class AutomationProgressBar extends StatelessWidget {
  final double progress;

  const AutomationProgressBar({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: GoogleFonts.urbanist(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: GoogleFonts.urbanist(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryLightBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryLightBlue),
          minHeight: 3,
        ),
      ],
    );
  }
}

/// Menu with automation actions
class AutomationMenu extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AutomationMenu({
    super.key,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: Colors.grey[600],
        size: UIConstants.iconSizeMedium,
      ),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit?.call();
            break;
          case 'delete':
            onDelete?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              const Icon(
                Icons.edit,
                size: UIConstants.iconSizeSmall,
                color: Colors.grey,
              ),
              const SizedBox(width: UIConstants.paddingSmall),
              Text(
                'Edit',
                style: GoogleFonts.urbanist(fontSize: 14),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              const Icon(
                Icons.delete,
                size: UIConstants.iconSizeSmall,
                color: Colors.red,
              ),
              const SizedBox(width: UIConstants.paddingSmall),
              Text(
                'Delete',
                style: GoogleFonts.urbanist(
                  fontSize: 14,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}