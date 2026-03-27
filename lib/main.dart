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
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
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
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 800),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: Text(
                    "إعدادي",
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: isDark ? Colors.white24 : Colors.black26,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.white12 : Colors.black12,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDark ? Colors.grey[850] : Colors.grey[200],
                      foregroundColor: isDark ? Colors.white : Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor:
                            isDark ? Colors.grey[900] : Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (context) => SettingsSheet(
                          isDark: isDark,
                          fontSize: fontSize,
                          updateFontSize: updateFontSize,
                          toggleTheme: toggleTheme,
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.settings,
                      size: 28,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    label: Text(
                      "الإعدادات",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 800),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 50 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.5),
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
                          horizontal: 80,
                          vertical: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    PrayerPage(
                              isDark: isDark,
                              fontSize: fontSize,
                            ),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.easeInOut;
                              var tween = Tween(begin: begin, end: end)
                                  .chain(CurveTween(curve: curve));
                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      child: const Text(
                        "ابدأ الصلاة",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsSheet extends StatefulWidget {
  final bool isDark;
  final double fontSize;
  final Function(double) updateFontSize;
  final VoidCallback toggleTheme;

  const SettingsSheet({
    super.key,
    required this.isDark,
    required this.fontSize,
    required this.updateFontSize,
    required this.toggleTheme,
  });

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  late double _currentFontSize;

  @override
  void initState() {
    super.initState();
    _currentFontSize = widget.fontSize;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: widget.isDark ? Colors.white38 : Colors.black38,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "الإعدادات",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: widget.isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.isDark ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "المظهر",
                  style: TextStyle(
                    fontSize: 18,
                    color: widget.isDark ? Colors.white : Colors.black,
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
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.isDark ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.text_fields,
                        color: widget.isDark ? Colors.white70 : Colors.black54),
                    const SizedBox(width: 8),
                    Text(
                      "حجم الخط",
                      style: TextStyle(
                        fontSize: 18,
                        color: widget.isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.format_size,
                        size: 20,
                        color: widget.isDark ? Colors.white70 : Colors.black54),
                    Expanded(
                      child: Slider(
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
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${_currentFontSize.round()}px",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: widget.isDark ? Colors.grey[700] : Colors.white,
                    borderRadius: BorderRadius.circular(12),
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
                      const SizedBox(height: 8),
                      Text(
                        "هذا مثال لتغيير حجم الخط",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: _currentFontSize * 0.6,
                          color: widget.isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "إغلاق",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class PrayerPage extends StatefulWidget {
  final bool isDark;
  final double fontSize;

  const PrayerPage({super.key, required this.isDark, required this.fontSize});

  @override
  State<PrayerPage> createState() => _PrayerPageState();
}

class _PrayerPageState extends State<PrayerPage> {
  late PageController _controller;
  int currentIndex = 0;
  final FocusNode _focusNode = FocusNode();

  final List<Map<String, String>> prayers = [
    {
      'title': 'صلاة ربانية',
      'body':
          'بسم الآب والابن والروح القدس الإله الواحد آمین. كيريي إيليسون يَارَبُّ ارْحَمْ. يَارَبُّ ارْحَمْ. يَارَبُّ بارك. آمين. المجد للآب والابن والروح القدس الآن وكل أوان وإلى دهر الدهور. آمين. اللهم اجعلنا مستحقين أن نقول بشكر: أبانا الذي في السَّمَواتِ، ليتقدس اسمك. ليأتِ ملكوتك. لتكن مشيئتُكَ، كما في السماء كذلك على الأرْضِ خُبزنا الذي للغد اعطنا اليوم. واغفر لنا ذنوبنا كما نغفر نحن أيضًا للمذنبين إلينا. ولا تدخلنا في تجربة. لكن نجنا مِنْ الشرير بالمسيح يسوعُ ربنا، لأَنَّ لَكَ المُلك والقوة والمجد إلى الأبد. آمين.'
    },
    {
      'title': 'صلاة الشكر',
      'body':
          'آمين. فلنشكر صانع الخيرات الرحوم الله، أبا ربنا وإلهنا ومخلصنا يسوع المسيح. لأنه سترنا وأعاننا، وحفظنا، وقبلنا إليه، وأشفق علينا، وعضدنا، وأتى بنا إلى هذه الساعة. هو أيضًا فلنسأله أن يحفظنا في هذا اليوم المقدس وكل أيام حياتنا بكل سلام، الضابط الكل الرب إلهنا. أيها السيد الرب الإله ضابط الكل أبو ربنا وإلهنا ومخلصنا يسوع المسيح، نشكرك على كل حال، ومن أجل كل حال، وفى كل حال، لأنك سترتنا وأعنتنا وحفظتنا وقبلتنا إليك، وأشفقت علينا وعضدتنا وأتيت بنا إلى هذه الساعة. من أجل هذا نسأل ونطلب من صلاحك يا محب البشر، امنحنا أن نكمل هذا اليوم المقدس وكل أيام حياتنا بكل سلام مع خوفك. كل حسد وكل تجربة وكل فعل الشيطان ومؤامرة الناس الأشرار، وقيام الأعداء الخفيين والظاهرين، انزعها عنا وعن سائر شعبك وعن موضعك المقدس هذا. أما الصالحات والنافعات فارزقنا إياها، لأنك أنت الذي أعطيتنا السلطان أن ندوس الحيات والعقارب وكل قوة العدو ولا تدخلنا في تجربة، لكن نجنا من الشرير. بالنعمة والرأفات ومحبة البشر، اللواتي لابنك الوحيد ربنا وإلهنا ومخلصنا يسوع المسيح. هذا الذي من قبله المجد والإكرام والعزة والسجود تليق بك معه ومع الروح القدس المحيى المساوي لك الآن وكل أوان وإلى دهر الدهور.'
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
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (currentIndex < prayers.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _previousPage() {
    if (currentIndex > 0) {
      _controller.previousPage(
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
          child: Column(
            children: [
              // Header with Page Indicator and Back Button
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Spacer(),
                    // Page Indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color:
                            widget.isDark ? Colors.grey[800] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${currentIndex + 1} / ${prayers.length}",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Back Button (يمين)
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: widget.isDark
                                ? Colors.grey[800]
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: textColor,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  reverse: true,
                  itemCount: prayers.length,
                  onPageChanged: (index) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final prayer = prayers[index];
                    return Column(
                      children: [
                        const SizedBox(height: 20),
                        // Title
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: widget.isDark
                                  ? [Colors.blue.shade900, Colors.blue.shade800]
                                  : [Colors.blue.shade100, Colors.blue.shade50],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            prayer["title"]!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: widget.isDark
                                  ? Colors.white
                                  : Colors.blue.shade900,
                              fontSize: widget.fontSize * 0.8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Text(
                                prayer["body"]!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: widget.fontSize,
                                  height: 1.8,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              // Navigation Buttons with Hover Effect
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Next Button (شمال)
                  if (currentIndex < prayers.length - 1)
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: StatefulBuilder(
                        builder: (context, setState) {
                          bool isHovered = false;
                          return MouseRegion(
                            onEnter: (_) => setState(() => isHovered = true),
                            onExit: (_) => setState(() => isHovered = false),
                            child: GestureDetector(
                              onTap: _nextPage,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isHovered
                                      ? (widget.isDark
                                          ? Colors.grey[700]
                                          : Colors.grey[300])
                                      : (widget.isDark
                                          ? Colors.grey[850]
                                          : Colors.white),
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: isHovered
                                      ? [
                                          BoxShadow(
                                            color: Colors.blue.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          )
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.arrow_back,
                                      color:
                                          isHovered ? Colors.blue : Colors.blue,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "التالي",
                                      style: TextStyle(
                                        color: isHovered
                                            ? Colors.blue
                                            : Colors.blue,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  // Previous Button (يمين)
                  if (currentIndex > 0)
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: StatefulBuilder(
                        builder: (context, setState) {
                          bool isHovered = false;
                          return MouseRegion(
                            onEnter: (_) => setState(() => isHovered = true),
                            onExit: (_) => setState(() => isHovered = false),
                            child: GestureDetector(
                              onTap: _previousPage,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isHovered
                                      ? (widget.isDark
                                          ? Colors.grey[700]
                                          : Colors.grey[300])
                                      : (widget.isDark
                                          ? Colors.grey[850]
                                          : Colors.white),
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: isHovered
                                      ? [
                                          BoxShadow(
                                            color: Colors.blue.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          )
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      "السابق",
                                      style: TextStyle(
                                        color: isHovered
                                            ? Colors.blue
                                            : Colors.blue,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward,
                                      color:
                                          isHovered ? Colors.blue : Colors.blue,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
