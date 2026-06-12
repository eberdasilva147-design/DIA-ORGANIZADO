class TaskModel {
  final String id;
  final String nome;
  final String data;
  final String horario;
  final String prioridade; // 'h', 'm', 'l'
  final bool concluida;
  final bool atrasada;
  final bool lembrete;

  TaskModel({
    required this.id,
    required this.nome,
    required this.data,
    required this.horario,
    this.prioridade = 'm',
    this.concluida = false,
    this.atrasada = false,
    this.lembrete = false,
  });

  Map<String, dynamic> toMap() => {
        'nome': nome,
        'data': data,
        'horario': horario,
        'prioridade': prioridade,
        'concluida': concluida,
        'atrasada': atrasada,
        'lembrete': lembrete,
      };

  factory TaskModel.fromMap(String id, Map<String, dynamic> map) => TaskModel(
        id: id,
        nome: map['nome'] ?? '',
        data: map['data'] ?? '',
        horario: map['horario'] ?? '',
        prioridade: map['prioridade'] ?? 'm',
        concluida: map['concluida'] ?? false,
        atrasada: map['atrasada'] ?? false,
        lembrete: map['lembrete'] ?? false,
      );

  TaskModel copyWith({
    String? id,
    String? nome,
    String? data,
    String? horario,
    String? prioridade,
    bool? concluida,
    bool? atrasada,
    bool? lembrete,
  }) =>
      TaskModel(
        id: id ?? this.id,
        nome: nome ?? this.nome,
        data: data ?? this.data,
        horario: horario ?? this.horario,
        prioridade: prioridade ?? this.prioridade,
        concluida: concluida ?? this.concluida,
        atrasada: atrasada ?? this.atrasada,
        lembrete: lembrete ?? this.lembrete,
      );

  DateTime? get dateTime {
    try {
      final parts = data.split('/');
      if (parts.length != 3) return null;
      final timeParts = horario.split(':');
      return DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
        timeParts.isNotEmpty ? int.parse(timeParts[0]) : 0,
        timeParts.length > 1 ? int.parse(timeParts[1]) : 0,
      );
    } catch (_) {
      return null;
    }
  }

  bool get isOverdue {
    final dt = dateTime;
    if (dt == null || concluida) return false;
    return dt.isBefore(DateTime.now());
  }
}
