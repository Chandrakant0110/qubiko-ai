import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../constants/api_constants.dart';
import '../../models/automation.dart';

/// Bottom sheet for adding or editing action buttons
class LinkButtonBottomSheet extends StatefulWidget {
  final DMButton? existingButton;
  final Function(DMButton) onSave;

  const LinkButtonBottomSheet({
    super.key,
    this.existingButton,
    required this.onSave,
  });

  @override
  State<LinkButtonBottomSheet> createState() => _LinkButtonBottomSheetState();
}

class _LinkButtonBottomSheetState extends State<LinkButtonBottomSheet> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();
  final FocusNode _linkFocusNode = FocusNode();
  
  String? _textError;
  String? _linkError;
  bool _isValidating = false;

  @override
  void initState() {
    super.initState();
    
    // Pre-fill if editing existing button
    if (widget.existingButton != null) {
      _textController.text = widget.existingButton!.text;
      _linkController.text = widget.existingButton!.link;
    }
    
    // Auto-focus text field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _textFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _linkController.dispose();
    _textFocusNode.dispose();
    _linkFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingButton != null;
    
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(UIConstants.borderRadiusLarge),
          topRight: Radius.circular(UIConstants.borderRadiusLarge),
        ),
      ),
      padding: EdgeInsets.only(
        left: UIConstants.paddingLarge,
        right: UIConstants.paddingLarge,
        top: UIConstants.paddingLarge,
        bottom: MediaQuery.of(context).viewInsets.bottom + UIConstants.paddingLarge,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isEditing),
          const SizedBox(height: UIConstants.paddingLarge),
          _buildTextField(),
          const SizedBox(height: UIConstants.paddingMedium),
          _buildLinkField(),
          const SizedBox(height: UIConstants.paddingLarge),
          _buildButtons(isEditing),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isEditing) {
    return Row(
      children: [
        Container(
          width: UIConstants.iconSizeXLarge,
          height: UIConstants.iconSizeXLarge,
          decoration: BoxDecoration(
            color: AppColors.primaryLightBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(UIConstants.iconSizeXLarge / 2),
          ),
          child: Icon(
            isEditing ? Icons.edit : Icons.add_link,
            color: AppColors.primaryLightBlue,
            size: UIConstants.iconSizeLarge,
          ),
        ),
        const SizedBox(width: UIConstants.paddingMedium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Edit Action Button' : 'Add Action Button',
                style: GoogleFonts.urbanist(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                'Create a clickable button with custom text and link',
                style: GoogleFonts.urbanist(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.close,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Button Text',
          style: GoogleFonts.urbanist(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: UIConstants.paddingSmall),
        TextField(
          controller: _textController,
          focusNode: _textFocusNode,
          style: GoogleFonts.urbanist(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'e.g., Get Special Offer, Download Guide, Contact Us',
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.all(UIConstants.paddingMedium),
            errorText: _textError,
            prefixIcon: Icon(
              Icons.text_fields,
              color: Colors.grey[400],
              size: UIConstants.iconSizeSmall,
            ),
          ),
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _linkFocusNode.requestFocus(),
          onChanged: (value) {
            if (_textError != null) {
              setState(() {
                _textError = null;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildLinkField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Button Link',
          style: GoogleFonts.urbanist(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: UIConstants.paddingSmall),
        TextField(
          controller: _linkController,
          focusNode: _linkFocusNode,
          style: GoogleFonts.urbanist(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'https://your-website.com',
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.all(UIConstants.paddingMedium),
            errorText: _linkError,
            prefixIcon: Icon(
              Icons.link,
              color: Colors.grey[400],
              size: UIConstants.iconSizeSmall,
            ),
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _handleSave(),
          onChanged: (value) {
            if (_linkError != null) {
              setState(() {
                _linkError = null;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildButtons(bool isEditing) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey[400]!),
              padding: const EdgeInsets.symmetric(vertical: UIConstants.paddingMedium),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
              ),
            ),
            child: Text(
              'Cancel',
              style: GoogleFonts.urbanist(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
        ),
        const SizedBox(width: UIConstants.paddingMedium),
        Expanded(
          child: ElevatedButton(
            onPressed: _isValidating ? null : _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLightBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: UIConstants.paddingMedium),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
              ),
              elevation: 0,
            ),
            child: _isValidating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    isEditing ? 'Update Button' : 'Add Button',
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  void _handleSave() async {
    // Clear previous errors
    setState(() {
      _textError = null;
      _linkError = null;
      _isValidating = true;
    });

    // Validate button text
    final buttonText = _textController.text.trim();
    if (buttonText.isEmpty) {
      setState(() {
        _textError = 'Button text is required';
        _isValidating = false;
      });
      _textFocusNode.requestFocus();
      return;
    }

    if (buttonText.length > 30) {
      setState(() {
        _textError = 'Button text must be 30 characters or less';
        _isValidating = false;
      });
      _textFocusNode.requestFocus();
      return;
    }

    // Validate URL
    final url = _linkController.text.trim();
    if (url.isEmpty) {
      setState(() {
        _linkError = 'Link URL is required';
        _isValidating = false;
      });
      _linkFocusNode.requestFocus();
      return;
    }

    if (!_isValidHttpUrl(url)) {
      setState(() {
        _linkError = 'Please enter a valid HTTP or HTTPS URL';
        _isValidating = false;
      });
      _linkFocusNode.requestFocus();
      return;
    }

    // Simulate validation delay (could be replaced with actual URL validation)
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isValidating = false;
    });

    // Create the button
    final button = DMButton(text: buttonText, link: url);
    
    // Close bottom sheet and return the button
    Navigator.of(context).pop();
    widget.onSave(button);
  }

  bool _isValidHttpUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && 
             (uri.scheme == 'http' || uri.scheme == 'https') &&
             uri.hasAuthority &&
             uri.host.isNotEmpty &&
             uri.host.contains('.');
    } catch (e) {
      return false;
    }
  }
}