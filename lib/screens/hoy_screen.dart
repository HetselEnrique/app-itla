import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/task_item.dart';
import '../widgets/day_selector_strip.dart';
import '../widgets/progress_card.dart';
import '../widgets/task_card.dart';

enum FilterType { hoy, proximas, sinFecha }

class HoyScreen extends StatefulWidget {
  const HoyScreen({super.key});

  @override
  State<HoyScreen> createState() => _HoyScreenState();
}

class _HoyScreenState extends State<HoyScreen> {
  FilterType _activeFilter = FilterType.hoy;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? const Color(0xFFFF5F00) : const Color(0xFFE4002B);

    final now = DateTime.now();
    // Formato: VIERNES - 20 NOV 2026
    final dateFormatted =
        DateFormat("EEEE - d MMM y", 'es').format(now).toUpperCase();

    // Obtener lista filtrada
    List<TaskItem> displayedTasks = [];
    switch (_activeFilter) {
      case FilterType.hoy:
        displayedTasks = appState.tasksForCurrentSelectedDate;
        break;
      case FilterType.proximas:
        displayedTasks = appState.upcomingTasks;
        break;
      case FilterType.sinFecha:
        displayedTasks = appState.tasksWithoutDate;
        break;
    }

    final progress = appState.todayProgress;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => appState.syncAulaVirtual(),
          color: accentColor,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
            children: [
              // 1. Barra superior: HE, FECHA, Hola Hetsel, botón rojo Actualizar
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: isDark
                        ? const Color(0xFF1C1D20)
                        : const Color(0xFF9CC6E0),
                    child: Text(
                      appState.session.initials,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateFormatted,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                        Text(
                          'Hola, ${appState.session.studentName}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Botón rojo Actualizar
                  ElevatedButton(
                    onPressed: appState.isLoading
                        ? null
                        : () => appState.syncAulaVirtual(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      minimumSize: const Size(0, 36),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: appState.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Actualizar',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ],
              ),

              // Alerta banner (ej: Cloudflare o error de sesión)
              if (appState.statusBanner != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: accentColor),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: accentColor, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          appState.statusBanner!,
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        color: accentColor,
                        onPressed: () => appState.clearStatusBanner(),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 18),

              // 2. Tira de días de la semana
              DaySelectorStrip(
                selectedDate: appState.selectedDate,
                onSelectDate: (date) {
                  appState.setSelectedDate(date);
                  setState(() => _activeFilter = FilterType.hoy);
                },
              ),

              const SizedBox(height: 18),

              // 3. Tarjeta Progreso de hoy: cuántas van hechas, círculo y barra
              ProgressCard(
                doneCount: progress['done'],
                totalCount: progress['total'],
                percentage: progress['percent'],
              ),

              const SizedBox(height: 18),

              // 4. Filtros: Hoy / Próximas / Sin fecha
              Row(
                children: [
                  _buildFilterChip('Hoy', FilterType.hoy, accentColor),
                  const SizedBox(width: 8),
                  _buildFilterChip('Próximas', FilterType.proximas, accentColor),
                  const SizedBox(width: 8),
                  _buildFilterChip('Sin fecha', FilterType.sinFecha, accentColor),
                ],
              ),

              const SizedBox(height: 16),

              // 5. Lista de tareas
              if (displayedTasks.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 48,
                        color: isDark ? Colors.white30 : Colors.black26,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _activeFilter == FilterType.hoy
                            ? 'No hay tareas para este día'
                            : (_activeFilter == FilterType.proximas
                                ? 'No hay tareas próximas pendientes'
                                : 'No hay tareas sin fecha'),
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black45,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...displayedTasks.map(
                  (task) => TaskCard(
                    task: task,
                    onToggleDone: () => appState.toggleTaskDone(task.id),
                  ),
                ),

              const SizedBox(height: 12),

              // 6. Tarjeta oscura "Lo que viene"
              _buildLoQueVieneCard(appState, isDark),

              const SizedBox(height: 60), // Margen para el FAB inferior
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, FilterType type, Color activeColor) {
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

  Widget _buildLoQueVieneCard(AppState appState, bool isDark) {
    final upcoming = appState.upcomingTasks;
    if (upcoming.isEmpty) return const SizedBox.shrink();

    // Encontrar la próxima fecha con tareas
    final nextDate = upcoming.first.dueDate;
    final formattedDate = nextDate != null
        ? DateFormat("EEEE d 'de' MMMM", 'es').format(nextDate)
        : 'Próximamente';

    final tasksForNextDate = upcoming
        .where((t) =>
            t.dueDate != null &&
            t.dueDate!.year == nextDate?.year &&
            t.dueDate!.month == nextDate?.month &&
            t.dueDate!.day == nextDate?.day)
        .length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1D20), // Tarjeta oscura fija según diseño
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lo que viene',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$formattedDate - $tasksForNextDate ${tasksForNextDate == 1 ? 'tarea' : 'tareas'} asignadas.',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
