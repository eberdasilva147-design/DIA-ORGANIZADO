import '../models/verse_model.dart';

class VerseService {
  static const List<Map<String, String>> _verses = [
    {'v': 'Tudo posso naquele que me fortalece.', 'r': 'Filipenses 4:13'},
    {'v': 'O Senhor é o meu pastor e nada me faltará.', 'r': 'Salmos 23:1'},
    {'v': 'Entrega o teu caminho ao Senhor, confia nele, e ele tudo fará.', 'r': 'Salmos 37:5'},
    {'v': 'Não te deixes vencer pelo mal, mas vence o mal com o bem.', 'r': 'Romanos 12:21'},
    {'v': 'Porque sou eu que conheço os planos que tenho para vocês, diz o Senhor.', 'r': 'Jeremias 29:11'},
    {'v': 'Sede fortes e corajosos. Não temais nem vos assusteis, porque o Senhor vosso Deus irá convosco.', 'r': 'Deuteronômio 31:6'},
    {'v': 'Bem-aventurados os que têm fome e sede de justiça, pois serão satisfeitos.', 'r': 'Mateus 5:6'},
    {'v': 'Mas os que esperam no Senhor renovam as suas forças.', 'r': 'Isaías 40:31'},
    {'v': 'Lança sobre o Senhor o teu peso e ele te susterá.', 'r': 'Salmos 55:22'},
    {'v': 'Confiai nele em todo o tempo, ó povo; derramai perante ele o vosso coração.', 'r': 'Salmos 62:8'},
    {'v': 'A fé é a certeza daquilo que esperamos e a prova das coisas que não vemos.', 'r': 'Hebreus 11:1'},
    {'v': 'O amor é paciente, o amor é bondoso. Não inveja, não se vangloria, não se orgulha.', 'r': '1 Coríntios 13:4'},
    {'v': 'Não vos conformeis com este século, mas transformai-vos pela renovação do vosso entendimento.', 'r': 'Romanos 12:2'},
    {'v': 'Em tudo dai graças, porque esta é a vontade de Deus em Cristo Jesus para convosco.', 'r': '1 Tessalonicenses 5:18'},
    {'v': 'Vinde a mim, todos os que estais cansados e sobrecarregados, e eu vos aliviarei.', 'r': 'Mateus 11:28'},
    {'v': 'Pedi e dar-se-vos-á; buscai e encontrareis; batei e abrir-se-vos-á.', 'r': 'Mateus 7:7'},
    {'v': 'O início da sabedoria é o temor do Senhor; bom senso têm todos os que praticam os seus preceitos.', 'r': 'Salmos 111:10'},
    {'v': 'Honra o Senhor com os teus bens e com as primícias de toda a tua renda.', 'r': 'Provérbios 3:9'},
    {'v': 'Porque onde estiverem dois ou três reunidos em meu nome, ali estou no meio deles.', 'r': 'Mateus 18:20'},
    {'v': 'Sede vigilantes e firmes na fé; sede valentes e fortes.', 'r': '1 Coríntios 16:13'},
    {'v': 'Alegrai-vos sempre no Senhor; outra vez digo: alegrai-vos.', 'r': 'Filipenses 4:4'},
    {'v': 'O Senhor está perto de todos os que o invocam, de todos os que o invocam com sinceridade.', 'r': 'Salmos 145:18'},
    {'v': 'O temor do Senhor é o princípio da sabedoria.', 'r': 'Provérbios 9:10'},
    {'v': 'Guardai-vos, pois, dos falsos profetas que vêm até vós com roupas de ovelha.', 'r': 'Mateus 7:15'},
    {'v': 'Não há amor maior do que dar a vida pelos amigos.', 'r': 'João 15:13'},
    {'v': 'Humilhai-vos perante o Senhor, e ele vos exaltará.', 'r': 'Tiago 4:10'},
    {'v': 'Ele cura os de coração partido e lhes sara as feridas.', 'r': 'Salmos 147:3'},
    {'v': 'Ao que crê tudo é possível.', 'r': 'Marcos 9:23'},
    {'v': 'Deus é amor, e quem permanece no amor permanece em Deus, e Deus nele.', 'r': '1 João 4:16'},
    {'v': 'Não temas, porque eu sou contigo; não te assombres, porque eu sou teu Deus.', 'r': 'Isaías 41:10'},
  ];

  static VerseModel getDailyVerse() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    final index = dayOfYear % _verses.length;
    final v = _verses[index];
    return VerseModel(versiculo: v['v']!, referencia: v['r']!);
  }

  static List<VerseModel> get allVerses =>
      _verses.map((v) => VerseModel(versiculo: v['v']!, referencia: v['r']!)).toList();
}
