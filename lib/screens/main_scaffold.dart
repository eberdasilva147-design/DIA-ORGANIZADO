import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/appointment_provider.dart';
import '../providers/note_provider.dart';
import '../providers/verse_provider.dart';
import '../utils/app_colors.dart';
import 'home/home_screen.dart';
import 'tasks/tasks_screen.dart';
import 'agenda/agenda_screen.dart';
import 'notes/notes_screen.dart';
import 'voice/voice_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    TasksScreen(),
    SizedBox.shrink(), // placeholder for voice (opens as modal)
    AgendaScreen(),
    NotesScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
      context.read<AppointmentProvider>().loadAppointments();
      context.read<NoteProvider>().loadNotes();
      context.read<VerseProvider>().loadFavorites();
    });
  }

  void _onTabTapped(int index) {
    if (index == 2) {
      _openVoice();
      return;
    }
    setState(() => _currentIndex = index);
  }

  void _openVoice() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const VoiceScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex == 2 ? 0 : _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _navItem(0, Icons.home_rounded, 'Início'),
              _navItem(1, Icons.check_circle_outline_rounded, 'Tarefas'),
              _voiceButton(),
              _navItem(3, Icons.calendar_month_rounded, 'Agenda'),
              _navItem(4, Icons.sticky_note_2_outlined, 'Notas'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final selected = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? AppColors.primary : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.primary : AppColors.textSecondary,
                fontSize: 10,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _voiceButton() {
    return Expanded(
      child: GestureDetector(
        onTap: _openVoice,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.gold, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.45),
                    blurRadius: 14,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.mic_rounded,
                  color: Colors.white, size: 26),
            ),
          ],
        ),
      ),
    );
  }
}
