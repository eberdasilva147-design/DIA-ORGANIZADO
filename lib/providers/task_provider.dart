import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../services/data_service.dart';
import '../services/notification_service.dart';

class TaskProvider extends ChangeNotifier {
  List<TaskModel> _tasks = [];
  bool _loading = false;

  List<TaskModel> get tasks => _tasks;
  bool get loading => _loading;

  List<TaskModel> get pending =>
      _tasks.where((t) => !t.concluida).toList()
        ..sort((a, b) {
          const order = {'h': 0, 'm': 1, 'l': 2};
          return (order[a.prioridade] ?? 1).compareTo(order[b.prioridade] ?? 1);
        });

  List<TaskModel> get completed =>
      _tasks.where((t) => t.concluida).toList();

  List<TaskModel> get todayTasks {
    final now = DateTime.now();
    return pending.where((t) {
      final dt = t.dateTime;
      if (dt == null) return false;
      return dt.day == now.day && dt.month == now.month && dt.year == now.year;
    }).take(10).toList();
  }

  TaskModel? get nextReminder {
    final now = DateTime.now();
    final upcoming = pending
        .where((t) => t.lembrete && (t.dateTime?.isAfter(now) ?? false))
        .toList();
    if (upcoming.isEmpty) return null;
    upcoming.sort((a, b) => a.dateTime!.compareTo(b.dateTime!));
    return upcoming.first;
  }

  void loadTasks() {
    _loading = true;
    notifyListeners();
    DataService.instance.streamTasks().listen((list) {
      _tasks = list.map((t) => t.copyWith(atrasada: t.isOverdue)).toList();
      _loading = false;
      notifyListeners();
    });
  }

  Future<void> addTask({
    required String nome,
    required String data,
    required String horario,
    required String prioridade,
    bool lembrete = false,
    String observacao = '',
    int lembreteMinAntes = 0,
  }) async {
    final task = TaskModel(
      id: const Uuid().v4(),
      nome: nome,
      data: data,
      horario: horario,
      prioridade: prioridade,
      lembrete: lembrete,
      observacao: observacao,
      lembreteMinAntes: lembreteMinAntes,
    );
    await DataService.instance.addTask(task);
    await _scheduleReminder(task);
  }

  Future<void> completeTask(String id) async {
    final task = _tasks.firstWhere((t) => t.id == id);
    await DataService.instance
        .updateTask(task.copyWith(concluida: true, atrasada: false));
    await NotificationService().cancelNotification(_notificationId(id));
  }

  Future<void> rescheduleTask(String id, String data, String horario) async {
    final task = _tasks.firstWhere((t) => t.id == id);
    final updated = task.copyWith(data: data, horario: horario, atrasada: false);
    await DataService.instance.updateTask(updated);
    await _scheduleReminder(updated);
  }

  Future<void> deleteTask(String id) async {
    await DataService.instance.deleteTask(id);
    await NotificationService().cancelNotification(_notificationId(id));
  }

  Future<void> updateTask(TaskModel task) async {
    await DataService.instance.updateTask(task);
    await _scheduleReminder(task);
  }

  /// Mostra/oculta a tarefa da Home (continua na lista de Tarefas).
  Future<void> toggleOcultarDaHome(String id) async {
    final t = _tasks.firstWhere((x) => x.id == id);
    await DataService.instance
        .updateTask(t.copyWith(ocultarDaHome: !t.ocultarDaHome));
  }

  // O plugin de notificações exige id int; deriva um estável do id da tarefa.
  int _notificationId(String taskId) => taskId.hashCode & 0x7fffffff;

  Future<void> _scheduleReminder(TaskModel task) async {
    final notifId = _notificationId(task.id);
    await NotificationService().cancelNotification(notifId);
    // Dispara na antecedência escolhida (horário − lembreteMinAntes)
    final dt = task.lembreteDateTime;
    if (!task.lembrete || task.concluida || dt == null || !dt.isAfter(DateTime.now())) {
      return;
    }
    final quando = task.lembreteMinAntes > 0
        ? ' (lembrete ${task.lembreteMinAntes} min antes)'
        : '';
    await NotificationService().scheduleTaskNotification(
      id: notifId,
      title: '⏰ Lembrete',
      body: '${task.nome} — ${task.horario}$quando',
      scheduledDate: dt,
    );
  }
}
