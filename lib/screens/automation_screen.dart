import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/api_constants.dart';
import '../providers/automation_providers.dart';
import '../models/automation.dart';
import '../services/exceptions/app_exceptions.dart';
import '../widgets/automation/automation_list_item.dart';
import 'automation_flow_screen.dart';

class AutomationScreen extends ConsumerStatefulWidget {
  const AutomationScreen({super.key});

  @override
  ConsumerState<AutomationScreen> createState() => _AutomationScreenState();
}

class _AutomationScreenState extends ConsumerState<AutomationScreen> {
  @override
  Widget build(BuildContext context) {
    final automationsAsync = ref.watch(automationProvider);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Row(
          children: [
            // Logo in AppBar
            Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.asset(
                  'assets/images/main_logo_bg.svg',
                  width: 40,
                  height: 40,
                ),
                Text(
                  'Q',
                  style: TextStyle(
                    fontFamily: GoogleFonts.urbanist().fontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..shader = AppColors.primaryGradient.createShader(
                        const Rect.fromLTWH(0.0, 0.0, 30, 30),
                      ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Text(
              'Automation',
              style: GoogleFonts.urbanist(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateAutomationBottomSheet,
          ),
        ],
      ),
      body: automationsAsync.when(
        data: (automations) => automations.isEmpty
            ? _buildEmptyState()
            : _buildAutomationsList(automations),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _buildErrorState(error),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateAutomationBottomSheet,
        backgroundColor: AppColors.primaryLightBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Create Automation',
          style: GoogleFonts.urbanist(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primaryLightBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.auto_awesome,
              size: 60,
              color: AppColors.primaryLightBlue,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Automations Yet',
            style: GoogleFonts.urbanist(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Create your first automation to streamline your Instagram workflow',
              textAlign: TextAlign.center,
              style: GoogleFonts.urbanist(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _showCreateAutomationBottomSheet,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLightBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add),
            label: Text(
              'Create Your First Automation',
              style: GoogleFonts.urbanist(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutomationsList(List<Automation> automations) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(automationProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(UIConstants.paddingMedium),
        itemCount: automations.length,
        itemBuilder: (context, index) {
          final automation = automations[index];
          return AutomationListItem(
            automation: automation,
            onTap: () => _editAutomation(automation),
            onEdit: () => _editAutomation(automation),
            onDelete: () => _deleteAutomation(automation.id),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(Object error) {
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
            'Error Loading Automations',
            style: GoogleFonts.urbanist(
              fontSize: 20,
              fontWeight: FontWeight.bold,
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
            onPressed: () {
              ref.invalidate(automationProvider);
            },
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

  void _showCreateAutomationBottomSheet() {
    final TextEditingController nameController = TextEditingController(
      text: AutomationConstants.defaultAutomationName,
    );
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateAutomationBottomSheet(
        nameController: nameController,
        onCreatePressed: (name) {
          Navigator.of(context).pop();
          _navigateToAutomationFlow(name);
        },
      ),
    );
  }

  Future<void> _navigateToAutomationFlow(String automationName) async {
    try {
      final operations = ref.read(automationOperationsProvider);
      await operations.startAutomationFlow(automationName);
      
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const AutomationFlowScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.toString());
      }
    }
  }

  void _editAutomation(Automation automation) {
    // Load the automation for editing
    ref.read(currentAutomationProvider.notifier).updateCurrentAutomation(automation);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AutomationFlowScreen(),
      ),
    );
  }

  Future<void> _deleteAutomation(String automationId) async {
    final confirmed = await _showDeleteConfirmation();
    if (confirmed == true) {
      try {
        await ref.read(automationProvider.notifier).deleteAutomation(automationId);
        if (mounted) {
          _showSuccessSnackBar('Automation deleted successfully');
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackBar('Failed to delete automation');
        }
      }
    }
  }

  Future<bool?> _showDeleteConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Automation',
          style: GoogleFonts.urbanist(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete this automation? This action cannot be undone.',
          style: GoogleFonts.urbanist(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.urbanist(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Delete',
              style: GoogleFonts.urbanist(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class CreateAutomationBottomSheet extends StatefulWidget {
  final TextEditingController nameController;
  final Function(String) onCreatePressed;

  const CreateAutomationBottomSheet({
    super.key,
    required this.nameController,
    required this.onCreatePressed,
  });

  @override
  State<CreateAutomationBottomSheet> createState() => _CreateAutomationBottomSheetState();
}

class _CreateAutomationBottomSheetState extends State<CreateAutomationBottomSheet> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    
    // Auto-focus and select all text
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      widget.nameController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: widget.nameController.text.length,
      );
    });
  }

  void _onFocusChange() {
    // Handle focus changes if needed in the future
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLightBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Icon(
                          Icons.auto_awesome,
                          color: AppColors.primaryLightBlue,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Create New Automation',
                              style: GoogleFonts.urbanist(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'Give your automation a meaningful name',
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
                  const SizedBox(height: 24),
                  
                  // Name input field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Automation Name',
                        style: GoogleFonts.urbanist(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: widget.nameController,
                        focusNode: _focusNode,
                        style: GoogleFonts.urbanist(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter automation name',
                          hintStyle: GoogleFonts.urbanist(
                            color: Colors.grey[400],
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.primaryLightBlue, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) {
                          if (widget.nameController.text.trim().isNotEmpty) {
                            widget.onCreatePressed(widget.nameController.text.trim());
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.urbanist(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                                                  onPressed: () {
                          final name = widget.nameController.text.trim();
                          if (name.isNotEmpty && name.length <= AutomationConstants.maxNameLength) {
                            widget.onCreatePressed(name);
                          }
                        },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryLightBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Create',
                            style: GoogleFonts.urbanist(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}