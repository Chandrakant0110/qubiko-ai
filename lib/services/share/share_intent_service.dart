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
    // Silently ignore if no files were actually shared
    // (this prevents false positives when the app returns from background,
    // e.g. after the Instagram OAuth browser session closes)
    if (files.isEmpty) {
      ReceiveSharingIntent.instance.reset();
      return;
    }

    final text = files
        .map((f) => f.path.trim())
        .firstWhere((p) => p.isNotEmpty, orElse: () => '');

    // No real text content — could be a non-text share or a spurious trigger
    if (text.isEmpty) {
      ReceiveSharingIntent.instance.reset();
      return;
    }

    // Only show "invalid link" snackbar when user actually shared something
    // that is not an Instagram URL
    if (_isInstagramUrl(text)) {
      _controller.add(text);
    } else {
      _controller.add(''); // sentinel → "Please share a valid Instagram link"
    }

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
