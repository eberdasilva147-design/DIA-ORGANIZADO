import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/task_model.dart';
import '../models/appointment_model.dart';
import '../models/note_model.dart';
import '../models/verse_model.dart';
import 'data_service.dart';

/// Implementação do [DataService] usando Supabase (Postgres + Realtime).
/// O schema das tabelas está em supabase/schema.sql na raiz do projeto.
class SupabaseDataService implements DataService {
  SupabaseClient get _db => Supabase.instance.client;
  String? get _uid => _db.auth.currentUser?.id;

  Map<String, dynamic> _withUser(Map<String, dynamic> map) =>
      map..['user_id'] = _uid;

  // ─── Tarefas ────────────────────────────────────────────────────────────────

  @override
  Stream<List<TaskModel>> streamTasks() {
    final uid = _uid;
    if (uid == null) return Stream.value(const []);
    return _db
        .from('tarefas')
        .stream(primaryKey: ['id'])
        .eq('user_id', uid)
        .map((rows) => rows
            .map((r) => TaskModel.fromMap(r['id'] as String, r))
            .toList());
  }

  @override
  Future<void> addTask(TaskModel task) => _db
      .from('tarefas')
      .insert(_withUser(task.toMap()..['id'] = task.id));

  @override
  Future<void> updateTask(TaskModel task) =>
      _db.from('tarefas').update(task.toMap()).eq('id', task.id);

  @override
  Future<void> deleteTask(String id) =>
      _db.from('tarefas').delete().eq('id', id);

  // ─── Compromissos ───────────────────────────────────────────────────────────

  @override
  Stream<List<AppointmentModel>> streamAppointments() {
    final uid = _uid;
    if (uid == null) return Stream.value(const []);
    return _db
        .from('compromissos')
        .stream(primaryKey: ['id'])
        .eq('user_id', uid)
        .map((rows) => rows
            .map((r) => AppointmentModel.fromMap(r['id'] as String, r))
            .toList());
  }

  @override
  Future<void> addAppointment(AppointmentModel appointment) => _db
      .from('compromissos')
      .insert(_withUser(appointment.toMap()..['id'] = appointment.id));

  @override
  Future<void> updateAppointment(AppointmentModel appointment) => _db
      .from('compromissos')
      .update(appointment.toMap())
      .eq('id', appointment.id);

  @override
  Future<void> deleteAppointment(String id) =>
      _db.from('compromissos').delete().eq('id', id);

  // ─── Notas ──────────────────────────────────────────────────────────────────

  @override
  Stream<List<NoteModel>> streamNotes() {
    final uid = _uid;
    if (uid == null) return Stream.value(const []);
    return _db
        .from('notas')
        .stream(primaryKey: ['id'])
        .eq('user_id', uid)
        .order('dataCriacao', ascending: false)
        .map((rows) => rows
            .map((r) => NoteModel.fromMap(r['id'] as String, r))
            .toList());
  }

  @override
  Future<void> addNote(NoteModel note) =>
      _db.from('notas').insert(_withUser(note.toMap()..['id'] = note.id));

  @override
  Future<void> updateNote(NoteModel note) =>
      _db.from('notas').update(note.toMap()).eq('id', note.id);

  @override
  Future<void> deleteNote(String id) =>
      _db.from('notas').delete().eq('id', id);

  // ─── Versículos Favoritos ───────────────────────────────────────────────────

  @override
  Stream<List<VerseModel>> streamFavoriteVerses() {
    final uid = _uid;
    if (uid == null) return Stream.value(const []);
    return _db
        .from('versiculos_favoritos')
        .stream(primaryKey: ['id'])
        .eq('user_id', uid)
        .map((rows) => rows.map(VerseModel.fromMap).toList());
  }

  @override
  Future<void> addFavoriteVerse(VerseModel verse) =>
      _db.from('versiculos_favoritos').insert(_withUser(verse.toMap()));

  // ─── Configurações ──────────────────────────────────────────────────────────

  @override
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    final uid = _uid;
    if (uid == null) return;
    await _db
        .from('configuracoes')
        .upsert(settings..['user_id'] = uid, onConflict: 'user_id');
  }
}
