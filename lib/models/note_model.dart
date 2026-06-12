class NoteModel {
  final String id;
  final String titulo;
  final String corpo;
  final DateTime dataCriacao;

  NoteModel({
    required this.id,
    required this.titulo,
    required this.corpo,
    required this.dataCriacao,
  });

  Map<String, dynamic> toMap() => {
        'titulo': titulo,
        'corpo': corpo,
        'dataCriacao': dataCriacao.toIso8601String(),
      };

  factory NoteModel.fromMap(String id, Map<String, dynamic> map) => NoteModel(
        id: id,
        titulo: map['titulo'] ?? '',
        corpo: map['corpo'] ?? '',
        dataCriacao: map['dataCriacao'] != null
            ? DateTime.tryParse(map['dataCriacao']) ?? DateTime.now()
            : DateTime.now(),
      );
}
