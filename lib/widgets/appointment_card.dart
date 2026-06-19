import 'package:flutter/material.dart';
import '../models/appointment_model.dart';
import '../utils/app_colors.dart';
import '../utils/dia_colors.dart';
import '../utils/l10n_ext.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onReschedule;
  final VoidCallback? onHide;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onDelete,
    this.onEdit,
    this.onReschedule,
    this.onHide,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final priorityColor = AppColors.priorityColor(appointment.prioridade);
    final status = appointment.statusKind;
    final statusLabel = l.statusLabel(status);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.border),
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
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            appointment.titulo,
                            style: TextStyle(
                              color: context.colors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (statusLabel.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _statusColor(status)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                color: _statusColor(status),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.schedule,
                            size: 13, color: context.colors.textSecondary),
                        const SizedBox(width: 4),
                        Text(appointment.horario,
                            style: TextStyle(
                                color: context.colors.textSecondary, fontSize: 12)),
                        const SizedBox(width: 10),
                        Icon(Icons.calendar_today,
                            size: 13, color: context.colors.textSecondary),
                        const SizedBox(width: 4),
                        Text(appointment.dateFormatted,
                            style: TextStyle(
                                color: context.colors.textSecondary, fontSize: 12)),
                      ],
                    ),
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
                        l.priorityBadge(l.priorityLabel(appointment.prioridade)),
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
                            _actionBtn(
                              l.actionEdit,
                              Icons.edit_outlined,
                              AppColors.celestial,
                              onEdit!,
                            ),
                          if (onReschedule != null)
                            _actionBtn(
                              l.actionReschedule,
                              Icons.event_repeat_outlined,
                              AppColors.gold,
                              onReschedule!,
                            ),
                          if (onHide != null)
                            _actionBtn(
                              l.actionHide,
                              Icons.visibility_off_outlined,
                              const Color(0xFF7B5EA7),
                              onHide!,
                            ),
                          if (onDelete != null)
                            _actionBtn(
                              l.actionDelete,
                              Icons.delete_outline,
                              AppColors.error,
                              onDelete!,
                            ),
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
            Text(
              label,
              style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'atrasado':
        return AppColors.error;
      case 'hoje':
        return AppColors.celestial;
      case 'confirmado':
        return AppColors.success;
      default:
        return AppColors.priorityMedium;
    }
  }
}
