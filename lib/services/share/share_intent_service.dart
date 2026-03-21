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
    if (files.isEmpty) {
      ReceiveSharingIntent.instance.reset();
      return;
    }

    final text = files
        .map((f) => f.path.trim())
        .firstWhere((p) => p.isNotEmpty, orElse: () => '');

    if (text.isEmpty) {
      ReceiveSharingIntent.instance.reset();
      return;
    }

    // Only handle web URLs (http/https). Silently ignore our own deep-link
    // scheme (qubikoai://) which leaks in when the OAuth browser redirects
    // back to the app — we don't want that to trigger the "invalid link" toast.
    Uri? uri;
    try {
      uri = Uri.parse(text);
    } catch (_) {}

    final scheme = uri?.scheme.toLowerCase() ?? '';
    if (scheme != 'http' && scheme != 'https') {
      ReceiveSharingIntent.instance.reset();
      return;
    }

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
