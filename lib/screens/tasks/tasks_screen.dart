import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/task_card.dart';
import 'task_create_modal.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Tarefas'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: AppColors.accent),
              onPressed: () => TaskCreateModal.show(context),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pendentes'),
              Tab(text: 'Concluídas'),
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
          label: const Text('Nova tarefa',
              style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}

class _PendingTasksList extends StatelessWidget {
  const _PendingTasksList();

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskProvider>().pending;
    if (tasks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, size: 56, color: AppColors.success),
            SizedBox(height: 12),
            Text('Nenhuma tarefa pendente!',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
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
        onTap: () => _showOptions(context, tasks[i]),
      ),
    );
  }

  void _showOptions(BuildContext context, TaskModel task) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle, color: AppColors.success),
              title: const Text('Concluir',
                  style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                context.read<TaskProvider>().completeTask(task.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: AppColors.accent),
              title: const Text('Editar / Reagendar',
                  style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                TaskCreateModal.show(context, task: task);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text('Excluir',
                  style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                context.read<TaskProvider>().deleteTask(task.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletedTasksList extends StatelessWidget {
  const _CompletedTasksList();

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskProvider>().completed;
    if (tasks.isEmpty) {
      return const Center(
        child: Text('Nenhuma tarefa concluída ainda.',
            style: TextStyle(color: AppColors.textSecondary)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
      itemCount: tasks.length,
      itemBuilder: (_, i) => TaskCard(
        task: tasks[i],
        onComplete: () {},
      ),
    );
  }
}
