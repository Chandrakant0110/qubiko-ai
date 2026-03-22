import 'package:flutter/foundation.dart' show listEquals, mapEquals;

enum AutomationStatus {
  draft,
  active,
  paused,
  error,
  completed;

  /// Returns a user-friendly display name for the status
  String get displayName {
    switch (this) {
      case AutomationStatus.draft:
        return 'Draft';
      case AutomationStatus.active:
        return 'Active';
      case AutomationStatus.paused:
        return 'Paused';
      case AutomationStatus.error:
        return 'Error';
      case AutomationStatus.completed:
        return 'Completed';
    }
  }

  /// Returns appropriate color for the status
  String get colorCode {
    switch (this) {
      case AutomationStatus.draft:
        return '#FFA726';
      case AutomationStatus.active:
        return '#66BB6A';
      case AutomationStatus.paused:
        return '#FFCA28';
      case AutomationStatus.error:
        return '#EF5350';
      case AutomationStatus.completed:
        return '#42A5F5';
    }
  }
}

/// Model representing an automation workflow
/// This encapsulates all automation data and business logic
class Automation {
  final String id;
  final String name;
  final String? description;
  final AutomationStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? selectedPostId;
  final Map<String, dynamic> configuration;
  final int stepCount;
  final int currentStep;
  
  // Step 2: Keyword triggers
  final bool anyKeyword;
  final List<String> triggerKeywords;
  
  // Step 3: DM message
  final String? dmMessage;
  final List<DMButton> dmButtons;
  
  // Step 4: Opening message
  final bool openingMessageEnabled;
  final String? openingMessage;
  final String? openingButtonText;

  // Step 5: Conditions
  final bool onlyFollowers;

  const Automation({
    required this.id,
    required this.name,
    this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.selectedPostId,
    this.configuration = const {},
    this.stepCount = 6,
    this.currentStep = 0,
    this.anyKeyword = false,
    this.triggerKeywords = const [],
    this.dmMessage,
    this.dmButtons = const [],
    this.openingMessageEnabled = false,
    this.openingMessage,
    this.openingButtonText,
    this.onlyFollowers = false,
  });

  /// Factory constructor to create a new automation
  factory Automation.create({
    required String name,
    String? description,
  }) {
    final now = DateTime.now();
    return Automation(
      id: _generateId(),
      name: name,
      description: description,
      status: AutomationStatus.draft,
      createdAt: now,
      updatedAt: now,
      currentStep: 0,
      anyKeyword: false,
      triggerKeywords: const [],
      dmButtons: const [],
    );
  }

  /// Creates Automation from JSON
  factory Automation.fromJson(Map<String, dynamic> json) {
    return Automation(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      status: AutomationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AutomationStatus.draft,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      selectedPostId: json['selected_post_id'] as String?,
      configuration: Map<String, dynamic>.from(json['configuration'] ?? {}),
      stepCount: json['step_count'] as int? ?? 6,
      currentStep: json['current_step'] as int? ?? 0,
      anyKeyword: json['any_keyword'] as bool? ?? false,
      triggerKeywords: List<String>.from(json['trigger_keywords'] ?? []),
      dmMessage: json['dm_message'] as String?,
      dmButtons: (json['dm_buttons'] as List?)?.map((item) => DMButton.fromJson(item)).toList() ?? [],
      openingMessageEnabled: json['opening_message_enabled'] as bool? ?? false,
      openingMessage: json['opening_message'] as String?,
      openingButtonText: json['opening_button_text'] as String?,
      onlyFollowers: json['only_followers'] as bool? ?? false,
    );
  }

