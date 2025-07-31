import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';
import '../constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../main.dart' show themeNotifier;
import 'dart:convert'; // Added for json
import 'package:http/http.dart' as http; // Added for http

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  String? _primaryToken;
  String? _expiresAt;
  bool _isConnected = false;
  StreamSubscription? _linkSubscription;
  final AppLinks _appLinks = AppLinks();

  // Add these:
  Map<String, dynamic>? _profileData;
  bool _loadingProfile = false;
  String? _profileError;

  @override
  void initState() {
    super.initState();
    _loadTokenData();
    _initAppLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initAppLinks() async {
    try {
      // Handle initial link if app was launched from a link
      final initialLink = await _appLinks.getInitialAppLink();
      if (initialLink != null) {
        _handleCallback(initialLink.toString());
      }

      // Handle links when app is already running
      _linkSubscription = _appLinks.uriLinkStream.listen((Uri? uri) {
        if (uri != null) {
          _handleCallback(uri.toString());
        }
      }, onError: (err) {
        print('Error handling deep link: $err');
      });
    } catch (e) {
      print('Error initializing app_links: $e');
    }
  }

  Future<void> _loadTokenData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('primary_token');
    final expiresAt = prefs.getString('expires_at');

    setState(() {
      _primaryToken = token;
      _expiresAt = expiresAt;
      _isConnected = token != null && expiresAt != null;
    });
    if (token != null) {
      _fetchProfile();
    }
  }

  Future<void> _saveTokenData(String token, int expiresIn) async {
    final prefs = await SharedPreferences.getInstance();
    final expiresAt = DateTime.now().add(Duration(seconds: expiresIn));

    await prefs.setString('primary_token', token);
    await prefs.setString('expires_at', expiresAt.toIso8601String());

    setState(() {
      _primaryToken = token;
      _expiresAt = expiresAt.toIso8601String();
      _isConnected = true;
    });

    _showToast('Instagram connected successfully!');
    HapticFeedback.mediumImpact();

    // Fetch profile after saving token
    _fetchProfile();
  }

  // --- Add this function ---
  Future<void> _fetchProfile() async {
    if (_primaryToken == null || _primaryToken!.isEmpty) return;
    setState(() {
      _loadingProfile = true;
      _profileError = null;
    });
    final url = Uri.parse(
      'https://graph.instagram.com/v23.0/me?fields=id,username,account_type,media_count,profile_picture_url,biography,website,name,followers_count,follows_count&access_token=$_primaryToken',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _profileData = json.decode(response.body);
          _loadingProfile = false;
        });
      } else {
        setState(() {
          _profileError = 'Failed to fetch profile: ${response.body}';
          _loadingProfile = false;
        });
      }
    } catch (e) {
      setState(() {
        _profileError = 'Error: $e';
        _loadingProfile = false;
      });
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
    
  }

  Future<void> _connectInstagram() async {
    const url = 'https://www.instagram.com/oauth/authorize?force_reauth=true&client_id=2935772819942060&redirect_uri=https://chandrakant-s4-n8n-duplicate.hf.space/webhook/instagram-login&response_type=code&scope=instagram_business_basic%2Cinstagram_business_manage_messages%2Cinstagram_business_manage_comments%2Cinstagram_business_content_publish%2Cinstagram_business_manage_insights';

    try {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      if (await canLaunchUrl(Uri.parse(url))) {
        _showToast('Opening Instagram authorization...');
      } else {
        _showToast('Could not open Instagram authorization');
      }
    } catch (e) {
      _showToast('Error opening Instagram authorization');
    }
  }

  Future<void> _handleCallback(String callbackUrl) async {
    try {
      print('Received callback: $callbackUrl');
      final uri = Uri.parse(callbackUrl);

      // Check if this is our custom scheme
      if (uri.scheme == 'qubikoai') {
        final token = uri.queryParameters['access_token'];
        final expiresIn = uri.queryParameters['expires_in'];

        if (token != null && expiresIn != null) {
          await _saveTokenData(token, int.parse(expiresIn));
          _showToast('Instagram OAuth successful! Token saved.');
        } else {
          _showToast('Invalid callback parameters');
        }
      }
    } catch (e) {
      print('Error processing callback: $e');
      _showToast('Error processing callback');
    }
  }

  // --- Add this widget for profile display ---
  Widget _buildProfileSection() {
    if (_loadingProfile) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_profileError != null) {
      return Text(_profileError!, style: const TextStyle(color: Colors.red));
    }
    if (_profileData == null) {
      return const SizedBox.shrink();
    }
    final profile = _profileData!;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: profile["profile_picture_url"] != null
                  ? NetworkImage(profile["profile_picture_url"])
                  : null,
              child: profile["profile_picture_url"] == null
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(profile["username"] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text(profile["account_type"] ?? ''),
                  if (profile["biography"] != null)
                    Text(profile["biography"], maxLines: 2, overflow: TextOverflow.ellipsis),
                  if (profile["website"] != null)
                    Text(profile["website"], style: const TextStyle(color: Colors.blue)),
                  Row(
                    children: [
                      Text('Posts: ${profile["media_count"] ?? 0}'),
                      const SizedBox(width: 8),
                      Text('Followers: ${profile["followers_count"] ?? 0}'),
                      const SizedBox(width: 8),
                      Text('Following: ${profile["follows_count"] ?? 0}'),
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

  Widget _buildConnectionStatus() {
    if (_isConnected) {
      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 24),
                SizedBox(width: 8),
                Text(
                  'Instagram Connected',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Token: ${_primaryToken?.substring(0, 20)}...',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            if (_expiresAt != null) ...[
              SizedBox(height: 4),
              Text(
                'Expires: ${DateTime.parse(_expiresAt!).toString().substring(0, 19)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.orange, size: 24),
                SizedBox(width: 8),
                Text(
                  'Instagram Not Connected',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Connect your Instagram account to access advanced features',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

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
              'Qubiko AI',
              style: GoogleFonts.urbanist(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          // Theme switcher button
          IconButton(
            icon: ValueListenableBuilder<ThemeMode>(
                valueListenable: themeNotifier,
                builder: (_, ThemeMode currentMode, __) {
                  return Icon(
                    currentMode == ThemeMode.dark
                        ? Icons.light_mode
                        : Icons.dark_mode,
                  );
                }),
            onPressed: () {
              final currentTheme = themeNotifier.value;
              themeNotifier.value = currentTheme == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark;
            },
            tooltip: 'Toggle theme',
          ),
          // User profile/menu
          IconButton(
            icon: user?.photoURL != null
                ? CircleAvatar(
                    backgroundImage: NetworkImage(user!.photoURL!),
                    radius: 14,
                  )
                : const Icon(Icons.account_circle),
            onPressed: () {
              // Handle user profile menu
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildConnectionStatus(),
            if (_isConnected) _buildProfileSection(), // <-- Add this line
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _connectInstagram,
              icon: Icon(Icons.link),
              label: Text(
                _isConnected ? 'Reconnect Instagram' : 'Connect Instagram',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor: _isConnected ? Colors.orange : Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 24),
            if (_isConnected) ...[
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connection Details:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Status: Connected'),
                    Text('Token Type: Bearer'),
                    if (_expiresAt != null)
                      Text('Expires: ${DateTime.parse(_expiresAt!).toString().substring(0, 19)}'),
                  ],
                ),
              ),
            ],
            // Test button for development
            SizedBox(height: 24),
            if (!_isConnected) ...[
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Development Test:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Click the button below to simulate OAuth callback'),
                    SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        // Simulate OAuth callback
                        final testCallback = 'qubikoai://callback?token_type=bearer&expires_in=5184000&access_token=test_token_123456789';
                        _handleCallback(testCallback);
                      },
                      child: Text('Test OAuth Callback'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 