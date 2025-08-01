import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/automation.dart';
import '../constants/api_constants.dart';
import '../services/exceptions/app_exceptions.dart';

/// Repository interface for automation data operations
/// This abstraction allows for different storage implementations
abstract class AutomationRepository {
  /// Retrieves all saved automations
  Future<List<Automation>> getAllAutomations();

  /// Saves an automation
  Future<void> saveAutomation(Automation automation);

  /// Updates an existing automation
  Future<void> updateAutomation(Automation automation);

  /// Deletes an automation by ID
  Future<void> deleteAutomation(String automationId);

  /// Retrieves a specific automation by ID
  Future<Automation?> getAutomationById(String automationId);

  /// Saves a draft automation (temporary storage)
  Future<void> saveDraft(Automation automation);

  /// Retrieves all draft automations
  Future<List<Automation>> getDrafts();

  /// Clears all draft automations
  Future<void> clearDrafts();
}

/// Local storage implementation of AutomationRepository using SharedPreferences
/// This provides persistent storage for automations on the device
class LocalAutomationRepository implements AutomationRepository {
  late final SharedPreferences _prefs;
  bool _initialized = false;

  /// Initializes the repository by loading SharedPreferences
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    }
  }

  @override
  Future<List<Automation>> getAllAutomations() async {
    try {
      await _ensureInitialized();
      
      final automationsJson = _prefs.getStringList(AutomationConstants.automationsStorageKey);
      if (automationsJson == null || automationsJson.isEmpty) {
        return [];
      }

      final automations = <Automation>[];
      for (final jsonString in automationsJson) {
        try {
          final jsonData = json.decode(jsonString) as Map<String, dynamic>;
          final automation = Automation.fromJson(jsonData);
          automations.add(automation);
        } catch (e) {
          // Log parsing error but continue with other automations
          print('Warning: Failed to parse automation: $e');
        }
      }

      // Sort by creation date (newest first)
      automations.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return automations;
    } catch (e) {
      throw StorageException.loadFailed();
    }
  }

  @override
  Future<void> saveAutomation(Automation automation) async {
    try {
      await _ensureInitialized();
      
      final automations = await getAllAutomations();
      
      // Check if automation already exists and update it
      final existingIndex = automations.indexWhere((a) => a.id == automation.id);
      if (existingIndex != -1) {
        automations[existingIndex] = automation;
      } else {
        automations.add(automation);
      }

      await _saveAutomationsList(automations);
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException.saveFailed();
    }
  }

  @override
  Future<void> updateAutomation(Automation automation) async {
    try {
      await _ensureInitialized();
      
      final automations = await getAllAutomations();
      final index = automations.indexWhere((a) => a.id == automation.id);
      
      if (index == -1) {
        throw StorageException(
          'Automation with ID ${automation.id} not found.',
          code: 'AUTOMATION_NOT_FOUND',
        );
      }

      automations[index] = automation.copyWith(updatedAt: DateTime.now());
      await _saveAutomationsList(automations);
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException.saveFailed();
    }
  }

  @override
  Future<void> deleteAutomation(String automationId) async {
    try {
      await _ensureInitialized();
      
      final automations = await getAllAutomations();
      automations.removeWhere((a) => a.id == automationId);
      
      await _saveAutomationsList(automations);
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException.saveFailed();
    }
  }

  @override
  Future<Automation?> getAutomationById(String automationId) async {
    try {
      final automations = await getAllAutomations();
      try {
        return automations.firstWhere((a) => a.id == automationId);
      } catch (e) {
        return null; // Not found
      }
    } catch (e) {
      throw StorageException.loadFailed();
    }
  }

  @override
  Future<void> saveDraft(Automation automation) async {
    try {
      await _ensureInitialized();
      
      final drafts = await getDrafts();
      
      // Remove existing draft with same ID if present
      drafts.removeWhere((d) => d.id == automation.id);
      drafts.add(automation);

      final draftsJson = drafts.map((d) => json.encode(d.toJson())).toList();
      await _prefs.setStringList(AutomationConstants.draftsStorageKey, draftsJson);
    } catch (e) {
      throw StorageException.saveFailed();
    }
  }

  @override
  Future<List<Automation>> getDrafts() async {
    try {
      await _ensureInitialized();
      
      final draftsJson = _prefs.getStringList(AutomationConstants.draftsStorageKey);
      if (draftsJson == null || draftsJson.isEmpty) {
        return [];
      }

      final drafts = <Automation>[];
      for (final jsonString in draftsJson) {
        try {
          final jsonData = json.decode(jsonString) as Map<String, dynamic>;
          final draft = Automation.fromJson(jsonData);
          drafts.add(draft);
        } catch (e) {
          print('Warning: Failed to parse draft: $e');
        }
      }

      return drafts;
    } catch (e) {
      throw StorageException.loadFailed();
    }
  }

  @override
  Future<void> clearDrafts() async {
    try {
      await _ensureInitialized();
      await _prefs.remove(AutomationConstants.draftsStorageKey);
    } catch (e) {
      throw StorageException.saveFailed();
    }
  }

  /// Helper method to save the automations list to storage
  Future<void> _saveAutomationsList(List<Automation> automations) async {
    final automationsJson = automations.map((a) => json.encode(a.toJson())).toList();
    final success = await _prefs.setStringList(
      AutomationConstants.automationsStorageKey, 
      automationsJson,
    );
    
    if (!success) {
      throw StorageException.saveFailed();
    }
  }
}

/// In-memory implementation for testing purposes
/// This provides a simple way to test repository operations without persistence
class InMemoryAutomationRepository implements AutomationRepository {
  final List<Automation> _automations = [];
  final List<Automation> _drafts = [];

  @override
  Future<List<Automation>> getAllAutomations() async {
    return List.from(_automations)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> saveAutomation(Automation automation) async {
    final index = _automations.indexWhere((a) => a.id == automation.id);
    if (index != -1) {
      _automations[index] = automation;
    } else {
      _automations.add(automation);
    }
  }

  @override
  Future<void> updateAutomation(Automation automation) async {
    final index = _automations.indexWhere((a) => a.id == automation.id);
    if (index == -1) {
      throw StorageException(
        'Automation with ID ${automation.id} not found.',
        code: 'AUTOMATION_NOT_FOUND',
      );
    }
    _automations[index] = automation.copyWith(updatedAt: DateTime.now());
  }

  @override
  Future<void> deleteAutomation(String automationId) async {
    _automations.removeWhere((a) => a.id == automationId);
  }

  @override
  Future<Automation?> getAutomationById(String automationId) async {
    try {
      return _automations.firstWhere((a) => a.id == automationId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveDraft(Automation automation) async {
    _drafts.removeWhere((d) => d.id == automation.id);
    _drafts.add(automation);
  }

  @override
  Future<List<Automation>> getDrafts() async {
    return List.from(_drafts);
  }

  @override
  Future<void> clearDrafts() async {
    _drafts.clear();
  }
}