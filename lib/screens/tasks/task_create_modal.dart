import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../utils/app_colors.dart';

class TaskCreateModal extends StatefulWidget {
  /// Se informada, o modal abre em modo edição com os campos preenchidos.
  final TaskModel? task;

  const TaskCreateModal({super.key, this.task});

  static Future<void> show(BuildContext context, {TaskModel? task}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<TaskProvider>(),
        child: TaskCreateModal(task: task),
      ),
    );
  }

  @override
  State<TaskCreateModal> createState() => _TaskCreateModalState();
}

class _TaskCreateModalState extends State<TaskCreateModal> {
  final _nameCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _priority = 'm';
  bool _reminder = false;
  int _lembreteMinAntes = 0; // antecedência do lembrete (minutos)

  // Opções de antecedência (minutos → rótulo)
  static const Map<int, String> _antecedencias = {
    0: 'No horário',
    5: '5 minutos antes',
    15: '15 minutos antes',
    30: '30 minutos antes',
    60: '1 hora antes',
    120: '2 horas antes',
    1440: '1 dia antes',
  };

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    if (task != null) {
      _nameCtrl.text = task.nome;
      _obsCtrl.text = task.observacao;
      _priority = task.prioridade;
      _reminder = task.lembrete;
      _lembreteMinAntes = task.lembreteMinAntes;
      final dt = task.dateTime;
      if (dt != null) {
        _selectedDate = dt;
        _selectedTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  String _antecedenciaLabel(int min) =>
      _antecedencias[min] ?? '$min minutos antes';

  Future<void> _pickAntecedencia() async {
    final escolha = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final e in _antecedencias.entries)
              ListTile(
                title: Text(e.value,
                    style: const TextStyle(color: AppColors.textPrimary)),
                trailing: _lembreteMinAntes == e.key
                    ? const Icon(Icons.check, color: AppColors.gold)
                    : null,
                onTap: () => Navigator.pop(context, e.key),
              ),
            ListTile(
              title: const Text('Personalizado…',
                  style: TextStyle(color: AppColors.accent)),
              onTap: () => Navigator.pop(context, -1),
            ),
          ],
        ),
      ),
    );
    if (escolha == null) return;
    if (escolha == -1) {
      await _pickCustomAntecedencia();
    } else {
      setState(() => _lembreteMinAntes = escolha);
    }
  }

  Future<void> _pickCustomAntecedencia() async {
    final ctrl = TextEditingController(
        text: _lembreteMinAntes > 0 ? '$_lembreteMinAntes' : '');
    final min = await showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Antecedência (minutos)',
            style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(hintText: 'Ex.: 45'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () =>
                  Navigator.pop(context, int.tryParse(ctrl.text.trim())),
              child: const Text('OK')),
        ],
      ),
    );
    if (min != null && min >= 0) setState(() => _lembreteMinAntes = min);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      // Em edição, a tarefa pode estar atrasada (data no passado)
      firstDate: _selectedDate.isBefore(now) ? _selectedDate : now,
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (d != null) setState(() => _selectedDate = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (t != null) setState(() => _selectedTime = t);
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    final data = DateFormat('dd/MM/yyyy').format(_selectedDate);
    final horario =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';
    final provider = context.read<TaskProvider>();
    if (_isEditing) {
      await provider.updateTask(widget.task!.copyWith(
        nome: _nameCtrl.text.trim(),
        data: data,
        horario: horario,
        prioridade: _priority,
        lembrete: _reminder,
        observacao: _obsCtrl.text.trim(),
        lembreteMinAntes: _lembreteMinAntes,
        atrasada: false,
      ));
    } else {
      await provider.addTask(
        nome: _nameCtrl.text.trim(),
        data: data,
        horario: horario,
        prioridade: _priority,
        lembrete: _reminder,
        observacao: _obsCtrl.text.trim(),
        lembreteMinAntes: _lembreteMinAntes,
      );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text(_isEditing ? 'Editar Tarefa' : 'Nova Tarefa',
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              autofocus: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Nome da tarefa',
                prefixIcon:
                    Icon(Icons.task_alt, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _obsCtrl,
              minLines: 1,
              maxLines: 3,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Observação (opcional)',
                prefixIcon:
                    Icon(Icons.notes_rounded, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('dd/MM/yyyy').format(_selectedDate),
                            style: const TextStyle(
                                color: AppColors.textPrimary, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: _pickTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.schedule,
                              size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Text(
                            '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                                color: AppColors.textPrimary, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Prioridade',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 8),
            Row(
              children: [
                _priorityChip('h', 'Alta', AppColors.priorityHigh),
                const SizedBox(width: 8),
                _priorityChip('m', 'Média', AppColors.priorityMedium),
                const SizedBox(width: 8),
                _priorityChip('l', 'Baixa', AppColors.priorityLow),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Ativar lembrete',
                    style: TextStyle(color: AppColors.textPrimary)),
                const Spacer(),
                Switch(
                  value: _reminder,
                  onChanged: (v) => setState(() => _reminder = v),
                ),
              ],
            ),
            if (_reminder) ...[
              const SizedBox(height: 4),
              GestureDetector(
                onTap: _pickAntecedencia,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.notifications_active_outlined,
                          size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      const Text('Avisar:',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 14)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _antecedenciaLabel(_lembreteMinAntes),
                          style: const TextStyle(
                              color: AppColors.textPrimary, fontSize: 14),
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down,
                          color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48)),
              child: Text(_isEditing ? 'Salvar alterações' : 'Salvar tarefa'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priorityChip(String value, String label, Color color) {
    final selected = _priority == value;
    return GestureDetector(
      onTap: () => setState(() => _priority = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.2) : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? color : AppColors.border, width: selected ? 2 : 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
