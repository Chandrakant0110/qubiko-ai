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
class InstagramPostsNotifier extends StateNotifier<AsyncValue<List<InstagramPost>>> {
  final InstagramService _instagramService;

  InstagramPostsNotifier(this._instagramService) : super(const AsyncValue.loading());

  /// Fetches Instagram posts from the API
  Future<void> fetchPosts() async {
    state = const AsyncValue.loading();
    
    try {
      final posts = await _instagramService.fetchPosts();
      state = AsyncValue.data(posts);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refreshes the posts data
  Future<void> refresh() => fetchPosts();

  /// Gets a specific post by ID
  InstagramPost? getPostById(String postId) {
    return state.whenOrNull(
      data: (posts) => posts.cast<InstagramPost?>().firstWhere(
        (post) => post?.id == postId,
        orElse: () => null,
      ),
    );
  }
}

/// Provider for Instagram posts state
final instagramPostsProvider = StateNotifierProvider<InstagramPostsNotifier, AsyncValue<List<InstagramPost>>>((ref) {
  final instagramService = ref.watch(instagramServiceProvider);
  return InstagramPostsNotifier(instagramService);
});

/// State notifier for managing automations
/// This handles CRUD operations and state management for automations
class AutomationNotifier extends StateNotifier<AsyncValue<List<Automation>>> {
  final AutomationRepository _repository;

  AutomationNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadAutomations();
  }

  /// Loads all automations from the repository
  Future<void> _loadAutomations() async {
    try {
      final automations = await _repository.getAllAutomations();
      state = AsyncValue.data(automations);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Creates a new automation
  Future<void> createAutomation(String name, {String? description}) async {
    try {
      final automation = Automation.create(name: name, description: description);
      await _repository.saveAutomation(automation);
      await _loadAutomations(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Updates an existing automation
  Future<void> updateAutomation(Automation automation) async {
    try {
      await _repository.updateAutomation(automation);
      await _loadAutomations(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Deletes an automation
  Future<void> deleteAutomation(String automationId) async {
    try {
      await _repository.deleteAutomation(automationId);
      await _loadAutomations(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Gets a specific automation by ID
  Automation? getAutomationById(String automationId) {
    return state.whenOrNull(
      data: (automations) => automations.cast<Automation?>().firstWhere(
        (automation) => automation?.id == automationId,
        orElse: () => null,
      ),
    );
  }

  /// Refreshes the automations list
  Future<void> refresh() => _loadAutomations();
}

/// Provider for automations state
final automationProvider = StateNotifierProvider<AutomationNotifier, AsyncValue<List<Automation>>>((ref) {
  final repository = ref.watch(automationRepositoryProvider);
  return AutomationNotifier(repository);
});

// =============================================================================
// CURRENT AUTOMATION FLOW PROVIDERS
// =============================================================================

/// State notifier for managing the current automation flow
/// This tracks the current automation being created/edited and its progress
class CurrentAutomationNotifier extends StateNotifier<Automation?> {
  final AutomationRepository _repository;

  CurrentAutomationNotifier(this._repository) : super(null);

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

  /// Saves the current automation as a draft
  Future<void> _saveDraft() async {
    if (state != null) {
      try {
        await _repository.saveDraft(state!);
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
        final finalAutomation = state!.withStatus(AutomationStatus.active);
        await _repository.saveAutomation(finalAutomation);
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
      final automation = await _repository.getAutomationById(automationId);
      if (automation != null) {
        state = automation;
      }
    } catch (error) {
      throw StorageException.loadFailed();
    }
  }
}

/// Provider for current automation flow state
final currentAutomationProvider = StateNotifierProvider<CurrentAutomationNotifier, Automation?>((ref) {
  final repository = ref.watch(automationRepositoryProvider);
  return CurrentAutomationNotifier(repository);
});

// =============================================================================
// UI STATE PROVIDERS
// =============================================================================

/// Provider for selected post ID in the automation flow
final selectedPostIdProvider = StateProvider<String?>((ref) => null);

/// Provider for automation flow loading state
final automationFlowLoadingProvider = StateProvider<bool>((ref) => false);

/// Provider for automation flow error state
final automationFlowErrorProvider = StateProvider<String?>((ref) => null);

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
  final ProviderRef _ref;

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
    await automationNotifier.createAutomation(name.trim(), description: description?.trim());
  }

  /// Starts a new automation flow with validation
  Future<void> startAutomationFlow(String name, {String? description}) async {
    if (name.trim().isEmpty) {
      throw ValidationException.fieldRequired('name');
    }

    final currentAutomationNotifier = _ref.read(currentAutomationProvider.notifier);
    currentAutomationNotifier.startNewAutomation(name.trim(), description: description?.trim());
  }

  /// Selects a post with validation
  Future<void> selectPost(String postId) async {
    if (postId.trim().isEmpty) {
      throw ValidationException.invalidSelection();
    }

    final currentAutomationNotifier = _ref.read(currentAutomationProvider.notifier);
    currentAutomationNotifier.selectPost(postId);
  }
}