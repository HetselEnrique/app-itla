import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/custom_bottom_nav.dart';
import 'hoy_screen.dart';
import 'mis_cursos_screen.dart';
import 'notas_screen.dart';
import 'agregar_tarea_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final List<Widget> _screens = const [
    HoyScreen(),
    MisCursosScreen(),
    SizedBox.shrink(), // Placeholder para el botón central +
    NotasScreen(),
  ];

  void _openAddTaskModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: FractionallySizedBox(
          heightFactor: 0.9,
          child: AgregarTareaScreen(
            onTaskAdded: () {
              Navigator.pop(ctx);
              // Cambiar a la pestaña Hoy para ver la tarea agregada
              Provider.of<AppState>(context, listen: false).setTabIndex(0);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;
    final accentColor = isDark ? const Color(0xFFFF5F00) : const Color(0xFFE4002B);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0, // AppBar invisible para diseño limpio
        elevation: 0,
      ),
      body: IndexedStack(
        index: appState.currentTabIndex == 2 ? 0 : appState.currentTabIndex,
        children: _screens,
      ),
      // FAB flotante en el centro: estilo notch
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTaskModal,
        elevation: 4,
        backgroundColor: accentColor,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 32,
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: appState.currentTabIndex,
        onTap: (index) {
          appState.setTabIndex(index);
        },
        onAddTap: _openAddTaskModal,
      ),
    );
  }
}
