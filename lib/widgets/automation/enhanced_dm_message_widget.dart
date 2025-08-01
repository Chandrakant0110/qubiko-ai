import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../constants/api_constants.dart';
import '../../providers/automation_providers.dart';
import '../../models/automation.dart';
import 'link_button_bottom_sheet.dart';

/// Enhanced widget for setting up DM message in Step 3
/// Supports multiple links (up to 3) with improved UI
class EnhancedDMMessageWidget extends ConsumerStatefulWidget {
  const EnhancedDMMessageWidget({super.key});

  @override
  ConsumerState<EnhancedDMMessageWidget> createState() => _EnhancedDMMessageWidgetState();
}

class _EnhancedDMMessageWidgetState extends ConsumerState<EnhancedDMMessageWidget> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, TextEditingController>> _buttonControllers = [];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentAutomation = ref.read(currentAutomationProvider);
      if (currentAutomation != null) {
        _messageController.text = currentAutomation.dmMessage ?? '';
        
        // Initialize button controllers from existing data
        _buttonControllers.clear();
        for (final button in currentAutomation.dmButtons) {
          _buttonControllers.add({
            'text': TextEditingController(text: button.text),
            'link': TextEditingController(text: button.link),
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    for (final controllerMap in _buttonControllers) {
      controllerMap['text']?.dispose();
      controllerMap['link']?.dispose();
    }
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
            _buildMessageCard(),
            const SizedBox(height: UIConstants.paddingLarge),
            _buildLinksSection(),
            const SizedBox(height: UIConstants.paddingLarge),
            _buildPreviewCard(),
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
          'Send DM',
          style: GoogleFonts.urbanist(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: UIConstants.paddingSmall),
        Text(
          'Create the message that will be sent automatically to users who interact with your post.',
          style: GoogleFonts.urbanist(
            fontSize: 16,
            color: Colors.grey[600],
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildMessageCard() {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
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
          Row(
            children: [
              Container(
                width: UIConstants.iconSizeLarge,
                height: UIConstants.iconSizeLarge,
                decoration: BoxDecoration(
                  color: AppColors.primaryLightBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(UIConstants.iconSizeLarge / 2),
                ),
                child: Icon(
                  Icons.message,
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
                      'Message Content',
                      style: GoogleFonts.urbanist(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Write your automated DM message',
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: UIConstants.paddingSmall,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: _getCharacterCountColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
                ),
                child: Text(
                  '${_messageController.text.length}/600',
                  style: GoogleFonts.urbanist(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getCharacterCountColor(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: UIConstants.paddingMedium),
          TextField(
            controller: _messageController,
            maxLines: 6,
            maxLength: 600,
            style: GoogleFonts.urbanist(
              fontSize: 16,
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: 'Type your message here...\n\nExample: "Thanks for your interest! Check out our latest offers using the link below."',
              hintStyle: GoogleFonts.urbanist(
                color: Colors.grey[400],
                height: 1.5,
              ),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
                borderSide: BorderSide(color: AppColors.primaryLightBlue, width: 2),
              ),
              contentPadding: const EdgeInsets.all(UIConstants.paddingMedium),
              counterText: '', // Hide the default counter
            ),
            onChanged: (value) {
              setState(() {}); // Update character count
              _updateMessage();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLinksSection() {
    final currentAutomation = ref.watch(currentAutomationProvider);
    
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
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
          Row(
            children: [
              Container(
                width: UIConstants.iconSizeLarge,
                height: UIConstants.iconSizeLarge,
                decoration: BoxDecoration(
                  color: AppColors.primaryLightBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(UIConstants.iconSizeLarge / 2),
                ),
                child: Icon(
                  Icons.link,
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
                      'Action Buttons',
                      style: GoogleFonts.urbanist(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Add up to 3 clickable buttons with links',
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: UIConstants.paddingSmall,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLightBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
                ),
                child: Text(
                  '${currentAutomation?.dmButtons.length ?? 0}/3',
                  style: GoogleFonts.urbanist(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryLightBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: UIConstants.paddingMedium),
          
          // Existing buttons
          if (currentAutomation?.dmButtons.isNotEmpty == true) ...[
            ...currentAutomation!.dmButtons.asMap().entries.map((entry) {
              final index = entry.key;
              final button = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: UIConstants.paddingMedium),
                child: _buildSavedButtonCard(index, button),
              );
            }).toList(),
          ],
          
          // Add button (if under limit)
          if ((currentAutomation?.dmButtons.length ?? 0) < 3)
            _buildAddButton(),
        ],
      ),
    );
  }

  Widget _buildSavedButtonCard(int index, DMButton button) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Button preview
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: UIConstants.paddingMedium,
              vertical: UIConstants.paddingSmall,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryLightBlue,
              borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
            ),
            child: Text(
              button.text,
              style: GoogleFonts.urbanist(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: UIConstants.paddingMedium),
          
          // Link preview
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  button.text,
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  button.link,
                  style: GoogleFonts.urbanist(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Action buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _editButton(index, button),
                icon: Icon(
                  Icons.edit,
                  color: AppColors.primaryLightBlue,
                  size: UIConstants.iconSizeSmall,
                ),
                tooltip: 'Edit button',
              ),
              IconButton(
                onPressed: () => _removeButton(index),
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: UIConstants.iconSizeSmall,
                ),
                tooltip: 'Delete button',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _showAddButtonBottomSheet,
        icon: Icon(
          Icons.add_link,
          size: UIConstants.iconSizeSmall,
        ),
        label: Text(
          'Add Action Button',
          style: GoogleFonts.urbanist(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLightBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            vertical: UIConstants.paddingMedium,
            horizontal: UIConstants.paddingLarge,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    final currentAutomation = ref.watch(currentAutomationProvider);
    final hasMessage = currentAutomation?.dmMessage?.isNotEmpty == true;
    final hasButtons = currentAutomation?.dmButtons.isNotEmpty == true;

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
        border: Border.all(
          color: AppColors.primaryLightBlue.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.preview,
                color: AppColors.primaryLightBlue,
                size: UIConstants.iconSizeMedium,
              ),
              const SizedBox(width: UIConstants.paddingSmall),
              Text(
                'Message Preview',
                style: GoogleFonts.urbanist(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryLightBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: UIConstants.paddingMedium),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(UIConstants.paddingMedium),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasMessage)
                  Text(
                    currentAutomation!.dmMessage!,
                    style: GoogleFonts.urbanist(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  )
                else
                  Text(
                    'Your message will appear here...',
                    style: GoogleFonts.urbanist(
                      fontSize: 14,
                      color: Colors.grey[400],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                if (hasButtons) ...[
                  const SizedBox(height: UIConstants.paddingMedium),
                  Wrap(
                    spacing: UIConstants.paddingSmall,
                    runSpacing: UIConstants.paddingSmall,
                    children: currentAutomation!.dmButtons.map((button) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: UIConstants.paddingMedium,
                          vertical: UIConstants.paddingSmall,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLightBlue,
                          borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
                        ),
                        child: Text(
                          button.text.isNotEmpty ? button.text : 'Button Text',
                          style: GoogleFonts.urbanist(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _updateMessage() {
    final buttons = _buttonControllers.map((controllerMap) {
      return DMButton(
        text: controllerMap['text']?.text ?? '',
        link: controllerMap['link']?.text ?? '',
      );
    }).toList();

    ref.read(currentAutomationProvider.notifier).updateDMMessage(
      message: _messageController.text,
      buttons: buttons,
    );
  }

  void _showAddButtonBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LinkButtonBottomSheet(
        onSave: (button) {
          ref.read(currentAutomationProvider.notifier).addDMButton(button);
          _showSuccessMessage('Action button added successfully');
        },
      ),
    );
  }

  void _editButton(int index, DMButton button) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LinkButtonBottomSheet(
        existingButton: button,
        onSave: (updatedButton) {
          ref.read(currentAutomationProvider.notifier).updateDMButton(index, updatedButton);
          _showSuccessMessage('Action button updated successfully');
        },
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(message),
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
  }

  void _removeButton(int index) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Action Button',
          style: GoogleFonts.urbanist(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this action button? This action cannot be undone.',
          style: GoogleFonts.urbanist(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.urbanist(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(currentAutomationProvider.notifier).removeDMButton(index);
              _showSuccessMessage('Action button deleted');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.urbanist(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCharacterCountColor() {
    final length = _messageController.text.length;
    if (length > 500) return Colors.red;
    if (length > 400) return Colors.orange;
    return AppColors.primaryLightBlue;
  }
}