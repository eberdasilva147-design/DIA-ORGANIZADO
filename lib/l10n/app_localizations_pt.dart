// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Dia Organizado';

  @override
  String get cancel => 'Cancelar';

  @override
  String get saveChanges => 'Salvar alterações';

  @override
  String get ok => 'OK';

  @override
  String get priority => 'Prioridade';

  @override
  String get priorityHigh => 'Alta';

  @override
  String get priorityMedium => 'Média';

  @override
  String get priorityLow => 'Baixa';

  @override
  String get moveToTrash => 'Mover para a Lixeira';

  @override
  String daysLeft(int days) {
    return '${days}d restantes';
  }

  @override
  String priorityBadge(String priority) {
    return '$priority Prioridade';
  }

  @override
  String get navHome => 'Início';

  @override
  String get navTasks => 'Tarefas';

  @override
  String get navAgenda => 'Agenda';

  @override
  String get navNotes => 'Notas';

  @override
  String get navVoice => 'Comando de Voz';

  @override
  String get navTrash => 'Lixeira';

  @override
  String get navSettings => 'Configurações';

  @override
  String get navLogout => 'Sair';

  @override
  String get digitalSanctuary => 'SANTUÁRIO DIGITAL';

  @override
  String get greetingMorning => 'Bom dia';

  @override
  String get greetingAfternoon => 'Boa tarde';

  @override
  String get greetingEvening => 'Boa noite';

  @override
  String get verseOfDay => 'VERSÍCULO DO DIA';

  @override
  String get nextReminder => 'Próximo lembrete';

  @override
  String get todaysAppointments => 'Compromissos de Hoje';

  @override
  String get noTodayAppointments => 'Nenhum compromisso para hoje 🎉';

  @override
  String get next5DaysActivities => 'Atividades dos próximos 5 dias';

  @override
  String get noNext5Days => 'Nada nos próximos 5 dias.';

  @override
  String get allAppointments => 'Todos os Compromissos';

  @override
  String get newTask => 'Nova Tarefa';

  @override
  String get tasksTitle => 'Tarefas';

  @override
  String get pendingTab => 'Pendentes';

  @override
  String get completedTab => 'Concluídas';

  @override
  String get noPendingTasks => 'Nenhuma tarefa pendente!';

  @override
  String get noCompletedTasks => 'Nenhuma tarefa concluída ainda.';

  @override
  String get newTaskFab => 'Nova tarefa';

  @override
  String moveToTrashTaskMsg(String name) {
    return '\"$name\" será movida para a lixeira. Você pode restaurá-la em até 30 dias.';
  }

  @override
  String get editTask => 'Editar Tarefa';

  @override
  String get taskNameHint => 'Nome da tarefa';

  @override
  String get observationHint => 'Observação (opcional)';

  @override
  String get enableReminder => 'Ativar lembrete';

  @override
  String get remindAt => 'Avisar:';

  @override
  String get saveTask => 'Salvar tarefa';

  @override
  String get reminderAtTime => 'No horário';

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
  String get reminder1Day => '1 dia antes';

  @override
  String get reminderCustom => 'Personalizado…';

  @override
  String get leadTimeMinutes => 'Antecedência (minutos)';

  @override
  String get leadTimeHint => 'Ex.: 45';

  @override
  String minBefore(int min) {
    return '$min minutos antes';
  }

  @override
  String get agendaTitle => 'Agenda';

  @override
  String get weekTab => 'Semana';

  @override
  String get monthTab => 'Mês';

  @override
  String get noAppointmentsDay => 'Nenhum compromisso neste dia.';

  @override
  String get newAppointmentFab => 'Novo compromisso';

  @override
  String get editAppointment => 'Editar Compromisso';

  @override
  String get newAppointment => 'Novo Compromisso';

  @override
  String get appointmentTitleHint => 'Título do compromisso';

  @override
  String get locationHint => 'Local / Descrição (opcional)';

  @override
  String get confirmed => 'Confirmado';

  @override
  String get saveAppointment => 'Salvar compromisso';

  @override
  String moveToTrashApptMsg(String name) {
    return '\"$name\" será movido para a lixeira. Você pode restaurá-lo em até 30 dias.';
  }

  @override
  String appointmentsCount(int count) {
    return '$count compromisso(s)';
  }

  @override
  String get weekDayMon => 'Seg';

  @override
  String get weekDayTue => 'Ter';

  @override
  String get weekDayWed => 'Qua';

  @override
  String get weekDayThu => 'Qui';

  @override
  String get weekDayFri => 'Sex';

  @override
  String get weekDaySat => 'Sáb';

  @override
  String get weekDaySun => 'Dom';

  @override
  String get notesTitle => 'Notas Rápidas';

  @override
  String get searchHint => 'Buscar notas...';

  @override
  String get noNotes => 'Nenhuma nota encontrada.';

  @override
  String get newNoteFab => 'Nova nota';

  @override
  String get editNoteTitle => 'Editar Nota';

  @override
  String get newNoteTitle => 'Nova Nota';

  @override
  String get noteTitleHint => 'Título';

  @override
  String get noteContentHint => 'Conteúdo da nota...';

  @override
  String get saveNote => 'Salvar nota';

  @override
  String get moveToTrashNoteMsg =>
      'A nota será movida para a lixeira. Você pode restaurá-la em até 30 dias.';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsAppearance => 'Aparência';

  @override
  String get settingsDarkMode => 'Modo escuro';

  @override
  String get settingsDarkModeSubtitle => 'Visual em tons de azul escuro';

  @override
  String get settingsNotifications => 'Notificações';

  @override
  String get settingsNotificationsSubtitle =>
      'Receber alertas de tarefas e compromissos';

  @override
  String get settingsPermissionBanner =>
      'As notificações estão desativadas. Para receber alertas, ative as notificações nas configurações do seu dispositivo.';

  @override
  String get settingsSound => 'Som';

  @override
  String get settingsSoundSubtitle => 'Tocar som ao receber alertas';

  @override
  String get settingsVibration => 'Vibração';

  @override
  String get settingsVibrationSubtitle => 'Vibrar ao receber alertas';

  @override
  String get settingsSilentMode => 'Modo silencioso';

  @override
  String get settingsSilentModeSubtitle =>
      'Alertas chegam sem som nem vibração';

  @override
  String get settingsDoNotDisturb => 'Não perturbe';

  @override
  String get settingsDoNotDisturbSubtitle =>
      'Silencia todas as notificações agora';

  @override
  String get settingsQuietHours => 'Horário de silêncio';

  @override
  String get settingsQuietHoursSubtitle =>
      'Silenciar notificações em um período fixo';

  @override
  String get settingsQuietPeriod => 'Período de silêncio';

  @override
  String get settingsStart => 'Início';

  @override
  String get settingsEnd => 'Fim';

  @override
  String get settingsTo => 'até';

  @override
  String get settingsRecurringReminders => 'Lembretes recorrentes';

  @override
  String get settingsRecurringRemindersSubtitle =>
      'Repetir alertas até confirmação';

  @override
  String get settingsOthers => 'Outros';

  @override
  String get settingsFavoriteVerses => 'Versículos favoritos';

  @override
  String get settingsVersion => 'Dia Organizado v1.0.0';

  @override
  String get settingsSignOut => 'Sair da conta';

  @override
  String get settingsLanguageSection => 'Idioma';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSubtitle => 'Escolha o idioma do aplicativo';

  @override
  String get voiceTitle => 'Comando de Voz';

  @override
  String get voiceSubtitle => 'Toque para iniciar — depois é só conversar';

  @override
  String get voicePaused => 'Pausado — toque para retomar';

  @override
  String get voiceProcessing => '🔵 Processando';

  @override
  String get voiceResponding => '🟣 Respondendo';

  @override
  String get voiceListening => '🟢 Ouvindo';

  @override
  String get voiceAnsweredByAI => '✨ Respondido pela IA';

  @override
  String get voiceBasicMode => '⚙️ Comandos básicos';

  @override
  String get voiceTypeHint => 'Ou digite seu comando aqui...';

  @override
  String get voiceExecute => 'Executar comando';

  @override
  String get voiceAvailableCommands => 'Comandos disponíveis:';

  @override
  String get voiceMicUnavailable =>
      'Microfone não disponível neste navegador. Use o campo de texto abaixo.';

  @override
  String get loginSubtitle => 'Faça login para continuar';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get passwordLabel => 'Senha';

  @override
  String get invalidEmail => 'E-mail inválido';

  @override
  String get minChars => 'Mínimo 6 caracteres';

  @override
  String get rememberCredentials => 'Lembrar e-mail e senha';

  @override
  String get loginButton => 'Entrar';

  @override
  String get noAccount => 'Não tem conta? ';

  @override
  String get registerLink => 'Cadastre-se';

  @override
  String get registerTitle => 'Criar conta';

  @override
  String get nameLabel => 'Seu nome';

  @override
  String get nameRequired => 'Informe seu nome';

  @override
  String get registerButton => 'Criar conta';

  @override
  String get tagline => 'Seu dia, do seu jeito.';

  @override
  String get verseScreenTitle => 'Versículo do Dia';

  @override
  String get verseTodayLabel => 'Versículo de hoje';

  @override
  String get verseSaveButton => 'Salvar';

  @override
  String get verseSavedLabel => 'Salvo';

  @override
  String get verseFavoritesTitle => 'Favoritos';

  @override
  String get trashTitle => 'Lixeira';

  @override
  String get trashEmptyButton => 'Esvaziar';

  @override
  String get trashEmptyTitle => 'Esvaziar Lixeira';

  @override
  String get trashEmptyMsg =>
      'Todos os itens serão excluídos permanentemente. Esta ação não pode ser desfeita.';

  @override
  String get trashNoTasks => 'Nenhuma tarefa na lixeira';

  @override
  String get trashNoAppts => 'Nenhum compromisso na lixeira';

  @override
  String get trashNoNotes => 'Nenhuma nota na lixeira';

  @override
  String get trashDeleteTitle => 'Excluir permanentemente';

  @override
  String trashDeleteMsg(String name) {
    return '\"$name\" será excluído permanentemente. Esta ação não pode ser desfeita.';
  }

  @override
  String get actionEdit => 'Editar';

  @override
  String get actionReschedule => 'Reagendar';

  @override
  String get actionHide => 'Ocultar';

  @override
  String get actionDelete => 'Excluir';

  @override
  String get actionRestore => 'Restaurar';

  @override
  String get statusOverdue => 'Atrasado';

  @override
  String get statusToday => 'Hoje';

  @override
  String get statusConfirmed => 'Confirmado';

  @override
  String get statusPending => 'Pendente';

  @override
  String get statusOverdueTask => 'ATRASADA';
}
