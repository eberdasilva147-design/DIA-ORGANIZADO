// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Organized Day';

  @override
  String get cancel => 'Cancel';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get ok => 'OK';

  @override
  String get priority => 'Priority';

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get priorityLow => 'Low';

  @override
  String get moveToTrash => 'Move to Trash';

  @override
  String daysLeft(int days) {
    return '${days}d left';
  }

  @override
  String priorityBadge(String priority) {
    return '$priority Priority';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navTasks => 'Tasks';

  @override
  String get navAgenda => 'Schedule';

  @override
  String get navNotes => 'Notes';

  @override
  String get navVoice => 'Voice Command';

  @override
  String get navTrash => 'Trash';

  @override
  String get navSettings => 'Settings';

  @override
  String get navLogout => 'Sign out';

  @override
  String get digitalSanctuary => 'DIGITAL SANCTUARY';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get verseOfDay => 'VERSE OF THE DAY';

  @override
  String get nextReminder => 'Next reminder';

  @override
  String get todaysAppointments => 'Today\'s Events';

  @override
  String get noTodayAppointments => 'No events for today 🎉';

  @override
  String get next5DaysActivities => 'Next 5 days activities';

  @override
  String get noNext5Days => 'Nothing in the next 5 days.';

  @override
  String get allAppointments => 'All Events';

  @override
  String get newTask => 'New Task';

  @override
  String get tasksTitle => 'Tasks';

  @override
  String get pendingTab => 'Pending';

  @override
  String get completedTab => 'Completed';

  @override
  String get noPendingTasks => 'No pending tasks!';

  @override
  String get noCompletedTasks => 'No completed tasks yet.';

  @override
  String get newTaskFab => 'New task';

  @override
  String moveToTrashTaskMsg(String name) {
    return '\"$name\" will be moved to trash. You can restore it within 30 days.';
  }

  @override
  String get editTask => 'Edit Task';

  @override
  String get taskNameHint => 'Task name';

  @override
  String get observationHint => 'Notes (optional)';

  @override
  String get enableReminder => 'Enable reminder';

  @override
  String get remindAt => 'Remind:';

  @override
  String get saveTask => 'Save task';

  @override
  String get reminderAtTime => 'At the time';

  @override
  String get reminder5Min => '5 minutes before';

  @override
  String get reminder15Min => '15 minutes before';

  @override
  String get reminder30Min => '30 minutes before';

  @override
  String get reminder1h => '1 hour before';

  @override
  String get reminder2h => '2 hours before';

  @override
  String get reminder1Day => '1 day before';

  @override
  String get reminderCustom => 'Custom…';

  @override
  String get leadTimeMinutes => 'Lead time (minutes)';

  @override
  String get leadTimeHint => 'E.g.: 45';

  @override
  String minBefore(int min) {
    return '$min minutes before';
  }

  @override
  String get agendaTitle => 'Schedule';

  @override
  String get weekTab => 'Week';

  @override
  String get monthTab => 'Month';

  @override
  String get noAppointmentsDay => 'No events on this day.';

  @override
  String get newAppointmentFab => 'New event';

  @override
  String get editAppointment => 'Edit Event';

  @override
  String get newAppointment => 'New Event';

  @override
  String get appointmentTitleHint => 'Event title';

  @override
  String get locationHint => 'Location / Description (optional)';

  @override
  String get confirmed => 'Confirmed';

  @override
  String get saveAppointment => 'Save event';

  @override
  String moveToTrashApptMsg(String name) {
    return '\"$name\" will be moved to trash. You can restore it within 30 days.';
  }

  @override
  String appointmentsCount(int count) {
    return '$count event(s)';
  }

  @override
  String get weekDayMon => 'Mon';

  @override
  String get weekDayTue => 'Tue';

  @override
  String get weekDayWed => 'Wed';

  @override
  String get weekDayThu => 'Thu';

  @override
  String get weekDayFri => 'Fri';

  @override
  String get weekDaySat => 'Sat';

  @override
  String get weekDaySun => 'Sun';

  @override
  String get notesTitle => 'Quick Notes';

  @override
  String get searchHint => 'Search notes...';

  @override
  String get noNotes => 'No notes found.';

  @override
  String get newNoteFab => 'New note';

  @override
  String get editNoteTitle => 'Edit Note';

  @override
  String get newNoteTitle => 'New Note';

  @override
  String get noteTitleHint => 'Title';

  @override
  String get noteContentHint => 'Note content...';

  @override
  String get saveNote => 'Save note';

  @override
  String get moveToTrashNoteMsg =>
      'The note will be moved to trash. You can restore it within 30 days.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsDarkMode => 'Dark mode';

  @override
  String get settingsDarkModeSubtitle => 'Dark blue tone visual';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsSubtitle =>
      'Receive alerts for tasks and events';

  @override
  String get settingsPermissionBanner =>
      'Notifications are disabled. To receive alerts, enable notifications in your device settings.';

  @override
  String get settingsSound => 'Sound';

  @override
  String get settingsSoundSubtitle => 'Play sound when receiving alerts';

  @override
  String get settingsVibration => 'Vibration';

  @override
  String get settingsVibrationSubtitle => 'Vibrate when receiving alerts';

  @override
  String get settingsSilentMode => 'Silent mode';

  @override
  String get settingsSilentModeSubtitle =>
      'Alerts arrive without sound or vibration';

  @override
  String get settingsDoNotDisturb => 'Do not disturb';

  @override
  String get settingsDoNotDisturbSubtitle => 'Silence all notifications now';

  @override
  String get settingsQuietHours => 'Quiet hours';

  @override
  String get settingsQuietHoursSubtitle =>
      'Silence notifications during a fixed period';

  @override
  String get settingsQuietPeriod => 'Quiet period';

  @override
  String get settingsStart => 'Start';

  @override
  String get settingsEnd => 'End';

  @override
  String get settingsTo => 'to';

  @override
  String get settingsRecurringReminders => 'Recurring reminders';

  @override
  String get settingsRecurringRemindersSubtitle =>
      'Repeat alerts until confirmed';

  @override
  String get settingsOthers => 'Other';

  @override
  String get settingsFavoriteVerses => 'Favorite verses';

  @override
  String get settingsVersion => 'Organized Day v1.0.0';

  @override
  String get settingsSignOut => 'Sign out';

  @override
  String get settingsLanguageSection => 'Language';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSubtitle => 'Choose the app language';

  @override
  String get voiceTitle => 'Voice Command';

  @override
  String get voiceSubtitle => 'Tap to start — then just talk';

  @override
  String get voicePaused => 'Paused — tap to resume';

  @override
  String get voiceProcessing => '🔵 Processing';

  @override
  String get voiceResponding => '🟣 Responding';

  @override
  String get voiceListening => '🟢 Listening';

  @override
  String get voiceAnsweredByAI => '✨ Answered by AI';

  @override
  String get voiceBasicMode => '⚙️ Basic commands';

  @override
  String get voiceTypeHint => 'Or type your command here...';

  @override
  String get voiceExecute => 'Run command';

  @override
  String get voiceAvailableCommands => 'Available commands:';

  @override
  String get voiceMicUnavailable =>
      'Microphone not available in this browser. Use the text field below.';

  @override
  String get loginSubtitle => 'Sign in to continue';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get invalidEmail => 'Invalid email';

  @override
  String get minChars => 'Minimum 6 characters';

  @override
  String get rememberCredentials => 'Remember email and password';

  @override
  String get loginButton => 'Sign in';

  @override
  String get noAccount => 'Don\'t have an account? ';

  @override
  String get registerLink => 'Sign up';

  @override
  String get registerTitle => 'Create account';

  @override
  String get nameLabel => 'Your name';

  @override
  String get nameRequired => 'Please enter your name';

  @override
  String get registerButton => 'Create account';

  @override
  String get tagline => 'Your day, your way.';

  @override
  String get verseScreenTitle => 'Verse of the Day';

  @override
  String get verseTodayLabel => 'Today\'s verse';

  @override
  String get verseSaveButton => 'Save';

  @override
  String get verseSavedLabel => 'Saved';

  @override
  String get verseFavoritesTitle => 'Favorites';

  @override
  String get trashTitle => 'Trash';

  @override
  String get trashEmptyButton => 'Empty';

  @override
  String get trashEmptyTitle => 'Empty Trash';

  @override
  String get trashEmptyMsg =>
      'All items will be permanently deleted. This action cannot be undone.';

  @override
  String get trashNoTasks => 'No tasks in trash';

  @override
  String get trashNoAppts => 'No events in trash';

  @override
  String get trashNoNotes => 'No notes in trash';

  @override
  String get trashDeleteTitle => 'Delete permanently';

  @override
  String trashDeleteMsg(String name) {
    return '\"$name\" will be permanently deleted. This action cannot be undone.';
  }

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionReschedule => 'Reschedule';

  @override
  String get actionHide => 'Hide';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionRestore => 'Restore';

  @override
  String get statusOverdue => 'Overdue';

  @override
  String get statusToday => 'Today';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusOverdueTask => 'OVERDUE';
}
