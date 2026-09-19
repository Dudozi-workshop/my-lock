import 'package:flutter_test/flutter_test.dart';
import 'package:my_lock/lock_engine/relock_policy.dart';

void main() {
  test('timed relock policies expose expected delays', () {
    expect(RelockPolicy.immediate.delay, Duration.zero);
    expect(RelockPolicy.after30Seconds.delay, const Duration(seconds: 30));
    expect(RelockPolicy.after1Minute.delay, const Duration(minutes: 1));
  });

  test('screen off policy uses event trigger instead of timer', () {
    expect(RelockPolicy.screenOff.delay, isNull);
    expect(RelockPolicy.screenOff.requiresScreenOffEvent, isTrue);
  });
}
