import 'dart:async';
import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

/// Detects when the app is opened via the Android share sheet with a
/// text/URL payload, filters to Instagram links only, and exposes a
/// broadcast stream that the UI can subscribe to.
///
/// Valid Instagram URL  → emits the URL string
/// Non-Instagram share  → emits empty string (sentinel for invalid-link snackbar)
class ShareIntentService {
  ShareIntentService._();
  static final ShareIntentService instance = ShareIntentService._();

  final _controller = StreamController<String>.broadcast();

  /// Stream of validated Instagram URLs (or '' for invalid shares).
  Stream<String> get instagramShareStream => _controller.stream;

  StreamSubscription<List<SharedMediaFile>>? _mediaSub;

  /// Call once from main() after WidgetsFlutterBinding.ensureInitialized().
  void initialize() {
    // ── Cold start: app was launched via the share sheet ─────────────────
    ReceiveSharingIntent.instance.getInitialMedia().then(
      (List<SharedMediaFile> files) {
        if (files.isNotEmpty) _handleSharedFiles(files);
      },
    );

    // ── Warm start: app is already running, new share arrives ────────────
    _mediaSub = ReceiveSharingIntent.instance.getMediaStream().listen(
      (List<SharedMediaFile> files) {
        if (files.isNotEmpty) _handleSharedFiles(files);
      },
      onError: (err) =>
          debugPrint('[ShareIntentService] stream error: $err'),
    );
  }

  void _handleSharedFiles(List<SharedMediaFile> files) {
    // Instagram shares its post URLs as a text/url SharedMediaFile.
    // The path field carries the actual URL text.
    final text = files
        .map((f) => f.path.trim())
        .firstWhere((p) => p.isNotEmpty, orElse: () => '');

    if (_isInstagramUrl(text)) {
      _controller.add(text);
    } else {
      _controller.add(''); // sentinel → show "invalid link" snackbar
    }

    // Consume so it doesn't re-fire on hot restart / resume.
    ReceiveSharingIntent.instance.reset();
  }

  /// Returns true for instagram.com and instagr.am URLs.
  bool _isInstagramUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final host = uri.host.toLowerCase();
      return host == 'instagram.com' ||
          host.endsWith('.instagram.com') ||
          host == 'instagr.am' ||
          host.endsWith('.instagr.am');
    } catch (_) {
      return false;
    }
  }

  void dispose() {
    _mediaSub?.cancel();
    _controller.close();
  }
}
