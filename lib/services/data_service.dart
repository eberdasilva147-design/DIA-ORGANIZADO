import '../models/task_model.dart';
import '../models/appointment_model.dart';
import '../models/note_model.dart';
import '../models/verse_model.dart';

/// Camada de dados do app. Os providers só conhecem esta interface,
/// então trocar o backend (local → Firebase → Supabase) não exige
/// mudanças nas telas: basta criar outra implementação e registrá-la
/// em [DataService.instance] no main.dart.
abstract class DataService {
  static late DataService instance;

  // Tarefas
  Stream<List<TaskModel>> streamTasks();
  Future<void> addTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> softDeleteTask(String id);
  Future<void> restoreTask(String id);
  Future<void> deleteTask(String id); // exclusão definitiva

  // Compromissos
  Stream<List<AppointmentModel>> streamAppointments();
  Future<void> addAppointment(AppointmentModel appointment);
  Future<void> updateAppointment(AppointmentModel appointment);
  Future<void> softDeleteAppointment(String id);
  Future<void> restoreAppointment(String id);
  Future<void> deleteAppointment(String id); // exclusão definitiva

  // Notas
  Stream<List<NoteModel>> streamNotes();
  Future<void> addNote(NoteModel note);
  Future<void> updateNote(NoteModel note);
  Future<void> softDeleteNote(String id);
  Future<void> restoreNote(String id);
  Future<void> deleteNote(String id); // exclusão definitiva

  // Versículos favoritos
  Stream<List<VerseModel>> streamFavoriteVerses();
  Future<void> addFavoriteVerse(VerseModel verse);

  // Configurações
  Future<void> saveSettings(Map<String, dynamic> settings);
}
