/// Intelligent gait and cadence filter to prevent false-positive step counts
/// caused by idle hand movements, desk typing, or phone fidgeting.
class StepFilterService {
  final int minBoutSteps;
  final double maxCadenceHz;
  final int minStepIntervalMs;
  final Duration boutTimeout;

  int _tentativeSteps = 0;
  bool _isConfirmedWalking = false;
  DateTime? _lastStepTime;
  String _pedestrianStatus = 'unknown'; // 'walking', 'stopped', 'unknown'

  StepFilterService({
    this.minBoutSteps = 8,
    this.maxCadenceHz = 3.2,
    this.minStepIntervalMs = 250,
    this.boutTimeout = const Duration(seconds: 3),
  });

  String get pedestrianStatus => _pedestrianStatus;
  bool get isConfirmedWalking => _isConfirmedWalking;
  int get pendingTentativeSteps => _tentativeSteps;

  /// Updates the latest pedestrian activity reported by the OS sensor.
  void updatePedestrianStatus(String status) {
    _pedestrianStatus = status.toLowerCase().trim();
    if (_pedestrianStatus == 'stopped') {
      _isConfirmedWalking = false;
      _tentativeSteps = 0;
    } else if (_pedestrianStatus == 'walking') {
      // If OS hardware already positively confirmed walking, expedite bout
      _isConfirmedWalking = true;
    }
  }

  /// Processes an incremental step delta from the device step counter.
  ///
  /// Returns the number of verified steps to add to the persistent step count.
  /// If the movement is deemed to be hand fidgeting or rapid shaking, returns 0.
  int processStepDelta(int delta, DateTime eventTime) {
    if (delta <= 0) return 0;

    // 1. Explicitly stopped: reject hand fidgets while sitting/stationary
    if (_pedestrianStatus == 'stopped') {
      _tentativeSteps = 0;
      return 0;
    }

    final now = eventTime;
    if (_lastStepTime != null) {
      final elapsedMs = now.difference(_lastStepTime!).inMilliseconds;

      // 2. Idle timeout: if gap between steps > boutTimeout, walking bout has paused
      if (elapsedMs > boutTimeout.inMilliseconds) {
        _isConfirmedWalking = false;
        _tentativeSteps = 0;
      } else if (elapsedMs > 0) {
        // 3. Cadence and frequency gate:
        // A human bipedal step takes at least ~250ms. High-frequency hand shaking
        // produces events faster than 3.2 Hz (~312ms/step). Reject unnatural spikes.
        final instantaneousCadence = (delta * 1000.0) / elapsedMs;
        if (instantaneousCadence > maxCadenceHz || (elapsedMs < minStepIntervalMs && delta == 1)) {
          // Rapid hand shaking or mechanical vibration detected — discard
          return 0;
        }
      }
    }
    _lastStepTime = now;

    // 4. Bout verification (The 8-step hysteresis window):
    // True human locomotion occurs in sustained bouts. Sporadic desk movements
    // (< 8 steps) are held in a tentative buffer. Once 8 consecutive steps
    // occur within valid cadence, all 8 steps are committed and subsequent
    // steps stream live.
    if (_isConfirmedWalking) {
      return delta;
    } else {
      _tentativeSteps += delta;
      if (_tentativeSteps >= minBoutSteps) {
        _isConfirmedWalking = true;
        final verifiedSteps = _tentativeSteps;
        _tentativeSteps = 0;
        return verifiedSteps;
      }
      // Hold in buffer until continuous walking bout is proven
      return 0;
    }
  }

  /// Resets filter state (e.g. at midnight or manual recalibration).
  void reset() {
    _tentativeSteps = 0;
    _isConfirmedWalking = false;
    _lastStepTime = null;
    _pedestrianStatus = 'unknown';
  }
}
