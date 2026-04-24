/// Permanent daily journal entry — no expiry, always kept in SQLite.
///
/// Unlike [EmotionalNote] (which auto-deletes), journal entries are the
/// user's personal diary and live indefinitely until explicitly deleted.
class JournalEntry {
  final int? id;
  final String title;
  final String content;

  /// Optional mood tag chosen by the user: 'happy', 'sad', 'anxious',
  /// 'calm', 'energised', 'tired', 'grateful', 'angry', 'neutral'.
  final String? mood;

  final DateTime createdAt;
  final DateTime updatedAt;

  JournalEntry({
    this.id,
    required this.title,
    required this.content,
    this.mood,
    required this.createdAt,
    required this.updatedAt,
  });

  JournalEntry copyWith({
    int? id,
    String? title,
    String? content,
    String? mood,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'content': content,
        'mood': mood,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory JournalEntry.fromMap(Map<String, dynamic> map) => JournalEntry(
        id: map['id'] as int?,
        title: map['title'] as String,
        content: map['content'] as String,
        mood: map['mood'] as String?,
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: DateTime.parse(map['updatedAt'] as String),
      );
}
