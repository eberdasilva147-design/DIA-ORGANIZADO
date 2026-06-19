import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/appointment_model.dart';
import '../../models/task_model.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/task_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/dia_colors.dart';
import '../../utils/l10n_ext.dart';
import '../../widgets/appointment_card.dart';
import '../../widgets/task_card.dart';
import 'appointment_create_modal.dart';
import '../tasks/task_create_modal.dart';
import '../tasks/tasks_screen.dart' show rescheduleTaskFlow, confirmDeleteTask;

/// Move o compromisso para a lixeira com confirmação.
Future<void> confirmDeleteAppointment(
    BuildContext context, AppointmentModel ap) async {
  final l = context.l10n;
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: context.colors.card,
      title: Text(l.moveToTrash,
          style: TextStyle(color: context.colors.textPrimary)),
      content: Text(
          l.moveToTrashApptMsg(ap.titulo),
          style: TextStyle(color: context.colors.textSecondary)),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel)),
        TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.actionDelete,
                style: const TextStyle(color: AppColors.error))),
      ],
    ),
  );
  if (ok == true && context.mounted) {
    await context.read<AppointmentProvider>().softDeleteAppointment(ap.id);
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

// ─── Helpers compartilhados ───────────────────────────────────────────────────

List<TaskModel> _tasksForDate(TaskProvider tasks, DateTime d) {
  return tasks.pending.where((t) {
    if (t.data.isEmpty) return false;
    final parts = t.data.split('/');
    if (parts.length != 3) return false;
    try {
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      return day == d.day && month == d.month && year == d.year;
    } catch (_) {
      return false;
    }
  }).toList()
    ..sort((a, b) => a.horario.compareTo(b.horario));
}

List<String> _prioritiesForDay(
    AppointmentProvider appts, TaskProvider tasks, DateTime d) {
  final Set<String> priorities = {};
  for (final a in appts.forDate(d)) {
    priorities.add(a.prioridade);
  }
  for (final t in _tasksForDate(tasks, d)) {
    priorities.add(t.prioridade);
  }
  return ['h', 'm', 'l'].where(priorities.contains).toList();
}

Widget _apptCard(BuildContext context, AppointmentModel ap) => AppointmentCard(
      appointment: ap,
      onEdit: () =>
          AppointmentCreateModal.show(context, ap.date, appointment: ap),
      onReschedule: () => rescheduleAppointmentFlow(context, ap),
      onHide: () =>
          context.read<AppointmentProvider>().toggleOcultarDaHome(ap.id),
      onDelete: () => confirmDeleteAppointment(context, ap),
    );

Widget _taskCard(BuildContext context, TaskModel t) => TaskCard(
      task: t,
      onComplete: () => context.read<TaskProvider>().completeTask(t.id),
      onEdit: () => TaskCreateModal.show(context, task: t),
      onReschedule: () => rescheduleTaskFlow(context, t),
      onDelete: () => confirmDeleteTask(context, t),
    );

// ─── Tela principal ───────────────────────────────────────────────────────────

class AgendaScreen extends StatefulWidget {
  AgendaScreen({super.key});

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
    final l = context.l10n;
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(l.agendaTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.accent),
            onPressed: () =>
                AppointmentCreateModal.show(context, _selectedDate),
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: [Tab(text: l.weekTab), Tab(text: l.monthTab)],
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
        onPressed: () =>
            AppointmentCreateModal.show(context, _selectedDate),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(l.newAppointmentFab,
            style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}

// ─── Semana ───────────────────────────────────────────────────────────────────

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
    final l = context.l10n;
    final appointments = context.watch<AppointmentProvider>();
    final tasks = context.watch<TaskProvider>();
    final locale = Localizations.localeOf(context).toLanguageTag();
    final days = _weekDays;
    final dayAps = appointments.forDate(selected);
    final dayTasks = _tasksForDate(tasks, selected);

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
              final hasEvents = appointments.forDate(d).isNotEmpty ||
                  _tasksForDate(tasks, d).isNotEmpty;
              return GestureDetector(
                onTap: () => onSelect(d),
                child: Container(
                  width: 52,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : context.colors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: isToday ? AppColors.accent : context.colors.border,
                        width: isToday ? 2 : 1),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('E', locale).format(d).toUpperCase(),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : context.colors.textSecondary,
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
                              : context.colors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (hasEvents)
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(top: 3),
                          decoration: BoxDecoration(
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
                DateFormat.MMMd(locale).format(selected),
                style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              if (dayAps.isNotEmpty || dayTasks.isNotEmpty)
                Text(
                    l.appointmentsCount(dayAps.length + dayTasks.length),
                    style: TextStyle(
                        color: context.colors.textSecondary, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: (dayAps.isEmpty && dayTasks.isEmpty)
              ? Center(
                  child: Text(l.noAppointmentsDay,
                      style: TextStyle(color: context.colors.textSecondary)))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  children: [
                    ...dayAps.map((ap) => _apptCard(context, ap)),
                    ...dayTasks.map((t) => _taskCard(context, t)),
                  ],
                ),
        ),
      ],
    );
  }
}

// ─── Mês ──────────────────────────────────────────────────────────────────────

class _MonthView extends StatefulWidget {
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

  @override
  State<_MonthView> createState() => _MonthViewState();
}

class _MonthViewState extends State<_MonthView> {
  OverlayEntry? _overlay;

