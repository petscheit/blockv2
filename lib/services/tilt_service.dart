import 'dart:async';
import 'dart:math' as math;

import 'package:sensors_plus/sensors_plus.dart';

class TiltService {
  TiltService({
    this.smoothingFactor = 0.90,
  });

  final double smoothingFactor;
  final StreamController<double> _tiltController = StreamController<double>.broadcast();
  StreamSubscription<AccelerometerEvent>? _accelerometerSub;

  double _gravityX = 0;
  double _gravityY = 0;
  double _gravityZ = 9.8;

  Stream<double> get tiltStream => _tiltController.stream;

  void start() {
    _accelerometerSub ??= accelerometerEventStream().listen(
      _onEvent,
      onError: (Object error, StackTrace stackTrace) {
        if (!_tiltController.isClosed) {
          _tiltController.addError(error, stackTrace);
        }
      },
    );
  }

  void stop() {
    _accelerometerSub?.cancel();
    _accelerometerSub = null;
  }

  void dispose() {
    stop();
    if (!_tiltController.isClosed) {
      _tiltController.close();
    }
  }

  void _onEvent(AccelerometerEvent event) {
    _gravityX = (smoothingFactor * _gravityX) + ((1 - smoothingFactor) * event.x);
    _gravityY = (smoothingFactor * _gravityY) + ((1 - smoothingFactor) * event.y);
    _gravityZ = (smoothingFactor * _gravityZ) + ((1 - smoothingFactor) * event.z);

    final double xy = math.sqrt((_gravityX * _gravityX) + (_gravityY * _gravityY));
    final double z = _gravityZ.abs();
    final double angleFromHorizontal = math.atan2(xy, z) * 180 / math.pi;
    _tiltController.add(angleFromHorizontal);
  }
}
