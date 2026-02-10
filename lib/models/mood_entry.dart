class MoodEntry {
  final int? id;
  final int moodScore;
  final String? notes;
  final DateTime timestamp;

  MoodEntry({
    this.id,
    required this.moodScore,
    this.notes,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'moodScore': moodScore,
      'notes': notes,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'],
      moodScore: map['moodScore'],
      notes: map['notes'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
