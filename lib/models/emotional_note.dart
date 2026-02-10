class EmotionalNote {
  final int? id;
  final String content;
  final DateTime createdAt;
  final DateTime expiresAt;

  EmotionalNote({
    this.id,
    required this.content,
    required this.createdAt,
    required this.expiresAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  factory EmotionalNote.fromMap(Map<String, dynamic> map) {
    return EmotionalNote(
      id: map['id'],
      content: map['content'],
      createdAt: DateTime.parse(map['createdAt']),
      expiresAt: DateTime.parse(map['expiresAt']),
    );
  }
}
