import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  double _fontSize = 30.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final isDark = prefs.getBool('isDark') ?? true;
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      _fontSize = prefs.getDouble('fontSize') ?? 30.0;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', _themeMode == ThemeMode.dark);
    await prefs.setDouble('fontSize', _fontSize);
  }

  void toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
      _saveSettings();
    });
  }

  void updateFontSize(double newSize) {
    setState(() {
      _fontSize = newSize;
      _saveSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: PrepPage(
        toggleTheme: toggleTheme,
        themeMode: _themeMode,
        fontSize: _fontSize,
        updateFontSize: updateFontSize,
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();

    // Navigate to main app after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        // The main app will be shown automatically when _isLoading becomes false
        // This is handled by the parent widget
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade900,
              Colors.purple.shade900,
              Colors.deepPurple.shade900,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Logo
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          Colors.blue.shade200,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.church,
                      size: 80,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // App Name
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 1500),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 50 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: Column(
                        children: [
                          Text(
                            "",
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w300,
                              color: Colors.white70,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "اعدادي",
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 20,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 80),

              // Loading Indicator
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 800),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Column(
                      children: [
                        const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "جاري التحميل...",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PrepPage extends StatelessWidget {
  final VoidCallback toggleTheme;
  final ThemeMode themeMode;
  final double fontSize;
  final Function(double) updateFontSize;

  const PrepPage({
    super.key,
    required this.toggleTheme,
    required this.themeMode,
    required this.fontSize,
    required this.updateFontSize,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [Colors.black, const Color(0xFF1A1A1A)]
                : [Colors.white, const Color(0xFFF5F5F5)],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Removed the animated icon
                const SizedBox(height: 20),

                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 800),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 30 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: Column(
                          children: [
                            Text(
                              "خدمة",
                              style: TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.w300,
                                color: isDark ? Colors.white70 : Colors.black54,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "اعدادي",
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                                shadows: [
                                  Shadow(
                                    blurRadius: 20,
                                    color: isDark
                                        ? Colors.white24
                                        : Colors.blue.shade200,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 60),
                Column(
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 800),
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 50 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          PrayerPage(
                                        isDark: isDark,
                                        fontSize: fontSize,
                                        updateFontSize: updateFontSize,
                                      ),
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        const begin = Offset(1.0, 0.0);
                                        const end = Offset.zero;
                                        const curve = Curves.easeInOutCubic;
                                        var tween = Tween(
                                                begin: begin, end: end)
                                            .chain(CurveTween(curve: curve));
                                        return SlideTransition(
                                          position: animation.drive(tween),
                                          child: child,
                                        );
                                      },
                                      transitionDuration:
                                          const Duration(milliseconds: 500),
                                    ),
                                  );
                                },
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.play_arrow, size: 28),
                                    SizedBox(width: 12),
                                    Text(
                                      "ابدأ الصلاة",
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 800),
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 70 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: Container(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor:
                                      isDark ? Colors.white : Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  side: BorderSide(
                                    color: isDark
                                        ? Colors.white24
                                        : Colors.black26,
                                    width: 1.5,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          SettingsPage(
                                        isDark: isDark,
                                        fontSize: fontSize,
                                        toggleTheme: toggleTheme,
                                        updateFontSize: updateFontSize,
                                      ),
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        const begin = Offset(0.0, 1.0);
                                        const end = Offset.zero;
                                        const curve = Curves.easeInOutCubic;
                                        var tween = Tween(
                                                begin: begin, end: end)
                                            .chain(CurveTween(curve: curve));
                                        return SlideTransition(
                                          position: animation.drive(tween),
                                          child: child,
                                        );
                                      },
                                      transitionDuration:
                                          const Duration(milliseconds: 500),
                                    ),
                                  );
                                },
                                icon: Icon(
                                  Icons.settings_outlined,
                                  size: 26,
                                ),
                                label: const Text(
                                  "الإعدادات",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  final bool isDark;
  final double fontSize;
  final VoidCallback toggleTheme;
  final Function(double) updateFontSize;

  const SettingsPage({
    super.key,
    required this.isDark,
    required this.fontSize,
    required this.toggleTheme,
    required this.updateFontSize,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late double _currentFontSize;

  @override
  void initState() {
    super.initState();
    _currentFontSize = widget.fontSize;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: widget.isDark
                              ? Colors.grey[800]
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: widget.isDark ? Colors.white : Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "الإعدادات",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: widget.isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 50),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: widget.isDark
                              ? [Colors.grey[900]!, Colors.grey[850]!]
                              : [Colors.white, Colors.grey[50]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color:
                                widget.isDark ? Colors.white10 : Colors.black12,
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(25),
                          onTap: () {
                            widget.toggleTheme();
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: widget.isDark
                                        ? Colors.grey[800]
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Icon(
                                    widget.isDark
                                        ? Icons.dark_mode
                                        : Icons.light_mode,
                                    color: widget.isDark
                                        ? Colors.amber
                                        : Colors.blue,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "المظهر",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: widget.isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        widget.isDark
                                            ? "الوضع الليلي"
                                            : "الوضع النهاري",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: widget.isDark
                                              ? Colors.white70
                                              : Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: !widget.isDark,
                                  onChanged: (_) {
                                    widget.toggleTheme();
                                    Navigator.pop(context);
                                  },
                                  activeColor: Colors.blue,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: widget.isDark
                              ? [Colors.grey[900]!, Colors.grey[850]!]
                              : [Colors.white, Colors.grey[50]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color:
                                widget.isDark ? Colors.white10 : Colors.black12,
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: widget.isDark
                                        ? Colors.grey[800]
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Icon(
                                    Icons.text_fields,
                                    color: Colors.blue,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "حجم الخط",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: widget.isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "تحكم في حجم النص في الصلوات",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: widget.isDark
                                              ? Colors.white70
                                              : Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "${_currentFontSize.round()}px",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Slider(
                              value: _currentFontSize,
                              min: 20,
                              max: 50,
                              divisions: 30,
                              onChanged: (value) {
                                setState(() {
                                  _currentFontSize = value;
                                });
                                widget.updateFontSize(value);
                              },
                              activeColor: Colors.blue,
                              thumbColor: Colors.blue,
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: widget.isDark
                                    ? Colors.grey[800]
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.blue.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    "معاينة النص",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "هذا مثال لتغيير حجم الخط",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: _currentFontSize * 0.6,
                                      color: widget.isDark
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.w500,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PrayerPage extends StatefulWidget {
  final bool isDark;
  final double fontSize;
  final Function(double) updateFontSize;

  const PrayerPage({
    super.key,
    required this.isDark,
    required this.fontSize,
    required this.updateFontSize,
  });

  @override
  State<PrayerPage> createState() => _PrayerPageState();
}

class _PrayerPageState extends State<PrayerPage>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int currentIndex = 0;
  final FocusNode _focusNode = FocusNode();
  bool _showList = false;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, String>> prayers = [
    {
      'title': 'صلاة ربانية',
      'body':
          'بسم الآب والابن والروح القدس الإله الواحد آمین. كيريي إيليسون يَارَبُّ ارْحَمْ. يَارَبُّ ارْحَمْ. يَارَبُّ بارك. آمين. المجد للآب والابن والروح القدس الآن وكل أوان وإلى دهر الدهور. آمين. اللهم اجعلنا مستحقين أن نقول بشكر: أبانا الذي في السَّمَواتِ، ليتقدس اسمك. ليأتِ ملكوتك. لتكن مشيئتُكَ، كما في السماء كذلك على الأرْضِ خُبزنا الذي للغد اعطنا اليوم. واغفر لنا ذنوبنا كما نغفر نحن أيضًا للمذنبين إلينا. ولا تدخلنا في تجربة. لكن نجنا مِنْ الشرير بالمسيح يسوعُ ربنا، لأَنَّ لَكَ المُلك والقوة والمجد إلى الأبد. آمين.'
    },
    {
      'title': 'صلاة الشكر',
      'body':
          ' فلنشكر صانع الخيرات الرحوم الله، أبا ربنا وإلهنا ومخلصنا يسوع المسيح. لأنه سترنا وأعاننا، وحفظنا، وقبلنا إليه، وأشفق علينا، وعضدنا، وأتى بنا إلى هذه الساعة. هو أيضًا فلنسأله أن يحفظنا في هذا اليوم المقدس وكل أيام حياتنا بكل سلام، الضابط الكل الرب إلهنا. أيها السيد الرب الإله ضابط الكل أبو ربنا وإلهنا ومخلصنا يسوع المسيح، نشكرك على كل حال، ومن أجل كل حال، وفى كل حال، لأنك سترتنا وأعنتنا وحفظتنا وقبلتنا إليك، وأشفقت علينا وعضدتنا وأتيت بنا إلى هذه الساعة. من أجل هذا نسأل ونطلب من صلاحك يا محب البشر، امنحنا أن نكمل هذا اليوم المقدس وكل أيام حياتنا بكل سلام مع خوفك. كل حسد وكل تجربة وكل فعل الشيطان ومؤامرة الناس الأشرار، وقيام الأعداء الخفيين والظاهرين، انزعها عنا وعن سائر شعبك وعن موضعك المقدس هذا. أما الصالحات والنافعات فارزقنا إياها، لأنك أنت الذي أعطيتنا السلطان أن ندوس الحيات والعقارب وكل قوة العدو ولا تدخلنا في تجربة، لكن نجنا من الشرير. بالنعمة والرأفات ومحبة البشر، اللواتي لابنك الوحيد ربنا وإلهنا ومخلصنا يسوع المسيح. هذا الذي من قبله المجد والإكرام والعزة والسجود تليق بك معه ومع الروح القدس المحيى المساوي لك الآن وكل أوان وإلى دهر الدهور.امين.'
    },
    {
      'title': 'المزمور الخمسون',
      'body':
          'ارحمني يا الله كعظيم رحمتك، ومثل كثرة رأفتك تمحو إثمي. اغسلني كثيرا من إثمي ومن خطيتي طهرني، لأني أنا عارف بإثمي وخطيتي قدامي فى كل حين. لك وحدك أخطأت، والشر قدامك صنعت. لكي تتبرر فى أقوالك. وتغلب إذا حوكمتُ. لأني هاأنذا بالاثام حبل بي، وبالخطايا ولدتني أمي. لأنك هكذا قد أحببت الحق، إذ أوضحت لي غوامض حكمتك ومستوراتها. تنضح على بزوفاك فأطهر، تغسلني فأبيض اكتر من الثلج. تسمعني سرورا وفرحا، فتبتهج عظامي المنسحقة. اصرف وجهك عن خطاياي، وامح كل آثامي. قلبا نقيا اخلق فى يا الله، وروحا مستقيما جدده فى أحشائي. لا تطرحني من قدام وجهك وروحك القدوس لا تنزعه منى. امنحني بهجة خلاصك، وبروح رئاسي عضدني فأعلم الأثمة طرقك والمنافقون إليك يرجعون، نجني من الدماء يا الله إله خلاصي، فيبتهج لساني بعدلك. يا رب افتح شفتي، فيخبر فمي بتسبيحك. لأنك لو آثرت الذبيحة لكنت الان أعطي، ولكنك لا تسر بالمحرقات، فالذبيحة لله روح منسحق. القلب المنكسر والمتواضع لا يرذله الله، أنعم يا رب بمسرتك على صهيون، ولتبن أسوار أورشليم. حينئذ تسر بذبائح البر قربانا ومحرقات ويقربون على مذابحك العجول. هلليلويا.'
    },
    {
      'title': 'بدء الصلاة',
      'body':
          'تسبحة الغروب من اليوم المبارك اقدمها للمسيح ملكى والاهي وارجوه ان يغفر لي خطاياى'
    },
    {
      'title': 'سبحوا الرب يا جميع الامم',
      'body':
          'سبحو الرب يا جميع الامم ولتباركه كافة الشعوب لان رحمته قد قويت علينا وحق الرب يدوم الي الابد هلليلويا'
    },
    {
      'title': 'اعترفوا للرب لانه صالح',
      'body':
          'اعترفوا للرب لأنه صالح وأن إلى الأبد رحمته. ليقل بيت إسرائيل إنه صالح وإن إلى الأبد رحمته. ليقل بيت هارون إنه صالح وإن إلى الأبد رحمته. ليقل أتقياء الرب إنه صالح وإن إلى الأبد رحمته. في ضيقتي صرختُ إلى الرب، فاستجاب لي وأخرجني إلى الرحب. الرب عوني فلا أخشى ماذا يصنع بي الإنسان. الرب لي معين وأنا أرى بأعدائي. الاتكال على الرب خير من الاتكال على البشر، الرجاء بالرب خير من الرجاء بالرؤساء. كل الأمم أحاطوا بي وباسم الرب انتقمتُ منهم. أحاطوا بي احتياطا واكتنفوني، وباسم الرب قهرتهم. أحاطوا بي مثل النحل حول الشهد، والتهبوا كنار في شوك، وباسم الرب انتقمت منهم. دفعتُ لأسقطَ والرب عضدني. قوتي وتسبحتي هو الرب وقد صار لي خلاصا. صوت التهليل والخلاص في مساكن الأبرار. يمين الرب صنعت قوة، يمين الرب رفعتني، يمين الرب صنعت قوة. فلن أموتَ بعدُ، بل أحيا وأحدث بأعمال الرب. تأديبا أدبني الرب وإلى الموت لم يُسْلِمْني. افتحوا لي أبواب البر لكي أدخل فيها وأعترفَ للرب. هذا هو باب الرب والصديقون يدخلون فيه. أعترف لك يا رب لأنك استجبت لي وكنت لي مخلصا. الحجر الذي رذله البناءون هذا صار رأسا للزاوية. من قبل الرب كان هذا وهو عجيب في أعيننا. هذا هو اليوم الذي صنعه الرب. فلنبتهج ونفرح فيه. يا رب خلصنا. يا رب سهل طريقنا. مبارك الآتي باسم الرب. باركناكم من بيت الرب. الله الرب أضاء علينا. رتبوا عيدا في الواصلين إلى قرون المذبح. أنت هو إلهي فأشكرك، إلهي أنت فأرفعك. أعترف لك يا رب، لأنك استجبت لي وصرت لي مخلصا. اشكروا الرب فإنه صالح وأن إلى الأبد رحمته هلليلويا'
    },
    {
      'title': 'اليك يا رب صرخت',
      'body':
          'إليك يا رب صرخت في حزني فاستجبت لي. يا رب نجِّ نفسي من الشفاه الظالمة ومن اللسان الغاش. ماذا تُعطي وماذا تُزاد أيها اللسان الغاش؟ سهام الأقوياء مرهفة مع جمر البريّة. ويل لي فإن غربتي قد طالت علي وسكنت في مساكن قيدار. طويلاً سكنت نفسي في الغربة ومع مبغضي السلام كنت صاحب سلام. وحين كنت أكلمهم به كانوا يقاتلونني باطلاً. هلليلويا.'
    },
    {
      'title': 'رفعت عيني الي الجبال',
      'body':
          'رفعت عيني إلى الجبال من حيث يأتي عوني. معونتي من عند الرب الذي صنع السماء والأرض. لا يسلم رجلك للزلل، فما ينعس حافظك. هوذا لا ينعس ولا ينام حارس إسرائيل. الرب يحفظك، الرب يظلل على يدك اليمنى، فلا تحرقك الشمس بالنهار ولا القمر بالليل. الرب يحفظك من كل سوء، الرب يحفظ نفسك. الرب يحفظ دخولك وخروجك من الآن وإلى الأبد. هلليلويا.'
    },
    {
      'title': 'فرحت بلقائلين لي',
      'body':
          'فرحتُ بالقائلين لي إلى بيت الرب نذهب. وقفت أرجلنا في أبواب أورشليم. أورشليم المبنية مثل مدينة متصلة بعضها ببعض. لأن هناك صعدت القبائل، قبائل الرب، شهادة لإسرائيل، يعترفون لاسم الرب. هناك نصبت كراسي للقضاء، كراسي بيت داود. اسألوا السلام لأورشليم، والخصب لمحبيك. ليكن السلام في حصنك، والخصب في أبراجك. الرصينة من اجل اخواتي واقربى تكلمت من اجلك بالسلام ومن اجل بيت الرب الهنا، التمست لك الخيرات هلليلويا.'
    },
    {
      'title': 'اليك رفعت عيني',
      'body':
          'إليك رفعت عيني يا ساكن السماء. فها هما مثل عيون العبيد إلى أيدي مواليهم، ومثل عيني الأمة إلى يدي سيدتها. كذلك أعيننا نحو الرب إلهنا حتى يترأف علينا. ارحمنا يا رب ارحمنا، فإننا كثيرًا ما امتلأنا هوانًا. وكثيرًا ما امتلأت نفوسنا عارًا من المخصبين وإهانة من المتعظمين. هلليلويا.'
    },
    {
      'title': 'لولا ان الرب كان معنا',
      'body':
          'لولا أن الرب كان معنا ليقل إسرائيل. لولا أن الرب كان معنا عندما قام الناس علينا. لابتلعونا ونحن أحياء عند سخط غضبهم علينا. إذن لغرقنا في الماء وجاز على نفوسنا السيل. بل جاز على نفوسنا الماء الذي لا نهاية له. مبارك الرب الذي لم يسلمنا فريسة لأسنانهم. نجت أنفسنا مثل العصفور من فخ الصيادين. الفخ انكسر ونحن نجونا. عوننا باسم الرب الذي صنع السماء والأرض. هلليلويا.'
    },
    {
      'title': 'المتوكلون علي الرب',
      'body':
          'المتوكلون على الرب مثل جبل صهيون لا يتزعزع إلى الأبد. الساكن بأورشليم. الجبال حولها والرب حول شعبه من الآن وإلى الأبد. الرب لا يترك عصا الخطاة تستقر على نصيب الصديقين، لكن لا يمد الصديقون أيديهم إلى الإثم. أحسن يا رب إلى الصالحين وإلى مستقيمي القلوب. أما الذين يميلون إلى العثرات فينزعهم الرب مع فَعَلة الإثم. والسلام على إسرائيل. هلليلويا.'
    },
    {
      'title': 'اذا ما رد الرب سبى صهيون',
      'body':
          'إذا ما ردّ الرب سبي صهيون صرنا فرحين. حينئذٍ امتلأ فمنا فرحًا ولساننا تهليلًا. حينئذٍ يُقال في الأمم إن الرب قد عظّم الصنيع معهم. عظّم الرب الصنيع معنا فصرنا فرحين. اردد يا رب سبيّنا مثل السيول في الجنوب. الذين يزرعون بالدموع يحصدون بالابتهاج. سيرًا كانوا يسيرون وهم باكون حاملين بذارهم، ويعودون بالفرح حاملين أغمارهم. هلليلويا.'
    },
    {
      'title': 'ان لم يبن الرب البيت',
      'body':
          'إن لم يبنِ الرب البيت فباطلاً يتعب البناؤون، وإن لم يحرس الرب المدينة فباطلاً يسهر الحراس. باطل هو لكم التبكير، انهضوا من بعد جلوسكم يا آكلي الخبز بالهموم، فإنه يمنح أحباؤه نوماً. البنون ميراث من الرب، أجرة ثمرة البطن. كالسهم بيد القوي كذلك أبناء الشبيبة. مغبوط هو الرجل الذي يملأ جعبته منهم، حينئذ لا يُخزون إذا كلموا أعداءهم في الأبواب. هلليلويا.'
    },
    {
      'title': 'طوبي لجميع الذين يتقون الرب',
      'body':
          'طوبى لجميع الذين يتقون الرب، السالكين في طرقه. تأكل من ثمرة أتعابك، تصير مغبوطًا ويكون لك الخير. امرأتك تصير مثل كرمة مخصبة في جوانب بيتك، بنوك مثل غروس الزيتون الجدد حول مائدتك. هكذا يبارك الإنسان المتقي الرب. يباركك الرب من صهيون، وتبصر خيرات أورشليم جميع أيام حياتك. وترى بني بنيك، والسلام على إسرائيل. هلليلويا.'
    },
    {
      'title': 'مرارا كثيرة حاربونى',
      'body':
          'مرارا كثيرة حاربوني منذ صباي ليقل إسرائيل. مرارا كثيرة قاتلوني منذ شبابي وانهم لم يقدروا عليّ. على ظهري جلدني الخطاة وأطالوا إثمهم. الرب صديق هو، يقطع أعناق الخطاة. فليخزَ وليرتد إلى الوراء كل الذين يبغضون صهيون، وليكونوا مثل عشب السطوح الذي ييبس قبل أن يُقطع، الذي لم يملأ الحاصد منه يده ولا الذي يجمع الغمور حضنه. ولم يقل المجتازون إن بركة الرب عليكم، وباركناكم باسم الرب. هلليلويا.'
    },
    {
      'title': 'الانجيل',
      'body':
          'ذوكصاصى او ثيموس ايمون فصل من بشارة معلمنا مار لوقا البشير وتلميذ الطاهر بركاته علي جميعنا امين. ولما قام من المجمع دخل بيت سمعان. وكانت حماة سمعان بحمَّى شديدة. فسألوه من أجلها. فوقف فوقا منها وانتهر الحمى، فتركتها وفي الحال قامت وخدمتهم. وعند غروب الشمس كان كل الذين عندهم مرضى بأنواع أمراض كثيرة يقدمونهم إليه. أما هو فكان يضع يديه على كل واحد منهم فيشفيهم. وكانت الشياطين تخرج من كثيرين وهي تصرخ وتقول: أنت هو المسيح ابن الله. فكان ينتهرهم ولا يدَعهم ينطقون، لأنهم كانوا قد عرفوه أنه هو المسيح والمجد لله دائما'
    },
    {
      'title': 'القطعة الاولي',
      'body':
          'إذا كان الصديق بالجهد يَخلُص فاين أظهر أنا الخاطئ؟ ثِقلُ النهار وحرُّه لم أحتمل لضعف بشريتي. لكن أنت يا الله الرحوم احسبني مع أصحاب الساعة الحادية عشرة. لأني هأنذا بالآثام حُبل بي وبالخطايا ولدتني أمي، فما أجسر أن أنظر إلى علو السماء. لكني أتكّل على غنى رحمتك ومحبّتك للبشرية، صارخًا قائلاً: اللهم اغفر لي أنا الخاطئ وارحمني.(ذوكصابتري كي ايو كي اجيو ابنفماتي)'
    },
    {
      'title': 'القطعة الثانية',
      'body':
          'أسرع لي يا مخلص بفتح الأحضان الأبوية. لأني أفنيت عمري في اللذات والشهوات، وقد مضى منى النهار وفات، فالآن اتكل على غنى رأفتك التي لا تفرغ. فلا تتخل عن قلبٍ خاشع مفتقر لرحمتك. لأني إليك أصرخ يا رب بتخشع: أخطأت يا أبتاه إلى السماء وقدامك ولست مستحقا أن أدعَى لك ابنا، بل اجعلني كأحد أجرائك(ذوكصابتري كي ايو كي اجيو ابنفماتي)'
    },
    {
      'title': 'القطعة الثالثة',
      'body':
          ' لكل إثم بحرص ونشاط فعلتُ، ولكل خطيةٍ بشوق واجتهاد ارتكبتُ، ولكل عذابٍ وحكم استوجبتُ. فهيئي لي أسبابَ التوبة أيتها السيدة العذراء. فإليك أتضرع وبك أستشفع، وإياك أدعو أن تساعديني لئلا أخزى. وعند مفارقة نفسي من جسدي احضري عندي، ولمؤامرة الأعداء اهزمي، ولأبواب الجحيم أغلقي. لئلا يبتلعوا نفسي يا عروس بلا عيب للختن الحقيقي.'
    },
    {
      'title': 'كيريي ايليسون',
      'body':
          'كيريي ايليسون كيريي ايليسون يارب ارحم.كيريي ايليسون كيريي ايليسون ارحمنا يا الله.كيريي ايليسون كيريي ايليسون اسمعنا ورحمنا.كيريي ايليسون كيريي ايليسون يارب ارحم.كيريي ايليسون كيريي ايليسون ارحمنا يا الله.كيريي ايليسون كيريي ايليسون اسمعنا ورحمنا.كيريي ايليسون كيريي ايليسون يارب ارحم.كيريي ايليسون كيريي ايليسون ارحمنا يا الله.كيريي ايليسون كيريي ايليسون اسمعنا ورحمنا.كيريي ايليسون كيريي ايليسون يارب ارحم.كيريي ايليسون كيريي ايليسون ارحمنا يا الله.كيريي ايليسون كيريي ايليسون اسمعنا ورحمنا.كيريي ايليسون كيريي ايليسون كيريي ايليسون.كيريي ايليسون كيريي ايليسون.'
    },
    {
      'title': 'قدوس قدوس قدوس',
      'body':
          'قدوس، قدوس، قدوس، رب الصباؤوت. السماء والأرض مملوءتان من مجدك وكرامتك. ارحمنا يا الله الآب ضابط الكل. أيها الثالوث القدوس ارحمنا. أيها الرب إله القوات كن معنا، لأنه ليس لنا معين في شدائدنا وضيقاتنا سواك.حل واغفر واصفح لنا يا الله عن سيئاتنا، التي صنعناها بإرادتنا والتي صنعناها بغير إرادتنا، التي فعلناها بمعرفة والتي فعلناها بغير معرفة، الخفية والظاهرة. يا رب اغفرها لنا، من أجل اسمك القدوس الذي دعي علينا. كرحمتك يا رب وليس كخطايانا.'
    },
    {
      'title': 'الصلاة الربانية',
      'body':
          'أبانا الذي في السماوات. ليتقدس اسمك. ليأت ملكوتك.لتكن مشيئتك. كما في السماء كذلك على الأرض.خبزنا الذي للغد أعطنا اليوم.وأغفر لنا ذنوبنا كما نغفر نحن أيضا للمذنبين إلينا.ولا تدخلنا في تجربة. لكن نجنا من الشرير.بالمسيح يسوع ربنا لأن لك الملك والقوة والمجد إلى الأبد. آمين.'
    },
    {
      'title': 'التحليل',
      'body':
          'نشكرك يا ملكنا المتحنن لأنك منحتنا أن نعبر هذا اليوم بسلام وأتيت بنا إلى المساء شاكرين، وجعلتنا مستحقين أن ننظر النور إلى المساء. اللهم اقبل تمجيدنا هذا الذي صار الآن. ونجنا من حيل المضاد وأبطل سائر فخاخه المنصوبة لنا. هب لنا في هذه الليلة المقبلة سلامة بغير ألم ولا قلق ولا تعب ولا خيال. لنجتازها أيضا بسلام وعفاف، وننهض للتسابيح والصلوات كل حين وفي كل مكان، نمجد اسمك القدوس في كل شيء، مع الآب غير المدرك ولا المبتدئ، والروح القدس المحيي المساوي لك الآن وكل أوان والى دهر الدهور أمين.'
    },
    {
      'title': 'طلبة تقال اخر كل ساعة',
      'body':
          'ارحمنا يا الله ثم ارحمنا. يا من في كل وقت وكل ساعة، في السماء وعلى الأرض، مسجودٌ له وممجد. المسيح إلهنا الصالح، الطويل الروح، الكثير الرحمة، الجزيل التحنن، الذي يحب الصديقين ويرحم الخطاة الذين أولهم أنا. الذي لا يشاء موت الخاطئ مثل ما يرجع ويحيا. الداعي الكل إلى الخلاص لأجل الموعد بالخيرات المنتظرة.يا رب اقبل منا في هذه الساعة وكل ساعة طلباتنا. سهل حياتنا، وأرشدنا إلى العمل بوصاياك. قدس أرواحنا. طهر أجسامنا. قوم أفكارنا. نق نياتنا. اشف أمراضنا واغفر خطايانا. ونجنا من كل حزن رديء ووجع قلب. أحطنا بملائكتك القديسين، لكي نكون بمعسكرهم محفوظين ومرشدين، لنصل إلى اتحاد الإيمان وإلى معرفة مجدك غير المحسوس وغير المحدود، فإنك مبارك إلى الأبد. أمين.'
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _toggleList() {
    setState(() {
      _showList = !_showList;
      if (_showList) {
        _slideController.forward();
      } else {
        _slideController.reverse();
      }
    });
  }

  void _selectPrayer(int index) {
    setState(() {
      currentIndex = index;
      _toggleList();
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  void _nextPage() {
    if (currentIndex < prayers.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _previousPage() {
    if (currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _handleKey(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _nextPage();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _previousPage();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDark ? Colors.white : Colors.black;
    final bgColor = widget.isDark ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _handleKey,
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Top Bar with Title and Back Button
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        const Spacer(),
                        // Back Button (Right Side)
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: widget.isDark
                                    ? Colors.grey[800]
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.isDark
                                        ? Colors.white10
                                        : Colors.black12,
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: textColor,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Current Prayer Title with Dropdown Button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: GestureDetector(
                      onTap: _toggleList,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: widget.isDark
                              ? Colors.grey[850]
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: widget.isDark
                                  ? Colors.white10
                                  : Colors.black12,
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                prayers[currentIndex]['title']!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: widget.fontSize * 0.7,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            Icon(
                              _showList
                                  ? Icons.arrow_drop_up
                                  : Icons.arrow_drop_down,
                              color: textColor,
                              size: 28,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // PageView for Prayer Content (without container/card)
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      reverse: true,
                      itemCount: prayers.length,
                      onPageChanged: (index) {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final prayer = prayers[index];
                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(24),
                          child: TweenAnimationBuilder<double>(
                            key: ValueKey(currentIndex),
                            tween: Tween<double>(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: Opacity(
                                  opacity: value,
                                  child: Text(
                                    prayer['body']!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: widget.fontSize,
                                      height: 1.8,
                                      letterSpacing: 0.8,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),

              // Dropdown List
              if (_showList)
                GestureDetector(
                  onTap: _toggleList,
                  child: Container(
                    color: Colors.black54,
                    child: Center(
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Material(
                          color: Colors.transparent,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 80),
                            decoration: BoxDecoration(
                              color: widget.isDark
                                  ? Colors.grey[900]
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: widget.isDark
                                        ? Colors.grey[800]
                                        : Colors.grey[100],
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(25),
                                      topRight: Radius.circular(25),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.menu_book,
                                        color: textColor,
                                        size: 28,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        "قائمة الصلوات",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: prayers.length,
                                    itemBuilder: (context, index) {
                                      final isSelected = currentIndex == index;
                                      return InkWell(
                                        onTap: () => _selectPrayer(index),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 16),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? (widget.isDark
                                                    ? Colors.blue
                                                        .withOpacity(0.2)
                                                    : Colors.blue.shade50)
                                                : null,
                                            border: Border(
                                              bottom: BorderSide(
                                                color: widget.isDark
                                                    ? Colors.grey[800]!
                                                    : Colors.grey[200]!,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              if (isSelected)
                                                Icon(
                                                  Icons.check_circle,
                                                  color: Colors.blue,
                                                  size: 20,
                                                )
                                              else
                                                const SizedBox(width: 20),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  prayers[index]['title']!,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: textColor,
                                                    fontWeight: isSelected
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    onPressed: _toggleList,
                                    child: const Text(
                                      "إغلاق",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),
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
}
