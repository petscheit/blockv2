import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/session_settings.dart';
import 'pages/home_page.dart';
import 'pages/passive_session_page.dart';

class BlockApp extends StatelessWidget {
  const BlockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Block',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: const SetupScreen(),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final TextTheme baseTextTheme =
        isDark ? Typography.material2021().white : Typography.material2021().black;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: isDark ? const Color(0xFF0A0D10) : const Color(0xFFF2ECE2),
      colorScheme: ColorScheme.fromSeed(
        seedColor: isDark ? const Color(0xFF8FA5B3) : const Color(0xFF7B6B4D),
        brightness: brightness,
      ),
      textTheme: baseTextTheme.apply(
            bodyColor: isDark ? const Color(0xFFF3F0E8) : const Color(0xFF2A2418),
            displayColor: isDark ? const Color(0xFFF3F0E8) : const Color(0xFF2A2418),
          ),
    );
  }
}

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  SessionSettings _settings = SessionSettings.defaults();
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) {
      return;
    }
    setState(() {
      _settings = SessionSettings(
        targetAngle: prefs.getDouble('target_angle') ?? 20,
        tolerance: prefs.getDouble('tolerance') ?? 5,
        showSecondHand: prefs.getBool('second_hand') ?? true,
        handThickness: prefs.getDouble('hand_thickness') ?? 5.2,
        themeMode: (prefs.getString('theme_mode') ?? 'night') == 'sand'
            ? BlockThemeMode.sand
            : BlockThemeMode.night,
        clockDesign: ClockDesignLabel.fromStorageValue(prefs.getString('clock_design')),
      );
      _loaded = true;
    });
  }

  Future<void> _saveSettings(SessionSettings value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('target_angle', value.targetAngle);
    await prefs.setDouble('tolerance', value.tolerance);
    await prefs.setBool('second_hand', value.showSecondHand);
    await prefs.setDouble('hand_thickness', value.handThickness);
    await prefs.setString('theme_mode', value.themeMode == BlockThemeMode.sand ? 'sand' : 'night');
    await prefs.setString('clock_design', value.clockDesign.storageValue);
  }

  Future<void> _openSession() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PassiveSessionPage(settings: _settings),
      ),
    );
    if (!mounted) {
      return;
    }
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator.adaptive(),
        ),
      );
    }

    return HomePage(
      settings: _settings,
      onChanged: (SessionSettings value) {
        setState(() => _settings = value);
        _saveSettings(value);
      },
      onStartSession: _openSession,
    );
  }
}
