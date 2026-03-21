import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/automation.dart';
import '../models/instagram_post.dart';
import '../services/instagram_service.dart';
import '../repositories/automation_repository.dart';
import '../services/exceptions/app_exceptions.dart';

// =============================================================================
// SERVICE PROVIDERS
// =============================================================================

/// Provider for Instagram service
/// This creates a singleton instance of the Instagram service
final instagramServiceProvider = Provider<InstagramService>((ref) {
  return HttpInstagramService();
});

/// Provider for Automation repository
/// This creates a singleton instance of the automation repository
final automationRepositoryProvider = Provider<AutomationRepository>((ref) {
  return LocalAutomationRepository();
});

// =============================================================================
// STATE PROVIDERS
// =============================================================================

/// State notifier for managing Instagram posts
/// This handles fetching, caching, and error states for Instagram posts
class InstagramPostsNotifier extends AsyncNotifier<List<InstagramPost>> {
  @override
  Future<List<InstagramPost>> build() async {
    return await fetchPosts();
  }

  /// Fetches Instagram posts from the API
  Future<List<InstagramPost>> fetchPosts() async {
    state = const AsyncValue.loading();

    try {
      final instagramService = ref.read(instagramServiceProvider);
      final posts = await instagramService.fetchPosts();
      state = AsyncValue.data(posts);
      return posts;
    } on SocketException catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    } on NetworkException catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Refreshes the posts data
  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  /// Gets a specific post by ID
  InstagramPost? getPostById(String postId) {
    return state.value?.firstWhere(
      (post) => post.id == postId,
      orElse: () => throw StateError('Post not found'),
    );
  }
}

/// Provider for Instagram posts state
final instagramPostsProvider =
    AsyncNotifierProvider<InstagramPostsNotifier, List<InstagramPost>>(
      InstagramPostsNotifier.new,
    );

/// State notifier for managing automations
/// This handles CRUD operations and state management for automations
class AutomationNotifier extends AsyncNotifier<List<Automation>> {
  @override
  Future<List<Automation>> build() async {
    return await _loadAutomations();
  }

