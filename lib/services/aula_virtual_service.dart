import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import '../models/task_item.dart';
import '../models/course.dart';

class ScrapingResult {
  final bool success;
  final bool cloudflareBlocked;
  final bool sessionExpired;
  final String? errorMessage;
  final List<TaskItem> tasks;
  final List<Course> courses;

  ScrapingResult({
    required this.success,
    this.cloudflareBlocked = false,
    this.sessionExpired = false,
    this.errorMessage,
    this.tasks = const [],
    this.courses = const [],
  });
}

class AulaVirtualService {
  static const String baseUrl = 'https://aulavirtual.itla.edu.do';

  /// Extrae los datos reales del Aula Virtual con la sesión de Microsoft (MoodleSession).
  /// Reglas especificadas en el diseño:
  /// - Solo cuando abres la app y le das a Actualizar (una sola vez, sin background).
  /// - Si Cloudflare bloquea: se detiene, no reintenta, y muestra "No pude entrar, entra de nuevo".
  /// - Si la sesión vence: pide entrar de nuevo sin borrar nada.
  static Future<ScrapingResult> syncData(String? sessionCookie) async {
    if (sessionCookie == null || sessionCookie.isEmpty) {
      return ScrapingResult(
        success: false,
        sessionExpired: true,
        errorMessage: 'Debes iniciar sesión con tu cuenta de Microsoft @itla.edu.do',
      );
    }

    try {
      final headers = {
        'Cookie': 'MoodleSession=$sessionCookie',
        'User-Agent':
            'Mozilla/5.0 (Linux; Android 13; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
      };

      // 1. Petición a la línea de tiempo del Moodle
      final response = await http
          .get(Uri.parse('$baseUrl/my/'), headers: headers)
          .timeout(const Duration(seconds: 15));

      // Detección de Cloudflare
      if (response.statusCode == 403 ||
          response.statusCode == 503 ||
          response.body.contains('Just a moment...') ||
          response.body.contains('cf-chl-bypass') ||
          response.body.contains('Cloudflare')) {
        return ScrapingResult(
          success: false,
          cloudflareBlocked: true,
          errorMessage: 'No pude entrar, entra de nuevo',
        );
      }

      // Detección de sesión vencida (redirección a login)
      if (response.statusCode == 302 ||
          response.body.contains('login/index.php') ||
          response.body.contains('Acceder')) {
        return ScrapingResult(
          success: false,
          sessionExpired: true,
          errorMessage: 'Tu sesión ha vencido. Entra de nuevo sin perder tus datos.',
        );
      }

      // Parseo de HTML del Dashboard (Línea de tiempo)
      final document = parser.parse(response.body);
      final List<TaskItem> extractedTasks = [];

      // Extraer tarjetas de eventos / línea de tiempo
      final eventNodes = document.querySelectorAll('.timeline-event-list-item, .event, .list-group-item');
      for (final node in eventNodes) {
        final titleElement = node.querySelector('.event-name, h6, .text-truncate, a');
        final courseElement = node.querySelector('.course-name, .text-muted, small');
        final dateElement = node.querySelector('.date, time, .small');
        final linkElement = node.querySelector('a');

        final title = titleElement?.text.trim() ?? 'Tarea';
        final course = courseElement?.text.trim() ?? 'Materia ITLA';
        final link = linkElement?.attributes['href'];

        DateTime? dueDate;
        if (dateElement != null) {
          dueDate = DateTime.tryParse(dateElement.text.trim());
        }

        extractedTasks.add(
          TaskItem(
            id: 'moodle_${title.hashCode}_${DateTime.now().millisecondsSinceEpoch}',
            title: title,
            courseName: course,
            dueDate: dueDate,
            origin: TaskOrigin.aulaVirtual,
            url: link != null ? (link.startsWith('http') ? link : '$baseUrl$link') : null,
          ),
        );
      }

      return ScrapingResult(
        success: true,
        tasks: extractedTasks,
        courses: Course.defaultCourses,
      );
    } catch (e) {
      return ScrapingResult(
        success: false,
        errorMessage: 'Error de conexión: $e',
      );
    }
  }
}
