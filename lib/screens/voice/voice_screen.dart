import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../models/task_model.dart';
import '../../models/appointment_model.dart';
import '../../models/note_model.dart';
import '../../providers/task_provider.dart';
import '../../providers/note_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/ai_voice_service.dart';
import '../../services/tts_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/dia_colors.dart';
import '../../utils/l10n_ext.dart';

/// Estado atual do ciclo de conversa (indicador visual).
enum _VoicePhase { idle, listening, processing, responding }

/// Ação proposta pelo interpretador offline, aguardando confirmação do usuário.
/// Garante que nada é salvo sem o "sim" — e nada é perdido.
class _PendingAction {
  final String kind; // create_task | create_appointment | create_note
  //                    | complete | delete | reschedule | cancel_appointment
  //                    | edit_task | edit_appointment | edit_note
  //                    | restore_task | restore_appointment | restore_note
  final Map<String, dynamic> data;
  final String summary; // texto curto exibido ao confirmar

  _PendingAction(this.kind, this.data, this.summary);
}

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
  String _source = ''; // 'ai' | 'basic' — origem da última resposta
  AiVoiceService? _ai;
  bool _conversationActive = false; // conversa hands-free iniciada
  bool _paused = false; // usuário tocou no ícone 🔇
  _VoicePhase _phase = _VoicePhase.idle;
  int _silentCycles = 0; // ciclos seguidos sem fala → inatividade
  _PendingAction? _pending; // ação offline aguardando confirmação
  bool _aiExhausted = false; // limite da IA estourou → fica no modo offline
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
        // 'no-speech'/'no-match': só silêncio — em conversa, volta a ouvir
        if (e.errorMsg == 'no-speech' || e.errorMsg == 'error_no_match') {
          _onSilentCycle();
          return;
        }
        // Erro real: encerra a conversa e avisa (sem ficar em loop)
        setState(() {
          _conversationActive = false;
          _feedback = '⚠️ Erro no microfone: ${e.errorMsg}';
        });
      },
      onStatus: (status) {
        debugPrint('STT status: $status | transcript: "$_transcript"');
        if (!mounted) return;
        // No Chrome o "finalResult" às vezes nunca chega; quando o
        // reconhecimento termina, processa o que foi capturado.
        if (status == 'done' || status == 'notListening') {
          if (_listening) setState(() => _listening = false);
          if (_transcript.isNotEmpty && !_processed) {
            _processed = true;
            _processCommand(_transcript);
          } else if (_transcript.isEmpty) {
            // Silêncio: conta inatividade e mantém ouvindo
            _onSilentCycle();
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

  /// Microfone principal: inicia (ou reinicia) a conversa hands-free.
  Future<void> _startConversation() async {
    if (!_available) {
      setState(() => _feedback = context.l10n.voiceMicUnavailable);
      return;
    }
    _ai?.resetConversation();
    setState(() {
      _conversationActive = true;
      _paused = false;
      _feedback = '';
      _source = '';
      _transcript = '';
      _silentCycles = 0;
      _phase = _VoicePhase.listening;
    });
    await _startListening();
  }

  /// Abre uma sessão de escuta. O navegador encerra após a pausa; o ciclo
  /// é mantido por _scheduleRelisten (após silêncio ou após a IA falar).
  Future<void> _startListening() async {
    if (!_available || !_conversationActive || _paused || _listening) return;
    await TtsService().stop(); // garante mic sem eco
    if (!mounted) return;
    setState(() {
      _listening = true;
      _processed = false;
      _transcript = '';
      _phase = _VoicePhase.listening;
    });
    await _speech.listen(
      onResult: (r) {
        if (!mounted) return;
        setState(() => _transcript = r.recognizedWords);
        if (r.recognizedWords.trim().isNotEmpty) _silentCycles = 0;
        if (r.finalResult && !_processed) {
          _processed = true;
          setState(() => _listening = false);
          _processCommand(r.recognizedWords);
        }
      },
      listenOptions: SpeechListenOptions(
        // Navegador usa hífen (pt-BR); Android/iOS usam underscore (pt_BR)
        localeId: kIsWeb ? 'pt-BR' : 'pt_BR',
        listenFor: const Duration(seconds: 30),
        // 3s de silêncio: não corta o usuário no meio do raciocínio
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        cancelOnError: true,
      ),
    );
  }

  /// Reabre a escuta após um pequeno intervalo, se a conversa segue ativa.
  void _scheduleRelisten() {
    if (!_conversationActive || _paused) return;
    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted || !_conversationActive || _paused || _listening) return;
      _startListening();
    });
  }

  /// Ícone inferior 🎤/🔇: pausa ou retoma a escuta contínua.
  Future<void> _togglePause() async {
    if (_paused) {
      setState(() => _paused = false);
      await _startListening();
    } else {
      setState(() => _paused = true);
      await _speech.stop();
      await TtsService().stop();
      if (mounted) setState(() => _listening = false);
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

  NoteModel? _findNote(List<NoteModel> list, String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return null;
    for (final n in list) {
      final t = n.titulo.toLowerCase();
      if (t.contains(q) || q.contains(t)) return n;
    }
    final qWords = q.split(' ').where((w) => w.length > 3).toSet();
    for (final n in list) {
      final tWords = n.titulo.toLowerCase().split(' ').toSet();
      if (qWords.intersection(tWords).isNotEmpty) return n;
    }
    return null;
  }

  /// Mostra a resposta na tela, fala em voz alta e — em conversa contínua —
  /// reabre o microfone quando a fala termina.
  void _say(String msg) {
    if (!mounted) return;
    setState(() => _feedback = msg);
    _speakThen(msg);
  }

  /// Fala a resposta e retorna automaticamente para escuta (modo contínuo).
  Future<void> _speakThen(String msg) async {
    if (mounted) setState(() => _phase = _VoicePhase.responding);
    final sound = context.read<SettingsProvider>().sound;
    if (sound) {
      // speak() completa quando a fala termina (mic já parado, sem eco)
      await TtsService().speak(msg);
    }
    if (!mounted) return;
    _scheduleRelisten(); // retorno automático à escuta (< 500ms)
  }

  /// Conta ciclos seguidos de silêncio; encerra por inatividade após o limite.
  void _onSilentCycle() {
    _silentCycles++;
    if (_silentCycles >= 5) {
      _endSession(); // inatividade prolongada
    } else {
      _scheduleRelisten();
    }
  }

  /// Encerra a sessão de voz (palavra de parada, inatividade ou pausa final).
  Future<void> _endSession({String farewell = ''}) async {
    await _speech.stop();
    await TtsService().stop();
    if (!mounted) return;
    setState(() {
      _conversationActive = false;
      _paused = false;
      _listening = false;
      _phase = _VoicePhase.idle;
      _silentCycles = 0;
      _feedback = farewell.isEmpty ? '⚪ Conversa encerrada.' : '⚪ $farewell';
    });
    if (farewell.isNotEmpty && context.read<SettingsProvider>().sound) {
      await TtsService().speak(farewell);
    }
  }

  Color get _feedbackColor {
    if (_feedback.startsWith('✅')) return AppColors.success;
    if (_feedback.startsWith('⚠️')) return AppColors.warning;
    return AppColors.accent; // perguntas / "Pensando..."
  }

  // ═══════════════════════════════════════════════════════════════════
  // Comandos
  // ═══════════════════════════════════════════════════════════════════

  /// Roteador: tenta a IA (Gemini) primeiro; se o limite gratuito diário
  /// estourar ou a IA estiver indisponível, cai nos comandos por regras.
  Future<void> _processCommand(String text) async {
    if (text.isEmpty) {
      _scheduleRelisten();
      return;
    }

    // Palavras de encerramento: finalizam a sessão de voz
    final t = text.trim().toLowerCase();
    if (t.split(RegExp(r'\s+')).length <= 3 &&
        RegExp(r'\b(encerrar|parar|finalizar|tchau|chega)\b').hasMatch(t)) {
      await _endSession(farewell: 'Encerrado. Até logo!');
      return;
    }

    if (mounted) setState(() => _phase = _VoicePhase.processing);

    // Se há uma proposta offline aguardando confirmação, trata aqui
    if (_pending != null) {
      _handlePendingReply(text);
      return;
    }

    final auth = context.read<AuthProvider>();
    // Modo local (sem nuvem) ou IA já esgotada nesta sessão: só offline
    if (auth.localMode || _aiExhausted) {
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
      final result = await _ai!.process(text);
      if (!mounted) return;
      // Modo contínuo: sempre volta a ouvir após responder
      _say(result.reply);
    } on AiQuotaException {
      if (!mounted) return;
      // Fica no offline pelo resto da sessão (não martela a cota)
      _aiExhausted = true;
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

  // ═══════════════════════════════════════════════════════════════════
  // Confirmação de ações offline (capturar → confirmar → salvar)
  // ═══════════════════════════════════════════════════════════════════

  bool _isYes(String t) => RegExp(
          r'\b(sim|claro|pode|confirm|isso|ok|okay|correto|certo|exato|positivo|manda|salva|salvar|agenda|cria|criar|fazer|faz)\b')
      .hasMatch(t);

  bool _isNo(String t) => RegExp(
          r'\b(n[ãa]o|nao|cancela|cancelar|deixa|esquece|errado|negativo|para)\b')
      .hasMatch(t);

  /// Resposta do usuário a uma proposta pendente.
  void _handlePendingReply(String text) {
    final t = text.trim().toLowerCase();
    final raw = _pending!.data['raw'] as String?;

    // "não" é checado antes de "sim" (ex.: "não pode" = negação)
    if (_isNo(t)) {
      _pending = null;
      _say('Ok, cancelei. Pode falar outro comando.');
      return;
    }
    if (_isYes(t)) {
      final summary = _pending!.summary;
      _executePending();
      _pending = null;
      _say('✅ Pronto! $summary');
      return;
    }
    // Redirecionar o tipo, mantendo o texto original
    if (raw != null && RegExp(r'\b(nota|anota)\b').hasMatch(t)) {
      _proposeNote(raw);
      return;
    }
    if (raw != null &&
        RegExp(r'\b(compromisso|reuni|consulta|agenda)\b').hasMatch(t)) {
      _proposeAppointmentFromRaw(raw);
      return;
    }
    if (raw != null && RegExp(r'\btarefa\b').hasMatch(t)) {
      _proposeTask(raw);
      return;
    }
    // Qualquer outra coisa: considera um novo comando
    _pending = null;
    _processCommandOffline(text);
  }

  Future<void> _executePending() async {
    final p = _pending!;
    final tasks = context.read<TaskProvider>();
    final notes = context.read<NoteProvider>();
    final appts = context.read<AppointmentProvider>();
    switch (p.kind) {
      case 'create_task':
        await tasks.addTask(
          nome: p.data['nome'] as String,
          data: p.data['data'] as String,
          horario: p.data['horario'] as String,
          prioridade: p.data['prioridade'] as String,
          lembrete: true,
        );
      case 'create_appointment':
        final parts = (p.data['data'] as String).split('/');
        await appts.addAppointment(
          titulo: p.data['titulo'] as String,
          horario: p.data['horario'] as String,
          local: p.data['local'] as String,
          date: DateTime(
              int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0])),
        );
      case 'create_note':
        await notes.addNote(
            titulo: p.data['titulo'] as String,
            corpo: p.data['corpo'] as String);
      case 'complete':
        await tasks.completeTask(p.data['id'] as String);
      case 'delete':
        await tasks.softDeleteTask(p.data['id'] as String);
      case 'reschedule':
        await tasks.rescheduleTask(p.data['id'] as String,
            p.data['data'] as String, p.data['horario'] as String);
      case 'cancel_appointment':
        await appts.softDeleteAppointment(p.data['id'] as String);
      case 'edit_task':
        final t = tasks.tasks.firstWhere((x) => x.id == p.data['id']);
        await tasks.updateTask(t.copyWith(
          nome: (p.data['nome'] as String?) ?? t.nome,
          data: (p.data['data'] as String?) ?? t.data,
          horario: (p.data['horario'] as String?) ?? t.horario,
          prioridade: (p.data['prioridade'] as String?) ?? t.prioridade,
        ));
      case 'edit_appointment':
        final ap = appts.appointments.firstWhere((x) => x.id == p.data['id']);
        DateTime? newDate;
        final dataStr = p.data['data'] as String?;
        if (dataStr != null) {
          final parts = dataStr.split('/');
          if (parts.length == 3) {
            newDate = DateTime(int.parse(parts[2]), int.parse(parts[1]),
                int.parse(parts[0]));
          }
        }
        await appts.updateAppointment(ap.copyWith(
          titulo: (p.data['titulo'] as String?) ?? ap.titulo,
          horario: (p.data['horario'] as String?) ?? ap.horario,
          local: (p.data['local'] as String?) ?? ap.local,
          prioridade: (p.data['prioridade'] as String?) ?? ap.prioridade,
          dia: newDate?.day ?? ap.dia,
          mes: newDate?.month ?? ap.mes,
          ano: newDate?.year ?? ap.ano,
        ));
      case 'edit_note':
        final n = notes.notes.firstWhere((x) => x.id == p.data['id']);
        await notes.updateNote(NoteModel(
          id: n.id,
          titulo: (p.data['titulo'] as String?) ?? n.titulo,
          corpo: (p.data['corpo'] as String?) ?? n.corpo,
          dataCriacao: n.dataCriacao,
        ));
      case 'restore_task':
        await tasks.restoreTask(p.data['id'] as String);
      case 'restore_appointment':
        await appts.restoreAppointment(p.data['id'] as String);
      case 'restore_note':
        await notes.restoreNote(p.data['id'] as String);
    }
  }

  // ─── Propostas (montam _pending + perguntam "Confirmo?") ─────────────

  void _proposeTask(String raw, {bool capture = false}) {
    final pr = _extractPriority(raw);
    final d = _extractDate(pr.rest);
    final tm = _extractTime(d.rest);
    var nome = _clean(tm.rest);
    if (nome.isEmpty) nome = _clean(raw);
    _pending = _PendingAction('create_task', {
      'nome': nome,
      'data': d.data,
      'horario': tm.horario,
      'prioridade': pr.prioridade,
      'raw': raw,
    }, 'Tarefa "$nome" em ${d.data} às ${tm.horario}');
    if (capture) {
      _say('Não entendi o comando, mas posso salvar como tarefa: "$nome" '
          'em ${d.data} às ${tm.horario}. Confirmo? (ou diga "nota" ou "compromisso")');
    } else {
      final prLabel = AppColors.priorityLabel(pr.prioridade);
      _say('Tarefa "$nome" para ${d.data} às ${tm.horario}, '
          'prioridade $prLabel. Confirmo?');
    }
  }

  void _proposeAppointmentFromRaw(String raw) {
    var rest = raw.replaceAll(
        RegExp(
            r'\bagendar\b|\bmarcar\b|novo compromisso|criar compromisso|\btenho\b|\buma?\b',
            caseSensitive: false),
        ' ');
    final d = _extractDate(rest);
    final tm = _extractTime(d.rest);
    rest = tm.rest;
    String local = '';
    final localReg =
        RegExp(r'\b(?:no|na|em)\s+([\wÀ-ú ]{3,30})\s*$', caseSensitive: false);
    final lm = localReg.firstMatch(rest.trim());
    if (lm != null) {
      local = _clean(lm.group(1)!);
      rest = rest.replaceFirst(localReg, ' ');
    }
    var titulo = _clean(rest);
    if (titulo.isEmpty) titulo = _clean(raw);
    _pending = _PendingAction('create_appointment', {
      'titulo': titulo,
      'data': d.data,
      'horario': tm.horario,
      'local': local,
      'raw': raw,
    }, 'Compromisso "$titulo" em ${d.data} às ${tm.horario}');
    _say('Compromisso "$titulo" para ${d.data} às ${tm.horario}'
        '${local.isNotEmpty ? ' em $local' : ''}. Confirmo?');
  }

  void _proposeNote(String raw) {
    final body = _clean(raw.replaceAll(
        RegExp(
            r'\b(anotar|anota|nova nota|criar nota|tomar nota|salvar nota|nota)\b',
            caseSensitive: false),
        ' '));
    final corpo = body.isEmpty ? _clean(raw) : body;
    final titulo = corpo.length > 40 ? '${corpo.substring(0, 40)}...' : corpo;
    _pending = _PendingAction(
        'create_note', {'titulo': titulo, 'corpo': corpo, 'raw': raw},
        'Nota "$titulo"');
    _say('Nota: "$titulo". Confirmo?');
  }

  // ─── Edição por voz ──────────────────────────────────────────────────

  void _proposeEditTask(String raw) {
    final tasks = context.read<TaskProvider>();
    var rest = raw.replaceAll(
        RegExp(
            r'\b(editar|atualizar|modificar|jogar|empurrar|botar)\b|\btarefa\b',
            caseSensitive: false),
        ' ');

    String taskPart = rest;
    String changePart = '';

    // Separador "nome — mudança"
    final emDash = rest.indexOf(' — ');
    final dash = rest.indexOf(' - ');
    final sep = emDash >= 0 ? emDash : dash;
    if (sep >= 0) {
      taskPart = rest.substring(0, sep);
      changePart = rest.substring(sep).replaceAll(RegExp(r'^ *[—\-]+ *'), '');
    } else {
      // Último "para" separa nome de mudança
      final ms = RegExp(r'\bpara\b', caseSensitive: false).allMatches(rest);
      if (ms.isNotEmpty) {
        final m = ms.last;
        taskPart = rest.substring(0, m.start);
        changePart = rest.substring(m.end);
      }
    }

    // "essa / este" → primeira tarefa pendente
    final query = _clean(taskPart);
    TaskModel? task;
    if (RegExp(r'^(essa|este|esta|isso|aquela|aquele)$').hasMatch(query)) {
      task = tasks.pending.isNotEmpty ? tasks.pending.first : null;
    } else {
      task = _findTask([...tasks.pending, ...tasks.completed], query);
    }
    if (task == null) {
      _say('Não encontrei a tarefa "${query.isNotEmpty ? query : '?'}". Qual o nome exato?');
      return;
    }

    final changeText = changePart.isEmpty ? raw : changePart;
    final pr = _extractPriority(changeText);
    final d = _extractDate(pr.rest);
    final tm = _extractTime(d.rest);

    final data = <String, dynamic>{'id': task.id, 'raw': raw};
    final changeDesc = <String>[];

    final wantsDate = changePart.isNotEmpty ||
        RegExp(r'\b(amanhã|amanha|hoje|segunda|terça|quarta|quinta|sexta|sábado|domingo|dia \d|depois de amanhã)\b',
                caseSensitive: false)
            .hasMatch(raw);
    if (wantsDate || tm.found) {
      data['data'] = d.data;
      data['horario'] = tm.horario;
      changeDesc.add('${d.data} às ${tm.horario}');
    }
    if (RegExp(r'\bprioridade\b|urgente', caseSensitive: false).hasMatch(raw)) {
      data['prioridade'] = pr.prioridade;
      changeDesc.add('prioridade: ${AppColors.priorityLabel(pr.prioridade)}');
    }

    if (data.length <= 2) {
      _say('O que quer alterar em "${task.nome}"? Diga a nova data, horário ou prioridade.');
      return;
    }
    _pending = _PendingAction(
        'edit_task', data, '"${task.nome}" atualizada: ${changeDesc.join(', ')}');
    _say('Atualizar "${task.nome}": ${changeDesc.join(', ')}. Confirmo?');
  }

  void _proposeEditAppointment(String raw) {
    final appts = context.read<AppointmentProvider>();
    var rest = raw.replaceAll(
        RegExp(
            r'\b(editar|alterar|mudar|atualizar|modificar|prioridade)\b|\b(compromisso|reuni[ãa]o|consulta|evento)\b',
            caseSensitive: false),
        ' ');

    String apPart = rest;
    String changePart = '';

    final emDash = rest.indexOf(' — ');
    final dash = rest.indexOf(' - ');
    final sep = emDash >= 0 ? emDash : dash;
    if (sep >= 0) {
      apPart = rest.substring(0, sep);
      changePart = rest.substring(sep).replaceAll(RegExp(r'^ *[—\-]+ *'), '');
    } else {
      final ms = RegExp(r'\bpara\b', caseSensitive: false).allMatches(rest);
      if (ms.isNotEmpty) {
        final m = ms.last;
        apPart = rest.substring(0, m.start);
        changePart = rest.substring(m.end);
      }
    }

    final query = _clean(apPart);
    final ap = _findAppointment(appts.appointments, query);
    if (ap == null) {
      _say('Não encontrei o compromisso "${query.isNotEmpty ? query : '?'}". Qual o nome?');
      return;
    }

    final changeText = changePart.isEmpty ? raw : changePart;
    final pr = _extractPriority(changeText);
    final d = _extractDate(pr.rest);
    final tm = _extractTime(d.rest);

    final data = <String, dynamic>{'id': ap.id, 'raw': raw};
    final changeDesc = <String>[];

    final wantsDate = changePart.isNotEmpty ||
        RegExp(r'\b(amanhã|amanha|hoje|segunda|terça|quarta|quinta|sexta|sábado|domingo|dia \d|depois de amanhã)\b',
                caseSensitive: false)
            .hasMatch(raw);
    if (wantsDate || tm.found) {
      data['data'] = d.data;
      data['horario'] = tm.horario;
      changeDesc.add('${d.data} às ${tm.horario}');
    }
    if (RegExp(r'\bprioridade\b|urgente', caseSensitive: false).hasMatch(raw)) {
      data['prioridade'] = pr.prioridade;
      changeDesc.add('prioridade: ${AppColors.priorityLabel(pr.prioridade)}');
    }

    if (data.length <= 2) {
      _say('O que quer alterar em "${ap.titulo}"? Diga a nova data, horário ou prioridade.');
      return;
    }
    _pending = _PendingAction(
        'edit_appointment', data, '"${ap.titulo}" atualizado: ${changeDesc.join(', ')}');
    _say('Atualizar "${ap.titulo}": ${changeDesc.join(', ')}. Confirmo?');
  }

  void _proposeEditNote(String raw) {
    final notesP = context.read<NoteProvider>();
    var rest = raw.replaceAll(
        RegExp(
            r'\b(editar|alterar|mudar|acrescentar|adicionar|incluir|colocar|inserir)\b|\bnota\b',
            caseSensitive: false),
        ' ');

    String notePart = rest;
    String addPart = '';

    final emDash = rest.indexOf(' — ');
    final dash = rest.indexOf(' - ');
    final sep = emDash >= 0 ? emDash : dash;
    if (sep >= 0) {
      notePart = rest.substring(0, sep);
      addPart = rest.substring(sep).replaceAll(RegExp(r'^ *[—\-]+ *'), '');
      addPart = addPart.replaceAll(
          RegExp(r'^(adicionar|acrescentar|incluir|colocar|inserir)\s*',
              caseSensitive: false),
          '');
    } else {
      // "acrescentar X na nota Y"
      final naReg = RegExp(r'\b(n[ao] nota|[àa] nota)\b', caseSensitive: false);
      final m = naReg.firstMatch(rest);
      if (m != null) {
        addPart = _clean(rest.substring(0, m.start));
        notePart = rest.substring(m.end);
      }
    }

    final query = _clean(notePart);
    final note = _findNote(notesP.notes, query);
    if (note == null) {
      _say('Não encontrei a nota "${query.isNotEmpty ? query : '?'}". Qual o título?');
      return;
    }

    final content = _clean(addPart);
    if (content.isEmpty) {
      _say('O que quer adicionar na nota "${note.titulo}"?');
      return;
    }

    final newCorpo =
        note.corpo.isEmpty ? content : '${note.corpo}\n$content';
    _pending = _PendingAction('edit_note',
        {'id': note.id, 'titulo': note.titulo, 'corpo': newCorpo, 'raw': raw},
        'Nota "${note.titulo}" atualizada');
    _say('Adicionar "$content" à nota "${note.titulo}". Confirmo?');
  }

  void _proposeRestore(String raw) {
    final tasks = context.read<TaskProvider>();
    final appts = context.read<AppointmentProvider>();
    final notesP = context.read<NoteProvider>();

    var rest = raw.replaceAll(
        RegExp(
            r'\b(restaurar|recuperar|desfazer exclu[sç][ãa]o( de)?)\b|\b(tarefa|nota|compromisso|reuni[ãa]o|consulta)\b',
            caseSensitive: false),
        ' ');
    final query = _clean(rest);

    final t = _findTask(tasks.trashed, query);
    if (t != null) {
      _pending = _PendingAction(
          'restore_task', {'id': t.id}, '"${t.nome}" restaurada da lixeira');
      _say('Restaurar a tarefa "${t.nome}" da lixeira? Confirmo?');
      return;
    }
    final ap = _findAppointment(appts.trashed, query);
    if (ap != null) {
      _pending = _PendingAction('restore_appointment', {'id': ap.id},
          '"${ap.titulo}" restaurado da lixeira');
      _say('Restaurar o compromisso "${ap.titulo}" da lixeira? Confirmo?');
      return;
    }
    final n = _findNote(notesP.trashed, query);
    if (n != null) {
      _pending = _PendingAction(
          'restore_note', {'id': n.id}, '"${n.titulo}" restaurada da lixeira');
      _say('Restaurar a nota "${n.titulo}" da lixeira? Confirmo?');
      return;
    }
    _say('Não encontrei "${query.isNotEmpty ? query : 'o item'}" na lixeira.');
  }

  /// Interpretador por regras (offline). Consultas/conversa respondem direto;
  /// mutações são PROPOSTAS e só executam após confirmação. Se nada casar,
  /// captura como tarefa (nunca perde) — também com confirmação.
  void _processCommandOffline(String text) {
    final lower = text.toLowerCase();
    final tasks = context.read<TaskProvider>();
    final appointments = context.read<AppointmentProvider>();

    // ═══ Conversa / informações (resposta direta, sem confirmação) ═══

    if (RegExp(r'^(oi|ol[áa]|bom dia|boa tarde|boa noite|e a[íi]|opa)\b')
        .hasMatch(lower)) {
      _say('Olá! Posso criar tarefas, agendar compromissos ou anotar notas. '
          'É só falar.');
      return;
    }
    if (RegExp(r'\b(obrigad|valeu|agrade)').hasMatch(lower)) {
      _say('De nada! 😊');
      return;
    }
    if (RegExp(r'\b(ajuda|me ajuda|quais comandos)\b|o que voc[êe] (faz|consegue|pode)')
        .hasMatch(lower)) {
      _say('Posso criar tarefas, agendar compromissos, anotar notas, concluir, '
          'reagendar, excluir e listar o que você tem. Fale naturalmente que '
          'eu confirmo antes de salvar.');
      return;
    }
    if (RegExp(r'que horas|horas s[ãa]o|hora certa').hasMatch(lower)) {
      _say('Agora são ${DateFormat('HH:mm').format(DateTime.now())}.');
      return;
    }
    if (RegExp(r'que dia [ée] hoje|data de hoje|dia de hoje').hasMatch(lower)) {
      _say('Hoje é ${DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(DateTime.now())}.');
      return;
    }
    if (RegExp(r'pr[óo]xim[oa] (compromisso|reuni|consulta)').hasMatch(lower)) {
      final up = appointments.upcoming;
      _say(up.isEmpty
          ? 'Você não tem compromissos futuros.'
          : 'Seu próximo compromisso é ${up.first.titulo} em '
              '${up.first.dateFormatted} às ${up.first.horario}.');
      return;
    }
    if (RegExp(r'pr[óo]xima tarefa').hasMatch(lower)) {
      final p = tasks.pending;
      _say(p.isEmpty
          ? 'Nenhuma tarefa pendente.'
          : 'Sua próxima tarefa é ${p.first.nome}, ${p.first.horario} ${p.first.data}.');
      return;
    }
    if (RegExp(r'quantas tarefas|quantos compromissos').hasMatch(lower)) {
      _say('Você tem ${tasks.pending.length} tarefa(s) pendente(s) e '
          '${appointments.upcoming.length} compromisso(s).');
      return;
    }
    if (RegExp(r'atrasad').hasMatch(lower)) {
      final late = tasks.pending.where((t) => t.isOverdue).toList();
      _say(late.isEmpty
          ? 'Você não tem tarefas atrasadas. 👍'
          : '${late.length} atrasada(s): ${late.take(5).map((t) => t.nome).join(', ')}.');
      return;
    }
    if (RegExp(r'(listar|quais|minhas)\b.*conclu[ií]da').hasMatch(lower)) {
      final done = tasks.completed;
      _say(done.isEmpty
          ? 'Você ainda não concluiu nenhuma tarefa.'
          : '${done.length} concluída(s):\n${done.take(5).map((t) => '• ${t.nome}').join('\n')}');
      return;
    }
    if (RegExp(r'(listar|quais|minhas|tenho)\b.*tarefa|o que (eu )?tenho (pra|para) fazer|tarefas de hoje|o que tenho hoje')
        .hasMatch(lower)) {
      final p = tasks.pending;
      _say(p.isEmpty
          ? 'Nenhuma tarefa pendente. Tudo em dia! 🎉'
          : 'Você tem ${p.length} tarefa(s):\n${p.take(5).map((t) => '• ${t.nome} (${t.horario} ${t.data})').join('\n')}');
      return;
    }
    if (RegExp(r'(listar|quais|meus)\b.*compromisso').hasMatch(lower) ||
        lower.contains('minha agenda')) {
      final up = appointments.upcoming.take(5).toList();
      _say(up.isEmpty
          ? 'Você não tem compromissos futuros.'
          : 'Próximos compromissos:\n${up.map((a) => '• ${a.titulo} — ${a.dateFormatted} às ${a.horario}').join('\n')}');
      return;
    }

    // ═══ Mutações: propõe e pede confirmação ═══

    // Restaurar da lixeira
    if (RegExp(r'\b(restaurar|recuperar|desfazer exclu)\b').hasMatch(lower)) {
      _proposeRestore(text);
      return;
    }

    // Editar tarefa (inclui "jogar X para amanhã" informal)
    if (RegExp(r'\b(editar|atualizar|modific[ar])\b.*\btarefa\b|\btarefa\b.*\b(editar|atualizar)\b')
            .hasMatch(lower) ||
        RegExp(r'\bjogar\b.*(para|pra)\b').hasMatch(lower) ||
        (RegExp(r'\b(alterar|mudar|trocar)\b').hasMatch(lower) &&
            RegExp(r'\bprioridade\b').hasMatch(lower) &&
            !RegExp(r'\b(compromisso|reuni[ãa]o|consulta|evento)\b')
                .hasMatch(lower))) {
      _proposeEditTask(text);
      return;
    }

    // Editar compromisso (inclui alterar prioridade de compromisso)
    if (RegExp(
            r'\b(editar|alterar|mudar|atualizar)\b.*(compromisso|reuni[ãa]o|consulta|evento)|'
            r'\b(compromisso|reuni[ãa]o|consulta|evento)\b.*\b(editar|alterar|mudar)\b|'
            r'\balterar prioridade\b.*(compromisso|reuni[ãa]o|consulta|evento|reuni)')
        .hasMatch(lower)) {
      _proposeEditAppointment(text);
      return;
    }

    // Editar nota (acrescentar conteúdo)
    if (RegExp(
            r'\b(editar|alterar|acrescentar|adicionar|incluir)\b.*\bnota\b|'
            r'\bnota\b.*(editar|alterar|acrescentar|adicionar)')
        .hasMatch(lower)) {
      _proposeEditNote(text);
      return;
    }

    // Reagendar
    if (RegExp(r'reagendar|adiar|transferir|empurr|\bmuda\b|\bpassa\b')
        .hasMatch(lower)) {
      var rest = text.replaceAll(
          RegExp(r'reagendar|adiar|transferir|empurr\w*|\bmuda\b|\bpassa\b|\bpara\b|\bpra\b|a tarefa|o lembrete',
              caseSensitive: false),
          ' ');
      final d = _extractDate(rest);
      final tm = _extractTime(d.rest);
      final nome = _clean(tm.rest);
      final task = _findTask(tasks.pending, nome);
      if (task == null) {
        _say('Não encontrei a tarefa "$nome".');
        return;
      }
      _pending = _PendingAction('reschedule',
          {'id': task.id, 'data': d.data, 'horario': tm.horario},
          '"${task.nome}" reagendada para ${d.data} às ${tm.horario}');
      _say('Reagendar "${task.nome}" para ${d.data} às ${tm.horario}? Confirmo?');
      return;
    }

    // Concluir
    if (RegExp(r'marcar como conclu[ií]da|concluir|finalizar|terminei|j[áa] fiz|completar|feita')
        .hasMatch(lower)) {
      final nome = _clean(text.replaceAll(
          RegExp(r'marcar como conclu[ií]da|concluir|finalizar|terminei|j[áa] fiz|completar|feita|a tarefa|de',
              caseSensitive: false),
          ' '));
      final task = _findTask(tasks.pending, nome);
      if (task == null) {
        _say('Não encontrei a tarefa "$nome".');
        return;
      }
      _pending = _PendingAction(
          'complete', {'id': task.id}, '"${task.nome}" concluída');
      _say('Concluir a tarefa "${task.nome}"? Confirmo?');
      return;
    }

    // Excluir tarefa
    if (RegExp(r'(excluir|apagar|remover|deletar|tira(r)? da lista)\b.*tarefa|(excluir|apagar|remover|deletar) (a )?tarefa')
        .hasMatch(lower)) {
      final nome = _clean(text.replaceAll(
          RegExp(r'(excluir|apagar|remover|deletar|tirar? da lista)( a)?( tarefa)?',
              caseSensitive: false),
          ' '));
      final task = _findTask(tasks.tasks, nome);
      if (task == null) {
        _say('Não encontrei a tarefa "$nome".');
        return;
      }
      _pending =
          _PendingAction('delete', {'id': task.id}, '"${task.nome}" excluída');
      _say('Excluir a tarefa "${task.nome}"? Confirmo?');
      return;
    }

    // Cancelar compromisso
    if (RegExp(r'(cancelar|desmarcar|excluir|apagar|remover)\b.*(compromisso|reuni[ãa]o|consulta|evento)')
        .hasMatch(lower)) {
      final nome = _clean(text.replaceAll(
          RegExp(r'(cancelar|desmarcar|excluir|apagar|remover)( o| a)?( compromisso| reuni[ãa]o| consulta| evento)?( de| da| do)?',
              caseSensitive: false),
          ' '));
      final ap = _findAppointment(appointments.appointments, nome);
      if (ap == null) {
        _say('Não encontrei o compromisso "$nome".');
        return;
      }
      _pending = _PendingAction('cancel_appointment', {'id': ap.id},
          'Compromisso "${ap.titulo}" cancelado');
      _say('Cancelar o compromisso "${ap.titulo}"? Confirmo?');
      return;
    }

    // Criar compromisso
    if (RegExp(r'\bagendar\b|novo compromisso|criar compromisso|\bmarcar\b.*(reuni[ãa]o|consulta|compromisso|evento)|tenho (uma )?(reuni[ãa]o|consulta)')
        .hasMatch(lower)) {
      _proposeAppointmentFromRaw(text);
      return;
    }

    // Criar nota
    if (RegExp(r'\b(anotar|anota|nova nota|criar nota|tomar nota|salvar nota)\b')
        .hasMatch(lower)) {
      _proposeNote(text);
      return;
    }

    // Criar tarefa (explícito)
    if (RegExp(r'criar tarefa|nova tarefa|adicionar tarefa|lembrar de|me lembra|lembrete|preciso|tenho que')
        .hasMatch(lower)) {
      _proposeTask(text);
      return;
    }

    // ═══ Captura: nada reconhecido → salva como tarefa (nunca perde) ═══
    _proposeTask(text, capture: true);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Container(
      decoration: BoxDecoration(
        color: context.colors.backgroundSecondary,
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
                      color: context.colors.border,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l.voiceTitle,
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l.voiceSubtitle,
                style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 32),

              // Microfone principal — inicia (ou reinicia) a conversa
              GestureDetector(
                onTap: _startConversation,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.gold, AppColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.5),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.mic_rounded,
                      size: 44, color: Colors.white),
                ),
              ),

              // Estado da conversa + controle (toque para pausar/retomar)
              if (_conversationActive) ...[
                const SizedBox(height: 18),
                Builder(builder: (_) {
                  Color color;
                  IconData icon;
                  String label;
                  if (_paused) {
                    color = context.colors.textSecondary;
                    icon = Icons.mic_off_rounded;
                    label = l.voicePaused;
                  } else {
                    switch (_phase) {
                      case _VoicePhase.processing:
                        color = const Color(0xFF1E88E5);
                        icon = Icons.sync_rounded;
                        label = l.voiceProcessing;
                      case _VoicePhase.responding:
                        color = const Color(0xFF8E24AA);
                        icon = Icons.graphic_eq_rounded;
                        label = l.voiceResponding;
                      case _VoicePhase.listening:
                      case _VoicePhase.idle:
                        color = AppColors.success;
                        icon = Icons.mic_rounded;
                        label = l.voiceListening;
                    }
                  }
                  final pulsing =
                      !_paused && _phase == _VoicePhase.listening;
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: _togglePause,
                        child: AnimatedBuilder(
                          animation: _pulseCtrl,
                          builder: (_, __) => Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color.withValues(
                                  alpha: pulsing
                                      ? 0.12 + _pulseCtrl.value * 0.14
                                      : 0.12),
                              border: Border.all(color: color, width: 2),
                            ),
                            child: Icon(icon, color: color, size: 26),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(label,
                          style: TextStyle(color: color, fontSize: 12)),
                    ],
                  );
                }),
              ],

              const SizedBox(height: 16),

              // (Transcrição de voz não é mais exibida — interface limpa)
              if (_feedback.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _feedbackColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _feedbackColor.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    _feedback,
                    style: TextStyle(color: _feedbackColor, fontSize: 14),
                  ),
                ),
                if (_source.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      _source == 'ai' ? l.voiceAnsweredByAI : l.voiceBasicMode,
                      style: TextStyle(
                          color: context.colors.textSecondary, fontSize: 10),
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
                      style: TextStyle(
                          color: context.colors.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: l.voiceTypeHint,
                        prefixIcon: Icon(Icons.keyboard_outlined,
                            color: context.colors.textSecondary, size: 20),
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
                    tooltip: l.voiceExecute,
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
    final l = context.l10n;
    final groups = <String, List<String>>{
      l.navTasks: [
        'Criar tarefa pagar conta amanhã às 9h',
        'Criar tarefa urgente ligar para Carlos sexta às 15h',
        'Concluir tarefa pagar conta',
        'Reagendar pagar conta para sexta às 10h',
        'Editar tarefa pagar conta — mudar para amanhã às 10h',
        'Alterar prioridade da tarefa reunião para alta',
        'Jogar tarefa pagar conta para amanhã',
        'Excluir tarefa pagar conta',
        'Listar minhas tarefas',
        'Listar tarefas concluídas',
      ],
      l.navAgenda: [
        'Agendar reunião amanhã às 10h no escritório',
        'Marcar consulta dia 20 às 14h30',
        'Editar compromisso reunião — mudar para sexta às 14h',
        'Alterar prioridade da reunião para alta',
        'Cancelar compromisso reunião',
        'Listar meus compromissos',
      ],
      l.navNotes: [
        'Anotar comprar material de escritório',
        'Editar nota compras — adicionar leite e ovos',
        'Acrescentar leite e ovos na nota compras',
      ],
      l.navTrash: [
        'Restaurar tarefa pagar conta',
        'Recuperar nota compras',
        'Restaurar compromisso reunião',
      ],
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.voiceAvailableCommands,
            style: TextStyle(
                color: context.colors.textSecondary,
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
                          style: TextStyle(
                              color: context.colors.textSecondary, fontSize: 12)),
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