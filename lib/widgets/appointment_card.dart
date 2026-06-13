import 'package:flutter/material.dart';
import '../models/appointment_model.dart';
import '../utils/app_colors.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onReschedule;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onDelete,
    this.onEdit,
    this.onReschedule,
  });

  // 🔴 atrasado · 🔵 hoje · 🟢 confirmado · 🟡 pendente
  static const _statusColors = {
    'atrasado': AppColors.error,
    'hoje': AppColors.celestial,
    'confirmado': AppColors.success,
    'pendente': AppColors.priorityMedium,
  };
  static const _statusLabels = {
    'atrasado': 'Atrasado',
    'hoje': 'Hoje',
    'confirmado': 'Confirmado',
    'pendente': 'Pendente',
  };

  @override
  Widget build(BuildContext context) {
    final status = appointment.statusKind;
    final statusColor = _statusColors[status] ?? AppColors.accent;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          // Faixa de status (cor por estado)
          Container(
            width: 4,
            height: 52,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.titulo,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.schedule,
                        size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(appointment.horario,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                    if (appointment.local.isNotEmpty) ...[
                      const SizedBox(width: 10),
                      const Icon(Icons.place,
                          size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          appointment.local,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      appointment.dateFormatted,
                      style: const TextStyle(
                          color: AppColors.accent, fontSize: 11),
                    ),
                    const SizedBox(width: 8),
                    // Etiqueta de status
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _statusLabels[status] ?? '',
                        style: TextStyle(
                            color: statusColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Menu de ações
          if (onEdit != null || onReschedule != null || onDelete != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert,
                  color: AppColors.textSecondary, size: 20),
              color: AppColors.card,
              onSelected: (v) {
                if (v == 'editar') onEdit?.call();
                if (v == 'reagendar') onReschedule?.call();
                if (v == 'excluir') onDelete?.call();
              },
              itemBuilder: (_) => [
                if (onEdit != null)
                  const PopupMenuItem(
                    value: 'editar',
                    child: Text('Editar',
                        style: TextStyle(color: AppColors.textPrimary)),
                  ),
                if (onReschedule != null)
                  const PopupMenuItem(
                    value: 'reagendar',
                    child: Text('Reagendar',
                        style: TextStyle(color: AppColors.textPrimary)),
                  ),
                if (onDelete != null)
                  const PopupMenuItem(
                    value: 'excluir',
                    child: Text('Excluir',
                        style: TextStyle(color: AppColors.error)),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
