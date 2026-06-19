import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/note_model.dart';
import '../providers/task_provider.dart';
import '../providers/appointment_provider.dart';
import '../providers/note_provider.dart';

/// Limite diário gratuito do Gemini atingido.
class AiQuotaException implements Exception {}

/// IA indisponível (rede, erro do servidor, não configurada).
class AiUnavailableException implements Exception {}

/// Resultado de uma rodada de conversa com a IA.
class AiResult {
  final String reply;

  /// true = tarefa concluída/pergunta respondida (microfone pode desligar).
  /// false = aguardando confirmação ou esclarecimento (continua ouvindo).
  final bool conversationDone;

  AiResult(this.reply, this.conversationDone);
}

/// Conversa com a IA (Gemini via Edge Function "ai-voice") e executa
/// as ações que ela decidir nos providers do app.
class AiVoiceService {
  final TaskProvider tasks;
  final AppointmentProvider appointments;
  final NoteProvider notes;

  /// Histórico da conversa para diálogo fluido ("muda pra sexta").
  final List<Map<String, String>> _history = [];

  AiVoiceService({
    required this.tasks,
    required this.appointments,
    required this.notes,
  });

  void resetConversation() => _history.clear();

  /// Envia a fala do usuário para a IA, executa as ações retornadas
  /// (presentes só após confirmação) e devolve a resposta + estado.
  Future<AiResult> process(String message) async {
    final context = _buildContext();

    Map<String, dynamic> data;
    try {
      final res = await Supabase.instance.client.functions.invoke(
        'ai-voice',
        body: {
          'message': message,
          'history': _history,
          'context': context,
        },
      );
      data = Map<String, dynamic>.from(res.data as Map);
    } on FunctionException catch (e) {
      if (e.status == 429) throw AiQuotaException();
      throw AiUnavailableException();
    } catch (_) {
      throw AiUnavailableException();
    }

    final reply = (data['reply'] as String?)?.trim() ?? '';
    final actions = (data['actions'] as List?) ?? const [];
    final done = (data['conversation_done'] as bool?) ?? true;

    for (final raw in actions) {
      try {
        await _execute(Map<String, dynamic>.from(raw as Map));
      } catch (_) {
        // Ação individual falhou (ex.: id inexistente): segue as demais
      }
    }

    // Guarda a troca no histórico (limita a 10 pares)
    _history.add({'role': 'user', 'text': message});
    _history.add({'role': 'model', 'text': reply});
    while (_history.length > 20) {
      _history.removeAt(0);
    }

    return AiResult(reply.isEmpty ? 'Feito!' : reply, done);
  }

  // ─── Contexto enviado à IA ──────────────────────────────────────────

  String _buildContext() {
    final now = DateTime.now();
    final hoje = DateFormat('dd/MM/yyyy').format(now);
    final diaSemana = DateFormat('EEEE', 'pt_BR').format(now);

    final b = StringBuffer()
      ..writeln('Hoje é $diaSemana, $hoje.')
      ..writeln('TAREFAS PENDENTES:');
    if (tasks.pending.isEmpty) {
      b.writeln('(nenhuma)');
    } else {
      for (final t in tasks.pending.take(20)) {
        b.writeln(
            '- id=${t.id} | ${t.nome} | ${t.data} ${t.horario} | prioridade=${t.prioridade}');
      }
    }
    b.writeln('PRÓXIMOS COMPROMISSOS:');
    final ups = appointments.upcoming.take(10).toList();
    if (ups.isEmpty) {
      b.writeln('(nenhum)');
    } else {
      for (final a in ups) {
        b.writeln(
            '- id=${a.id} | ${a.titulo} | ${a.dateFormatted} ${a.horario}'
            '${a.local.isNotEmpty ? ' | local=${a.local}' : ''}');
      }
    }
    return b.toString();
  }

  // ─── Execução das ações decididas pela IA ───────────────────────────

