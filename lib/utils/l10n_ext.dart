import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

export '../l10n/app_localizations.dart';

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

extension L10nPriority on AppLocalizations {
  String priorityLabel(String code) {
    switch (code.toLowerCase()) {
      case 'h':
        return priorityHigh;
      case 'm':
        return priorityMedium;
      default:
        return priorityLow;
    }
  }

  String statusLabel(String status) {
    switch (status) {
      case 'atrasado':
        return statusOverdue;
      case 'hoje':
        return statusToday;
      case 'confirmado':
        return statusConfirmed;
      default:
        return statusPending;
    }
  }
}
