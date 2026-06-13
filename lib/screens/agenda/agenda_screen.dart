import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/appointment_model.dart';
import '../../providers/appointment_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/appointment_card.dart';
import 'appointment_create_modal.dart';

/// Pede confirmação antes de excluir um compromisso.
Future<void> confirmDeleteAppointment(
    BuildContext context, AppointmentModel ap) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppColors.card,
      title: const Text('Excluir compromisso',
          style: TextStyle(color: AppColors.textPrimary)),
      content: Text('Excluir "${ap.titulo}"?',
          style: const TextStyle(color: AppColors.textSecondary)),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar')),
        TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir',
                style: TextStyle(color: AppColors.error))),
      ],
    ),
  );
  if (ok == true && context.mounted) {
    await context.read<AppointmentProvider>().deleteAppointment(ap.id);
  }
}

/// Reagenda um compromisso (nova data + horário).
Future<void> rescheduleAppointmentFlow(
    BuildContext context, AppointmentModel ap) async {
  final now = DateTime.now();
  final d = await showDatePicker(
    context: context,
    initialDate: ap.date.isBefore(now) ? now : ap.date,
    firstDate: now.subtract(const Duration(days: 1)),
    lastDate: now.add(const Duration(days: 365 * 2)),
    builder: (ctx, child) => Theme(
      data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary)),
      child: child!,
    ),
  );
  if (d == null || !context.mounted) return;
  final hm = ap.horario.split(':');
  final t = await showTimePicker(
    context: context,
    initialTime: TimeOfDay(
        hour: int.tryParse(hm.isNotEmpty ? hm[0] : '9') ?? 9,
        minute: int.tryParse(hm.length > 1 ? hm[1] : '0') ?? 0),
    builder: (ctx, child) => Theme(
      data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary)),
      child: child!,
    ),
  );
  if (t == null || !context.mounted) return;
  final horario =
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  await context.read<AppointmentProvider>().reschedule(ap.id, d, horario);
}

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Agenda'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.accent),
            onPressed: () => AppointmentCreateModal.show(context, _selectedDate),
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: const [Tab(text: 'Semana'), Tab(text: 'Mês')],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _WeekView(
            selected: _selectedDate,
            onSelect: (d) => setState(() => _selectedDate = d),
          ),
          _MonthView(
            selected: _selectedDate,
            currentMonth: _currentMonth,
            onSelect: (d) => setState(() => _selectedDate = d),
            onMonthChange: (m) => setState(() => _currentMonth = m),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_agenda',
        onPressed: () => AppointmentCreateModal.show(context, _selectedDate),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Novo compromisso',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _WeekView extends StatelessWidget {
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;

  const _WeekView({required this.selected, required this.onSelect});

  List<DateTime> get _weekDays {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (i) => weekStart.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    final appointments = context.watch<AppointmentProvider>();
    final days = _weekDays;
    final dayAps = appointments.forDate(selected);

    return Column(
      children: [
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: days.length,
            itemBuilder: (_, i) {
              final d = days[i];
              final isSelected = d.day == selected.day &&
                  d.month == selected.month &&
                  d.year == selected.year;
              final isToday = d.day == DateTime.now().day &&
                  d.month == DateTime.now().month;
              final hasEvents = appointments.forDate(d).isNotEmpty;
              return GestureDetector(
                onTap: () => onSelect(d),
                child: Container(
                  width: 52,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: isToday
                            ? AppColors.accent
                            : AppColors.border,
                        width: isToday ? 2 : 1),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('E', 'pt_BR').format(d).toUpperCase(),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${d.day}',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (hasEvents)
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(top: 3),
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                DateFormat("d 'de' MMMM", 'pt_BR').format(selected),
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              if (dayAps.isNotEmpty)
                Text('${dayAps.length} compromisso(s)',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: dayAps.isEmpty
              ? const Center(
                  child: Text('Nenhum compromisso neste dia.',
                      style: TextStyle(color: AppColors.textSecondary)))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: dayAps.length,
                  itemBuilder: (_, i) => AppointmentCard(
                    appointment: dayAps[i],
                    onDelete: () =>
                        confirmDeleteAppointment(context, dayAps[i]),
                    onEdit: () => AppointmentCreateModal.show(
                        context, dayAps[i].date,
                        appointment: dayAps[i]),
                    onReschedule: () =>
                        rescheduleAppointmentFlow(context, dayAps[i]),
                  ),
                ),
        ),
      ],
    );
  }
}

class _MonthView extends StatelessWidget {
  final DateTime selected;
  final DateTime currentMonth;
  final ValueChanged<DateTime> onSelect;
  final ValueChanged<DateTime> onMonthChange;

  const _MonthView({
    required this.selected,
    required this.currentMonth,
    required this.onSelect,
    required this.onMonthChange,
  });

  List<DateTime?> get _calDays {
    final first = DateTime(currentMonth.year, currentMonth.month, 1);
    final last = DateTime(currentMonth.year, currentMonth.month + 1, 0);
    final startOffset = first.weekday - 1; // Monday = 0
    final days = <DateTime?>[];
    for (int i = 0; i < startOffset; i++) {
      days.add(null);
    }
    for (int d = 1; d <= last.day; d++) {
      days.add(DateTime(currentMonth.year, currentMonth.month, d));
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    final appointments = context.watch<AppointmentProvider>();
    final days = _calDays;
    final dayAps = appointments.forDate(selected);
    final headers = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

    return Column(
      children: [
        // Month navigation
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: AppColors.accent),
                onPressed: () => onMonthChange(DateTime(
                    currentMonth.year, currentMonth.month - 1)),
              ),
              Expanded(
                child: Text(
                  DateFormat("MMMM 'de' yyyy", 'pt_BR').format(currentMonth),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: AppColors.accent),
                onPressed: () => onMonthChange(DateTime(
                    currentMonth.year, currentMonth.month + 1)),
              ),
            ],
          ),
        ),
        // Headers
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: headers
                .map((h) => Expanded(
                      child: Text(h,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 6),
        // Grid (deslize para trocar de mês)
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragEnd: (dr) {
            final v = dr.primaryVelocity ?? 0;
            if (v < -100) {
              onMonthChange(
                  DateTime(currentMonth.year, currentMonth.month + 1));
            } else if (v > 100) {
              onMonthChange(
                  DateTime(currentMonth.year, currentMonth.month - 1));
            }
          },
          child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: days.length,
            itemBuilder: (_, i) {
              final d = days[i];
              if (d == null) return const SizedBox.shrink();
              final isSelected =
                  d.day == selected.day && d.month == selected.month && d.year == selected.year;
              final isToday = d.day == DateTime.now().day &&
                  d.month == DateTime.now().month &&
                  d.year == DateTime.now().year;
              final hasEvents = appointments.forDate(d).isNotEmpty;
              return GestureDetector(
                onTap: () => onSelect(d),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    shape: BoxShape.circle,
                    border: isToday && !isSelected
                        ? Border.all(color: AppColors.accent, width: 2)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${d.day}',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight:
                              isToday ? FontWeight.w700 : FontWeight.normal,
                        ),
                      ),
                      if (hasEvents)
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          ),
        ),
        const Divider(height: 20),
        // Selected day appointments
        Expanded(
          child: dayAps.isEmpty
              ? const Center(
                  child: Text('Nenhum compromisso neste dia.',
                      style: TextStyle(color: AppColors.textSecondary)))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: dayAps.length,
                  itemBuilder: (_, i) => AppointmentCard(
                    appointment: dayAps[i],
                    onDelete: () =>
                        confirmDeleteAppointment(context, dayAps[i]),
                    onEdit: () => AppointmentCreateModal.show(
                        context, dayAps[i].date,
                        appointment: dayAps[i]),
                    onReschedule: () =>
                        rescheduleAppointmentFlow(context, dayAps[i]),
                  ),
                ),
        ),
      ],
    );
  }
}
