import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/verse_provider.dart';
import '../../models/appointment_model.dart';
import '../../utils/app_colors.dart';
import '../../widgets/task_card.dart';
import '../../widgets/appointment_card.dart';
import '../settings/settings_screen.dart';
import '../tasks/task_create_modal.dart';
import '../tasks/tasks_screen.dart' show rescheduleTaskFlow;
import '../agenda/agenda_screen.dart'
    show rescheduleAppointmentFlow, confirmDeleteAppointment;
import '../agenda/appointment_create_modal.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  String _formattedDate() {
    return DateFormat("EEEE, d 'de' MMMM 'de' yyyy", 'pt_BR')
        .format(DateTime.now());
  }

  Widget _sectionTitle(IconData icon, String title, String? count) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              children: [
                Icon(icon, color: AppColors.gold, size: 18),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(title,
                      style: GoogleFonts.notoSerif(
                          color: AppColors.textPrimary,
                          fontSize: 19,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          if (count != null)
            Text(count,
                style: GoogleFonts.spaceGrotesk(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
        ],
      );

  Widget _emptyCard(String text) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
            child: Text(text,
                style: const TextStyle(color: AppColors.textSecondary))),
      );

  Widget _apptCard(BuildContext context, AppointmentModel ap) =>
      AppointmentCard(
        appointment: ap,
        onEdit: () =>
            AppointmentCreateModal.show(context, ap.date, appointment: ap),
        onReschedule: () => rescheduleAppointmentFlow(context, ap),
        onHide: () =>
            context.read<AppointmentProvider>().toggleOcultarDaHome(ap.id),
        onDelete: () => confirmDeleteAppointment(context, ap),
      );

  Widget _novaTarefaButton(BuildContext context) => GestureDetector(
        onTap: () => TaskCreateModal.show(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.gold, AppColors.primary],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.4),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text('Nova Tarefa',
                  style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final tasks = context.watch<TaskProvider>();
    final appointments = context.watch<AppointmentProvider>();
    final verses = context.watch<VerseProvider>();
    final nextReminder = tasks.nextReminder;

    final now = DateTime.now();
    final startToday = DateTime(now.year, now.month, now.day);
    final end5 = startToday.add(const Duration(days: 6)); // hoje + 5 dias
    final todayAppts =
        appointments.forDate(now).where((a) => !a.ocultarDaHome).toList();
    final next5Tasks = tasks.pending.where((t) {
      if (t.ocultarDaHome) return false;
      final dt = t.dateTime;
      return dt != null && !dt.isBefore(startToday) && dt.isBefore(end5);
    }).toList();
    final next5Appts = appointments.upcoming
        .where((a) => !a.ocultarDaHome && a.date.isBefore(end5))
        .toList();
    final allAppts =
        appointments.upcoming.where((a) => !a.ocultarDaHome).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            snap: true,
            backgroundColor: AppColors.background,
            title: const Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    color: AppColors.accent, size: 22),
                SizedBox(width: 8),
                Text('Dia Organizado',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined,
                    color: AppColors.textSecondary),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen())),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Saudação + data
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_greeting()}, ${auth.userName}',
                        style: GoogleFonts.notoSerif(
                          color: AppColors.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formattedDate().toUpperCase(),
                        style: GoogleFonts.spaceGrotesk(
                          color: AppColors.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),

                // Versículo do dia — hero escuro (design Sacred Order)
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.heroDark, AppColors.heroDarkSoft],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.18),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: AppColors.gold.withValues(alpha: 0.6)),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'VERSÍCULO DO DIA',
                          style: GoogleFonts.spaceGrotesk(
                            color: AppColors.gold,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        '"${verses.dailyVerse.versiculo}"',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoSerif(
                          color: Colors.white,
                          fontSize: 17,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        verses.dailyVerse.referencia.toUpperCase(),
                        style: GoogleFonts.spaceGrotesk(
                          color: AppColors.gold,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 3,
                        ),
                      ),
                    ],
                  ),
                ),

                // Lembrete mais próximo
                if (nextReminder != null && !nextReminder.ocultarDaHome) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.notifications_active,
                            color: AppColors.warning, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Próximo lembrete',
                                style: TextStyle(
                                    color: AppColors.warning,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600),
                              ),
                              Text(
                                nextReminder.nome,
                                style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '${nextReminder.horario}  ${nextReminder.data}',
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // ── COMPROMISSOS DE HOJE ──
                const SizedBox(height: 20),
                _sectionTitle(Icons.event_available_outlined,
                    'Compromissos de Hoje', '${todayAppts.length}'),
                const SizedBox(height: 8),
                if (todayAppts.isEmpty)
                  _emptyCard('Nenhum compromisso para hoje 🎉')
                else
                  ...todayAppts.map((ap) => _apptCard(context, ap)),

                // Botão Nova Tarefa (destaque premium Sacred Order)
                const SizedBox(height: 12),
                _novaTarefaButton(context),

                // ── ATIVIDADES DOS PRÓXIMOS 5 DIAS ──
                const SizedBox(height: 22),
                _sectionTitle(Icons.upcoming_outlined,
                    'Atividades dos próximos 5 dias', null),
                const SizedBox(height: 8),
                if (next5Tasks.isEmpty && next5Appts.isEmpty)
                  _emptyCard('Nada nos próximos 5 dias.')
                else ...[
                  ...next5Tasks.map((t) => TaskCard(
                        task: t,
                        onComplete: () =>
                            context.read<TaskProvider>().completeTask(t.id),
                        onReschedule: () => rescheduleTaskFlow(context, t),
                        onHide: () => context
                            .read<TaskProvider>()
                            .toggleOcultarDaHome(t.id),
                      )),
                  ...next5Appts.map((ap) => _apptCard(context, ap)),
                ],

                // ── TODOS OS COMPROMISSOS ──
                if (allAppts.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  _sectionTitle(Icons.event_note_outlined,
                      'Todos os Compromissos', '${allAppts.length}'),
                  const SizedBox(height: 8),
                  ...allAppts.map((ap) => _apptCard(context, ap)),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
