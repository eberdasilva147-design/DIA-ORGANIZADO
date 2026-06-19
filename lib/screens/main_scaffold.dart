import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../providers/appointment_provider.dart';
import '../providers/note_provider.dart';
import '../providers/verse_provider.dart';
import '../utils/app_colors.dart';
import '../utils/dia_colors.dart';
import '../utils/l10n_ext.dart';
import 'home/home_screen.dart';
import 'tasks/tasks_screen.dart';
import 'tasks/task_create_modal.dart';
import 'agenda/agenda_screen.dart';
import 'notes/notes_screen.dart';
import 'voice/voice_screen.dart';
import 'settings/settings_screen.dart';
import 'trash/trash_screen.dart';
import 'auth/login_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    const TasksScreen(),
    const SizedBox.shrink(),
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
      builder: (_) => VoiceScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final body = IndexedStack(
          index: _currentIndex == 2 ? 0 : _currentIndex,
          children: _screens,
        );

        if (wide) {
          return Scaffold(
            backgroundColor: context.colors.background,
            body: Row(
              children: [
                _buildSidebar(),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 1100),
                      child: body,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: body,
          bottomNavigationBar: _buildBottomNav(),
        );
      },
    );
  }

  // ─── Sidebar (desktop) ────────────────────────────────────────────────────

  Widget _buildSidebar() {
    final auth = context.watch<AuthProvider>();
    final l = context.l10n;
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: context.colors.backgroundSecondary,
        border: Border(right: BorderSide(color: context.colors.border, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),

          // Logo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.star_outline_rounded,
                    color: AppColors.accent, size: 26),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l.appTitle,
                    style: GoogleFonts.notoSerif(
                      color: context.colors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Perfil
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.gold,
                  child: Text(
                    auth.userName.isNotEmpty
                        ? auth.userName[0].toUpperCase()
                        : '?',
                    style: GoogleFonts.notoSerif(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          color: context.colors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        l.digitalSanctuary,
                        style: GoogleFonts.spaceGrotesk(
                          color: context.colors.textSecondary,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Navegação
          _sideItem(0, Icons.auto_awesome_outlined, l.navHome),
          _sideItem(1, Icons.check_circle_outline_rounded, l.navTasks),
          _sideItem(3, Icons.calendar_month_outlined, l.navAgenda),
          _sideItem(4, Icons.menu_book_outlined, l.navNotes),
          _sideAction(Icons.mic_none_rounded, l.navVoice, _openVoice),
          _sideAction(Icons.delete_outline_rounded, l.navTrash, () {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TrashScreen()));
          }),

          const Spacer(),

          // Botão principal
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              onPressed: () => TaskCreateModal.show(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                l.newTask,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Rodapé
          _sideAction(Icons.settings_outlined, l.navSettings, () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => SettingsScreen()));
          }),
          if (!auth.localMode)
            _sideAction(Icons.logout_rounded, l.navLogout, () async {
              await context.read<AuthProvider>().signOut();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              }
            }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _sideItem(int index, IconData icon, String label) {
    final selected = _currentIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onTabTapped(index),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              gradient: selected
                  ? LinearGradient(
                      colors: [AppColors.gold, Color(0xFFC09A1F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              borderRadius: BorderRadius.circular(10),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Icon(icon,
                    size: 19,
                    color:
                        selected ? Colors.white : context.colors.textSecondary),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    color: selected ? Colors.white : context.colors.textPrimary,
                    fontSize: 13.5,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sideAction(IconData icon, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                Icon(icon, size: 19, color: context.colors.textSecondary),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    color: context.colors.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Barra inferior (mobile) ──────────────────────────────────────────────

  Widget _buildBottomNav() {
    final l = context.l10n;
    return Container(
      decoration: BoxDecoration(
        color: context.colors.card,
        border: Border(top: BorderSide(color: context.colors.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _navItem(0, Icons.home_rounded, l.navHome),
              _navItem(1, Icons.check_circle_outline_rounded, l.navTasks),
              _voiceButton(),
              _navItem(3, Icons.calendar_month_rounded, l.navAgenda),
              _navItem(4, Icons.sticky_note_2_outlined, l.navNotes),
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
              color: selected ? AppColors.primary : context.colors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.primary : context.colors.textSecondary,
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
