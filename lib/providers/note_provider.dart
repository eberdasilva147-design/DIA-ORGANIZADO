import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/note_model.dart';
import '../services/data_service.dart';

class NoteProvider extends ChangeNotifier {
  List<NoteModel> _notes = [];
  String _search = '';

  List<NoteModel> get notes => _search.isEmpty
      ? _notes
      : _notes
          .where((n) =>
              n.titulo.toLowerCase().contains(_search.toLowerCase()) ||
              n.corpo.toLowerCase().contains(_search.toLowerCase()))
          .toList();

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

  Future<void> deleteNote(String id) async {
    await DataService.instance.deleteNote(id);
  }
}
