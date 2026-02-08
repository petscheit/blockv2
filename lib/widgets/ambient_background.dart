import 'package:flutter/material.dart';

import '../models/session_settings.dart';

class AmbientBackground extends StatelessWidget {
  const AmbientBackground({
    super.key,
    required this.themeMode,
  });

  final BlockThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    final bool isNight = themeMode == BlockThemeMode.night;
    final Color top = isNight ? const Color(0xFF0A0D10) : const Color(0xFFF1EBDD);
    final Color bottom = isNight ? const Color(0xFF141A20) : const Color(0xFFE6DAC5);
    final Color glow = isNight ? const Color(0x332E465C) : const Color(0x33AA8A58);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[top, bottom],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Align(
            alignment: const Alignment(0, -0.1),
            child: Container(
              width: 420,
              height: 420,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[glow, Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
