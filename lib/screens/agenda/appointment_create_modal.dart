import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/appointment_model.dart';
import '../../providers/appointment_provider.dart';
import '../../utils/app_colors.dart';

class AppointmentCreateModal extends StatefulWidget {
  final DateTime initialDate;

  /// Se informado, abre em modo edição.
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
      ));
    } else {
      await provider.addAppointment(
        titulo: _titleCtrl.text.trim(),
        horario: horario,
        local: _localCtrl.text.trim(),
        date: _selectedDate,
      );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
            Text(_isEditing ? 'Editar Compromisso' : 'Novo Compromisso',
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: _titleCtrl,
              autofocus: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Título do compromisso',
                prefixIcon: Icon(Icons.event, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _localCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Local (opcional)',
                prefixIcon: Icon(Icons.place, color: AppColors.textSecondary),
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
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.verified_outlined,
                    size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                const Text('Confirmado',
                    style: TextStyle(color: AppColors.textPrimary)),
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
              child: Text(
                  _isEditing ? 'Salvar alterações' : 'Salvar compromisso'),
            ),
          ],
        ),
      ),
    );
  }
}
