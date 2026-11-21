import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/task_item.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(initSettings);
  }

  /// Alerta automática según la especificación del diseño:
  /// - Simple: avisa 1 día antes.
  /// - Con trabajo (video, maqueta, grabar, editar): avisa 3-4 días antes.
  Future<void> scheduleTaskAlert(TaskItem task) async {
    if (task.dueDate == null) return;

    final daysBefore = task.complexity == TaskComplexity.conTrabajo ? 3 : 1;
    final scheduledDate = task.dueDate!.subtract(Duration(days: daysBefore));

    // Si la fecha ya pasó, no se programa
    if (scheduledDate.isBefore(DateTime.now())) return;

    final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'itla_task_alerts',
      'Alertas de Tareas ITLA',
      channelDescription: 'Notificaciones anticipadas para tareas del ITLA',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    final title = task.complexity == TaskComplexity.conTrabajo
        ? '⚠️ Tarea con Trabajo próxima (${task.courseName})'
        : '📌 Tarea por vencer mañana (${task.courseName})';

    final body = '${task.title} - Vence: ${task.dueDate!.day}/${task.dueDate!.month}';

    try {
      await _notificationsPlugin.zonedSchedule(
        task.id.hashCode,
        title,
        body,
        tzDateTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {
      // Ignorar en plataformas sin soporte exacto de alarmas
    }
  }

  Future<void> cancelAlert(String taskId) async {
    try {
      await _notificationsPlugin.cancel(taskId.hashCode);
    } catch (_) {}
  }
}
