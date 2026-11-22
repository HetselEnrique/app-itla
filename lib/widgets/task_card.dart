import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task_item.dart';

class TaskCard extends StatelessWidget {
  final TaskItem task;
  final VoidCallback onToggleDone;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggleDone,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor =
        isDark ? const Color(0xFFFF5F00) : const Color(0xFFE4002B);

    final cardBg = isDark ? const Color(0xFF1C1D20) : const Color(0xFF9CC6E0);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subtextColor = isDark ? Colors.white70 : const Color(0xFF333333);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onToggleDone,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Etiqueta de URGENTE / VENCE HOY en rojo
                if (task.isUrgent)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'URGENTE / VENCE HOY',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Checkbox para marcar hecha
                    GestureDetector(
                      onTap: onToggleDone,
                      child: Container(
                        margin: const EdgeInsets.only(right: 12, top: 2),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: task.isDone ? accentColor : Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: task.isDone
                                ? accentColor
                                : Colors.grey.shade400,
                            width: 2,
                          ),
                        ),
                        child: task.isDone
                            ? const Icon(Icons.check,
                                size: 16, color: Colors.white)
                            : null,
                      ),
                    ),

                    // Título y detalles
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              decoration: task.isDone
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            task.courseName,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: subtextColor,
                            ),
                          ),
                          if (task.topic != null && task.topic!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Tema: ${task.topic}',
                              style: TextStyle(
                                fontSize: 12,
                                color: subtextColor.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.schedule,
                                  size: 14, color: subtextColor),
                              const SizedBox(width: 4),
                              Text(
                                task.dueDate != null
                                    ? DateFormat('EEEE d MMMM', 'es')
                                        .format(task.dueDate!)
                                    : 'Sin fecha',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: subtextColor,
                                ),
                              ),
                              if (task.origin == TaskOrigin.manual) ...[
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    task.complexity == TaskComplexity.conTrabajo
                                        ? 'Con trabajo'
                                        : 'Presencial',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: subtextColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
