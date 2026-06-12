import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_tts/flutter_tts.dart';

/// Serviço de síntese de voz (Text-to-Speech) em português.
/// Na web usa as vozes do próprio navegador; no celular, as do sistema.
class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  Future<void> _init() async {
    if (_initialized) return;
    await _tts.setLanguage('pt-BR');
    // Na web a taxa 1.0 é a velocidade natural; no Android/iOS é 0.5
    await _tts.setSpeechRate(kIsWeb ? 1.0 : 0.5);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    // speak() só completa quando a fala termina — permite ao modo
    // conversa reabrir o microfone na hora certa
    await _tts.awaitSpeakCompletion(true);
    _initialized = true;
  }

  /// Fala o texto em voz alta (limpa emojis e formatação antes).
  /// O Future completa quando a fala TERMINA.
  Future<void> speak(String text) async {
    final clean = _cleanForSpeech(text);
    if (clean.isEmpty) return;
    try {
      await _init();
      await _tts.stop();
      await _tts.speak(clean);
    } catch (_) {
      // Sem voz disponível no dispositivo: segue só com o texto na tela
    }
  }

  /// Interrompe qualquer fala em andamento.
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }

  /// Remove emojis, símbolos e formatação que a voz não deve ler.
  String _cleanForSpeech(String text) {
    var t = text;
    // Emojis e pictogramas
    t = t.replaceAll(
        RegExp(r'[\u{1F000}-\u{1FAFF}\u{2600}-\u{27BF}\u{2190}-\u{21FF}\u{FE0F}]',
            unicode: true),
        ' ');
    // Marcadores e símbolos de formatação
    t = t.replaceAll(RegExp(r'[•·—"\*\#\(\)\[\]]'), ' ');
    // Quebras de linha viram pausas
    t = t.replaceAll('\n', '. ');
    t = t.replaceAll(RegExp(r'\s+'), ' ').trim();
    return t;
  }
}
