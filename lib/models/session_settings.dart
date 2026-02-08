import 'package:flutter/material.dart';

enum BlockThemeMode {
  night,
  sand,
}

extension BlockThemeModeLabel on BlockThemeMode {
  String get label {
    switch (this) {
      case BlockThemeMode.night:
        return 'Night';
      case BlockThemeMode.sand:
        return 'Sand';
    }
  }
}

enum ClockDesign {
  stoneDial,
  railwayDial,
  minimalDial,
  orbitDial,
  flipAlarm,
  tubeDigital,
}

extension ClockDesignLabel on ClockDesign {
  String get label {
    switch (this) {
      case ClockDesign.stoneDial:
        return 'Stone Dial';
      case ClockDesign.railwayDial:
        return 'Railway';
      case ClockDesign.minimalDial:
        return 'Minimal';
      case ClockDesign.orbitDial:
        return 'Orbit';
      case ClockDesign.flipAlarm:
        return 'Flip Alarm';
      case ClockDesign.tubeDigital:
        return 'Tube Digital';
    }
  }

  String get storageValue {
    switch (this) {
      case ClockDesign.stoneDial:
        return 'stone';
      case ClockDesign.railwayDial:
        return 'railway';
      case ClockDesign.minimalDial:
        return 'minimal';
      case ClockDesign.orbitDial:
        return 'orbit';
      case ClockDesign.flipAlarm:
        return 'flip';
      case ClockDesign.tubeDigital:
        return 'tube';
    }
  }

  static ClockDesign fromStorageValue(String? value) {
    return ClockDesign.values.firstWhere(
      (ClockDesign design) => design.storageValue == value,
      orElse: () => ClockDesign.stoneDial,
    );
  }
}

@immutable
class SessionSettings {
  const SessionSettings({
    required this.targetAngle,
    required this.tolerance,
    required this.showSecondHand,
    required this.themeMode,
    required this.handThickness,
    required this.clockDesign,
  });

  final double targetAngle;
  final double tolerance;
  final bool showSecondHand;
  final BlockThemeMode themeMode;
  final double handThickness;
  final ClockDesign clockDesign;

  factory SessionSettings.defaults() {
    return const SessionSettings(
      targetAngle: 20,
      tolerance: 5,
      showSecondHand: true,
      themeMode: BlockThemeMode.night,
      handThickness: 5.2,
      clockDesign: ClockDesign.stoneDial,
    );
  }

  SessionSettings copyWith({
    double? targetAngle,
    double? tolerance,
    bool? showSecondHand,
    BlockThemeMode? themeMode,
    double? handThickness,
    ClockDesign? clockDesign,
  }) {
    return SessionSettings(
      targetAngle: targetAngle ?? this.targetAngle,
      tolerance: tolerance ?? this.tolerance,
      showSecondHand: showSecondHand ?? this.showSecondHand,
      themeMode: themeMode ?? this.themeMode,
      handThickness: handThickness ?? this.handThickness,
      clockDesign: clockDesign ?? this.clockDesign,
    );
  }
}
