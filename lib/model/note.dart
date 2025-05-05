class Note {
  final int? id;
  final String title;
  final String content;
  final int categoryId;
  final String priority;
  final String userId;
  final DateTime createdAt;
  final bool isFavorite;
  final bool isArchived;

  const Note({
    this.id,
    required this.title,
    required this.content,
    required this.categoryId,
    required this.priority,
    required this.userId,
    required this.createdAt,
    required this.isFavorite,
    required this.isArchived
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category_id': categoryId,
      'priority': priority,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'is_favorite': isFavorite ? 1 : 0,
      'is_archived': isArchived ? 1 : 0
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      categoryId: map['category_id'],
      priority: map['priority'],
      userId: map['user_id'],
      createdAt: DateTime.parse(map['created_at']),
      isFavorite: map['is_favorite'] == 1,
      isArchived: map['is_archived'] == 1
    );
  }
}
