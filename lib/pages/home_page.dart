import 'package:flutter/material.dart';

import '../models/session_settings.dart';
import '../widgets/ambient_background.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.settings,
    required this.onChanged,
    required this.onStartSession,
  });

  final SessionSettings settings;
  final ValueChanged<SessionSettings> onChanged;
  final VoidCallback onStartSession;

  @override
  Widget build(BuildContext context) {
    final bool isNight = settings.themeMode == BlockThemeMode.night;
    final bool isAnalogStyle =
        settings.clockDesign != ClockDesign.flipAlarm && settings.clockDesign != ClockDesign.tubeDigital;
    final Color panelColor = isNight ? const Color(0xCC141A20) : const Color(0xCCF5EDDE);
    final Color textColor = isNight ? const Color(0xFFF0ECE3) : const Color(0xFF2A2418);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          AmbientBackground(themeMode: settings.themeMode),
          SafeArea(
            minimum: const EdgeInsets.all(20),
            child: Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: panelColor,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                        color: textColor.withValues(alpha: 0.15),
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                          color: Colors.black.withValues(alpha: isNight ? 0.35 : 0.16),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'The Block',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                  color: textColor,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'A calm, passive clock. Set your angle, then begin a session.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: textColor.withValues(alpha: 0.8),
                                  height: 1.35,
                                ),
                          ),
                          const SizedBox(height: 22),
                          _SettingLabel(label: 'Target Angle: ${settings.targetAngle.toStringAsFixed(0)}°'),
                          Slider(
                            min: 5,
                            max: 45,
                            value: settings.targetAngle,
                            onChanged: (double value) => onChanged(settings.copyWith(targetAngle: value)),
                          ),
                          _SettingLabel(label: 'Tolerance: ±${settings.tolerance.toStringAsFixed(0)}°'),
                          Slider(
                            min: 2,
                            max: 15,
                            value: settings.tolerance,
                            onChanged: (double value) => onChanged(settings.copyWith(tolerance: value)),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: _ModeChip(
                                  label: 'Night',
                                  selected: settings.themeMode == BlockThemeMode.night,
                                  onTap: () => onChanged(settings.copyWith(themeMode: BlockThemeMode.night)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _ModeChip(
                                  label: 'Sand',
                                  selected: settings.themeMode == BlockThemeMode.sand,
                                  onTap: () => onChanged(settings.copyWith(themeMode: BlockThemeMode.sand)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const _SettingLabel(label: 'Clock Design'),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: ClockDesign.values
                                .map(
                                  (ClockDesign design) => _DesignChip(
                                    label: design.label,
                                    selected: settings.clockDesign == design,
                                    onTap: () => onChanged(settings.copyWith(clockDesign: design)),
                                  ),
                                )
                                .toList(),
                          ),
                          if (isAnalogStyle) ...<Widget>[
                            SwitchListTile.adaptive(
                              value: settings.showSecondHand,
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                'Show second hand',
                                style: TextStyle(color: textColor),
                              ),
                              onChanged: (bool enabled) => onChanged(settings.copyWith(showSecondHand: enabled)),
                            ),
                            const _SettingLabel(label: 'Hand Thickness'),
                            Slider(
                              min: 3.2,
                              max: 8.0,
                              value: settings.handThickness,
                              onChanged: (double value) => onChanged(settings.copyWith(handThickness: value)),
                            ),
                          ],
                          if (!isAnalogStyle)
                            Text(
                              'This design uses fixed styling for readability.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: textColor.withValues(alpha: 0.72),
                                  ),
                            ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: onStartSession,
                              child: const Text('Start Passive Session'),
                            ),
                          ),
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
    );
  }
}

class _SettingLabel extends StatelessWidget {
  const _SettingLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
    );
  }
}

class _DesignChip extends StatelessWidget {
  const _DesignChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: selected ? Theme.of(context).colorScheme.secondaryContainer : Colors.transparent,
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.35),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: selected ? Theme.of(context).colorScheme.primaryContainer : Colors.transparent,
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}