  /// Loads all automations from the repository
  Future<List<Automation>> _loadAutomations() async {
    try {
      final repository = ref.read(automationRepositoryProvider);
      final automations = await repository.getAllAutomations();
      return automations;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Creates a new automation
  Future<void> createAutomation(String name, {String? description}) async {
    try {
      final repository = ref.read(automationRepositoryProvider);
      final automation = Automation.create(
        name: name,
        description: description,
      );
      await repository.saveAutomation(automation);
      ref.invalidateSelf(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Updates an existing automation
  Future<void> updateAutomation(Automation automation) async {
    try {
      final repository = ref.read(automationRepositoryProvider);
      await repository.updateAutomation(automation);
      ref.invalidateSelf(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Deletes an automation
  Future<void> deleteAutomation(String automationId) async {
    try {
      final repository = ref.read(automationRepositoryProvider);
      await repository.deleteAutomation(automationId);
      ref.invalidateSelf(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Gets a specific automation by ID
  Automation? getAutomationById(String automationId) {
    return state.value?.firstWhere(
      (automation) => automation.id == automationId,
      orElse: () => throw StateError('Automation not found'),
    );
  }

  /// Refreshes the automations list
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

/// Provider for automations state
final automationProvider =
    AsyncNotifierProvider<AutomationNotifier, List<Automation>>(
      AutomationNotifier.new,
    );

// =============================================================================
// CURRENT AUTOMATION FLOW PROVIDERS
// =============================================================================

/// State notifier for managing the current automation flow
/// This tracks the current automation being created/edited and its progress
class CurrentAutomationNotifier extends Notifier<Automation?> {
  @override
  Automation? build() {
    return null;
  }

  /// Starts a new automation flow
  void startNewAutomation(String name, {String? description}) {
    state = Automation.create(name: name, description: description);
  }

  /// Updates the current automation
  void updateCurrentAutomation(Automation automation) {
    state = automation;
  }

  /// Selects a post for the current automation
  void selectPost(String postId) {
    if (state != null) {
      state = state!.withSelectedPost(postId);
      _saveDraft(); // Auto-save as draft
    }
  }

  /// Moves to the next step
  void nextStep() {
    if (state != null && state!.canProceedToNextStep) {
      state = state!.nextStep();
      _saveDraft(); // Auto-save as draft
    }
  }

  /// Moves to the previous step
  void previousStep() {
    if (state != null) {
      state = state!.previousStep();
      _saveDraft(); // Auto-save as draft
    }
  }

  /// Updates automation configuration for a specific key
  void updateConfiguration(String key, dynamic value) {
    if (state != null) {
      final newConfig = Map<String, dynamic>.from(state!.configuration);
      newConfig[key] = value;
      state = state!.copyWith(configuration: newConfig);
      _saveDraft(); // Auto-save as draft
    }
  }

  /// Updates keyword trigger settings
  void updateKeywordSettings({
    bool? anyKeyword,
    List<String>? triggerKeywords,
  }) {
    if (state != null) {
      state = state!.copyWith(
        anyKeyword: anyKeyword,
        triggerKeywords: triggerKeywords,
      );
      _saveDraft(); // Auto-save as draft
    }
  }

  /// Adds a trigger keyword (max 3 allowed, case-sensitive, no exact duplicates)
  void addTriggerKeyword(String keyword) {
    if (state != null &&
        state!.triggerKeywords.length < 3 &&
        !state!.triggerKeywords.contains(keyword)) {
      final newKeywords = List<String>.from(state!.triggerKeywords);
      newKeywords.add(keyword);
      state = state!.copyWith(triggerKeywords: newKeywords);
      _saveDraft(); // Auto-save as draft
    }
  }

  /// Removes a trigger keyword
  void removeTriggerKeyword(String keyword) {
    if (state != null) {
      final newKeywords = List<String>.from(state!.triggerKeywords);
      newKeywords.remove(keyword);
      state = state!.copyWith(triggerKeywords: newKeywords);
      _saveDraft(); // Auto-save as draft
    }
  }

  /// Updates DM message data
  void updateDMMessage({String? message, List<DMButton>? buttons}) {
    if (state != null) {
      state = state!.copyWith(dmMessage: message, dmButtons: buttons);
      _saveDraft(); // Auto-save as draft
    }
  }

  /// Adds a DM button (max 3 allowed)
  void addDMButton(DMButton button) {
    if (state != null && state!.dmButtons.length < 3) {
      final newButtons = List<DMButton>.from(state!.dmButtons);
      newButtons.add(button);
      state = state!.copyWith(dmButtons: newButtons);
      _saveDraft(); // Auto-save as draft
    }
  }

  /// Updates a DM button at specific index
  void updateDMButton(int index, DMButton button) {
    if (state != null && index >= 0 && index < state!.dmButtons.length) {
      final newButtons = List<DMButton>.from(state!.dmButtons);
      newButtons[index] = button;
      state = state!.copyWith(dmButtons: newButtons);
      _saveDraft(); // Auto-save as draft
    }
  }

  /// Removes a DM button
  void removeDMButton(int index) {
    if (state != null && index >= 0 && index < state!.dmButtons.length) {
      final newButtons = List<DMButton>.from(state!.dmButtons);
      newButtons.removeAt(index);
      state = state!.copyWith(dmButtons: newButtons);
      _saveDraft(); // Auto-save as draft
    }
  }

  /// Updates opening message data
  void updateOpeningMessage({String? message, String? buttonText}) {
    if (state != null) {
      state = state!.copyWith(
        openingMessage: message,
        openingButtonText: buttonText,
      );
      _saveDraft(); // Auto-save as draft
    }
  }

  /// Saves the current automation as a draft
  Future<void> _saveDraft() async {
    if (state != null) {
      try {
        final repository = ref.read(automationRepositoryProvider);
        await repository.saveDraft(state!);
      } catch (e) {
        // Log error but don't interrupt the flow
        print('Warning: Failed to save draft: $e');
      }
    }
  }

  /// Saves the automation and completes the flow
  Future<void> saveAutomation() async {
    if (state != null) {
      try {
        final repository = ref.read(automationRepositoryProvider);
        final finalAutomation = state!.withStatus(AutomationStatus.active);
        await repository.saveAutomation(finalAutomation);
        state = null; // Clear current automation
      } catch (error) {
        throw StorageException.saveFailed();
      }
    }
  }

  /// Clears the current automation (cancels the flow)
  void clearCurrentAutomation() {
    state = null;
  }

  /// Loads a draft automation by ID
  Future<void> loadDraft(String automationId) async {
    try {
      final repository = ref.read(automationRepositoryProvider);
      final automation = await repository.getAutomationById(automationId);
      if (automation != null) {
        state = automation;
      }
    } catch (error) {
      throw StorageException.loadFailed();
    }
  }
}

/// Provider for current automation flow state
final currentAutomationProvider =
    NotifierProvider<CurrentAutomationNotifier, Automation?>(
      CurrentAutomationNotifier.new,
    );

// =============================================================================
// UI STATE PROVIDERS
// =============================================================================

/// Provider for selected post ID in the automation flow
class SelectedPostIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;
}

final selectedPostIdProvider =
    NotifierProvider<SelectedPostIdNotifier, String?>(
      SelectedPostIdNotifier.new,
    );

/// Provider for automation flow loading state
class AutomationFlowLoadingNotifier extends Notifier<bool> {
  @override
  bool build() => false;
}

final automationFlowLoadingProvider =
    NotifierProvider<AutomationFlowLoadingNotifier, bool>(
      AutomationFlowLoadingNotifier.new,
    );

/// Provider for automation flow error state
class AutomationFlowErrorNotifier extends Notifier<String?> {
  @override
  String? build() => null;
}

final automationFlowErrorProvider =
    NotifierProvider<AutomationFlowErrorNotifier, String?>(
      AutomationFlowErrorNotifier.new,
    );

// =============================================================================
// COMPUTED PROVIDERS
// =============================================================================

/// Provider that computes if the current step can proceed
final canProceedToNextStepProvider = Provider<bool>((ref) {
  final currentAutomation = ref.watch(currentAutomationProvider);
  return currentAutomation?.canProceedToNextStep ?? false;
});

/// Provider that computes the current step progress percentage
final currentStepProgressProvider = Provider<double>((ref) {
  final currentAutomation = ref.watch(currentAutomationProvider);
  return currentAutomation?.progressPercentage ?? 0.0;
});

/// Provider that computes the current step number (1-based)
final currentStepNumberProvider = Provider<int>((ref) {
  final currentAutomation = ref.watch(currentAutomationProvider);
  return (currentAutomation?.currentStep ?? 0) + 1;
});

/// Provider that computes the selected post details
final selectedPostProvider = Provider<InstagramPost?>((ref) {
  final currentAutomation = ref.watch(currentAutomationProvider);
  final instagramPosts = ref.watch(instagramPostsProvider);

  if (currentAutomation?.selectedPostId == null) return null;

  return instagramPosts.whenOrNull(
    data: (posts) => posts.cast<InstagramPost?>().firstWhere(
      (post) => post?.id == currentAutomation!.selectedPostId,
      orElse: () => null,
    ),
  );
});

// =============================================================================
// UTILITY PROVIDERS
// =============================================================================

/// Provider for handling automation operations with error handling
final automationOperationsProvider = Provider<AutomationOperations>((ref) {
  return AutomationOperations(ref);
});

/// Class that encapsulates automation operations with proper error handling
class AutomationOperations {
  final Ref _ref;

  AutomationOperations(this._ref);

  /// Creates a new automation with validation
  Future<void> createAutomation(String name, {String? description}) async {
    if (name.trim().isEmpty) {
      throw ValidationException.fieldRequired('name');
    }

    if (name.length > 100) {
      throw ValidationException.fieldTooLong('name', 100);
    }

    final automationNotifier = _ref.read(automationProvider.notifier);
    await automationNotifier.createAutomation(
      name.trim(),
      description: description?.trim(),
    );
  }

  /// Starts a new automation flow with validation
  Future<void> startAutomationFlow(String name, {String? description}) async {
    if (name.trim().isEmpty) {
      throw ValidationException.fieldRequired('name');
    }

    final currentAutomationNotifier = _ref.read(
      currentAutomationProvider.notifier,
    );
    currentAutomationNotifier.startNewAutomation(
      name.trim(),
      description: description?.trim(),
    );
  }

  /// Selects a post with validation
  Future<void> selectPost(String postId) async {
    if (postId.trim().isEmpty) {
      throw ValidationException.invalidSelection();
    }

    final currentAutomationNotifier = _ref.read(
      currentAutomationProvider.notifier,
    );
    currentAutomationNotifier.selectPost(postId);
  }
}
