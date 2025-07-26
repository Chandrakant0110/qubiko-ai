import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../main.dart' show themeNotifier;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _tokenController = TextEditingController();
  String? _token;
  Map<String, dynamic>? _profileData;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('instagram_token');
      if (_token != null) {
        _tokenController.text = _token!;
        _fetchProfile();
      }
    });
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('instagram_token', token);
    setState(() {
      _token = token;
      _profileData = null;
      _error = null;
    });
    _fetchProfile();
  }

  Future<void> _deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('instagram_token');
    setState(() {
      _token = null;
      _profileData = null;
      _error = null;
      _tokenController.clear();
    });
  }

  Future<void> _fetchProfile() async {
    if (_token == null || _token!.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final url = Uri.parse(
      'https://graph.instagram.com/v23.0/me?fields=id,username,account_type,media_count,profile_picture_url,biography,website,name,followers_count,follows_count&access_token=$_token',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _profileData = json.decode(response.body);
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to fetch profile: '+response.body;
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: '+e.toString();
        _loading = false;
      });
    }
  }

  void _showTokenDialog({bool isEdit = false}) {
    showDialog(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController(text: isEdit ? _token : '');
        return AlertDialog(
          title: Text(isEdit ? 'Edit Instagram Token' : 'Add Instagram Token'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter token'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _saveToken(controller.text.trim());
              },
              child: const Text('Save'),
            ),
            if (isEdit && _token != null)
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _deleteToken();
                },
                child: const Text('Delete'),
              ),
          ],
        );
      },
    );
  }

  void _showUserProfileMenu(BuildContext context, user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primaryLightBlue.withOpacity(0.2),
                backgroundImage:
                    user?.photoURL != null ? NetworkImage(user.photoURL) : null,
                child: user?.photoURL == null
                    ? const Icon(Icons.person,
                        size: 40, color: AppColors.primaryLightBlue)
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                user?.displayName ?? user?.email ?? 'User',
                style: GoogleFonts.urbanist(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (user?.email != null) ...[
                const SizedBox(height: 4),
                Text(
                  user!.email!,
                  style: GoogleFonts.urbanist(
                    color: Colors.grey,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.vpn_key),
                title: const Text('Add Token'),
                onTap: () {
                  Navigator.pop(context);
                  _showTokenDialog(isEdit: false);
                },
              ),
              if (_token != null)
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit Token'),
                  onTap: () {
                    Navigator.pop(context);
                    _showTokenDialog(isEdit: true);
                  },
                ),
              if (_token != null)
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Delete Token'),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteToken();
                  },
                ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text(
                  'Sign Out',
                  style: GoogleFonts.urbanist(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(authProvider.notifier).signOut();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/auth',
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_token == null || _token!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Add your Instagram Token:'),
            const SizedBox(height: 16),
            TextField(
              controller: _tokenController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter token',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final token = _tokenController.text.trim();
                if (token.isNotEmpty) {
                  _saveToken(token);
                }
              },
              child: const Text('Save'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      );
    }
    if (_profileData != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_profileData!["profile_picture_url"] != null)
              Center(
                child: CircleAvatar(
                  backgroundImage: NetworkImage(_profileData!["profile_picture_url"]),
                  radius: 48,
                ),
              ),
            const SizedBox(height: 16),
            Text('Name: '+(_profileData!["name"] ?? "") ),
            Text('Username: '+(_profileData!["username"] ?? "") ),
            Text('Account Type: '+(_profileData!["account_type"] ?? "") ),
            Text('Media Count: '+(_profileData!["media_count"]?.toString() ?? "") ),
            Text('Followers: '+(_profileData!["followers_count"]?.toString() ?? "") ),
            Text('Follows: '+(_profileData!["follows_count"]?.toString() ?? "") ),
            if (_profileData!["biography"] != null) ...[
              const SizedBox(height: 8),
              Text('Bio: '+_profileData!["biography"]),
            ],
            if (_profileData!["website"] != null) ...[
              const SizedBox(height: 8),
              Text('Website: '+_profileData!["website"]),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchProfile,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }
    return const Center(child: Text('No profile data.'));
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
          IconButton(
            icon: user?.photoURL != null
                ? CircleAvatar(
                    backgroundImage: NetworkImage(user!.photoURL!),
                    radius: 14,
                  )
                : const Icon(Icons.account_circle),
            onPressed: () {
              _showUserProfileMenu(context, user);
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
} 