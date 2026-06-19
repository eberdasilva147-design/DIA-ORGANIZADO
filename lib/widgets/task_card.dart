import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../utils/app_colors.dart';
import '../utils/dia_colors.dart';
import '../utils/l10n_ext.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onComplete;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onReschedule;
  final VoidCallback? onHide;
  final VoidCallback? onEdit;
  final bool showDate;

  const TaskCard({
    super.key,
    required this.task,
    required this.onComplete,
    this.onTap,
    this.onDelete,
    this.onReschedule,
    this.onHide,
    this.onEdit,
    this.showDate = true,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final overdue = task.isOverdue;
    final priorityColor = AppColors.priorityColor(task.prioridade);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: overdue ? AppColors.error.withValues(alpha: 0.5) : c.border,
            width: overdue ? 1.5 : 1,
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: overdue ? AppColors.error : priorityColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (overdue) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      l.statusOverdueTask,
                                      style: const TextStyle(
                                          color: AppColors.error,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                ],
                                Text(
                                  task.nome,
                                  style: TextStyle(
                                    color: task.concluida
                                        ? c.textSecondary
                                        : c.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    decoration: task.concluida
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                if (task.observacao.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    task.observacao,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: c.textSecondary, fontSize: 12),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (!task.concluida)
                            GestureDetector(
                              onTap: onComplete,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: AppColors.gold, width: 2),
                                ),
                                child: const Icon(Icons.check,
                                    size: 18, color: AppColors.accent),
                              ),
                            )
                          else
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.success,
                              ),
                              child: const Icon(Icons.check,
                                  size: 18, color: Colors.white),
                            ),
                        ],
                      ),
                      if (showDate && task.horario.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.schedule,
                                size: 13, color: c.textSecondary),
                            const SizedBox(width: 4),
                            Text(task.horario,
                                style: TextStyle(
                                    color: c.textSecondary, fontSize: 12)),
                            if (task.data.isNotEmpty) ...[
                              const SizedBox(width: 10),
                              Icon(Icons.calendar_today,
                                  size: 13, color: c.textSecondary),
                              const SizedBox(width: 4),
                              Text(task.data,
                                  style: TextStyle(
                                      color: c.textSecondary, fontSize: 12)),
                            ],
                          ],
                        ),
                      ],
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: priorityColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: priorityColor.withValues(alpha: 0.35)),
                        ),
                        child: Text(
                          l.priorityBadge(l.priorityLabel(task.prioridade)),
                          style: TextStyle(
                            color: priorityColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (onEdit != null ||
                          onReschedule != null ||
                          onHide != null ||
                          onDelete != null) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            if (onEdit != null)
                              _actionBtn(l.actionEdit, Icons.edit_outlined,
                                  AppColors.celestial, onEdit!),
                            if (onReschedule != null)
                              _actionBtn(l.actionReschedule,
                                  Icons.event_repeat_outlined,
                                  AppColors.gold, onReschedule!),
                            if (onHide != null)
                              _actionBtn(l.actionHide,
                                  Icons.visibility_off_outlined,
                                  const Color(0xFF7B5EA7), onHide!),
                            if (onDelete != null)
                              _actionBtn(l.actionDelete, Icons.delete_outline,
                                  AppColors.error, onDelete!),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionBtn(
      String label, IconData icon, Color color, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
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
