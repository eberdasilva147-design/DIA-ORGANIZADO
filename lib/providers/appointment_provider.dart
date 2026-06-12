import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/appointment_model.dart';
import '../services/data_service.dart';

class AppointmentProvider extends ChangeNotifier {
  List<AppointmentModel> _appointments = [];

  List<AppointmentModel> get appointments => _appointments;

  List<AppointmentModel> forDate(DateTime date) =>
      _appointments.where((a) => a.isOnDate(date)).toList()
        ..sort((a, b) => a.horario.compareTo(b.horario));

  List<AppointmentModel> get upcoming {
    final now = DateTime.now();
    return _appointments
        .where((a) => a.date.isAfter(now.subtract(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  void loadAppointments() {
    DataService.instance.streamAppointments().listen((list) {
      _appointments = list;
      notifyListeners();
    });
  }

  Future<void> addAppointment({
    required String titulo,
    required String horario,
    String local = '',
    required DateTime date,
  }) async {
    final ap = AppointmentModel(
      id: const Uuid().v4(),
      titulo: titulo,
      horario: horario,
      local: local,
      dia: date.day,
      mes: date.month,
      ano: date.year,
    );
    await DataService.instance.addAppointment(ap);
  }

  Future<void> deleteAppointment(String id) async {
    await DataService.instance.deleteAppointment(id);
  }
}
