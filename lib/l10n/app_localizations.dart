import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt')
  ];

  /// No description provided for @appTitle.
  ///
  /// In pt, this message translates to:
  /// **'Dia Organizado'**
  String get appTitle;

  /// No description provided for @cancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @saveChanges.
  ///
  /// In pt, this message translates to:
  /// **'Salvar alterações'**
  String get saveChanges;

  /// No description provided for @ok.
  ///
  /// In pt, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @priority.
  ///
  /// In pt, this message translates to:
  /// **'Prioridade'**
  String get priority;

  /// No description provided for @priorityHigh.
  ///
  /// In pt, this message translates to:
  /// **'Alta'**
  String get priorityHigh;

  /// No description provided for @priorityMedium.
  ///
  /// In pt, this message translates to:
  /// **'Média'**
  String get priorityMedium;

  /// No description provided for @priorityLow.
  ///
  /// In pt, this message translates to:
  /// **'Baixa'**
  String get priorityLow;

  /// No description provided for @moveToTrash.
  ///
  /// In pt, this message translates to:
  /// **'Mover para a Lixeira'**
  String get moveToTrash;

  /// No description provided for @daysLeft.
  ///
  /// In pt, this message translates to:
  /// **'{days}d restantes'**
  String daysLeft(int days);

  /// No description provided for @priorityBadge.
  ///
  /// In pt, this message translates to:
  /// **'{priority} Prioridade'**
  String priorityBadge(String priority);

  /// No description provided for @navHome.
  ///
  /// In pt, this message translates to:
  /// **'Início'**
  String get navHome;

  /// No description provided for @navTasks.
  ///
  /// In pt, this message translates to:
  /// **'Tarefas'**
  String get navTasks;

  /// No description provided for @navAgenda.
  ///
  /// In pt, this message translates to:
  /// **'Agenda'**
  String get navAgenda;

  /// No description provided for @navNotes.
  ///
  /// In pt, this message translates to:
  /// **'Notas'**
  String get navNotes;

  /// No description provided for @navVoice.
  ///
  /// In pt, this message translates to:
  /// **'Comando de Voz'**
  String get navVoice;

  /// No description provided for @navTrash.
  ///
  /// In pt, this message translates to:
  /// **'Lixeira'**
  String get navTrash;

  /// No description provided for @navSettings.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get navSettings;

  /// No description provided for @navLogout.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get navLogout;

  /// No description provided for @digitalSanctuary.
  ///
  /// In pt, this message translates to:
  /// **'SANTUÁRIO DIGITAL'**
  String get digitalSanctuary;

  /// No description provided for @greetingMorning.
  ///
  /// In pt, this message translates to:
  /// **'Bom dia'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In pt, this message translates to:
  /// **'Boa tarde'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In pt, this message translates to:
  /// **'Boa noite'**
  String get greetingEvening;

  /// No description provided for @verseOfDay.
  ///
  /// In pt, this message translates to:
  /// **'VERSÍCULO DO DIA'**
  String get verseOfDay;

  /// No description provided for @nextReminder.
  ///
  /// In pt, this message translates to:
  /// **'Próximo lembrete'**
  String get nextReminder;

  /// No description provided for @todaysAppointments.
  ///
  /// In pt, this message translates to:
  /// **'Compromissos de Hoje'**
  String get todaysAppointments;

  /// No description provided for @noTodayAppointments.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum compromisso para hoje 🎉'**
  String get noTodayAppointments;

  /// No description provided for @next5DaysActivities.
  ///
  /// In pt, this message translates to:
  /// **'Atividades dos próximos 5 dias'**
  String get next5DaysActivities;

  /// No description provided for @noNext5Days.
  ///
  /// In pt, this message translates to:
  /// **'Nada nos próximos 5 dias.'**
  String get noNext5Days;

  /// No description provided for @allAppointments.
  ///
  /// In pt, this message translates to:
  /// **'Todos os Compromissos'**
  String get allAppointments;

  /// No description provided for @newTask.
  ///
  /// In pt, this message translates to:
  /// **'Nova Tarefa'**
  String get newTask;

  /// No description provided for @tasksTitle.
  ///
  /// In pt, this message translates to:
  /// **'Tarefas'**
  String get tasksTitle;

  /// No description provided for @pendingTab.
  ///
  /// In pt, this message translates to:
  /// **'Pendentes'**
  String get pendingTab;

  /// No description provided for @completedTab.
  ///
  /// In pt, this message translates to:
  /// **'Concluídas'**
  String get completedTab;

  /// No description provided for @noPendingTasks.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma tarefa pendente!'**
  String get noPendingTasks;

  /// No description provided for @noCompletedTasks.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma tarefa concluída ainda.'**
  String get noCompletedTasks;

  /// No description provided for @newTaskFab.
  ///
  /// In pt, this message translates to:
  /// **'Nova tarefa'**
  String get newTaskFab;

  /// No description provided for @moveToTrashTaskMsg.
  ///
  /// In pt, this message translates to:
  /// **'\"{name}\" será movida para a lixeira. Você pode restaurá-la em até 30 dias.'**
  String moveToTrashTaskMsg(String name);

  /// No description provided for @editTask.
  ///
  /// In pt, this message translates to:
  /// **'Editar Tarefa'**
  String get editTask;

  /// No description provided for @taskNameHint.
  ///
  /// In pt, this message translates to:
  /// **'Nome da tarefa'**
  String get taskNameHint;

  /// No description provided for @observationHint.
  ///
  /// In pt, this message translates to:
  /// **'Observação (opcional)'**
  String get observationHint;

  /// No description provided for @enableReminder.
  ///
  /// In pt, this message translates to:
  /// **'Ativar lembrete'**
  String get enableReminder;

  /// No description provided for @remindAt.
  ///
  /// In pt, this message translates to:
  /// **'Avisar:'**
  String get remindAt;

  /// No description provided for @saveTask.
  ///
  /// In pt, this message translates to:
  /// **'Salvar tarefa'**
  String get saveTask;

  /// No description provided for @reminderAtTime.
  ///
  /// In pt, this message translates to:
  /// **'No horário'**
  String get reminderAtTime;

  /// No description provided for @reminder5Min.
  ///
  /// In pt, this message translates to:
  /// **'5 minutos antes'**
  String get reminder5Min;

  /// No description provided for @reminder15Min.
  ///
  /// In pt, this message translates to:
  /// **'15 minutos antes'**
  String get reminder15Min;

  /// No description provided for @reminder30Min.
  ///
  /// In pt, this message translates to:
  /// **'30 minutos antes'**
  String get reminder30Min;

  /// No description provided for @reminder1h.
  ///
  /// In pt, this message translates to:
  /// **'1 hora antes'**
  String get reminder1h;

  /// No description provided for @reminder2h.
  ///
  /// In pt, this message translates to:
  /// **'2 horas antes'**
  String get reminder2h;

  /// No description provided for @reminder1Day.
  ///
  /// In pt, this message translates to:
  /// **'1 dia antes'**
  String get reminder1Day;

  /// No description provided for @reminderCustom.
  ///
  /// In pt, this message translates to:
  /// **'Personalizado…'**
  String get reminderCustom;

  /// No description provided for @leadTimeMinutes.
  ///
  /// In pt, this message translates to:
  /// **'Antecedência (minutos)'**
  String get leadTimeMinutes;

  /// No description provided for @leadTimeHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: 45'**
  String get leadTimeHint;

  /// No description provided for @minBefore.
  ///
  /// In pt, this message translates to:
  /// **'{min} minutos antes'**
  String minBefore(int min);

  /// No description provided for @agendaTitle.
  ///
  /// In pt, this message translates to:
  /// **'Agenda'**
  String get agendaTitle;

  /// No description provided for @weekTab.
  ///
  /// In pt, this message translates to:
  /// **'Semana'**
  String get weekTab;

  /// No description provided for @monthTab.
  ///
  /// In pt, this message translates to:
  /// **'Mês'**
  String get monthTab;

  /// No description provided for @noAppointmentsDay.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum compromisso neste dia.'**
  String get noAppointmentsDay;

  /// No description provided for @newAppointmentFab.
  ///
  /// In pt, this message translates to:
  /// **'Novo compromisso'**
  String get newAppointmentFab;

  /// No description provided for @editAppointment.
  ///
  /// In pt, this message translates to:
  /// **'Editar Compromisso'**
  String get editAppointment;

  /// No description provided for @newAppointment.
  ///
  /// In pt, this message translates to:
  /// **'Novo Compromisso'**
  String get newAppointment;

  /// No description provided for @appointmentTitleHint.
  ///
  /// In pt, this message translates to:
  /// **'Título do compromisso'**
  String get appointmentTitleHint;

  /// No description provided for @locationHint.
  ///
  /// In pt, this message translates to:
  /// **'Local / Descrição (opcional)'**
  String get locationHint;

  /// No description provided for @confirmed.
  ///
  /// In pt, this message translates to:
  /// **'Confirmado'**
  String get confirmed;

  /// No description provided for @saveAppointment.
  ///
  /// In pt, this message translates to:
  /// **'Salvar compromisso'**
  String get saveAppointment;

  /// No description provided for @moveToTrashApptMsg.
  ///
  /// In pt, this message translates to:
  /// **'\"{name}\" será movido para a lixeira. Você pode restaurá-lo em até 30 dias.'**
  String moveToTrashApptMsg(String name);

  /// No description provided for @appointmentsCount.
  ///
  /// In pt, this message translates to:
  /// **'{count} compromisso(s)'**
  String appointmentsCount(int count);

  /// No description provided for @weekDayMon.
  ///
  /// In pt, this message translates to:
  /// **'Seg'**
  String get weekDayMon;

  /// No description provided for @weekDayTue.
  ///
  /// In pt, this message translates to:
  /// **'Ter'**
  String get weekDayTue;

  /// No description provided for @weekDayWed.
  ///
  /// In pt, this message translates to:
  /// **'Qua'**
  String get weekDayWed;

  /// No description provided for @weekDayThu.
  ///
  /// In pt, this message translates to:
  /// **'Qui'**
  String get weekDayThu;

  /// No description provided for @weekDayFri.
  ///
  /// In pt, this message translates to:
  /// **'Sex'**
  String get weekDayFri;

  /// No description provided for @weekDaySat.
  ///
  /// In pt, this message translates to:
  /// **'Sáb'**
  String get weekDaySat;

  /// No description provided for @weekDaySun.
  ///
  /// In pt, this message translates to:
  /// **'Dom'**
  String get weekDaySun;

  /// No description provided for @notesTitle.
  ///
  /// In pt, this message translates to:
  /// **'Notas Rápidas'**
  String get notesTitle;

  /// No description provided for @searchHint.
  ///
  /// In pt, this message translates to:
  /// **'Buscar notas...'**
  String get searchHint;

  /// No description provided for @noNotes.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma nota encontrada.'**
  String get noNotes;

  /// No description provided for @newNoteFab.
  ///
  /// In pt, this message translates to:
  /// **'Nova nota'**
  String get newNoteFab;

  /// No description provided for @editNoteTitle.
  ///
  /// In pt, this message translates to:
  /// **'Editar Nota'**
  String get editNoteTitle;

  /// No description provided for @newNoteTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nova Nota'**
  String get newNoteTitle;

  /// No description provided for @noteTitleHint.
  ///
  /// In pt, this message translates to:
  /// **'Título'**
  String get noteTitleHint;

  /// No description provided for @noteContentHint.
  ///
  /// In pt, this message translates to:
  /// **'Conteúdo da nota...'**
  String get noteContentHint;

  /// No description provided for @saveNote.
  ///
  /// In pt, this message translates to:
  /// **'Salvar nota'**
  String get saveNote;

  /// No description provided for @moveToTrashNoteMsg.
  ///
  /// In pt, this message translates to:
  /// **'A nota será movida para a lixeira. Você pode restaurá-la em até 30 dias.'**
  String get moveToTrashNoteMsg;

  /// No description provided for @settingsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In pt, this message translates to:
  /// **'Aparência'**
  String get settingsAppearance;

  /// No description provided for @settingsDarkMode.
  ///
  /// In pt, this message translates to:
  /// **'Modo escuro'**
  String get settingsDarkMode;

  /// No description provided for @settingsDarkModeSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Visual em tons de azul escuro'**
  String get settingsDarkModeSubtitle;

  /// No description provided for @settingsNotifications.
  ///
  /// In pt, this message translates to:
  /// **'Notificações'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Receber alertas de tarefas e compromissos'**
  String get settingsNotificationsSubtitle;

  /// No description provided for @settingsPermissionBanner.
  ///
  /// In pt, this message translates to:
  /// **'As notificações estão desativadas. Para receber alertas, ative as notificações nas configurações do seu dispositivo.'**
  String get settingsPermissionBanner;

  /// No description provided for @settingsSound.
  ///
  /// In pt, this message translates to:
  /// **'Som'**
  String get settingsSound;

  /// No description provided for @settingsSoundSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Tocar som ao receber alertas'**
  String get settingsSoundSubtitle;

  /// No description provided for @settingsVibration.
  ///
  /// In pt, this message translates to:
  /// **'Vibração'**
  String get settingsVibration;

  /// No description provided for @settingsVibrationSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Vibrar ao receber alertas'**
  String get settingsVibrationSubtitle;

  /// No description provided for @settingsSilentMode.
  ///
  /// In pt, this message translates to:
  /// **'Modo silencioso'**
  String get settingsSilentMode;

  /// No description provided for @settingsSilentModeSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Alertas chegam sem som nem vibração'**
  String get settingsSilentModeSubtitle;

  /// No description provided for @settingsDoNotDisturb.
  ///
  /// In pt, this message translates to:
  /// **'Não perturbe'**
  String get settingsDoNotDisturb;

  /// No description provided for @settingsDoNotDisturbSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Silencia todas as notificações agora'**
  String get settingsDoNotDisturbSubtitle;

  /// No description provided for @settingsQuietHours.
  ///
  /// In pt, this message translates to:
  /// **'Horário de silêncio'**
  String get settingsQuietHours;

  /// No description provided for @settingsQuietHoursSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Silenciar notificações em um período fixo'**
  String get settingsQuietHoursSubtitle;

  /// No description provided for @settingsQuietPeriod.
  ///
  /// In pt, this message translates to:
  /// **'Período de silêncio'**
  String get settingsQuietPeriod;

  /// No description provided for @settingsStart.
  ///
  /// In pt, this message translates to:
  /// **'Início'**
  String get settingsStart;

  /// No description provided for @settingsEnd.
  ///
  /// In pt, this message translates to:
  /// **'Fim'**
  String get settingsEnd;

  /// No description provided for @settingsTo.
  ///
  /// In pt, this message translates to:
  /// **'até'**
  String get settingsTo;

  /// No description provided for @settingsRecurringReminders.
  ///
  /// In pt, this message translates to:
  /// **'Lembretes recorrentes'**
  String get settingsRecurringReminders;

  /// No description provided for @settingsRecurringRemindersSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Repetir alertas até confirmação'**
  String get settingsRecurringRemindersSubtitle;

  /// No description provided for @settingsOthers.
  ///
  /// In pt, this message translates to:
  /// **'Outros'**
  String get settingsOthers;

  /// No description provided for @settingsFavoriteVerses.
  ///
  /// In pt, this message translates to:
  /// **'Versículos favoritos'**
  String get settingsFavoriteVerses;

  /// No description provided for @settingsVersion.
  ///
  /// In pt, this message translates to:
  /// **'Dia Organizado v1.0.0'**
  String get settingsVersion;

  /// No description provided for @settingsSignOut.
  ///
  /// In pt, this message translates to:
  /// **'Sair da conta'**
  String get settingsSignOut;

  /// No description provided for @settingsLanguageSection.
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get settingsLanguageSection;

  /// No description provided for @settingsLanguage.
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Escolha o idioma do aplicativo'**
  String get settingsLanguageSubtitle;

  /// No description provided for @voiceTitle.
  ///
  /// In pt, this message translates to:
  /// **'Comando de Voz'**
  String get voiceTitle;

  /// No description provided for @voiceSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Toque para iniciar — depois é só conversar'**
  String get voiceSubtitle;

  /// No description provided for @voicePaused.
  ///
  /// In pt, this message translates to:
  /// **'Pausado — toque para retomar'**
  String get voicePaused;

  /// No description provided for @voiceProcessing.
  ///
  /// In pt, this message translates to:
  /// **'🔵 Processando'**
  String get voiceProcessing;

  /// No description provided for @voiceResponding.
  ///
  /// In pt, this message translates to:
  /// **'🟣 Respondendo'**
  String get voiceResponding;

  /// No description provided for @voiceListening.
  ///
  /// In pt, this message translates to:
  /// **'🟢 Ouvindo'**
  String get voiceListening;

  /// No description provided for @voiceAnsweredByAI.
  ///
  /// In pt, this message translates to:
  /// **'✨ Respondido pela IA'**
  String get voiceAnsweredByAI;

  /// No description provided for @voiceBasicMode.
  ///
  /// In pt, this message translates to:
  /// **'⚙️ Comandos básicos'**
  String get voiceBasicMode;

  /// No description provided for @voiceTypeHint.
  ///
  /// In pt, this message translates to:
  /// **'Ou digite seu comando aqui...'**
  String get voiceTypeHint;

  /// No description provided for @voiceExecute.
  ///
  /// In pt, this message translates to:
  /// **'Executar comando'**
  String get voiceExecute;

  /// No description provided for @voiceAvailableCommands.
  ///
  /// In pt, this message translates to:
  /// **'Comandos disponíveis:'**
  String get voiceAvailableCommands;

  /// No description provided for @voiceMicUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Microfone não disponível neste navegador. Use o campo de texto abaixo.'**
  String get voiceMicUnavailable;

  /// No description provided for @loginSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Faça login para continuar'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get passwordLabel;

  /// No description provided for @invalidEmail.
  ///
  /// In pt, this message translates to:
  /// **'E-mail inválido'**
  String get invalidEmail;

  /// No description provided for @minChars.
  ///
  /// In pt, this message translates to:
  /// **'Mínimo 6 caracteres'**
  String get minChars;

  /// No description provided for @rememberCredentials.
  ///
  /// In pt, this message translates to:
  /// **'Lembrar e-mail e senha'**
  String get rememberCredentials;

  /// No description provided for @loginButton.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get loginButton;

  /// No description provided for @noAccount.
  ///
  /// In pt, this message translates to:
  /// **'Não tem conta? '**
  String get noAccount;

  /// No description provided for @registerLink.
  ///
  /// In pt, this message translates to:
  /// **'Cadastre-se'**
  String get registerLink;

  /// No description provided for @registerTitle.
  ///
  /// In pt, this message translates to:
  /// **'Criar conta'**
  String get registerTitle;

  /// No description provided for @nameLabel.
  ///
  /// In pt, this message translates to:
  /// **'Seu nome'**
  String get nameLabel;

  /// No description provided for @nameRequired.
  ///
  /// In pt, this message translates to:
  /// **'Informe seu nome'**
  String get nameRequired;

  /// No description provided for @registerButton.
  ///
  /// In pt, this message translates to:
  /// **'Criar conta'**
  String get registerButton;

  /// No description provided for @tagline.
  ///
  /// In pt, this message translates to:
  /// **'Seu dia, do seu jeito.'**
  String get tagline;

  /// No description provided for @verseScreenTitle.
  ///
  /// In pt, this message translates to:
  /// **'Versículo do Dia'**
  String get verseScreenTitle;

  /// No description provided for @verseTodayLabel.
  ///
  /// In pt, this message translates to:
  /// **'Versículo de hoje'**
  String get verseTodayLabel;

  /// No description provided for @verseSaveButton.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get verseSaveButton;

  /// No description provided for @verseSavedLabel.
  ///
  /// In pt, this message translates to:
  /// **'Salvo'**
  String get verseSavedLabel;

  /// No description provided for @verseFavoritesTitle.
  ///
  /// In pt, this message translates to:
  /// **'Favoritos'**
  String get verseFavoritesTitle;

  /// No description provided for @trashTitle.
  ///
  /// In pt, this message translates to:
  /// **'Lixeira'**
  String get trashTitle;

  /// No description provided for @trashEmptyButton.
  ///
  /// In pt, this message translates to:
  /// **'Esvaziar'**
  String get trashEmptyButton;

  /// No description provided for @trashEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Esvaziar Lixeira'**
  String get trashEmptyTitle;

  /// No description provided for @trashEmptyMsg.
  ///
  /// In pt, this message translates to:
  /// **'Todos os itens serão excluídos permanentemente. Esta ação não pode ser desfeita.'**
  String get trashEmptyMsg;

  /// No description provided for @trashNoTasks.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma tarefa na lixeira'**
  String get trashNoTasks;

  /// No description provided for @trashNoAppts.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum compromisso na lixeira'**
  String get trashNoAppts;

  /// No description provided for @trashNoNotes.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma nota na lixeira'**
  String get trashNoNotes;

  /// No description provided for @trashDeleteTitle.
  ///
  /// In pt, this message translates to:
  /// **'Excluir permanentemente'**
  String get trashDeleteTitle;

  /// No description provided for @trashDeleteMsg.
  ///
  /// In pt, this message translates to:
  /// **'\"{name}\" será excluído permanentemente. Esta ação não pode ser desfeita.'**
  String trashDeleteMsg(String name);

  /// No description provided for @actionEdit.
  ///
  /// In pt, this message translates to:
  /// **'Editar'**
  String get actionEdit;

  /// No description provided for @actionReschedule.
  ///
  /// In pt, this message translates to:
  /// **'Reagendar'**
  String get actionReschedule;

  /// No description provided for @actionHide.
  ///
  /// In pt, this message translates to:
  /// **'Ocultar'**
  String get actionHide;

  /// No description provided for @actionDelete.
  ///
  /// In pt, this message translates to:
  /// **'Excluir'**
  String get actionDelete;

  /// No description provided for @actionRestore.
  ///
  /// In pt, this message translates to:
  /// **'Restaurar'**
  String get actionRestore;

  /// No description provided for @statusOverdue.
  ///
  /// In pt, this message translates to:
  /// **'Atrasado'**
  String get statusOverdue;

  /// No description provided for @statusToday.
  ///
  /// In pt, this message translates to:
  /// **'Hoje'**
  String get statusToday;

  /// No description provided for @statusConfirmed.
  ///
  /// In pt, this message translates to:
  /// **'Confirmado'**
  String get statusConfirmed;

  /// No description provided for @statusPending.
  ///
  /// In pt, this message translates to:
  /// **'Pendente'**
  String get statusPending;

  /// No description provided for @statusOverdueTask.
  ///
  /// In pt, this message translates to:
  /// **'ATRASADA'**
  String get statusOverdueTask;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
