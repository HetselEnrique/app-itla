import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/task_item.dart';
import '../models/course.dart';

class AgregarTareaScreen extends StatefulWidget {
  final VoidCallback? onTaskAdded;

  const AgregarTareaScreen({super.key, this.onTaskAdded});

  @override
  State<AgregarTareaScreen> createState() => _AgregarTareaScreenState();
}

class _AgregarTareaScreenState extends State<AgregarTareaScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedCourse;
  final _topicController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDueDate;
  TaskComplexity _selectedComplexity = TaskComplexity.simple;

  @override
  void dispose() {
    _topicController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 180)),
    );
    if (picked != null) {
      setState(() => _selectedDueDate = picked);
    }
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCourse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una materia')),
      );
      return;
    }

    final appState = Provider.of<AppState>(context, listen: false);

    final newTask = TaskItem(
      id: 'manual_${DateTime.now().millisecondsSinceEpoch}',
      title: _descriptionController.text.trim(),
      courseName: _selectedCourse!,
      topic: _topicController.text.trim(),
      description: _descriptionController.text.trim(),
      dueDate: _selectedDueDate,
      origin: TaskOrigin.manual,
      complexity: _selectedComplexity,
    );

    appState.addTask(newTask);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _selectedComplexity == TaskComplexity.conTrabajo
              ? 'Tarea guardada. Alerta programada para 3-4 días antes.'
              : 'Tarea guardada. Alerta programada para 1 día antes.',
        ),
      ),
    );

    if (widget.onTaskAdded != null) {
      widget.onTaskAdded!();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? const Color(0xFFFF5F00) : const Color(0xFFE4002B);

    final inputFill = isDark ? const Color(0xFF1C1D20) : const Color(0xFFE2EDF5);
    final courses = appState.courses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar tarea'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Para la clase presencial',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 20),

                // 1. MATERIA
                _buildFieldLabel('MATERIA'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: inputFill,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedCourse,
                      hint: const Text('Seleccionar materia...'),
                      items: courses.map((Course c) {
                        return DropdownMenuItem<String>(
                          value: c.name,
                          child: Text(c.name),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedCourse = val),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // 2. TEMA
                _buildFieldLabel('TEMA'),
                TextFormField(
                  controller: _topicController,
                  decoration: InputDecoration(
                    hintText: 'Ej. Simple Past, Derivadas, etc.',
                    filled: true,
                    fillColor: inputFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Escribe el tema' : null,
                ),

                const SizedBox(height: 18),

                // 3. QUE HAY QUE HACER
                _buildFieldLabel('QUE HAY QUE HACER'),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Ej. Escribir 10 oraciones en pasado',
                    filled: true,
                    fillColor: inputFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Escribe qué hay que hacer' : null,
                ),

                const SizedBox(height: 18),

                // 4. FECHA DE ENTREGA
                _buildFieldLabel('FECHA DE ENTREGA'),
                InkWell(
                  onTap: _pickDueDate,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                    decoration: BoxDecoration(
                      color: inputFill,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDueDate == null
                              ? 'Tocar para seleccionar fecha'
                              : DateFormat("EEEE d 'de' MMMM", 'es')
                                  .format(_selectedDueDate!),
                          style: TextStyle(
                            fontSize: 15,
                            color: _selectedDueDate == null
                                ? Colors.grey
                                : (isDark ? Colors.white : Colors.black87),
                          ),
                        ),
                        Icon(Icons.calendar_month, color: accentColor),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 5. TIPO: Simple vs Con trabajo
                _buildFieldLabel('TIPO DE TAREA'),
                Row(
                  children: [
                    _buildComplexityOption(
                      title: 'Simple',
                      complexity: TaskComplexity.simple,
                      accentColor: accentColor,
                    ),
                    const SizedBox(width: 12),
                    _buildComplexityOption(
                      title: 'Con trabajo',
                      complexity: TaskComplexity.conTrabajo,
                      accentColor: accentColor,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Tipo con trabajo = video, maqueta, grabar o editar. Avisa 3-4 días antes.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),

                const SizedBox(height: 32),

                // BOTÓN GUARDAR TAREA
                ElevatedButton(
                  onPressed: _saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Guardar tarea',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildComplexityOption({
    required String title,
    required TaskComplexity complexity,
    required Color accentColor,
  }) {
    final isSelected = _selectedComplexity == complexity;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedComplexity = complexity),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? accentColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? accentColor : Colors.grey.shade400,
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : null,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
