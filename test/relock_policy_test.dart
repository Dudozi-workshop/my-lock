import 'package:flutter_test/flutter_test.dart';
import 'package:my_lock/lock_engine/relock_policy.dart';

void main() {
  test('relock policies expose expected delays', () {
    expect(RelockPolicy.immediate.delay, Duration.zero);
    expect(RelockPolicy.after30Seconds.delay, const Duration(seconds: 30));
    expect(RelockPolicy.after1Minute.delay, const Duration(minutes: 1));
    expect(RelockPolicy.screenOff.delay, isNull);
  });

  test('screen-off policy is event driven', () {
    expect(RelockPolicy.screenOff.requiresScreenOffEvent, isTrue);
    expect(RelockPolicy.immediate.requiresScreenOffEvent, isFalse);
  });
}
