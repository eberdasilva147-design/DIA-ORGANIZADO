class AppointmentModel {
  final String id;
  final String titulo;
  final String horario;
  final String local;
  final int dia;
  final int mes;
  final int ano;

  AppointmentModel({
    required this.id,
    required this.titulo,
    required this.horario,
    this.local = '',
    required this.dia,
    required this.mes,
    required this.ano,
  });

  Map<String, dynamic> toMap() => {
        'titulo': titulo,
        'horario': horario,
        'local': local,
        'dia': dia,
        'mes': mes,
        'ano': ano,
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
      );

  DateTime get date => DateTime(ano, mes, dia);

  String get dateFormatted => '$dia/${mes.toString().padLeft(2, '0')}/$ano';

  bool isOnDate(DateTime d) => d.day == dia && d.month == mes && d.year == ano;
}
