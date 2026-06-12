import 'package:flutter/material.dart';
import '../models/verse_model.dart';
import '../services/data_service.dart';
import '../services/verse_service.dart';

class VerseProvider extends ChangeNotifier {
  List<VerseModel> _favorites = [];
  final VerseModel dailyVerse = VerseService.getDailyVerse();

  List<VerseModel> get favorites => _favorites;

  void loadFavorites() {
    DataService.instance.streamFavoriteVerses().listen((list) {
      _favorites = list;
      notifyListeners();
    });
  }

  Future<void> addFavorite(VerseModel verse) async {
    await DataService.instance.addFavoriteVerse(verse);
  }

  bool isFavorite(VerseModel verse) =>
      _favorites.any((f) => f.referencia == verse.referencia);
}