  /// Converts Automation to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'selected_post_id': selectedPostId,
      'configuration': configuration,
      'step_count': stepCount,
      'current_step': currentStep,
      'any_keyword': anyKeyword,
      'trigger_keywords': triggerKeywords,
      'dm_message': dmMessage,
      'dm_buttons': dmButtons.map((button) => button.toJson()).toList(),
      'opening_message_enabled': openingMessageEnabled,
      'opening_message': openingMessage,
      'opening_button_text': openingButtonText,
      'only_followers': onlyFollowers,
    };
  }

  /// Creates a copy with updated fields
  Automation copyWith({
    String? id,
    String? name,
    String? description,
    AutomationStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? selectedPostId,
    Map<String, dynamic>? configuration,
    int? stepCount,
    int? currentStep,
    bool? anyKeyword,
    List<String>? triggerKeywords,
    String? dmMessage,
    List<DMButton>? dmButtons,
    bool? openingMessageEnabled,
    String? openingMessage,
    String? openingButtonText,
    bool? onlyFollowers,
  }) {
    return Automation(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      selectedPostId: selectedPostId ?? this.selectedPostId,
      configuration: configuration ?? Map<String, dynamic>.from(this.configuration),
      stepCount: stepCount ?? this.stepCount,
      currentStep: currentStep ?? this.currentStep,
      anyKeyword: anyKeyword ?? this.anyKeyword,
      triggerKeywords: triggerKeywords ?? List<String>.from(this.triggerKeywords),
      dmMessage: dmMessage ?? this.dmMessage,
      dmButtons: dmButtons ?? List<DMButton>.from(this.dmButtons),
      openingMessageEnabled: openingMessageEnabled ?? this.openingMessageEnabled,
      openingMessage: openingMessage ?? this.openingMessage,
      openingButtonText: openingButtonText ?? this.openingButtonText,
      onlyFollowers: onlyFollowers ?? this.onlyFollowers,
    );
  }

  /// Updates the automation with a selected post
  Automation withSelectedPost(String postId) {
    return copyWith(
      selectedPostId: postId,
      updatedAt: DateTime.now(),
    );
  }

  /// Advances to the next step
  Automation nextStep() {
    if (currentStep < stepCount - 1) {
      return copyWith(
        currentStep: currentStep + 1,
        updatedAt: DateTime.now(),
      );
    }
    return this;
  }

  /// Goes back to the previous step
  Automation previousStep() {
    if (currentStep > 0) {
      return copyWith(
        currentStep: currentStep - 1,
        updatedAt: DateTime.now(),
      );
    }
    return this;
  }

  /// Updates the automation status
  Automation withStatus(AutomationStatus newStatus) {
    return copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
    );
  }

  /// Checks if the automation is complete
  bool get isComplete => currentStep >= stepCount - 1;

  /// Checks if the automation can proceed to next step
  bool get canProceedToNextStep {
    switch (currentStep) {
      case 0: // Select Post step
        return selectedPostId != null && selectedPostId!.isNotEmpty;
      case 1: // Set Trigger step (Keywords)
        return anyKeyword || (triggerKeywords.isNotEmpty && triggerKeywords.length <= 3);
      case 2: // Send DM step
        return dmMessage != null && 
               dmMessage!.trim().isNotEmpty && 
               dmMessage!.length <= 600 &&
               dmButtons.isNotEmpty &&
               dmButtons.every((button) => button.isValid);
      case 3: // Opening Message step — optional, always allow Next when toggle is off
        if (!openingMessageEnabled) return true;
        return openingMessage != null &&
               openingMessage!.trim().isNotEmpty &&
               openingMessage!.length <= 600 &&
               openingButtonText != null &&
               openingButtonText!.trim().isNotEmpty;
      case 4: // Set Conditions step — always optional
        return true;
      case 5: // Review step
        return true;
      default:
        return false;
    }
  }

  /// Gets the progress percentage (0.0 to 1.0)
  double get progressPercentage => (currentStep + 1) / stepCount;

  /// Gets a formatted creation date
  String get formattedCreatedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return 'Recently';
    }
  }

  /// Private helper to generate unique IDs
  static String _generateId() {
    return 'automation_${DateTime.now().millisecondsSinceEpoch}_${(DateTime.now().microsecond % 1000).toString().padLeft(3, '0')}';
  }

  /// Value equality — compares every field so Riverpod detects all state changes.
  /// (Without this, `Notifier<Automation?>` would see old == new on every copyWith
  /// and skip listener notifications entirely.)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Automation &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.status == status &&
        other.selectedPostId == selectedPostId &&
        other.currentStep == currentStep &&
        other.anyKeyword == anyKeyword &&
        listEquals(other.triggerKeywords, triggerKeywords) &&
        other.dmMessage == dmMessage &&
        listEquals(other.dmButtons, dmButtons) &&
        other.openingMessageEnabled == openingMessageEnabled &&
        other.openingMessage == openingMessage &&
        other.openingButtonText == openingButtonText &&
        other.onlyFollowers == onlyFollowers &&
        mapEquals(other.configuration, configuration);
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        description,
        status,
        selectedPostId,
        currentStep,
        anyKeyword,
        Object.hashAll(triggerKeywords),
        dmMessage,
        Object.hashAll(dmButtons),
        openingMessageEnabled,
        openingMessage,
        openingButtonText,
        onlyFollowers,
      );

  @override
  String toString() {
    return 'Automation(id: $id, name: $name, status: $status, step: $currentStep/$stepCount)';
  }
}

/// Model representing a DM button with text and link
class DMButton {
  final String text;
  final String link;

  const DMButton({
    required this.text,
    required this.link,
  });

  factory DMButton.fromJson(Map<String, dynamic> json) {
    return DMButton(
      text: json['text'] as String? ?? '',
      link: json['link'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'link': link,
    };
  }

  DMButton copyWith({
    String? text,
    String? link,
  }) {
    return DMButton(
      text: text ?? this.text,
      link: link ?? this.link,
    );
  }

  bool get isValid => text.trim().isNotEmpty && link.trim().isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DMButton && other.text == text && other.link == link;
  }

  @override
  int get hashCode => text.hashCode ^ link.hashCode;

  @override
  String toString() => 'DMButton(text: $text, link: $link)';
}