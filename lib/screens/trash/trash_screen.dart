import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/note_provider.dart';
import '../../models/task_model.dart';
import '../../models/appointment_model.dart';
import '../../models/note_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/dia_colors.dart';
import '../../utils/l10n_ext.dart';

class TrashScreen extends StatelessWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: c.background,
        appBar: AppBar(
          title: Text(l.trashTitle),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.delete_forever, color: AppColors.error),
              label: Text(l.trashEmptyButton,
                  style: TextStyle(color: AppColors.error, fontSize: 13)),
              onPressed: () => _confirmEmptyTrash(context),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline, size: 16),
                    const SizedBox(width: 6),
                    Text(l.navTasks,
                        style: GoogleFonts.plusJakartaSans(fontSize: 13)),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_month_outlined, size: 16),
                    const SizedBox(width: 6),
                    Text(l.navAgenda,
                        style: GoogleFonts.plusJakartaSans(fontSize: 13)),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.note_outlined, size: 16),
                    const SizedBox(width: 6),
                    Text(l.navNotes,
                        style: GoogleFonts.plusJakartaSans(fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _TasksTrash(),
            _AppointmentsTrash(),
            _NotesTrash(),
          ],
        ),
      ),
    );
  }

  void _confirmEmptyTrash(BuildContext context) {
    final l = context.l10n;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.colors.card,
        title: Text(l.trashEmptyTitle,
            style: TextStyle(color: context.colors.textPrimary)),
        content: Text(
          l.trashEmptyMsg,
          style: TextStyle(color: context.colors.textSecondary),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.cancel)),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final tasks = context.read<TaskProvider>().trashed;
              final appts = context.read<AppointmentProvider>().trashed;
              final notes = context.read<NoteProvider>().trashed;
              for (final t in tasks) {
                await context.read<TaskProvider>().deleteTask(t.id);
              }
              for (final a in appts) {
                await context.read<AppointmentProvider>().deleteAppointment(a.id);
              }
              for (final n in notes) {
                await context.read<NoteProvider>().deleteNote(n.id);
              }
            },
            child: Text(l.trashEmptyButton,
                style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ─── Aba Tarefas ────────────────────────────────────────────────────────────

class _TasksTrash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final items = context.watch<TaskProvider>().trashed;
    if (items.isEmpty) return _EmptyTrash(label: l.trashNoTasks);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
      itemCount: items.length,
      itemBuilder: (_, i) => _TrashTaskCard(task: items[i]),
    );
  }
}

class _TrashTaskCard extends StatelessWidget {
  final TaskModel task;
  const _TrashTaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final priorityColor = AppColors.priorityColor(task.prioridade);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: priorityColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.nome,
                        style: TextStyle(
                            color: c.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: priorityColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                              l.priorityBadge(l.priorityLabel(task.prioridade)),
                              style: TextStyle(
                                  color: priorityColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.timer_outlined,
                            size: 12, color: c.textSecondary),
                        const SizedBox(width: 3),
                        Text(l.daysLeft(task.daysUntilPurge),
                            style: TextStyle(
                                color: c.textSecondary, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _TrashActions(
                      onRestore: () =>
                          context.read<TaskProvider>().restoreTask(task.id),
                      onDelete: () =>
                          _confirmDelete(context, task.nome, () => context
                              .read<TaskProvider>()
                              .deleteTask(task.id)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Aba Agenda ─────────────────────────────────────────────────────────────

class _AppointmentsTrash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final items = context.watch<AppointmentProvider>().trashed;
    if (items.isEmpty) return _EmptyTrash(label: l.trashNoAppts);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
      itemCount: items.length,
      itemBuilder: (_, i) => _TrashApptCard(appt: items[i]),
    );
  }
}

class _TrashApptCard extends StatelessWidget {
  final AppointmentModel appt;
  const _TrashApptCard({required this.appt});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final priorityColor = AppColors.priorityColor(appt.prioridade);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: priorityColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appt.titulo,
                        style: TextStyle(
                            color: c.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      '${appt.dateFormatted}${appt.horario.isNotEmpty ? ' · ${appt.horario}' : ''}',
                      style: TextStyle(color: c.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: priorityColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                              l.priorityBadge(l.priorityLabel(appt.prioridade)),
                              style: TextStyle(
                                  color: priorityColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.timer_outlined,
                            size: 12, color: c.textSecondary),
                        const SizedBox(width: 3),
                        Text(l.daysLeft(appt.daysUntilPurge),
                            style: TextStyle(
                                color: c.textSecondary, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _TrashActions(
                      onRestore: () => context
                          .read<AppointmentProvider>()
                          .restoreAppointment(appt.id),
                      onDelete: () => _confirmDelete(
                          context,
                          appt.titulo,
                          () => context
                              .read<AppointmentProvider>()
                              .deleteAppointment(appt.id)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Aba Notas ───────────────────────────────────────────────────────────────

class _NotesTrash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final items = context.watch<NoteProvider>().trashed;
    if (items.isEmpty) return _EmptyTrash(label: l.trashNoNotes);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
      itemCount: items.length,
      itemBuilder: (_, i) => _TrashNoteCard(note: items[i]),
    );
  }
}

class _TrashNoteCard extends StatelessWidget {
  final NoteModel note;
  const _TrashNoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(note.titulo,
                style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
            if (note.corpo.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(note.corpo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: c.textSecondary, fontSize: 12)),
            ],
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.timer_outlined, size: 12, color: c.textSecondary),
                const SizedBox(width: 3),
                Text(l.daysLeft(note.daysUntilPurge),
                    style: TextStyle(color: c.textSecondary, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 8),
            _TrashActions(
              onRestore: () =>
                  context.read<NoteProvider>().restoreNote(note.id),
              onDelete: () => _confirmDelete(
                  context,
                  note.titulo,
                  () => context.read<NoteProvider>().deleteNote(note.id)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Widgets compartilhados ──────────────────────────────────────────────────

class _TrashActions extends StatelessWidget {
  final VoidCallback onRestore;
  final VoidCallback onDelete;
  const _TrashActions({required this.onRestore, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Row(
      children: [
        _btn(context, l.actionRestore, Icons.restore_rounded,
            AppColors.celestial, onRestore),
        const SizedBox(width: 8),
        _btn(context, l.actionDelete, Icons.delete_forever_outlined,
            AppColors.error, onDelete),
      ],
    );
  }

  Widget _btn(BuildContext context, String label, IconData icon, Color color,
      VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _EmptyTrash extends StatelessWidget {
  final String label;
  const _EmptyTrash({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.delete_outline,
              size: 56, color: context.colors.textSecondary.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text(label,
              style: TextStyle(
                  color: context.colors.textSecondary, fontSize: 15)),
        ],
      ),
    );
  }
}

void _confirmDelete(
    BuildContext context, String nome, VoidCallback onConfirm) {
  final l = context.l10n;
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: context.colors.card,
      title: Text(l.trashDeleteTitle,
          style: TextStyle(color: context.colors.textPrimary)),
      content: Text(
        l.trashDeleteMsg(nome),
        style: TextStyle(color: context.colors.textSecondary),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.cancel)),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          child: Text(l.actionDelete,
              style: const TextStyle(color: AppColors.error)),
        ),
      ],
    ),
  );
}
