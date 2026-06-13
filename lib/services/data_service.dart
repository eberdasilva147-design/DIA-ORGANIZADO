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
  Future<void> deleteTask(String id);

  // Compromissos
  Stream<List<AppointmentModel>> streamAppointments();
  Future<void> addAppointment(AppointmentModel appointment);
  Future<void> updateAppointment(AppointmentModel appointment);
  Future<void> deleteAppointment(String id);

  // Notas
  Stream<List<NoteModel>> streamNotes();
  Future<void> addNote(NoteModel note);
  Future<void> updateNote(NoteModel note);
  Future<void> deleteNote(String id);

  // Versículos favoritos
  Stream<List<VerseModel>> streamFavoriteVerses();
  Future<void> addFavoriteVerse(VerseModel verse);

  // Configurações
  Future<void> saveSettings(Map<String, dynamic> settings);
}
