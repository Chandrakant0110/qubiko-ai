import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../constants/api_constants.dart';
import '../../providers/automation_providers.dart';

/// Widget for setting up opening message in Step 4
/// Provides toggle, text input and button text configuration
class OpeningMessageWidget extends ConsumerStatefulWidget {
  const OpeningMessageWidget({super.key});

  @override
  ConsumerState<OpeningMessageWidget> createState() => _OpeningMessageWidgetState();
}

class _OpeningMessageWidgetState extends ConsumerState<OpeningMessageWidget> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _buttonTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final current = ref.read(currentAutomationProvider);
      if (current != null) {
        _messageController.text = current.openingMessage ?? '';
        _buttonTextController.text =
            current.openingButtonText ?? 'Send me the link';
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _buttonTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentAutomation = ref.watch(currentAutomationProvider);
    if (currentAutomation == null) {
      return const Center(child: Text('No automation data'));
    }
    // Use provider as source of truth for toggle state
    final isEnabled = currentAutomation.openingMessageEnabled;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(UIConstants.paddingLarge),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: UIConstants.paddingLarge),
            _buildToggleSection(isEnabled),
            const SizedBox(height: UIConstants.paddingLarge),
            if (isEnabled) ...[
              _buildMessageCard(),
              const SizedBox(height: UIConstants.paddingLarge),
              _buildButtonTextSection(),
              const SizedBox(height: UIConstants.paddingLarge),
              _buildPreviewCard(),
              const SizedBox(height: UIConstants.paddingLarge),
            ],
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
          'Opening Message',
          style: GoogleFonts.urbanist(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: UIConstants.paddingSmall),
        Text(
          'Set up an initial message that users will receive before the main automation triggers.',
          style: GoogleFonts.urbanist(
            fontSize: 16,
            color: Colors.grey[600],
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleSection(bool isEnabled) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingLarge),
      decoration: BoxDecoration(
        color: isEnabled
            ? AppColors.primaryLightBlue.withValues(alpha: 0.1)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
        border: Border.all(
          color: isEnabled
              ? AppColors.primaryLightBlue.withValues(alpha: 0.3)
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
              color: isEnabled
                  ? AppColors.primaryLightBlue.withValues(alpha: 0.2)
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(UIConstants.iconSizeXLarge / 2),
            ),
            child: Icon(
              Icons.message_outlined,
              color: isEnabled ? AppColors.primaryLightBlue : Colors.grey[600],
              size: UIConstants.iconSizeMedium,
            ),
          ),
          const SizedBox(width: UIConstants.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Opening message',
                  style: GoogleFonts.urbanist(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isEnabled
                      ? 'Send an initial message to start the conversation'
                      : 'Tap to enable an opening message (optional)',
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
              value: isEnabled,
              onChanged: (value) {
                // Drive state through provider — widget rebuilds reactively
                ref
                    .read(currentAutomationProvider.notifier)
                    .setOpeningMessageEnabled(value);
                if (!value) {
                  _messageController.clear();
                  ref.read(currentAutomationProvider.notifier).updateOpeningMessage(
                        message: '',
                        buttonText: '',
                      );
                } else {
                  _buttonTextController.text = 'Send me the link';
                  ref.read(currentAutomationProvider.notifier).updateOpeningMessage(
                        buttonText: 'Send me the link',
                      );
                }
              },
              activeColor: AppColors.primaryLightBlue,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
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
                  Icons.edit_note,
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
                      'Opening Message Text',
                      style: GoogleFonts.urbanist(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Write the initial message users will receive',
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
            maxLines: 4,
            maxLength: 600,
            style: GoogleFonts.urbanist(
              fontSize: 16,
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: 'Enter your opening message...\n\nExample: "Hi! Thank you for showing interest. To get the link, please reply with your request."',
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
              ref.read(currentAutomationProvider.notifier).updateOpeningMessage(message: value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildButtonTextSection() {
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
                  Icons.smart_button,
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
                      'Button Text',
                      style: GoogleFonts.urbanist(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Customize the button text users will see',
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: UIConstants.paddingMedium),
          TextField(
            controller: _buttonTextController,
            style: GoogleFonts.urbanist(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'Enter button text...',
              hintStyle: GoogleFonts.urbanist(
                color: Colors.grey[400],
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
              prefixIcon: Icon(
                Icons.text_fields,
                color: Colors.grey[400],
                size: UIConstants.iconSizeSmall,
              ),
            ),
            onChanged: (value) {
              ref.read(currentAutomationProvider.notifier).updateOpeningMessage(buttonText: value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard() {
    final currentAutomation = ref.watch(currentAutomationProvider);
    final hasMessage = currentAutomation?.openingMessage?.isNotEmpty == true;
    final hasButtonText = currentAutomation?.openingButtonText?.isNotEmpty == true;

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
                    currentAutomation!.openingMessage!,
                    style: GoogleFonts.urbanist(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  )
                else
                  Text(
                    'Your opening message will appear here...',
                    style: GoogleFonts.urbanist(
                      fontSize: 14,
                      color: Colors.grey[400],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                if (hasButtonText) ...[
                  const SizedBox(height: UIConstants.paddingMedium),
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
                      currentAutomation!.openingButtonText!,
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.withOpacity(0.1),
            Colors.orange.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
        border: Border.all(
          color: Colors.orange.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: UIConstants.iconSizeXLarge,
            height: UIConstants.iconSizeXLarge,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(UIConstants.iconSizeXLarge / 2),
            ),
            child: const Icon(
              Icons.info_outline,
              color: Colors.orange,
              size: UIConstants.iconSizeMedium,
            ),
          ),
          const SizedBox(width: UIConstants.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Note',
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'The opening message is sent first to initiate contact. After users respond, your main DM automation will trigger.',
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

  Color _getCharacterCountColor() {
    final length = _messageController.text.length;
    if (length > 500) return Colors.red;
    if (length > 400) return Colors.orange;
    return AppColors.primaryLightBlue;
  }
}