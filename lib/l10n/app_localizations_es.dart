// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Día Organizado';

  @override
  String get cancel => 'Cancelar';

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String get ok => 'OK';

  @override
  String get priority => 'Prioridad';

  @override
  String get priorityHigh => 'Alta';

  @override
  String get priorityMedium => 'Media';

  @override
  String get priorityLow => 'Baja';

  @override
  String get moveToTrash => 'Mover a la Papelera';

  @override
  String daysLeft(int days) {
    return '${days}d restantes';
  }

  @override
  String priorityBadge(String priority) {
    return '$priority Prioridad';
  }

  @override
  String get navHome => 'Inicio';

  @override
  String get navTasks => 'Tareas';

  @override
  String get navAgenda => 'Agenda';

  @override
  String get navNotes => 'Notas';

  @override
  String get navVoice => 'Comando de Voz';

  @override
  String get navTrash => 'Papelera';

  @override
  String get navSettings => 'Configuración';

  @override
  String get navLogout => 'Salir';

  @override
  String get digitalSanctuary => 'SANTUARIO DIGITAL';

  @override
  String get greetingMorning => 'Buenos días';

  @override
  String get greetingAfternoon => 'Buenas tardes';

  @override
  String get greetingEvening => 'Buenas noches';

  @override
  String get verseOfDay => 'VERSÍCULO DEL DÍA';

  @override
  String get nextReminder => 'Próximo recordatorio';

  @override
  String get todaysAppointments => 'Eventos de Hoy';

  @override
  String get noTodayAppointments => 'Sin eventos por hoy 🎉';

  @override
  String get next5DaysActivities => 'Actividades de los próximos 5 días';

  @override
  String get noNext5Days => 'Nada en los próximos 5 días.';

  @override
  String get allAppointments => 'Todos los Eventos';

  @override
  String get newTask => 'Nueva Tarea';

  @override
  String get tasksTitle => 'Tareas';

  @override
  String get pendingTab => 'Pendientes';

  @override
  String get completedTab => 'Completadas';

  @override
  String get noPendingTasks => '¡Sin tareas pendientes!';

  @override
  String get noCompletedTasks => 'Sin tareas completadas aún.';

  @override
  String get newTaskFab => 'Nueva tarea';

  @override
  String moveToTrashTaskMsg(String name) {
    return '\"$name\" será movida a la papelera. Puede restaurarla en hasta 30 días.';
  }

  @override
  String get editTask => 'Editar Tarea';

  @override
  String get taskNameHint => 'Nombre de la tarea';

  @override
  String get observationHint => 'Observación (opcional)';

  @override
  String get enableReminder => 'Activar recordatorio';

  @override
  String get remindAt => 'Avisar:';

  @override
  String get saveTask => 'Guardar tarea';

  @override
  String get reminderAtTime => 'A la hora';

  @override
  String get reminder5Min => '5 minutos antes';

  @override
  String get reminder15Min => '15 minutos antes';

  @override
  String get reminder30Min => '30 minutos antes';

  @override
  String get reminder1h => '1 hora antes';

  @override
  String get reminder2h => '2 horas antes';

  @override
  String get reminder1Day => '1 día antes';

  @override
  String get reminderCustom => 'Personalizado…';

  @override
  String get leadTimeMinutes => 'Anticipación (minutos)';

  @override
  String get leadTimeHint => 'Ej.: 45';

  @override
  String minBefore(int min) {
    return '$min minutos antes';
  }

  @override
  String get agendaTitle => 'Agenda';

  @override
  String get weekTab => 'Semana';

  @override
  String get monthTab => 'Mes';

  @override
  String get noAppointmentsDay => 'Sin eventos en este día.';

  @override
  String get newAppointmentFab => 'Nuevo evento';

  @override
  String get editAppointment => 'Editar Evento';

  @override
  String get newAppointment => 'Nuevo Evento';

  @override
  String get appointmentTitleHint => 'Título del evento';

  @override
  String get locationHint => 'Lugar / Descripción (opcional)';

  @override
  String get confirmed => 'Confirmado';

  @override
  String get saveAppointment => 'Guardar evento';

  @override
  String moveToTrashApptMsg(String name) {
    return '\"$name\" será movido a la papelera. Puede restaurarlo en hasta 30 días.';
  }

  @override
  String appointmentsCount(int count) {
    return '$count evento(s)';
  }

  @override
  String get weekDayMon => 'Lun';

  @override
  String get weekDayTue => 'Mar';

  @override
  String get weekDayWed => 'Mié';

  @override
  String get weekDayThu => 'Jue';

  @override
  String get weekDayFri => 'Vie';

  @override
  String get weekDaySat => 'Sáb';

  @override
  String get weekDaySun => 'Dom';

  @override
  String get notesTitle => 'Notas Rápidas';

  @override
  String get searchHint => 'Buscar notas...';

  @override
  String get noNotes => 'Ninguna nota encontrada.';

  @override
  String get newNoteFab => 'Nueva nota';

  @override
  String get editNoteTitle => 'Editar Nota';

  @override
  String get newNoteTitle => 'Nueva Nota';

  @override
  String get noteTitleHint => 'Título';

  @override
  String get noteContentHint => 'Contenido de la nota...';

  @override
  String get saveNote => 'Guardar nota';

  @override
  String get moveToTrashNoteMsg =>
      'La nota será movida a la papelera. Puede restaurarla en hasta 30 días.';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsDarkMode => 'Modo oscuro';

  @override
  String get settingsDarkModeSubtitle => 'Visual en tonos azul oscuro';

  @override
  String get settingsNotifications => 'Notificaciones';

  @override
  String get settingsNotificationsSubtitle =>
      'Recibir alertas de tareas y eventos';

  @override
  String get settingsPermissionBanner =>
      'Las notificaciones están desactivadas. Para recibir alertas, active las notificaciones en la configuración de su dispositivo.';

  @override
  String get settingsSound => 'Sonido';

  @override
  String get settingsSoundSubtitle => 'Reproducir sonido al recibir alertas';

  @override
  String get settingsVibration => 'Vibración';

  @override
  String get settingsVibrationSubtitle => 'Vibrar al recibir alertas';

  @override
  String get settingsSilentMode => 'Modo silencioso';

  @override
  String get settingsSilentModeSubtitle => 'Alertas sin sonido ni vibración';

  @override
  String get settingsDoNotDisturb => 'No molestar';

  @override
  String get settingsDoNotDisturbSubtitle =>
      'Silenciar todas las notificaciones ahora';

  @override
  String get settingsQuietHours => 'Horario de silencio';

  @override
  String get settingsQuietHoursSubtitle =>
      'Silenciar notificaciones en un período fijo';

  @override
  String get settingsQuietPeriod => 'Período de silencio';

  @override
  String get settingsStart => 'Inicio';

  @override
  String get settingsEnd => 'Fin';

  @override
  String get settingsTo => 'hasta';

  @override
  String get settingsRecurringReminders => 'Recordatorios recurrentes';

  @override
  String get settingsRecurringRemindersSubtitle =>
      'Repetir alertas hasta confirmación';

  @override
  String get settingsOthers => 'Otros';

  @override
  String get settingsFavoriteVerses => 'Versículos favoritos';

  @override
  String get settingsVersion => 'Día Organizado v1.0.0';

  @override
  String get settingsSignOut => 'Cerrar sesión';

  @override
  String get settingsLanguageSection => 'Idioma';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSubtitle => 'Elija el idioma de la aplicación';

  @override
  String get voiceTitle => 'Comando de Voz';

  @override
  String get voiceSubtitle => 'Toque para iniciar — luego solo hable';

  @override
  String get voicePaused => 'Pausado — toque para reanudar';

  @override
  String get voiceProcessing => '🔵 Procesando';

  @override
  String get voiceResponding => '🟣 Respondiendo';

  @override
  String get voiceListening => '🟢 Escuchando';

  @override
  String get voiceAnsweredByAI => '✨ Respondido por IA';

  @override
  String get voiceBasicMode => '⚙️ Comandos básicos';

  @override
  String get voiceTypeHint => 'O escriba su comando aquí...';

  @override
  String get voiceExecute => 'Ejecutar comando';

  @override
  String get voiceAvailableCommands => 'Comandos disponibles:';

  @override
  String get voiceMicUnavailable =>
      'Micrófono no disponible en este navegador. Use el campo de texto abajo.';

  @override
  String get loginSubtitle => 'Inicie sesión para continuar';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get invalidEmail => 'Correo inválido';

  @override
  String get minChars => 'Mínimo 6 caracteres';

  @override
  String get rememberCredentials => 'Recordar correo y contraseña';

  @override
  String get loginButton => 'Entrar';

  @override
  String get noAccount => '¿No tiene cuenta? ';

  @override
  String get registerLink => 'Regístrese';

  @override
  String get registerTitle => 'Crear cuenta';

  @override
  String get nameLabel => 'Su nombre';

  @override
  String get nameRequired => 'Ingrese su nombre';

  @override
  String get registerButton => 'Crear cuenta';

  @override
  String get tagline => 'Tu día, a tu manera.';

  @override
  String get verseScreenTitle => 'Versículo del Día';

  @override
  String get verseTodayLabel => 'Versículo de hoy';

  @override
  String get verseSaveButton => 'Guardar';

  @override
  String get verseSavedLabel => 'Guardado';

  @override
  String get verseFavoritesTitle => 'Favoritos';

  @override
  String get trashTitle => 'Papelera';

  @override
  String get trashEmptyButton => 'Vaciar';

  @override
  String get trashEmptyTitle => 'Vaciar Papelera';

  @override
  String get trashEmptyMsg =>
      'Todos los elementos serán eliminados permanentemente. Esta acción no puede deshacerse.';

  @override
  String get trashNoTasks => 'Ninguna tarea en la papelera';

  @override
  String get trashNoAppts => 'Ningún evento en la papelera';

  @override
  String get trashNoNotes => 'Ninguna nota en la papelera';

  @override
  String get trashDeleteTitle => 'Eliminar permanentemente';

  @override
  String trashDeleteMsg(String name) {
    return '\"$name\" será eliminado permanentemente. Esta acción no puede deshacerse.';
  }

  @override
  String get actionEdit => 'Editar';

  @override
  String get actionReschedule => 'Reagendar';

  @override
  String get actionHide => 'Ocultar';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get actionRestore => 'Restaurar';

  @override
  String get statusOverdue => 'Atrasado';

  @override
  String get statusToday => 'Hoy';

  @override
  String get statusConfirmed => 'Confirmado';

  @override
  String get statusPending => 'Pendiente';

  @override
  String get statusOverdueTask => 'ATRASADA';
}
