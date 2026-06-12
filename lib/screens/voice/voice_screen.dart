import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../providers/task_provider.dart';
import '../../providers/note_provider.dart';
import '../../utils/app_colors.dart';

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key});

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen>
    with SingleTickerProviderStateMixin {
  final SpeechToText _speech = SpeechToText();
  bool _available = false;
  bool _listening = false;
  String _transcript = '';
  String _feedback = '';
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
      onError: (e) => setState(() {
        _listening = false;
        // 'no-speech' não é um erro real: o usuário só ficou em silêncio
        _feedback = e.errorMsg == 'no-speech' || e.errorMsg == 'error_no_match'
            ? 'Não ouvi nada. Toque no microfone e tente de novo.'
            : '⚠️ Erro no microfone: ${e.errorMsg}';
      }),
    );
    setState(() {});
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (!_available) {
      setState(() => _feedback = 'Microfone não disponível. Verifique as permissões.');
      return;
    }
    if (_listening) {
      await _speech.stop();
      setState(() => _listening = false);
      // Se o usuário parou manualmente, processa o que já foi dito
      if (_transcript.isNotEmpty) _processCommand(_transcript);
    } else {
      setState(() {
        _listening = true;
        _transcript = '';
        _feedback = 'Ouvindo...';
      });
      await _speech.listen(
        onResult: (r) {
          setState(() => _transcript = r.recognizedWords);
          if (r.finalResult) {
            _processCommand(r.recognizedWords);
            setState(() => _listening = false);
          }
        },
        // Navegador usa hífen (pt-BR); Android/iOS usam underscore (pt_BR)
        localeId: kIsWeb ? 'pt-BR' : 'pt_BR',
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
      );
    }
  }

  void _processCommand(String text) {
    if (text.isEmpty) {
      setState(() => _feedback = 'Nenhum comando detectado. Tente novamente.');
      return;
    }

    final lower = text.toLowerCase();
    final tasks = context.read<TaskProvider>();
    final notes = context.read<NoteProvider>();

    // Reagendar tarefa (antes de "criar tarefa", pois pode conter "lembrete")
    if (lower.contains('reagendar')) {
      String rest = text
          .replaceAll(RegExp(r'reagendar( a tarefa| o lembrete| a reunião)?',
              caseSensitive: false), '')
          .trim();
      String data = DateFormat('dd/MM/yyyy').format(DateTime.now());
      String horario = '08:00';

      if (rest.toLowerCase().contains('amanhã')) {
        data = DateFormat('dd/MM/yyyy')
            .format(DateTime.now().add(const Duration(days: 1)));
        rest = rest.replaceAll(RegExp(r'amanhã', caseSensitive: false), '').trim();
      }

      final timeReg =
          RegExp(r'às (\d{1,2})(?::(\d{2}))?h?', caseSensitive: false);
      final timeMatch = timeReg.firstMatch(rest.toLowerCase());
      if (timeMatch != null) {
        final h = timeMatch.group(1)!.padLeft(2, '0');
        final m = (timeMatch.group(2) ?? '00').padLeft(2, '0');
        horario = '$h:$m';
        rest = rest.replaceAll(timeReg, '').trim();
      }

      rest = rest
          .replaceAll(RegExp(r'\bpara\b', caseSensitive: false), '')
          .trim();

      final restLower = rest.toLowerCase();
      final match = tasks.pending
          .where((t) =>
              t.nome.toLowerCase().contains(restLower) ||
              restLower.contains(t.nome.toLowerCase()))
          .toList();
      if (rest.isNotEmpty && match.isNotEmpty) {
        tasks.rescheduleTask(match.first.id, data, horario);
        setState(() => _feedback =
            '✅ Tarefa "${match.first.nome}" reagendada para $data às $horario');
      } else {
        setState(() => _feedback = '⚠️ Tarefa não encontrada: "$rest"');
      }
      return;
    }

    // Criar tarefa
    if (lower.contains('criar tarefa') || lower.contains('adicionar tarefa') ||
        lower.contains('lembrar de') || lower.contains('lembrete')) {
      String nome = text;
      String data = DateFormat('dd/MM/yyyy').format(DateTime.now());
      String horario = '08:00';

      // Detectar "amanhã"
      if (lower.contains('amanhã')) {
        data = DateFormat('dd/MM/yyyy')
            .format(DateTime.now().add(const Duration(days: 1)));
        nome = nome.replaceAll(RegExp(r'amanhã', caseSensitive: false), '').trim();
      }

      // Detectar hora "às Xh" ou "às X:XX"
      final timeReg = RegExp(r'às (\d{1,2})(?::(\d{2}))?h?', caseSensitive: false);
      final timeMatch = timeReg.firstMatch(lower);
      if (timeMatch != null) {
        final h = timeMatch.group(1)!.padLeft(2, '0');
        final m = (timeMatch.group(2) ?? '00').padLeft(2, '0');
        horario = '$h:$m';
        nome = nome.replaceAll(timeReg, '').trim();
      }

      // Remover prefixo de comando
      nome = nome
          .replaceAll(RegExp(r'criar tarefa', caseSensitive: false), '')
          .replaceAll(RegExp(r'adicionar tarefa', caseSensitive: false), '')
          .replaceAll(RegExp(r'lembrar de', caseSensitive: false), '')
          .replaceAll(RegExp(r'lembrete', caseSensitive: false), '')
          .trim();

      if (nome.isEmpty) nome = text;

      tasks.addTask(
        nome: nome,
        data: data,
        horario: horario,
        prioridade: 'm',
        lembrete: true,
      );
      setState(() => _feedback = '✅ Tarefa criada: "$nome" para $data às $horario');
      return;
    }

    // Adicionar nota
    if (lower.contains('adicionar nota') || lower.contains('nova nota') ||
        lower.contains('anotar')) {
      String body = text
          .replaceAll(RegExp(r'adicionar nota', caseSensitive: false), '')
          .replaceAll(RegExp(r'nova nota', caseSensitive: false), '')
          .replaceAll(RegExp(r'anotar', caseSensitive: false), '')
          .trim();
      if (body.isEmpty) body = text;
      final titulo = body.length > 40 ? '${body.substring(0, 40)}...' : body;
      notes.addNote(titulo: titulo, corpo: body);
      setState(() => _feedback = '✅ Nota criada: "$titulo"');
      return;
    }

    // Marcar como concluída
    if (lower.contains('marcar como concluída') ||
        lower.contains('marcar como concluida') ||
        lower.contains('concluir tarefa')) {
      String taskName = text
          .replaceAll(RegExp(r'marcar como conclu[ií]da( a tarefa)?', caseSensitive: false), '')
          .replaceAll(RegExp(r'concluir tarefa', caseSensitive: false), '')
          .trim();
      final allTasks = tasks.pending;
      final match = allTasks
          .where((t) => t.nome.toLowerCase().contains(taskName.toLowerCase()))
          .toList();
      if (match.isNotEmpty) {
        tasks.completeTask(match.first.id);
        setState(() => _feedback = '✅ Tarefa "${match.first.nome}" concluída!');
      } else {
        setState(() => _feedback = '⚠️ Tarefa não encontrada: "$taskName"');
      }
      return;
    }

    setState(() => _feedback = '⚠️ Comando não reconhecido. Tente:\n"Criar tarefa [nome] amanhã às 9h"\n"Adicionar nota [texto]"\n"Marcar como concluída [tarefa]"\n"Reagendar [tarefa] para amanhã às 10h"');
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
        child: Padding(
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
                            : [AppColors.primary, AppColors.accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_listening ? AppColors.error : AppColors.primary)
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

              const SizedBox(height: 24),

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
              ],

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
    final cmds = [
      'Criar tarefa [nome] amanhã às 9h',
      'Lembrar de [nome] às 15h',
      'Adicionar nota [texto]',
      'Marcar como concluída [tarefa]',
      'Reagendar [tarefa] para amanhã às 10h',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Comandos disponíveis:',
            style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        ...cmds.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.arrow_right,
                      size: 16, color: AppColors.accent),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text('"$c"',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
