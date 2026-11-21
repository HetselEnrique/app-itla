class NoteItem {
  final String id;
  final String subject; // La materia como título (ej: Inglés, Precálculo)
  final String content; // Apuntes libres
  final DateTime createdAt;

  NoteItem({
    required this.id,
    required this.subject,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'subject': subject,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
      };

  factory NoteItem.fromJson(Map<String, dynamic> json) => NoteItem(
        id: json['id'] ?? '',
        subject: json['subject'] ?? '',
        content: json['content'] ?? '',
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
            : DateTime.now(),
      );
}
