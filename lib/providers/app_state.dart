import 'package:flutter/material.dart';
import '../models/course.dart';
import '../models/task_item.dart';
import '../models/note_item.dart';
import '../models/user_session.dart';
import '../services/storage_service.dart';
import '../services/aula_virtual_service.dart';
import '../services/notification_service.dart';

class AppState extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _isLoading = false;
  String? _statusBanner;
  int _currentTabIndex = 0;
  DateTime _selectedDate = DateTime.now();

  UserSession _session = UserSession();
  List<Course> _courses = Course.defaultCourses;
  List<TaskItem> _tasks = [];
  List<NoteItem> _notes = [];

  // Getters
  bool get isDarkMode => _isDarkMode;
  bool get isLoading => _isLoading;
  String? get statusBanner => _statusBanner;
  int get currentTabIndex => _currentTabIndex;
  DateTime get selectedDate => _selectedDate;
  UserSession get session => _session;
  List<Course> get courses => _courses;
  List<TaskItem> get tasks => _tasks;
  List<NoteItem> get notes => _notes;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    _isDarkMode = await StorageService.loadDarkMode();
    _session = await StorageService.loadSession();
    _courses = await StorageService.loadCourses();
    _tasks = await StorageService.loadTasks();
    _notes = await StorageService.loadNotes();

    // Inicializar servicio de alertas
    await NotificationService().init();

    _isLoading = false;
    notifyListeners();
  }

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await StorageService.saveDarkMode(_isDarkMode);
    notifyListeners();
  }

  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void clearStatusBanner() {
    _statusBanner = null;
    notifyListeners();
  }

  // Login de Microsoft (Guarda sesión pero no contraseña)
  Future<void> loginWithMicrosoft({
    required String cookie,
    String name = 'Hetsel',
    String initials = 'HE',
    String email = 'hetsel@itla.edu.do',
  }) async {
    _session = UserSession(
      studentName: name,
      initials: initials,
      email: email,
      moodleSessionCookie: cookie,
      isLoggedIn: true,
      lastSync: DateTime.now(),
    );
    await StorageService.saveSession(_session);
    notifyListeners();

    // Sincronizar datos de una vez
    await syncAulaVirtual();
  }

  // Sincronización manual al dar a "Actualizar"
  Future<void> syncAulaVirtual() async {
    if (_isLoading) return;
    _isLoading = true;
    _statusBanner = null;
    notifyListeners();

    final result = await AulaVirtualService.syncData(_session.moodleSessionCookie);

    if (result.success) {
      // Mantener las tareas manuales creadas por el estudiante
      final manualTasks = _tasks.where((t) => t.origin == TaskOrigin.manual).toList();
      _tasks = [...manualTasks, ...result.tasks];
      await StorageService.saveTasks(_tasks);

      _session = _session.copyWith(lastSync: DateTime.now());
      await StorageService.saveSession(_session);
    } else {
      if (result.cloudflareBlocked) {
        // Regla: "Si Cloudflare bloquea: se detiene, no reintenta, y muestra No pude entrar, entra de nuevo."
        _statusBanner = 'No pude entrar, entra de nuevo';
      } else if (result.sessionExpired) {
        // Regla: "Si la sesión vence: botón Entra de nuevo, sin borrar nada."
        _session = _session.copyWith(isLoggedIn: false);
        await StorageService.saveSession(_session);
        _statusBanner = result.errorMessage;
      } else {
        _statusBanner = result.errorMessage ?? 'Error al actualizar';
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  // Agregar tarea presencial (manual)
  Future<void> addTask(TaskItem task) async {
    _tasks.insert(0, task);
    await StorageService.saveTasks(_tasks);
    await NotificationService().scheduleTaskAlert(task);
    notifyListeners();
  }

  // Marcar/Desmarcar tarea hecha (se muestra tachada)
  Future<void> toggleTaskDone(String taskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _tasks[index].isDone = !_tasks[index].isDone;
      await StorageService.saveTasks(_tasks);
      notifyListeners();
    }
  }

  // Agregar apuntes de clase
  Future<void> addNote(NoteItem note) async {
    _notes.insert(0, note);
    await StorageService.saveNotes(_notes);
    notifyListeners();
  }

  Future<void> deleteNote(String noteId) async {
    _notes.removeWhere((n) => n.id == noteId);
    await StorageService.saveNotes(_notes);
    notifyListeners();
  }

  // --- FILTROS Y ESTADÍSTICAS PARA LA PANTALLA HOY ---

  List<TaskItem> get tasksForCurrentSelectedDate {
    return _tasks.where((t) {
      if (t.dueDate == null) return false;
      return t.dueDate!.year == _selectedDate.year &&
          t.dueDate!.month == _selectedDate.month &&
          t.dueDate!.day == _selectedDate.day;
    }).toList();
  }

  List<TaskItem> get tasksDueToday {
    return _tasks.where((t) => t.isDueToday).toList();
  }

  List<TaskItem> get upcomingTasks {
    final now = DateTime.now();
    return _tasks.where((t) {
      if (t.dueDate == null) return false;
      return t.dueDate!.isAfter(DateTime(now.year, now.month, now.day, 23, 59, 59));
    }).toList();
  }

  List<TaskItem> get tasksWithoutDate {
    return _tasks.where((t) => t.dueDate == null).toList();
  }

  // Progreso de hoy: X de Y hechas - Z%
  Map<String, dynamic> get todayProgress {
    final todayTasks = tasksDueToday;
    if (todayTasks.isEmpty) {
      return {'done': 0, 'total': 0, 'percent': 0.0};
    }
    final done = todayTasks.where((t) => t.isDone).length;
    final total = todayTasks.length;
    final percent = done / total;
    return {'done': done, 'total': total, 'percent': percent};
  }

  // Tareas por materia
  List<TaskItem> getTasksForCourse(String courseName) {
    return _tasks
        .where((t) =>
            t.courseName.toLowerCase().contains(courseName.toLowerCase()) ||
            courseName.toLowerCase().contains(t.courseName.toLowerCase()))
        .toList();
  }
}
