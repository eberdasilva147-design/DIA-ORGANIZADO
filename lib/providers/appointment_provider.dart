import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/appointment_model.dart';
import '../services/data_service.dart';

class AppointmentProvider extends ChangeNotifier {
  List<AppointmentModel> _appointments = [];

  List<AppointmentModel> get appointments =>
      _appointments.where((a) => !a.isInTrash).toList();

  List<AppointmentModel> get trashed =>
      _appointments.where((a) => a.isInTrash).toList()
        ..sort((a, b) => b.deletedAt!.compareTo(a.deletedAt!));

  List<AppointmentModel> forDate(DateTime date) =>
      appointments.where((a) => a.isOnDate(date)).toList()
        ..sort((a, b) => a.horario.compareTo(b.horario));

  List<AppointmentModel> get upcoming {
    final now = DateTime.now();
    return appointments
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
    String prioridade = 'm',
  }) async {
    final ap = AppointmentModel(
      id: const Uuid().v4(),
      titulo: titulo,
      horario: horario,
      local: local,
      dia: date.day,
      mes: date.month,
      ano: date.year,
      prioridade: prioridade,
    );
    await DataService.instance.addAppointment(ap);
  }

  Future<void> updateAppointment(AppointmentModel ap) async {
    await DataService.instance.updateAppointment(ap);
  }

  Future<void> reschedule(String id, DateTime date, String horario) async {
    final ap = _appointments.firstWhere((a) => a.id == id);
    await updateAppointment(ap.copyWith(
      dia: date.day,
      mes: date.month,
      ano: date.year,
      horario: horario,
    ));
  }

  Future<void> toggleOcultarDaHome(String id) async {
    final ap = _appointments.firstWhere((a) => a.id == id);
    await updateAppointment(ap.copyWith(ocultarDaHome: !ap.ocultarDaHome));
  }

  Future<void> toggleConfirmado(String id) async {
    final ap = _appointments.firstWhere((a) => a.id == id);
    await updateAppointment(ap.copyWith(confirmado: !ap.confirmado));
  }

  /// Move para a lixeira (soft delete).
  Future<void> softDeleteAppointment(String id) async {
    await DataService.instance.softDeleteAppointment(id);
  }

  /// Restaura da lixeira.
  Future<void> restoreAppointment(String id) async {
    await DataService.instance.restoreAppointment(id);
  }

  /// Exclui definitivamente (apenas itens já na lixeira).
  Future<void> deleteAppointment(String id) async {
    await DataService.instance.deleteAppointment(id);
  }
}
