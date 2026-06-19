import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/dia_colors.dart';
import '../../utils/l10n_ext.dart';
import '../../widgets/task_card.dart';
import 'task_create_modal.dart';

/// Reagenda uma tarefa: escolhe nova data e horário e atualiza.
Future<void> rescheduleTaskFlow(BuildContext context, TaskModel task) async {
  final now = DateTime.now();
  final initial = task.dateTime ?? now;
  final firstDate = initial.isBefore(now) ? now : initial;
  final d = await showDatePicker(
    context: context,
    initialDate: firstDate,
    firstDate: now.subtract(const Duration(days: 1)),
    lastDate: now.add(const Duration(days: 365 * 2)),
    builder: (ctx, child) => Theme(
      data: ThemeData.light().copyWith(
        colorScheme: const ColorScheme.light(primary: AppColors.primary),
      ),
      child: child!,
    ),
  );
  if (d == null || !context.mounted) return;
  final t = await showTimePicker(
    context: context,
    initialTime: TimeOfDay(hour: initial.hour, minute: initial.minute),
    builder: (ctx, child) => Theme(
      data: ThemeData.light().copyWith(
        colorScheme: const ColorScheme.light(primary: AppColors.primary),
      ),
      child: child!,
    ),
  );
  if (t == null || !context.mounted) return;
  final data = DateFormat('dd/MM/yyyy').format(d);
  final horario =
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  await context.read<TaskProvider>().rescheduleTask(task.id, data, horario);
}

/// Move a tarefa para a lixeira com confirmação.
Future<void> confirmDeleteTask(BuildContext context, TaskModel task) async {
  final l = context.l10n;
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: context.colors.card,
      title: Text(l.moveToTrash,
          style: TextStyle(color: context.colors.textPrimary)),
      content: Text(
          l.moveToTrashTaskMsg(task.nome),
          style: TextStyle(color: context.colors.textSecondary)),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel)),
        TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.actionDelete,
                style: const TextStyle(color: AppColors.error))),
      ],
    ),
  );
  if (ok == true && context.mounted) {
    await context.read<TaskProvider>().softDeleteTask(task.id);
  }
}

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: context.colors.background,
        appBar: AppBar(
          title: Text(l.tasksTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: AppColors.accent),
              onPressed: () => TaskCreateModal.show(context),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: l.pendingTab),
              Tab(text: l.completedTab),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _PendingTasksList(),
            _CompletedTasksList(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'fab_tarefas',
          onPressed: () => TaskCreateModal.show(context),
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(l.newTaskFab,
              style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}

class _PendingTasksList extends StatelessWidget {
  const _PendingTasksList();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final tasks = context.watch<TaskProvider>().pending;
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, size: 56, color: AppColors.success),
            const SizedBox(height: 12),
            Text(l.noPendingTasks,
                style: TextStyle(color: context.colors.textSecondary, fontSize: 16)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: tasks.length,
      itemBuilder: (_, i) => TaskCard(
        task: tasks[i],
        onComplete: () =>
            context.read<TaskProvider>().completeTask(tasks[i].id),
        onEdit: () => TaskCreateModal.show(context, task: tasks[i]),
        onReschedule: () => rescheduleTaskFlow(context, tasks[i]),
        onDelete: () => confirmDeleteTask(context, tasks[i]),
      ),
    );
  }
}

class _CompletedTasksList extends StatelessWidget {
  const _CompletedTasksList();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final tasks = context.watch<TaskProvider>().completed;
    if (tasks.isEmpty) {
      return Center(
        child: Text(l.noCompletedTasks,
            style: TextStyle(color: context.colors.textSecondary)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
      itemCount: tasks.length,
      itemBuilder: (_, i) => TaskCard(
        task: tasks[i],
        onComplete: () {},
        onDelete: () => confirmDeleteTask(context, tasks[i]),
      ),
    );
  }
}
