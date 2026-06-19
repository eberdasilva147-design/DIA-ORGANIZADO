class NoteModel {
  final String id;
  final String titulo;
  final String corpo;
  final DateTime dataCriacao;
  final DateTime? deletedAt;

  NoteModel({
    required this.id,
    required this.titulo,
    required this.corpo,
    required this.dataCriacao,
    this.deletedAt,
  });

  Map<String, dynamic> toMap() => {
        'titulo': titulo,
        'corpo': corpo,
        'dataCriacao': dataCriacao.toIso8601String(),
        'deleted_at': deletedAt?.toUtc().toIso8601String(),
      };

  factory NoteModel.fromMap(String id, Map<String, dynamic> map) => NoteModel(
        id: id,
        titulo: map['titulo'] ?? '',
        corpo: map['corpo'] ?? '',
        dataCriacao: map['dataCriacao'] != null
            ? DateTime.tryParse(map['dataCriacao']) ?? DateTime.now()
            : DateTime.now(),
        deletedAt: map['deleted_at'] != null
            ? DateTime.tryParse(map['deleted_at'] as String)
            : null,
      );

  NoteModel copyWith({
    String? id,
    String? titulo,
    String? corpo,
    DateTime? dataCriacao,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) =>
      NoteModel(
        id: id ?? this.id,
        titulo: titulo ?? this.titulo,
        corpo: corpo ?? this.corpo,
        dataCriacao: dataCriacao ?? this.dataCriacao,
        deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
      );

  bool get isInTrash => deletedAt != null;

  int get daysUntilPurge {
    if (deletedAt == null) return 30;
    final purgeDate = deletedAt!.add(const Duration(days: 30));
    return purgeDate.difference(DateTime.now()).inDays.clamp(0, 30);
  }
}
