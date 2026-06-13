class TaskModel {
  final String id;
  final String nome;
  final String data;
  final String horario;
  final String prioridade; // 'h', 'm', 'l'
  final bool concluida;
  final bool atrasada;
  final bool lembrete;
  final String observacao;
  final int lembreteMinAntes; // minutos antes do horário para o lembrete
  final bool ocultarDaHome;

  TaskModel({
    required this.id,
    required this.nome,
    required this.data,
    required this.horario,
    this.prioridade = 'm',
    this.concluida = false,
    this.atrasada = false,
    this.lembrete = false,
    this.observacao = '',
    this.lembreteMinAntes = 0,
    this.ocultarDaHome = false,
  });

  Map<String, dynamic> toMap() => {
        'nome': nome,
        'data': data,
        'horario': horario,
        'prioridade': prioridade,
        'concluida': concluida,
        'atrasada': atrasada,
        'lembrete': lembrete,
        'observacao': observacao,
        'lembrete_min_antes': lembreteMinAntes,
        'ocultar_da_home': ocultarDaHome,
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
        observacao: map['observacao'] ?? '',
        lembreteMinAntes: (map['lembrete_min_antes'] as num?)?.toInt() ?? 0,
        ocultarDaHome: map['ocultar_da_home'] ?? false,
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
    String? observacao,
    int? lembreteMinAntes,
    bool? ocultarDaHome,
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
        observacao: observacao ?? this.observacao,
        lembreteMinAntes: lembreteMinAntes ?? this.lembreteMinAntes,
        ocultarDaHome: ocultarDaHome ?? this.ocultarDaHome,
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

  /// Momento em que o lembrete deve disparar (horário − antecedência).
  DateTime? get lembreteDateTime {
    final dt = dateTime;
    if (dt == null) return null;
    return dt.subtract(Duration(minutes: lembreteMinAntes));
  }

  bool get isOverdue {
    final dt = dateTime;
    if (dt == null || concluida) return false;
    return dt.isBefore(DateTime.now());
  }
}
