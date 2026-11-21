enum TaskOrigin { aulaVirtual, manual }

enum TaskComplexity { simple, conTrabajo }

class TaskItem {
  final String id;
  final String title;
  final String courseName;
  final String? courseCode;
  final String? topic;
  final String? description;
  final DateTime? dueDate;
  bool isDone;
  final TaskOrigin origin;
  final TaskComplexity complexity;
  final String? url;

  TaskItem({
    required this.id,
    required this.title,
    required this.courseName,
    this.courseCode,
    this.topic,
    this.description,
    this.dueDate,
    this.isDone = false,
    this.origin = TaskOrigin.aulaVirtual,
    this.complexity = TaskComplexity.simple,
    this.url,
  });

  /// Indica si la tarea vence hoy
  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  /// Indica si la tarea está vencida o vence pronto (para marcar URGENTE)
  bool get isUrgent {
    if (dueDate == null || isDone) return false;
    final now = DateTime.now();
    final difference = dueDate!.difference(now);
    return isDueToday || (difference.inHours <= 24 && !difference.isNegative);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'courseName': courseName,
        'courseCode': courseCode,
        'topic': topic,
        'description': description,
        'dueDate': dueDate?.toIso8601String(),
        'isDone': isDone,
        'origin': origin.name,
        'complexity': complexity.name,
        'url': url,
      };

  factory TaskItem.fromJson(Map<String, dynamic> json) => TaskItem(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        courseName: json['courseName'] ?? '',
        courseCode: json['courseCode'],
        topic: json['topic'],
        description: json['description'],
        dueDate: json['dueDate'] != null ? DateTime.tryParse(json['dueDate']) : null,
        isDone: json['isDone'] ?? false,
        origin: json['origin'] == 'manual' ? TaskOrigin.manual : TaskOrigin.aulaVirtual,
        complexity: json['complexity'] == 'conTrabajo'
            ? TaskComplexity.conTrabajo
            : TaskComplexity.simple,
        url: json['url'],
      );
}
