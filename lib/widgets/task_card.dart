import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../utils/app_colors.dart';
import 'priority_badge.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onComplete;
  final VoidCallback? onTap;
  final bool showDate;

  const TaskCard({
    super.key,
    required this.task,
    required this.onComplete,
    this.onTap,
    this.showDate = true,
  });

  @override
  Widget build(BuildContext context) {
    final overdue = task.isOverdue;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: overdue ? AppColors.error.withValues(alpha: 0.6) : AppColors.border,
            width: overdue ? 1.5 : 1,
          ),
          // Sombra ambiental quente (design Sacred Order)
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.07),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            PriorityBadge(priority: task.prioridade, compact: true),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.nome,
                    style: TextStyle(
                      color: task.concluida
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      decoration:
                          task.concluida ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (showDate && task.horario.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (overdue)
                          Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'ATRASADA',
                              style: TextStyle(
                                  color: AppColors.error,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        const Icon(Icons.schedule,
                            size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 3),
                        Text(
                          '${task.horario}  ${task.data}',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            PriorityBadge(priority: task.prioridade),
            const SizedBox(width: 8),
            if (!task.concluida)
              GestureDetector(
                onTap: onComplete,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.gold, width: 2),
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
                child: const Icon(Icons.check, size: 18, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}
