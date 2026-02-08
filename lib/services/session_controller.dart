import 'package:flutter/foundation.dart';

class SessionController extends ChangeNotifier {
  SessionController({
    required this.targetAngle,
    required this.tolerance,
    this.enterHold = const Duration(milliseconds: 200),
    this.exitHold = const Duration(milliseconds: 200),
    this.exitExtraTolerance = 3,
  });

  final double targetAngle;
  final double tolerance;
  final Duration enterHold;
  final Duration exitHold;
  final double exitExtraTolerance;

  bool _showClock = false;
  double _currentTilt = 0;
  DateTime? _enterCandidateSince;
  DateTime? _exitCandidateSince;

  bool get showClock => _showClock;
  double get currentTilt => _currentTilt;

  void onTilt(double angle) {
    _currentTilt = angle;
    final DateTime now = DateTime.now();
    final double delta = (angle - targetAngle).abs();
    final bool enterZone = delta <= tolerance;
    final bool exitZone = delta > (tolerance + exitExtraTolerance);

    if (!_showClock) {
      if (enterZone) {
        _enterCandidateSince ??= now;
        if (now.difference(_enterCandidateSince!) >= enterHold) {
          _showClock = true;
          _enterCandidateSince = null;
          _exitCandidateSince = null;
          notifyListeners();
        }
      } else {
        _enterCandidateSince = null;
      }
      return;
    }

    if (exitZone) {
      _exitCandidateSince ??= now;
      if (now.difference(_exitCandidateSince!) >= exitHold) {
        _showClock = false;
        _exitCandidateSince = null;
        _enterCandidateSince = null;
        notifyListeners();
      }
    } else {
      _exitCandidateSince = null;
    }
  }
}
