import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/appointment_model.dart';
import '../../providers/appointment_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/dia_colors.dart';
import '../../utils/l10n_ext.dart';

class AppointmentCreateModal extends StatefulWidget {
  final DateTime initialDate;
  final AppointmentModel? appointment;

  const AppointmentCreateModal(
      {super.key, required this.initialDate, this.appointment});

  static Future<void> show(BuildContext context, DateTime date,
      {AppointmentModel? appointment}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<AppointmentProvider>(),
        child: AppointmentCreateModal(
            initialDate: date, appointment: appointment),
      ),
    );
  }

  @override
  State<AppointmentCreateModal> createState() => _State();
}

class _State extends State<AppointmentCreateModal> {
  final _titleCtrl = TextEditingController();
  final _localCtrl = TextEditingController();
  late DateTime _selectedDate;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  bool _confirmado = false;
  String _priority = 'm';

  bool get _isEditing => widget.appointment != null;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    final ap = widget.appointment;
    if (ap != null) {
      _titleCtrl.text = ap.titulo;
      _localCtrl.text = ap.local;
      _selectedDate = ap.date;
      _confirmado = ap.confirmado;
      _priority = ap.prioridade;
      final hm = ap.horario.split(':');
      if (hm.length == 2) {
        _selectedTime = TimeOfDay(
            hour: int.tryParse(hm[0]) ?? 9, minute: int.tryParse(hm[1]) ?? 0);
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _localCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (ctx, child) => Theme(
        data: ThemeData.light()
            .copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primary)),
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
        data: ThemeData.light()
            .copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primary)),
        child: child!,
      ),
    );
    if (t != null) setState(() => _selectedTime = t);
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) return;
    final horario =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';
    final provider = context.read<AppointmentProvider>();
    if (_isEditing) {
      await provider.updateAppointment(widget.appointment!.copyWith(
        titulo: _titleCtrl.text.trim(),
        horario: horario,
        local: _localCtrl.text.trim(),
        dia: _selectedDate.day,
        mes: _selectedDate.month,
        ano: _selectedDate.year,
        confirmado: _confirmado,
        prioridade: _priority,
      ));
    } else {
      await provider.addAppointment(
        titulo: _titleCtrl.text.trim(),
        horario: horario,
        local: _localCtrl.text.trim(),
        date: _selectedDate,
        prioridade: _priority,
      );
    }
    if (mounted) Navigator.pop(context);
  }

  Widget _priorityChip(String value, String label, Color color) {
    final selected = _priority == value;
    return GestureDetector(
      onTap: () => setState(() => _priority = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.2) : context.colors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? color : context.colors.border,
              width: selected ? 2 : 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : context.colors.textSecondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.backgroundSecondary,
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
                    color: context.colors.border,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text(_isEditing ? l.editAppointment : l.newAppointment,
                style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: _titleCtrl,
              autofocus: true,
              style: TextStyle(color: context.colors.textPrimary),
              decoration: InputDecoration(
                hintText: l.appointmentTitleHint,
                prefixIcon: Icon(Icons.event, color: context.colors.textSecondary),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _localCtrl,
              style: TextStyle(color: context.colors.textPrimary),
              decoration: InputDecoration(
                hintText: l.locationHint,
                prefixIcon: Icon(Icons.place, color: context.colors.textSecondary),
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
                        color: context.colors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.colors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 16, color: context.colors.textSecondary),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('dd/MM/yyyy').format(_selectedDate),
                            style: TextStyle(
                                color: context.colors.textPrimary, fontSize: 14),
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
                        color: context.colors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.colors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.schedule,
                              size: 16, color: context.colors.textSecondary),
                          const SizedBox(width: 8),
                          Text(
                            '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                                color: context.colors.textPrimary, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(l.priority,
                style: TextStyle(
                    color: context.colors.textSecondary, fontSize: 13)),
            const SizedBox(height: 8),
            Row(
              children: [
                _priorityChip('h', l.priorityHigh, AppColors.priorityHigh),
                const SizedBox(width: 8),
                _priorityChip('m', l.priorityMedium, AppColors.priorityMedium),
                const SizedBox(width: 8),
                _priorityChip('l', l.priorityLow, AppColors.priorityLow),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.verified_outlined,
                    size: 18, color: context.colors.textSecondary),
                const SizedBox(width: 8),
                Text(l.confirmed,
                    style: TextStyle(color: context.colors.textPrimary)),
                const Spacer(),
                Switch(
                  value: _confirmado,
                  onChanged: (v) => setState(() => _confirmado = v),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48)),
              child: Text(_isEditing ? l.saveChanges : l.saveAppointment),
            ),
          ],
        ),
      ),
    );
  }
}
