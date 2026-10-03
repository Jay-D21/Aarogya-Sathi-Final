import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/step_filter_service.dart';

void main() {
  group('StepFilterService - Hand Movement & Cadence Filter', () {
    late StepFilterService filter;

    setUp(() {
      filter = StepFilterService(
        minBoutSteps: 8,
        maxCadenceHz: 3.2,
        minStepIntervalMs: 250,
        boutTimeout: const Duration(seconds: 3),
      );
    });

    test('Rejects step deltas when pedestrian status is explicitly stopped', () {
      filter.updatePedestrianStatus('stopped');
      final base = DateTime(2026, 10, 3, 12, 0, 0);

      // User moves phone in hand while sitting at desk
      final added1 = filter.processStepDelta(5, base);
      final added2 = filter.processStepDelta(10, base.add(const Duration(milliseconds: 600)));

      expect(added1, 0);
      expect(added2, 0);
      expect(filter.isConfirmedWalking, false);
      expect(filter.pendingTentativeSteps, 0);
    });

    test('Rejects high-frequency hand shaking (> 3.2 Hz cadence)', () {
      final base = DateTime(2026, 10, 3, 12, 0, 0);

      // First step initializes time
      filter.processStepDelta(1, base);

      // Shaking phone rapidly (e.g. 5 steps in 200ms = 25 Hz)
      final shakeAdded = filter.processStepDelta(5, base.add(const Duration(milliseconds: 200)));
      expect(shakeAdded, 0);

      // Another rapid shake within 100ms
      final rapidAdded = filter.processStepDelta(1, base.add(const Duration(milliseconds: 300)));
      expect(rapidAdded, 0);
    });

    test('Buffers and discards isolated desk fidgets (< 8 steps) after idle timeout', () {
      final base = DateTime(2026, 10, 3, 12, 0, 0);

      // User picks up phone, moves it 3 times (normal pace 600ms)
      expect(filter.processStepDelta(1, base), 0);
      expect(filter.processStepDelta(1, base.add(const Duration(milliseconds: 600))), 0);
      expect(filter.processStepDelta(1, base.add(const Duration(milliseconds: 1200))), 0);
      expect(filter.pendingTentativeSteps, 3);
      expect(filter.isConfirmedWalking, false);

      // User leaves phone on desk for 4 seconds (> 3s timeout)
      final idleTime = base.add(const Duration(seconds: 5));
      // Next movement occurs after timeout -> previous 3 tentative steps discarded
      expect(filter.processStepDelta(1, idleTime), 0);
      expect(filter.pendingTentativeSteps, 1); // Reset to 1, old 3 discarded
    });

    test('Correctly verifies and flushes genuine sustained walking bout', () {
      var base = DateTime(2026, 10, 3, 12, 0, 0);
      int totalVerifiedSteps = 0;

      // Simulate a user taking 12 real walking steps at 600ms cadence (~1.67 steps/sec)
      for (int i = 0; i < 12; i++) {
        final stepTime = base.add(Duration(milliseconds: i * 600));
        final verified = filter.processStepDelta(1, stepTime);
        totalVerifiedSteps += verified;

        if (i < 7) {
          // First 7 steps should be buffered tentatively
          expect(verified, 0);
          expect(filter.isConfirmedWalking, false);
        } else if (i == 7) {
          // 8th step crosses minBoutSteps: flushes entire buffer (8 steps)
          expect(verified, 8);
          expect(filter.isConfirmedWalking, true);
        } else {
          // Steps 9..12 stream live (1 step each)
          expect(verified, 1);
          expect(filter.isConfirmedWalking, true);
        }
      }

      // Total verified steps matches actual walking steps taken
      expect(totalVerifiedSteps, 12);
    });

    test('Expedites confirmation when OS confirms walking status', () {
      final base = DateTime(2026, 10, 3, 12, 0, 0);
      filter.updatePedestrianStatus('walking');

      expect(filter.isConfirmedWalking, true);
      final verified = filter.processStepDelta(2, base);
      expect(verified, 2);
    });

    test('Reset clears all internal states', () {
      filter.updatePedestrianStatus('walking');
      filter.reset();

      expect(filter.isConfirmedWalking, false);
      expect(filter.pedestrianStatus, 'unknown');
      expect(filter.pendingTentativeSteps, 0);
    });
  });
}
