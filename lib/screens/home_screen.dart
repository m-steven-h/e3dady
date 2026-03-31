// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/home_widgets.dart';
import '../services/auth_service.dart';
import '../providers/user_provider.dart';
import 'auth/login_screen.dart';
import 'account/account_screen.dart';
import 'prayer/prayer_screen.dart';
import 'settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoggedIn = false;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final userName = prefs.getString('userName') ?? '';

    setState(() {
      _isLoggedIn = isLoggedIn;
      _userName = userName;
    });

    if (isLoggedIn) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      try {
        final user = await authService.getCurrentUser();
        userProvider.setUser(user);
      } catch (e) {
        print('Error loading user: $e');
      }
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              HomeHeader(
                isLoggedIn: _isLoggedIn,
                userName: _userName,
                onLogout: _logout,
              ),

              const SizedBox(height: 20),

              // Main Content
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Welcome Message
                        if (_isLoggedIn) WelcomeCard(userName: _userName),

                        const SizedBox(height: 20),

                        // Main Buttons
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            childAspectRatio: 1.2,
                            children: [
                              HomeButton(
                                icon: Icons.access_time_filled,
                                title: 'ابدأ الصلاة',
                                color: const Color(0xFF4CAF50),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const PrayerScreen(),
                                    ),
                                  );
                                },
                              ),
                              HomeButton(
                                icon: Icons.settings,
                                title: 'الإعدادات',
                                color: const Color(0xFF2196F3),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SettingsScreen(),
                                    ),
                                  );
                                },
                              ),
                              if (_isLoggedIn)
                                HomeButton(
                                  icon: Icons.account_circle,
                                  title: 'الحساب',
                                  color: const Color(0xFFFF9800),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const AccountScreen(),
                                      ),
                                    );
                                  },
                                )
                              else
                                HomeButton(
                                  icon: Icons.login,
                                  title: 'تسجيل دخول',
                                  color: const Color(0xFF9C27B0),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen(),
                                      ),
                                    );
                                  },
                                ),
                              HomeButton(
                                icon: Icons.info_outline,
                                title: 'عن التطبيق',
                                color: const Color(0xFF607D8B),
                                onTap: () {
                                  _showAboutDialog();
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('عن التطبيق'),
        content: const Text(
          'خدمة إعدادي\n'
          'نظام متكامل لإدارة حضور وغياب طلاب المرحلة الإعدادية\n'
          'الإصدار 1.0.0',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}
