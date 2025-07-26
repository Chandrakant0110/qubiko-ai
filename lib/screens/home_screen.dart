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
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _tokenController = TextEditingController();
  String? _token;
  Map<String, dynamic>? _profileData;
  List<Map<String, dynamic>> _posts = [];
  bool _loading = false;
  bool _loadingPosts = false;
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
      _posts = [];
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

  Future<void> _fetchPosts() async {
    if (_token == null || _token!.isEmpty) return;
    setState(() {
      _loadingPosts = true;
    });
    final url = Uri.parse(
      'https://graph.instagram.com/v23.0/me/media?fields=id,caption,media_type,media_url,permalink,thumbnail_url,timestamp&access_token=$_token',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _posts = List<Map<String, dynamic>>.from(data['data'] ?? []);
          _loadingPosts = false;
        });
      } else {
        setState(() {
          _loadingPosts = false;
        });
      }
    } catch (e) {
      setState(() {
        _loadingPosts = false;
      });
    }
  }

  void _showTokenManagementDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController(text: _token);
        return AlertDialog(
          title: const Text('Token Management'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(hintText: 'Enter token'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _saveToken(controller.text.trim());
                    },
                    child: const Text('Save'),
                  ),
                  if (_token != null)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _deleteToken();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Delete'),
                    ),
                ],
              ),
            ],
          ),
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
                title: const Text('Token Management'),
                onTap: () {
                  Navigator.pop(context);
                  _showTokenManagementDialog();
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

  Widget _buildProfileRow() {
    final profile = _profileData!;
    return Row(
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatColumn('Posts', profile["media_count"]?.toString() ?? '0'),
              _buildStatColumn('Followers', profile["followers_count"]?.toString() ?? '0'),
              _buildStatColumn('Following', profile["follows_count"]?.toString() ?? '0'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildBio(String bio) {
    final regex = RegExp(r'@([A-Za-z0-9_\.]+)');
    final spans = <TextSpan>[];
    int start = 0;
    for (final match in regex.allMatches(bio)) {
      if (match.start > start) {
        spans.add(TextSpan(text: bio.substring(start, match.start)));
      }
      final mention = match.group(1)!;
      spans.add(
        TextSpan(
          text: '@$mention',
          style: const TextStyle(color: Colors.blue),
          recognizer: TapGestureRecognizer()
            ..onTap = () => launchUrl(Uri.parse('https://www.instagram.com/$mention')),
        ),
      );
      start = match.end;
    }
    if (start < bio.length) {
      spans.add(TextSpan(text: bio.substring(start)));
    }
    return RichText(text: TextSpan(style: const TextStyle(color: Colors.black), children: spans));
  }

  Widget _buildWebsite(String? website) {
    if (website == null || website.isEmpty) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () => launchUrl(Uri.parse(website)),
      child: Text(
        website,
        style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
      ),
    );
  }

  Widget _buildPostsGrid() {
    if (_loadingPosts) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_posts.isEmpty) {
      return const Center(child: Text('No posts found.'));
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 3/4,
      ),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];
        final isVideo = post["media_type"] == "VIDEO";
        final thumb = post["thumbnail_url"] ?? post["media_url"];
        return GestureDetector(
          onTap: () => launchUrl(Uri.parse(post["permalink"])),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(thumb, fit: BoxFit.cover),
              if (isVideo)
                const Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.videocam, color: Colors.white, size: 20),
                  ),
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
            _buildProfileRow(),
            const SizedBox(height: 16),
            Text(_profileData!["account_type"] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_profileData!["biography"] != null)
              _buildBio(_profileData!["biography"]),
            if (_profileData!["website"] != null) ...[
              const SizedBox(height: 8),
              _buildWebsite(_profileData!["website"]),
            ],
            const SizedBox(height: 16),
            if(_posts.isEmpty)
              ElevatedButton(
                onPressed: _fetchPosts,
                child: const Text('Fetch Posts'),
              ),
            const SizedBox(height: 16),
            _buildPostsGrid(),
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