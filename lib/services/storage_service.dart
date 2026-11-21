import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/course.dart';
import '../models/task_item.dart';
import '../models/note_item.dart';
import '../models/user_session.dart';

class StorageService {
  static const String _keyTasks = 'itla_tasks';
  static const String _keyCourses = 'itla_courses';
  static const String _keyNotes = 'itla_notes';
  static const String _keySession = 'itla_session';
  static const String _keyDarkMode = 'itla_dark_mode';

  static Future<List<TaskItem>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyTasks);
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(jsonString);
      return list.map((item) => TaskItem.fromJson(item)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveTasks(List<TaskItem> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString(_keyTasks, jsonString);
  }

  static Future<List<Course>> loadCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyCourses);
    if (jsonString == null || jsonString.isEmpty) {
      return Course.defaultCourses;
    }
    try {
      final List<dynamic> list = jsonDecode(jsonString);
      return list.map((item) => Course.fromJson(item)).toList();
    } catch (_) {
      return Course.defaultCourses;
    }
  }

  static Future<void> saveCourses(List<Course> courses) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(courses.map((c) => c.toJson()).toList());
    await prefs.setString(_keyCourses, jsonString);
  }

  static Future<List<NoteItem>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyNotes);
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(jsonString);
      return list.map((item) => NoteItem.fromJson(item)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveNotes(List<NoteItem> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(notes.map((n) => n.toJson()).toList());
    await prefs.setString(_keyNotes, jsonString);
  }

  static Future<UserSession> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keySession);
    if (jsonString == null || jsonString.isEmpty) {
      return UserSession(isLoggedIn: false);
    }
    try {
      return UserSession.fromJson(jsonDecode(jsonString));
    } catch (_) {
      return UserSession(isLoggedIn: false);
    }
  }

  static Future<void> saveSession(UserSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySession, jsonEncode(session.toJson()));
  }

  static Future<bool> loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDarkMode) ?? false;
  }

  static Future<void> saveDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, isDark);
  }
}