  Future<void> _execute(Map<String, dynamic> a) async {
    switch (a['type'] as String?) {
      case 'create_task':
        final tNome = (a['nome'] as String?) ?? 'Nova tarefa';
        final tData = (a['data'] as String?) ??
            DateFormat('dd/MM/yyyy').format(DateTime.now());
        final tHora = (a['horario'] as String?) ?? '08:00';
        // Guarda anti-duplicidade: não recria tarefa idêntica
        final dupT = tasks.tasks.any((t) =>
            t.nome.toLowerCase() == tNome.toLowerCase() &&
            t.data == tData &&
            t.horario == tHora);
        if (dupT) break;
        await tasks.addTask(
          nome: tNome,
          data: tData,
          horario: tHora,
          prioridade: (a['prioridade'] as String?) ?? 'm',
          lembrete: (a['lembrete'] as bool?) ?? true,
        );
      case 'complete_task':
        final id = a['id'] as String?;
        if (id != null) await tasks.completeTask(id);
      case 'delete_task':
        final id = a['id'] as String?;
        if (id != null) await tasks.softDeleteTask(id);
      case 'reschedule_task':
        final id = a['id'] as String?;
        if (id != null) {
          await tasks.rescheduleTask(
            id,
            (a['data'] as String?) ??
                DateFormat('dd/MM/yyyy').format(DateTime.now()),
            (a['horario'] as String?) ?? '08:00',
          );
        }
      case 'create_appointment':
        final dataStr = (a['data'] as String?) ??
            DateFormat('dd/MM/yyyy').format(DateTime.now());
        final apTitulo = (a['titulo'] as String?) ?? 'Compromisso';
        final apHora = (a['horario'] as String?) ?? '08:00';
        // Guarda anti-duplicidade: não recria compromisso idêntico
        final dupA = appointments.appointments.any((ap) =>
            ap.titulo.toLowerCase() == apTitulo.toLowerCase() &&
            ap.dateFormatted == dataStr &&
            ap.horario == apHora);
        if (dupA) break;
        final parts = dataStr.split('/');
        await appointments.addAppointment(
          titulo: apTitulo,
          horario: apHora,
          local: (a['local'] as String?) ?? '',
          date: DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          ),
        );
      case 'delete_appointment':
        final id = a['id'] as String?;
        if (id != null) await appointments.softDeleteAppointment(id);
      case 'create_note':
        final corpo = (a['corpo'] as String?) ?? '';
        await notes.addNote(
          titulo: (a['titulo'] as String?) ??
              (corpo.length > 40 ? '${corpo.substring(0, 40)}...' : corpo),
          corpo: corpo,
        );
      case 'edit_task':
        final id = a['id'] as String?;
        if (id == null) break;
        final t = tasks.tasks.firstWhere((x) => x.id == id,
            orElse: () => throw Exception('task not found'));
        await tasks.updateTask(t.copyWith(
          nome: (a['nome'] as String?) ?? t.nome,
          data: (a['data'] as String?) ?? t.data,
          horario: (a['horario'] as String?) ?? t.horario,
          prioridade: (a['prioridade'] as String?) ?? t.prioridade,
        ));
      case 'edit_appointment':
        final id = a['id'] as String?;
        if (id == null) break;
        final ap = appointments.appointments.firstWhere((x) => x.id == id,
            orElse: () => throw Exception('appointment not found'));
        DateTime? newDate;
        final dataStr = a['data'] as String?;
        if (dataStr != null) {
          final parts = dataStr.split('/');
          if (parts.length == 3) {
            newDate = DateTime(
                int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
          }
        }
        await appointments.updateAppointment(ap.copyWith(
          titulo: (a['titulo'] as String?) ?? ap.titulo,
          horario: (a['horario'] as String?) ?? ap.horario,
          local: (a['local'] as String?) ?? ap.local,
          prioridade: (a['prioridade'] as String?) ?? ap.prioridade,
          dia: newDate?.day ?? ap.dia,
          mes: newDate?.month ?? ap.mes,
          ano: newDate?.year ?? ap.ano,
        ));
      case 'edit_note':
        final id = a['id'] as String?;
        if (id == null) break;
        final n = notes.notes.firstWhere((x) => x.id == id,
            orElse: () => throw Exception('note not found'));
        await notes.updateNote(NoteModel(
          id: n.id,
          titulo: (a['titulo'] as String?) ?? n.titulo,
          corpo: (a['corpo'] as String?) ?? n.corpo,
          dataCriacao: n.dataCriacao,
        ));
      case 'restore_task':
        final id = a['id'] as String?;
        if (id != null) await tasks.restoreTask(id);
      default:
        break; // 'none' ou tipo desconhecido
    }
  }
}
