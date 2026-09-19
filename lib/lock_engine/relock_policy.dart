enum RelockPolicy {
  immediate(
    label: '즉시',
    summary: '앱을 벗어나면 즉시',
    delay: Duration.zero,
  ),
  after30Seconds(
    label: '30초 후',
    summary: '앱을 벗어난 뒤 30초',
    delay: Duration(seconds: 30),
  ),
  after1Minute(
    label: '1분 후',
    summary: '앱을 벗어난 뒤 1분',
    delay: Duration(minutes: 1),
  ),
  screenOff(
    label: '화면이 꺼질 때',
    summary: '화면이 꺼지면 다시 잠금',
    delay: null,
    requiresScreenOffEvent: true,
  );

  const RelockPolicy({
    required this.label,
    required this.summary,
    required this.delay,
    this.requiresScreenOffEvent = false,
  });

  final String label;
  final String summary;
  final Duration? delay;
  final bool requiresScreenOffEvent;
}
