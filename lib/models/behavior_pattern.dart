class BehaviorPattern {
  final int? id;
  final DateTime timestamp;
  final int appOpenCount;
  final int screenTimeSeconds;
  final String timeOfDay;
  final int interactionSpeed;

  BehaviorPattern({
    this.id,
    required this.timestamp,
    required this.appOpenCount,
    required this.screenTimeSeconds,
    required this.timeOfDay,
    required this.interactionSpeed,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'appOpenCount': appOpenCount,
      'screenTimeSeconds': screenTimeSeconds,
      'timeOfDay': timeOfDay,
      'interactionSpeed': interactionSpeed,
    };
  }

  factory BehaviorPattern.fromMap(Map<String, dynamic> map) {
    return BehaviorPattern(
      id: map['id'],
      timestamp: DateTime.parse(map['timestamp']),
      appOpenCount: map['appOpenCount'],
      screenTimeSeconds: map['screenTimeSeconds'],
      timeOfDay: map['timeOfDay'],
      interactionSpeed: map['interactionSpeed'],
    );
  }
}