  List<DateTime?> get _calDays {
    final first =
        DateTime(widget.currentMonth.year, widget.currentMonth.month, 1);
    final last =
        DateTime(widget.currentMonth.year, widget.currentMonth.month + 1, 0);
    final startOffset = first.weekday - 1;
    final days = <DateTime?>[];
    for (int i = 0; i < startOffset; i++) {
      days.add(null);
    }
    for (int d = 1; d <= last.day; d++) {
      days.add(
          DateTime(widget.currentMonth.year, widget.currentMonth.month, d));
    }
    return days;
  }

  void _showPopup(BuildContext context, DateTime day, Offset globalPos,
      List<AppointmentModel> appts, List<TaskModel> tasks) {
    _hidePopup();

    final screen = MediaQuery.of(context).size;
    const popupW = 280.0;

    double left = globalPos.dx - popupW / 2;
    double top = globalPos.dy + 8;

    if (left < 8) left = 8;
    if (left + popupW > screen.width - 8) left = screen.width - popupW - 8;

    final itemCount = appts.length + tasks.length;
    final estimatedH = 60.0 + itemCount * 52.0;
    if (top + estimatedH > screen.height - 16) {
      top = globalPos.dy - estimatedH - 8;
    }

    _overlay = OverlayEntry(
      builder: (_) => Positioned(
        left: left,
        top: top,
        width: popupW,
        child: Material(
          color: Colors.transparent,
          child: _DayPopup(
            day: day,
            appts: appts,
            tasks: tasks,
            onClose: _hidePopup,
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlay!);
  }

  void _hidePopup() {
    _overlay?.remove();
    _overlay = null;
  }

  @override
  void deactivate() {
    _hidePopup();
    super.deactivate();
  }

  @override
  void dispose() {
    _hidePopup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final appointments = context.watch<AppointmentProvider>();
    final tasks = context.watch<TaskProvider>();
    final locale = Localizations.localeOf(context).toLanguageTag();
    final days = _calDays;
    final headers = [
      l.weekDayMon, l.weekDayTue, l.weekDayWed,
      l.weekDayThu, l.weekDayFri, l.weekDaySat, l.weekDaySun,
    ];

    return Column(
      children: [
        // Navegação de mês
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: AppColors.accent),
                onPressed: () {
                  _hidePopup();
                  widget.onMonthChange(DateTime(
                      widget.currentMonth.year, widget.currentMonth.month - 1));
                },
              ),
              Expanded(
                child: Text(
                  DateFormat.yMMMM(locale).format(widget.currentMonth),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: AppColors.accent),
                onPressed: () {
                  _hidePopup();
                  widget.onMonthChange(DateTime(
                      widget.currentMonth.year, widget.currentMonth.month + 1));
                },
              ),
            ],
          ),
        ),
        // Cabeçalhos dias da semana
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: headers
                .map((h) => Expanded(
                      child: Text(h,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: context.colors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 4),
        // Grid do calendário
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragEnd: (dr) {
              final v = dr.primaryVelocity ?? 0;
              if (v < -100) {
                _hidePopup();
                widget.onMonthChange(DateTime(
                    widget.currentMonth.year, widget.currentMonth.month + 1));
              } else if (v > 100) {
                _hidePopup();
                widget.onMonthChange(DateTime(
                    widget.currentMonth.year, widget.currentMonth.month - 1));
              }
            },
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 0.9,
              ),
              itemCount: days.length,
              itemBuilder: (_, i) {
                final d = days[i];
                if (d == null) return const SizedBox.shrink();

                final isSelected = d.day == widget.selected.day &&
                    d.month == widget.selected.month &&
                    d.year == widget.selected.year;
                final isToday = d.day == DateTime.now().day &&
                    d.month == DateTime.now().month &&
                    d.year == DateTime.now().year;
                final priorities =
                    _prioritiesForDay(appointments, tasks, d);
                final hasEvents = priorities.isNotEmpty;

                return GestureDetector(
                  onTapUp: (details) {
                    widget.onSelect(d);
                    if (!hasEvents) {
                      _hidePopup();
                      return;
                    }
                    _showPopup(
                      context,
                      d,
                      details.globalPosition,
                      appointments.forDate(d),
                      _tasksForDate(tasks, d),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.transparent,
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
                                : context.colors.textPrimary,
                            fontSize: 13,
                            fontWeight: isToday
                                ? FontWeight.w700
                                : FontWeight.normal,
                          ),
                        ),
                        if (priorities.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: priorities.map((p) {
                              final color = isSelected
                                  ? Colors.white
                                  : AppColors.priorityColor(p);
                              return Container(
                                width: 5,
                                height: 5,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 1),
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Card flutuante do dia ────────────────────────────────────────────────────

class _DayPopup extends StatelessWidget {
  final DateTime day;
  final List<AppointmentModel> appts;
  final List<TaskModel> tasks;
  final VoidCallback onClose;

  _DayPopup({
    required this.day,
    required this.appts,
    required this.tasks,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final allItems = <Widget>[
      ...appts.map((ap) => _itemRow(
            context: context,
            time: ap.horario,
            title: ap.titulo,
            prioridade: ap.prioridade,
          )),
      ...tasks.map((t) => _itemRow(
            context: context,
            time: t.horario,
            title: t.nome,
            prioridade: t.prioridade,
          )),
    ];

    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    DateFormat.yMMMd(locale).format(day),
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onClose,
                  child: Icon(Icons.close,
                      size: 18, color: context.colors.textSecondary),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: context.colors.border),
          // Itens
          ...allItems,
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _itemRow({
    required BuildContext context,
    required String time,
    required String title,
    required String prioridade,
  }) {
    final l = context.l10n;
    final color = AppColors.priorityColor(prioridade);
    final label = l.priorityLabel(prioridade);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            if (time.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  time,
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const SizedBox(width: 6),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
