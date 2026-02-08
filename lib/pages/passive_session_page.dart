import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../models/session_settings.dart';
import '../services/session_controller.dart';
import '../services/tilt_service.dart';
import '../widgets/ambient_background.dart';
import '../widgets/analog_clock.dart';

class PassiveSessionPage extends StatefulWidget {
  const PassiveSessionPage({
    super.key,
    required this.settings,
  });

  final SessionSettings settings;

  @override
  State<PassiveSessionPage> createState() => _PassiveSessionPageState();
}

class _PassiveSessionPageState extends State<PassiveSessionPage> {
  late final SessionController _sessionController;
  late final TiltService _tiltService;
  StreamSubscription<double>? _tiltSub;
  Timer? _clockTimer;
  DateTime _time = DateTime.now();
  bool _motionUnavailable = false;

  @override
  void initState() {
    super.initState();
    _sessionController = SessionController(
      targetAngle: widget.settings.targetAngle,
      tolerance: widget.settings.tolerance,
    );
    _tiltService = TiltService();

    _startSession();
  }

  Future<void> _startSession() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await WakelockPlus.enable();

    _tiltService.start();
    _tiltSub = _tiltService.tiltStream.listen(
      _sessionController.onTilt,
      onError: (Object error, StackTrace stackTrace) {
        if (!mounted) {
          return;
        }
        setState(() => _motionUnavailable = true);
      },
    );

    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_sessionController.showClock || !mounted) {
        return;
      }
      setState(() => _time = DateTime.now());
    });

    _sessionController.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    if (!mounted) {
      return;
    }
    setState(() {
      _time = DateTime.now();
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _tiltSub?.cancel();
    _tiltService.dispose();
    _sessionController
      ..removeListener(_onControllerUpdate)
      ..dispose();
    WakelockPlus.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool showClock = _sessionController.showClock;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          AmbientBackground(themeMode: widget.settings.themeMode),
          if (_motionUnavailable)
            const Positioned(
              left: 24,
              right: 24,
              bottom: 32,
              child: Text(
                'Motion sensor unavailable',
                textAlign: TextAlign.center,
              ),
            ),
          IgnorePointer(
            child: AnimatedOpacity(
              opacity: showClock ? 1 : 0,
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 380),
                    child: Semantics(
                      label: 'Analog clock',
                      value: '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}',
                      child: AnalogClock(
                        time: _time,
                        settings: widget.settings,
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
