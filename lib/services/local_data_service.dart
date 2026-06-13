import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task_model.dart';
import '../models/appointment_model.dart';
import '../models/note_model.dart';
import '../models/verse_model.dart';
import 'data_service.dart';

/// Implementação local do [DataService] usando shared_preferences.
/// No navegador os dados ficam no localStorage; no celular, em arquivo.
/// Não precisa de internet, conta ou banco de dados.
class LocalDataService implements DataService {
  late SharedPreferences _prefs;

  List<TaskModel> _tasks = [];
  List<AppointmentModel> _appointments = [];
  List<NoteModel> _notes = [];
  List<VerseModel> _verses = [];

  final _taskCtrl = StreamController<List<TaskModel>>.broadcast();
  final _appointmentCtrl =
      StreamController<List<AppointmentModel>>.broadcast();
  final _noteCtrl = StreamController<List<NoteModel>>.broadcast();
  final _verseCtrl = StreamController<List<VerseModel>>.broadcast();

  static const _kTasks = 'local_tarefas';
  static const _kAppointments = 'local_compromissos';
  static const _kNotes = 'local_notas';
  static const _kVerses = 'local_versiculos';
  static const _kSeeded = 'local_seeded';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    _tasks = _loadList(_kTasks)
        .map((m) => TaskModel.fromMap(m['id'] as String, m))
        .toList();
    _appointments = _loadList(_kAppointments)
        .map((m) => AppointmentModel.fromMap(m['id'] as String, m))
        .toList();
    _notes = _loadList(_kNotes)
        .map((m) => NoteModel.fromMap(m['id'] as String, m))
        .toList();
    _verses = _loadList(_kVerses).map(VerseModel.fromMap).toList();

    if (!(_prefs.getBool(_kSeeded) ?? false)) {
      await _seedDemoData();
      await _prefs.setBool(_kSeeded, true);
    }
  }

  List<Map<String, dynamic>> _loadList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> _saveTasks() async {
    await _prefs.setString(
        _kTasks,
        jsonEncode(
            _tasks.map((t) => t.toMap()..['id'] = t.id).toList()));
    _taskCtrl.add(List.unmodifiable(_tasks));
  }

  Future<void> _saveAppointments() async {
    await _prefs.setString(
        _kAppointments,
        jsonEncode(
            _appointments.map((a) => a.toMap()..['id'] = a.id).toList()));
    _appointmentCtrl.add(List.unmodifiable(_appointments));
  }

  Future<void> _saveNotes() async {
    await _prefs.setString(
        _kNotes,
        jsonEncode(
            _notes.map((n) => n.toMap()..['id'] = n.id).toList()));
    _noteCtrl.add(List.unmodifiable(_notes));
  }

  Future<void> _saveVerses() async {
    await _prefs.setString(
        _kVerses, jsonEncode(_verses.map((v) => v.toMap()).toList()));
    _verseCtrl.add(List.unmodifiable(_verses));
  }

  // ─── Tarefas ────────────────────────────────────────────────────────────────

  @override
  Stream<List<TaskModel>> streamTasks() async* {
    yield List.unmodifiable(_tasks);
    yield* _taskCtrl.stream;
  }

  @override
  Future<void> addTask(TaskModel task) async {
    _tasks.add(task);
    await _saveTasks();
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    final i = _tasks.indexWhere((t) => t.id == task.id);
    if (i >= 0) _tasks[i] = task;
    await _saveTasks();
  }

  @override
  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    await _saveTasks();
  }

  // ─── Compromissos ───────────────────────────────────────────────────────────

  @override
  Stream<List<AppointmentModel>> streamAppointments() async* {
    yield List.unmodifiable(_appointments);
    yield* _appointmentCtrl.stream;
  }

  @override
  Future<void> addAppointment(AppointmentModel appointment) async {
    _appointments.add(appointment);
    await _saveAppointments();
  }

  @override
  Future<void> updateAppointment(AppointmentModel appointment) async {
    final i = _appointments.indexWhere((a) => a.id == appointment.id);
    if (i >= 0) _appointments[i] = appointment;
    await _saveAppointments();
  }

  @override
  Future<void> deleteAppointment(String id) async {
    _appointments.removeWhere((a) => a.id == id);
    await _saveAppointments();
  }

  // ─── Notas ──────────────────────────────────────────────────────────────────

  @override
  Stream<List<NoteModel>> streamNotes() async* {
    yield _sortedNotes();
    yield* _noteCtrl.stream.map((_) => _sortedNotes());
  }

  List<NoteModel> _sortedNotes() {
    final list = List<NoteModel>.from(_notes)
      ..sort((a, b) => b.dataCriacao.compareTo(a.dataCriacao));
    return List.unmodifiable(list);
  }

  @override
  Future<void> addNote(NoteModel note) async {
    _notes.add(note);
    await _saveNotes();
  }

  @override
  Future<void> updateNote(NoteModel note) async {
    final i = _notes.indexWhere((n) => n.id == note.id);
    if (i >= 0) _notes[i] = note;
    await _saveNotes();
  }

  @override
  Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n.id == id);
    await _saveNotes();
  }

  // ─── Versículos Favoritos ───────────────────────────────────────────────────

  @override
  Stream<List<VerseModel>> streamFavoriteVerses() async* {
    yield List.unmodifiable(_verses);
    yield* _verseCtrl.stream;
  }

  @override
  Future<void> addFavoriteVerse(VerseModel verse) async {
    _verses.add(verse);
    await _saveVerses();
  }

  // ─── Configurações ──────────────────────────────────────────────────────────

  @override
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    await _prefs.setString('local_configuracoes', jsonEncode(settings));
  }

  // ─── Dados de exemplo (apenas na primeira execução) ─────────────────────────

  Future<void> _seedDemoData() async {
    String fmt(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));

    _tasks = [
      TaskModel(
        id: 'demo-1',
        nome: 'Pagar conta de energia',
        data: fmt(today),
        horario: '09:00',
        prioridade: 'h',
        lembrete: true,
      ),
      TaskModel(
        id: 'demo-2',
        nome: 'Estudar Flutter',
        data: fmt(today),
        horario: '14:00',
        prioridade: 'm',
      ),
      TaskModel(
        id: 'demo-3',
        nome: 'Ligar para Carlos',
        data: fmt(tomorrow),
        horario: '15:00',
        prioridade: 'l',
        lembrete: true,
      ),
    ];
    await _saveTasks();

    _appointments = [
      AppointmentModel(
        id: 'demo-ap-1',
        titulo: 'Reunião de equipe',
        horario: '15:00',
        local: 'Escritório',
        dia: today.day,
        mes: today.month,
        ano: today.year,
      ),
      AppointmentModel(
        id: 'demo-ap-2',
        titulo: 'Consulta médica',
        horario: '10:30',
        local: 'Clínica Central',
        dia: tomorrow.day,
        mes: tomorrow.month,
        ano: tomorrow.year,
      ),
    ];
    await _saveAppointments();

    _notes = [
      NoteModel(
        id: 'demo-nota-1',
        titulo: 'Bem-vindo ao Dia Organizado! 👋',
        corpo: 'Este é o modo local: tudo que você criar fica salvo '
            'neste dispositivo, sem precisar de conta. '
            'Experimente criar tarefas, notas e compromissos — '
            'ou use o botão de voz no centro da barra inferior.',
        dataCriacao: DateTime.now(),
      ),
    ];
    await _saveNotes();
  }
}
