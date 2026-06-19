import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/note_model.dart';
import '../services/data_service.dart';

class NoteProvider extends ChangeNotifier {
  List<NoteModel> _notes = [];
  String _search = '';

  List<NoteModel> get notes {
    final active = _notes.where((n) => !n.isInTrash).toList();
    if (_search.isEmpty) return active;
    return active
        .where((n) =>
            n.titulo.toLowerCase().contains(_search.toLowerCase()) ||
            n.corpo.toLowerCase().contains(_search.toLowerCase()))
        .toList();
  }

  List<NoteModel> get trashed =>
      _notes.where((n) => n.isInTrash).toList()
        ..sort((a, b) => b.deletedAt!.compareTo(a.deletedAt!));

  void setSearch(String q) {
    _search = q;
    notifyListeners();
  }

  void loadNotes() {
    DataService.instance.streamNotes().listen((list) {
      _notes = list;
      notifyListeners();
    });
  }

  Future<void> addNote({required String titulo, required String corpo}) async {
    final note = NoteModel(
      id: const Uuid().v4(),
      titulo: titulo,
      corpo: corpo,
      dataCriacao: DateTime.now(),
    );
    await DataService.instance.addNote(note);
  }

  Future<void> updateNote(NoteModel note) async {
    await DataService.instance.updateNote(note);
  }

  /// Move para a lixeira (soft delete).
  Future<void> softDeleteNote(String id) async {
    await DataService.instance.softDeleteNote(id);
  }

  /// Restaura da lixeira.
  Future<void> restoreNote(String id) async {
    await DataService.instance.restoreNote(id);
  }

  /// Exclui definitivamente (apenas itens já na lixeira).
  Future<void> deleteNote(String id) async {
    await DataService.instance.deleteNote(id);
  }
}
