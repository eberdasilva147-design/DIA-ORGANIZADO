class AppointmentModel {
  final String id;
  final String titulo;
  final String horario;
  final String local;
  final int dia;
  final int mes;
  final int ano;
  final bool ocultarDaHome;
  final bool confirmado;
  final String prioridade; // 'h', 'm', 'l'
  final DateTime? deletedAt;

  AppointmentModel({
    required this.id,
    required this.titulo,
    required this.horario,
    this.local = '',
    required this.dia,
    required this.mes,
    required this.ano,
    this.ocultarDaHome = false,
    this.confirmado = false,
    this.prioridade = 'm',
    this.deletedAt,
  });

  Map<String, dynamic> toMap() => {
        'titulo': titulo,
        'horario': horario,
        'local': local,
        'dia': dia,
        'mes': mes,
        'ano': ano,
        'ocultar_da_home': ocultarDaHome,
        'confirmado': confirmado,
        'prioridade': prioridade,
        'deleted_at': deletedAt?.toUtc().toIso8601String(),
      };

  factory AppointmentModel.fromMap(String id, Map<String, dynamic> map) =>
      AppointmentModel(
        id: id,
        titulo: map['titulo'] ?? '',
        horario: map['horario'] ?? '',
        local: map['local'] ?? '',
        dia: map['dia'] ?? 1,
        mes: map['mes'] ?? 1,
        ano: map['ano'] ?? DateTime.now().year,
        ocultarDaHome: map['ocultar_da_home'] ?? false,
        confirmado: map['confirmado'] ?? false,
        prioridade: map['prioridade'] ?? 'm',
        deletedAt: map['deleted_at'] != null
            ? DateTime.tryParse(map['deleted_at'] as String)
            : null,
      );

  AppointmentModel copyWith({
    String? id,
    String? titulo,
    String? horario,
    String? local,
    int? dia,
    int? mes,
    int? ano,
    bool? ocultarDaHome,
    bool? confirmado,
    String? prioridade,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) =>
      AppointmentModel(
        id: id ?? this.id,
        titulo: titulo ?? this.titulo,
        horario: horario ?? this.horario,
        local: local ?? this.local,
        dia: dia ?? this.dia,
        mes: mes ?? this.mes,
        ano: ano ?? this.ano,
        ocultarDaHome: ocultarDaHome ?? this.ocultarDaHome,
        confirmado: confirmado ?? this.confirmado,
        prioridade: prioridade ?? this.prioridade,
        deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
      );

  DateTime get date => DateTime(ano, mes, dia);

  String get dateFormatted =>
      '$dia/${mes.toString().padLeft(2, '0')}/$ano';

  bool isOnDate(DateTime d) => d.day == dia && d.month == mes && d.year == ano;

  bool get isInTrash => deletedAt != null;

  int get daysUntilPurge {
    if (deletedAt == null) return 30;
    final purgeDate = deletedAt!.add(const Duration(days: 30));
    return purgeDate.difference(DateTime.now()).inDays.clamp(0, 30);
  }

  String get statusKind {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = date;
    if (d.isBefore(today)) return 'atrasado';
    if (d.isAtSameMomentAs(today)) return 'hoje';
    return confirmado ? 'confirmado' : 'pendente';
  }
}
