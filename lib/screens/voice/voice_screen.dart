import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../models/task_model.dart';
import '../../models/appointment_model.dart';
import '../../providers/task_provider.dart';
import '../../providers/note_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/ai_voice_service.dart';
import '../../services/tts_service.dart';
import '../../utils/app_colors.dart';

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key});

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen>
    with SingleTickerProviderStateMixin {
  final SpeechToText _speech = SpeechToText();
  final TextEditingController _typedCtrl = TextEditingController();
  bool _available = false;
  bool _listening = false;
  bool _processed = false;
  String _transcript = '';
  String _feedback = '';
  String _status = '';
  String _source = ''; // 'ai' | 'basic' — origem da última resposta
  AiVoiceService? _ai;
  bool _conversationMode = false; // mic reabre sozinho após a resposta
  bool _muteWhileSpeaking = true; // mic mudo enquanto a IA fala
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _available = await _speech.initialize(
      onError: (e) {
        debugPrint('STT erro: ${e.errorMsg} (permanente: ${e.permanent})');
        if (!mounted) return;
        setState(() => _listening = false);
        // 'no-speech' não é um erro real: o usuário só ficou em silêncio
        _say(e.errorMsg == 'no-speech' || e.errorMsg == 'error_no_match'
            ? 'Não ouvi nada. Verifique se o microfone certo está '
                'selecionado no Windows e tente de novo.'
            : '⚠️ Erro no microfone: ${e.errorMsg}');
      },
      onStatus: (status) {
        debugPrint('STT status: $status | transcript: "$_transcript"');
        if (!mounted) return;
        setState(() => _status = status);
        // No Chrome o "finalResult" às vezes nunca chega; quando o
        // reconhecimento termina, processa o que foi capturado.
        if (status == 'done' || status == 'notListening') {
          if (_listening) setState(() => _listening = false);
          if (_transcript.isNotEmpty && !_processed) {
            _processed = true;
            _processCommand(_transcript);
          }
        }
      },
    );
    debugPrint('STT disponível: $_available');
    setState(() {});
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _typedCtrl.dispose();
    _speech.stop();
    TtsService().stop();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (!_available) {
      setState(() => _feedback =
          'Microfone não disponível neste navegador. Use o campo de texto abaixo.');
      return;
    }
    if (_listening) {
      await _speech.stop();
      setState(() => _listening = false);
      // Se o usuário parou manualmente, processa o que já foi dito
      if (_transcript.isNotEmpty && !_processed) {
        _processed = true;
        _processCommand(_transcript);
      }
    } else {
      // Cala a resposta falada antes de ouvir, senão o app escuta a si mesmo
      await TtsService().stop();
      setState(() {
        _listening = true;
        _processed = false;
        _transcript = '';
        _feedback = 'Ouvindo...';
      });
      await _speech.listen(
        onResult: (r) {
          debugPrint(
              'STT resultado: "${r.recognizedWords}" (final: ${r.finalResult})');
          if (!mounted) return;
          setState(() => _transcript = r.recognizedWords);
          if (r.finalResult && !_processed) {
            _processed = true;
            _processCommand(r.recognizedWords);
            setState(() => _listening = false);
          }
        },
        listenOptions: SpeechListenOptions(
          // Navegador usa hífen (pt-BR); Android/iOS usam underscore (pt_BR)
          localeId: kIsWeb ? 'pt-BR' : 'pt_BR',
          listenFor: const Duration(seconds: 30),
          // 2s de silêncio já encerra a fala (3s deixava lento)
          pauseFor: const Duration(seconds: 2),
          partialResults: true,
          cancelOnError: true,
        ),
      );
    }
  }

  void _submitTyped() {
    final text = _typedCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _transcript = text);
    _processCommand(text);
    _typedCtrl.clear();
  }

  // ═══════════════════════════════════════════════════════════════════
  // Interpretação de datas, horários e prioridade
  // ═══════════════════════════════════════════════════════════════════

  static const _weekdays = {
    'segunda': DateTime.monday,
    'terça': DateTime.tuesday,
    'terca': DateTime.tuesday,
    'quarta': DateTime.wednesday,
    'quinta': DateTime.thursday,
    'sexta': DateTime.friday,
    'sábado': DateTime.saturday,
    'sabado': DateTime.saturday,
    'domingo': DateTime.sunday,
  };

  String _fmt(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

  /// Extrai a data do texto (hoje, amanhã, depois de amanhã, dia da
  /// semana, "dia 15") e devolve o texto sem essa parte.
  ({String data, String rest}) _extractDate(String text) {
    final now = DateTime.now();
    var rest = text;
    DateTime date = now;

    String strip(String src, Pattern p) =>
        src.replaceAll(RegExp(p as String, caseSensitive: false), ' ');

    final lower = text.toLowerCase();
    if (lower.contains('depois de amanhã')) {
      date = now.add(const Duration(days: 2));
      rest = strip(rest, r'depois de amanhã');
    } else if (lower.contains('amanhã') || lower.contains('amanha')) {
      date = now.add(const Duration(days: 1));
      rest = strip(rest, r'amanhã|amanha');
    } else if (lower.contains('hoje')) {
      rest = strip(rest, r'\bhoje\b');
    } else {
      var matched = false;
      for (final entry in _weekdays.entries) {
        final reg = RegExp('\\b${entry.key}(-feira)?\\b', caseSensitive: false);
        if (reg.hasMatch(lower)) {
          var ahead = (entry.value - now.weekday) % 7;
          if (ahead == 0) ahead = 7; // próxima ocorrência
          date = now.add(Duration(days: ahead));
          rest = rest.replaceAll(reg, ' ');
          rest = rest.replaceAll(
              RegExp(r'\b(na|no|nesta|neste|próxima|próximo|proxima|proximo)\b\s*$',
                  caseSensitive: false),
              ' ');
          matched = true;
          break;
        }
      }
      if (!matched) {
        final dayReg = RegExp(r'\bdia (\d{1,2})\b', caseSensitive: false);
        final m = dayReg.firstMatch(lower);
        if (m != null) {
          final day = int.parse(m.group(1)!);
          var candidate = DateTime(now.year, now.month, day);
          if (candidate.isBefore(DateTime(now.year, now.month, now.day))) {
            candidate = DateTime(now.year, now.month + 1, day);
          }
          date = candidate;
          rest = rest.replaceAll(dayReg, ' ');
        }
      }
    }
    return (data: _fmt(date), rest: rest);
  }

  /// Extrai o horário ("às 9h", "as 14:30", "às 9 e meia", "meio-dia").
  ({String horario, String rest, bool found}) _extractTime(String text) {
    var rest = text;
    final lower = text.toLowerCase();

    if (lower.contains('meio-dia') || lower.contains('meio dia')) {
      rest = rest.replaceAll(
          RegExp(r'(ao\s+)?meio[- ]dia', caseSensitive: false), ' ');
      return (horario: '12:00', rest: rest, found: true);
    }

    final reg = RegExp(
        r'\b[àa]s?\s+(\d{1,2})(?::(\d{2}))?(\s+e\s+meia)?\s*(?:h\b|hrs?\b|horas?\b)?',
        caseSensitive: false);
    final m = reg.firstMatch(lower);
    if (m != null) {
      final h = m.group(1)!.padLeft(2, '0');
      var min = (m.group(2) ?? '00').padLeft(2, '0');
      if (m.group(3) != null) min = '30';
      rest = rest.replaceFirst(RegExp(reg.pattern, caseSensitive: false), ' ');
      return (horario: '$h:$min', rest: rest, found: true);
    }
    return (horario: '08:00', rest: rest, found: false);
  }

  /// Extrai a prioridade ("prioridade alta", "urgente").
  ({String prioridade, String rest}) _extractPriority(String text) {
    var rest = text;
    final lower = text.toLowerCase();
    String p = 'm';
    if (lower.contains('prioridade alta') || lower.contains('urgente')) {
      p = 'h';
    } else if (lower.contains('prioridade baixa')) {
      p = 'l';
    } else if (lower.contains('prioridade média') ||
        lower.contains('prioridade media')) {
      p = 'm';
    }
    rest = rest.replaceAll(
        RegExp(r'(com\s+)?prioridade\s+(alta|m[ée]dia|baixa)|urgente',
            caseSensitive: false),
        ' ');
    return (prioridade: p, rest: rest);
  }

  /// Limpa espaços duplicados e preposições soltas nas pontas.
  String _clean(String text) => text
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll(RegExp(r'^\s*(para|pra|de|da|do|a|o)\s+', caseSensitive: false), '')
      .replaceAll(RegExp(r'\s+(para|pra|em|no|na|de)\s*$', caseSensitive: false), '')
      .trim();

  /// Busca um item da lista pelo nome falado (parcial, nos dois sentidos).
  TaskModel? _findTask(List<TaskModel> list, String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return null;
    for (final t in list) {
      final n = t.nome.toLowerCase();
      if (n.contains(q) || q.contains(n)) return t;
    }
    final qWords = q.split(' ').where((w) => w.length > 3).toSet();
    for (final t in list) {
      final nWords = t.nome.toLowerCase().split(' ').toSet();
      if (qWords.intersection(nWords).isNotEmpty) return t;
    }
    return null;
  }

  AppointmentModel? _findAppointment(
      List<AppointmentModel> list, String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return null;
    for (final a in list) {
      final n = a.titulo.toLowerCase();
      if (n.contains(q) || q.contains(n)) return a;
    }
    final qWords = q.split(' ').where((w) => w.length > 3).toSet();
    for (final a in list) {
      final nWords = a.titulo.toLowerCase().split(' ').toSet();
      if (qWords.intersection(nWords).isNotEmpty) return a;
    }
    return null;
  }

  /// Mostra a resposta na tela e fala em voz alta
  /// (a menos que o som esteja desligado nas configurações).
  void _say(String msg) {
    setState(() => _feedback = msg);
    if (context.read<SettingsProvider>().sound) {
      TtsService().speak(msg);
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // Comandos
  // ═══════════════════════════════════════════════════════════════════

  /// Roteador: tenta a IA (Gemini) primeiro; se o limite gratuito diário
  /// estourar ou a IA estiver indisponível, cai nos comandos por regras.
  Future<void> _processCommand(String text) async {
    if (text.isEmpty) {
      _say('Nenhum comando detectado. Tente novamente.');
      return;
    }

    final auth = context.read<AuthProvider>();
    // Modo local (sem nuvem): só comandos básicos
    if (auth.localMode) {
      setState(() => _source = 'basic');
      _processCommandOffline(text);
      return;
    }

    _ai ??= AiVoiceService(
      tasks: context.read<TaskProvider>(),
      appointments: context.read<AppointmentProvider>(),
      notes: context.read<NoteProvider>(),
    );

    setState(() {
      _feedback = 'Pensando... 💭';
      _source = 'ai';
    });

    try {
      final reply = await _ai!.process(text);
      if (!mounted) return;
      setState(() => _feedback = '✅ $reply');
      await _speakAndMaybeContinue(reply);
    } on AiQuotaException {
      if (!mounted) return;
      setState(() => _source = 'basic');
      _processCommandOffline(text);
      setState(() => _feedback =
          '⚠️ Limite gratuito da IA atingido hoje — usando comandos básicos.\n\n$_feedback');
    } on AiUnavailableException {
      if (!mounted) return;
      setState(() => _source = 'basic');
      _processCommandOffline(text);
    }
  }

  /// Fala a resposta e, no modo conversa, reabre o microfone em seguida.
  Future<void> _speakAndMaybeContinue(String reply) async {
    final sound = context.read<SettingsProvider>().sound;

    // Opção do usuário: ouvir ENQUANTO ela fala (risco de eco, escolha dele)
    if (_conversationMode && !_muteWhileSpeaking && !_listening) {
      await _toggleListening();
    }

    if (sound) {
      // speak() só completa quando a fala termina (mic mudo nesse período)
      await TtsService().speak(reply);
    }

    if (!mounted || !_conversationMode) return;
    if (!_listening) await _toggleListening();
  }

  /// Interpretador por regras (offline/fallback) — comandos conhecidos.
  void _processCommandOffline(String text) {
    final lower = text.toLowerCase();
    final tasks = context.read<TaskProvider>();
    final notes = context.read<NoteProvider>();
    final appointments = context.read<AppointmentProvider>();

    // ── Consultas ─────────────────────────────────────────────────────

    if (RegExp(r'(listar|quais|minhas)\b.*\btarefas conclu[ií]das')
        .hasMatch(lower)) {
      final done = tasks.completed;
      if (done.isEmpty) {
        _say('Você ainda não concluiu nenhuma tarefa.');
      } else {
        final names = done.take(5).map((t) => '• ${t.nome}').join('\n');
        _say('✅ ${done.length} tarefa(s) concluída(s):\n$names');
      }
      return;
    }

    if (RegExp(r'(listar|quais( s[ãa]o)?|minhas)\b.*\btarefas')
        .hasMatch(lower)) {
      final p = tasks.pending;
      if (p.isEmpty) {
        _say('✅ Nenhuma tarefa pendente. Tudo em dia! 🎉');
      } else {
        final names = p
            .take(5)
            .map((t) => '• ${t.nome} (${t.horario} ${t.data})')
            .join('\n');
        _say('✅ Você tem ${p.length} tarefa(s) pendente(s):\n$names');
      }
      return;
    }

    if (RegExp(r'(listar|quais|meus)\b.*\bcompromissos').hasMatch(lower) ||
        lower.contains('minha agenda')) {
      final up = appointments.upcoming.take(5).toList();
      if (up.isEmpty) {
        _say('Você não tem compromissos futuros.');
      } else {
        final names = up
            .map((a) => '• ${a.titulo} — ${a.dateFormatted} às ${a.horario}')
            .join('\n');
        _say('✅ Próximos compromissos:\n$names');
      }
      return;
    }

    // ── Reagendar tarefa ──────────────────────────────────────────────

    if (lower.contains('reagendar')) {
      var rest = text.replaceAll(
          RegExp(r'reagendar( a tarefa| o lembrete| a reunião)?',
              caseSensitive: false),
          ' ');
      final d = _extractDate(rest);
      final t = _extractTime(d.rest);
      final nome = _clean(t.rest);

      final task = _findTask(tasks.pending, nome);
      if (task != null) {
        tasks.rescheduleTask(task.id, d.data, t.horario);
        _say('✅ "${task.nome}" reagendada para ${d.data} às ${t.horario}');
      } else {
        _say('⚠️ Tarefa não encontrada: "$nome"');
      }
      return;
    }

    // ── Concluir tarefa ───────────────────────────────────────────────

    if (RegExp(r'marcar como conclu[ií]da|concluir|finalizar|terminei|j[áa] fiz')
        .hasMatch(lower)) {
      final nome = _clean(text.replaceAll(
          RegExp(
              r'marcar como conclu[ií]da( a tarefa)?|concluir( a)?( tarefa)?|finalizar( a)?( tarefa)?|terminei( a)?( tarefa)?|j[áa] fiz( a)?( tarefa)?',
              caseSensitive: false),
          ' '));
      final task = _findTask(tasks.pending, nome);
      if (task != null) {
        tasks.completeTask(task.id);
        _say('✅ Tarefa "${task.nome}" concluída! Parabéns! 🎉');
      } else {
        _say('⚠️ Tarefa não encontrada: "$nome"');
      }
      return;
    }

    // ── Excluir tarefa ────────────────────────────────────────────────

    if (RegExp(r'(excluir|apagar|remover|deletar)\b.*\btarefa|'
            r'(excluir|apagar|remover|deletar) tarefa')
        .hasMatch(lower)) {
      final nome = _clean(text.replaceAll(
          RegExp(r'(excluir|apagar|remover|deletar)( a)?( tarefa)?',
              caseSensitive: false),
          ' '));
      final task = _findTask(tasks.tasks, nome);
      if (task != null) {
        tasks.deleteTask(task.id);
        _say('✅ Tarefa "${task.nome}" excluída.');
      } else {
        _say('⚠️ Tarefa não encontrada: "$nome"');
      }
      return;
    }

    // ── Cancelar compromisso ──────────────────────────────────────────

    if (RegExp(r'(cancelar|excluir|apagar|remover|desmarcar)\b.*\b(compromisso|reuni[ãa]o|consulta|evento)')
        .hasMatch(lower)) {
      final nome = _clean(text.replaceAll(
          RegExp(
              r'(cancelar|excluir|apagar|remover|desmarcar)( o| a)?( compromisso| reuni[ãa]o| consulta| evento)?( de| da| do)?',
              caseSensitive: false),
          ' '));
      final ap = _findAppointment(appointments.appointments, nome);
      if (ap != null) {
        appointments.deleteAppointment(ap.id);
        _say('✅ Compromisso "${ap.titulo}" cancelado.');
      } else {
        _say('⚠️ Compromisso não encontrado: "$nome"');
      }
      return;
    }

    // ── Criar compromisso / agendamento ───────────────────────────────

    if (RegExp(r'\bagendar\b|\bmarcar\b.*\b(reuni[ãa]o|consulta|compromisso|evento)|novo compromisso|criar compromisso')
        .hasMatch(lower)) {
      var rest = text.replaceAll(
          RegExp(
              r'\bagendar\b|\bmarcar\b|novo compromisso|criar compromisso|\buma?\b',
              caseSensitive: false),
          ' ');

      final d = _extractDate(rest);
      final t = _extractTime(d.rest);
      rest = t.rest;

      // Local: "no escritório", "na clínica" (após remover data/hora)
      String local = '';
      final localReg = RegExp(r'\b(?:no|na|em)\s+([\wÀ-ú ]{3,30})\s*$',
          caseSensitive: false);
      final lm = localReg.firstMatch(rest.trim());
      if (lm != null) {
        local = _clean(lm.group(1)!);
        rest = rest.replaceFirst(localReg, ' ');
      }

      final titulo = _clean(rest);
      if (titulo.isEmpty) {
        _say('⚠️ Não entendi o nome do compromisso. Tente: "Agendar reunião amanhã às 10h"');
        return;
      }

      final parts = d.data.split('/');
      appointments.addAppointment(
        titulo: titulo,
        horario: t.horario,
        local: local,
        date: DateTime(
            int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0])),
      );
      _say('✅ Compromisso "$titulo" agendado para ${d.data} às ${t.horario}'
          '${local.isNotEmpty ? ' em $local' : ''}');
      return;
    }

    // ── Criar tarefa / lembrete ───────────────────────────────────────

    if (lower.contains('criar tarefa') ||
        lower.contains('adicionar tarefa') ||
        lower.contains('nova tarefa') ||
        lower.contains('lembrar de') ||
        lower.contains('lembrete')) {
      var rest = text.replaceAll(
          RegExp(
              r'criar tarefa|adicionar tarefa|nova tarefa|lembrar de|criar lembrete|adicionar lembrete|lembrete',
              caseSensitive: false),
          ' ');

      final pr = _extractPriority(rest);
      final d = _extractDate(pr.rest);
      final t = _extractTime(d.rest);
      var nome = _clean(t.rest);
      if (nome.isEmpty) nome = _clean(text);

      tasks.addTask(
        nome: nome,
        data: d.data,
        horario: t.horario,
        prioridade: pr.prioridade,
        lembrete: true,
      );
      final prLabel = AppColors.priorityLabel(pr.prioridade);
      _say('✅ Tarefa criada: "$nome"\n📅 ${d.data} às ${t.horario} • Prioridade $prLabel');
      return;
    }

    // ── Adicionar nota ────────────────────────────────────────────────

    if (lower.contains('adicionar nota') ||
        lower.contains('nova nota') ||
        lower.contains('criar nota') ||
        lower.contains('anotar')) {
      final body = _clean(text.replaceAll(
          RegExp(r'adicionar nota|nova nota|criar nota|anotar( que)?',
              caseSensitive: false),
          ' '));
      if (body.isEmpty) {
        _say('⚠️ A nota ficou vazia. Tente: "Anotar comprar material"');
        return;
      }
      final titulo = body.length > 40 ? '${body.substring(0, 40)}...' : body;
      notes.addNote(titulo: titulo, corpo: body);
      _say('✅ Nota criada: "$titulo"');
      return;
    }

    _say('⚠️ Comando não reconhecido. Exemplos:\n'
        '• "Criar tarefa pagar conta amanhã às 9h"\n'
        '• "Agendar reunião sexta às 10h no escritório"\n'
        '• "Concluir tarefa pagar conta"\n'
        '• "Listar minhas tarefas"');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Comando de Voz',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Toque no microfone e fale seu comando',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 32),

              // Mic button
              AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, child) => Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _listening
                        ? AppColors.error.withValues(
                            alpha: 0.1 + _pulseCtrl.value * 0.15)
                        : Colors.transparent,
                  ),
                  child: child,
                ),
                child: GestureDetector(
                  onTap: _toggleListening,
                  child: Container(
                    width: 90,
                    height: 90,
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: _listening
                            ? [AppColors.error, AppColors.error.withValues(alpha: 0.7)]
                            : [AppColors.gold, AppColors.primary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_listening ? AppColors.error : AppColors.gold)
                              .withValues(alpha: 0.5),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      _listening ? Icons.stop_rounded : Icons.mic_rounded,
                      size: 44,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              if (_listening) ...[
                const SizedBox(height: 10),
                Text(
                  _status == 'listening'
                      ? '🎙️ Capturando áudio... fale agora'
                      : 'Status: $_status',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11),
                ),
              ],

              // Modo conversa contínua
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.forum_outlined,
                      size: 16, color: AppColors.accent),
                  const SizedBox(width: 6),
                  const Text(
                    'Conversa contínua',
                    style: TextStyle(
                        color: AppColors.textPrimary, fontSize: 13),
                  ),
                  Switch(
                    value: _conversationMode,
                    onChanged: (v) =>
                        setState(() => _conversationMode = v),
                  ),
                ],
              ),
              if (_conversationMode)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.mic_off_outlined,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    const Text(
                      'Silenciar mic enquanto ela fala',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                    Switch(
                      value: _muteWhileSpeaking,
                      onChanged: (v) =>
                          setState(() => _muteWhileSpeaking = v),
                    ),
                  ],
                ),

              const SizedBox(height: 12),

              // Transcription
              if (_transcript.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Você disse:',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 11)),
                      const SizedBox(height: 4),
                      Text(
                        '"$_transcript"',
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),

              if (_feedback.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _feedback.startsWith('✅')
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _feedback.startsWith('✅')
                          ? AppColors.success.withValues(alpha: 0.4)
                          : AppColors.warning.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    _feedback,
                    style: TextStyle(
                      color: _feedback.startsWith('✅')
                          ? AppColors.success
                          : AppColors.warning,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (_source.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      _source == 'ai'
                          ? '✨ Respondido pela IA'
                          : '⚙️ Comandos básicos',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 10),
                    ),
                  ),
                ],
              ],

              const SizedBox(height: 20),

              // Fallback: digitar o comando
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _typedCtrl,
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Ou digite seu comando aqui...',
                        prefixIcon: Icon(Icons.keyboard_outlined,
                            color: AppColors.textSecondary, size: 20),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _submitTyped(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _submitTyped,
                    icon: const Icon(Icons.send_rounded,
                        color: AppColors.primary),
                    tooltip: 'Executar comando',
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const _CommandsHelp(),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommandsHelp extends StatelessWidget {
  const _CommandsHelp();

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<String>>{
      'Tarefas': [
        'Criar tarefa pagar conta amanhã às 9h',
        'Criar tarefa urgente ligar para Carlos sexta às 15h',
        'Concluir tarefa pagar conta',
        'Reagendar pagar conta para sexta às 10h',
        'Excluir tarefa pagar conta',
        'Listar minhas tarefas',
        'Listar tarefas concluídas',
      ],
      'Agenda': [
        'Agendar reunião amanhã às 10h no escritório',
        'Marcar consulta dia 20 às 14h30',
        'Cancelar compromisso reunião',
        'Listar meus compromissos',
      ],
      'Notas': [
        'Anotar comprar material de escritório',
      ],
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Comandos disponíveis:',
            style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        for (final entry in groups.entries) ...[
          Text(entry.key.toUpperCase(),
              style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1)),
          const SizedBox(height: 4),
          ...entry.value.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.arrow_right,
                        size: 16, color: AppColors.gold),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text('"$c"',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
