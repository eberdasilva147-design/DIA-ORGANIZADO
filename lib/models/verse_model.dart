class VerseModel {
  final String versiculo;
  final String referencia;

  VerseModel({required this.versiculo, required this.referencia});

  Map<String, dynamic> toMap() => {
        'versiculo': versiculo,
        'referencia': referencia,
      };

  factory VerseModel.fromMap(Map<String, dynamic> map) => VerseModel(
        versiculo: map['versiculo'] ?? '',
        referencia: map['referencia'] ?? '',
      );
}
