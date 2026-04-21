class GratitudeEntry {
  final int? id;
  final String content;
  final String? category; // 'people', 'moments', 'self', 'nature', 'other'
  final DateTime createdAt;

  GratitudeEntry({
    this.id,
    required this.content,
    this.category,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'category': category ?? 'other',
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory GratitudeEntry.fromMap(Map<String, dynamic> map) {
    return GratitudeEntry(
      id: map['id'],
      content: map['content'],
      category: map['category'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
