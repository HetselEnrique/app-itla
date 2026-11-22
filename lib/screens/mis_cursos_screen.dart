import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/course.dart';
import '../models/task_item.dart';
import '../widgets/task_card.dart';

enum CourseFilter { todos, conTareas, sinTareas }

class MisCursosScreen extends StatefulWidget {
  const MisCursosScreen({super.key});

  @override
  State<MisCursosScreen> createState() => _MisCursosScreenState();
}

class _MisCursosScreenState extends State<MisCursosScreen> {
  CourseFilter _activeFilter = CourseFilter.todos;
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor =
        isDark ? const Color(0xFFFF5F00) : const Color(0xFFE4002B);

    final courses = appState.courses;

    // Filtrar cursos según pestaña y búsqueda
    final filteredCourses = courses.where((course) {
      final tasks = appState.getTasksForCourse(course.name);
      final hasTasks = tasks.isNotEmpty;

      // Filtro de estado
      if (_activeFilter == CourseFilter.conTareas && !hasTasks) return false;
      if (_activeFilter == CourseFilter.sinTareas && hasTasks) return false;

      // Filtro de búsqueda
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchName = course.name.toLowerCase().contains(query);
        final matchCode = course.code.toLowerCase().contains(query);
        final matchProfessor = course.professor.toLowerCase().contains(query);
        return matchName || matchCode || matchProfessor;
      }

      return true;
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
          children: [
            // Cabecera: Título "Mis cursos", periodo y botón Buscar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mis cursos',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '2026-C-3 - ${courses.length} CURSOS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                      if (!_isSearching) _searchQuery = '';
                    });
                  },
                  icon: Icon(_isSearching ? Icons.close : Icons.search),
                  color: accentColor,
                ),
              ],
            ),

            if (_isSearching) ...[
              const SizedBox(height: 12),
              TextField(
                autofocus: true,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Buscar por materia, código o profesor...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1C1D20) : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Filtros: Todos / Con tareas / Sin tareas
            Row(
              children: [
                _buildFilterChip('Todos', CourseFilter.todos, accentColor),
                const SizedBox(width: 8),
                _buildFilterChip(
                    'Con tareas', CourseFilter.conTareas, accentColor),
                const SizedBox(width: 8),
                _buildFilterChip(
                    'Sin tareas', CourseFilter.sinTareas, accentColor),
              ],
            ),

            const SizedBox(height: 18),

            // Lista de los 7 cursos
            ...filteredCourses.map((course) {
              final courseTasks = appState.getTasksForCourse(course.name);
              final taskCount = courseTasks.length;
              final nextTask =
                  courseTasks.isNotEmpty ? courseTasks.first : null;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1C1D20)
                      : const Color(0xFF9CC6E0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () =>
                        _showCourseTasksModal(context, course, courseTasks),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${course.code} - ${course.professor}',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.assignment_outlined,
                                size: 14,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                taskCount == 0
                                    ? 'Sin tareas pendientes'
                                    : '$taskCount ${taskCount == 1 ? 'tarea' : 'tareas'} • Próxima: ${nextTask?.title ?? ''}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      isDark ? Colors.white60 : Colors.black54,
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
            }),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, CourseFilter type, Color activeColor) {
    final isSelected = _activeFilter == type;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : Colors.grey.shade400,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : null,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  void _showCourseTasksModal(
      BuildContext context, Course course, List<TaskItem> tasks) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          height: MediaQuery.of(ctx).size.height * 0.7,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1D20) : const Color(0xFFF1F3F4),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                course.name,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                '${course.code} • Prof. ${course.professor}',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              const Divider(),
              Expanded(
                child: tasks.isEmpty
                    ? const Center(
                        child:
                            Text('No hay tareas registradas para esta materia'),
                      )
                    : ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, i) {
                          return TaskCard(
                            task: tasks[i],
                            onToggleDone: () {
                              Provider.of<AppState>(context, listen: false)
                                  .toggleTaskDone(tasks[i].id);
                              Navigator.pop(ctx);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
