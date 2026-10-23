import '../l10n/app_localizations.dart';
import '../model/recurring_transaction.dart';
import '../providers/settings_provider.dart';

extension RecurrenceLabel on Recurrence {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    Recurrence.daily => l10n.recurrenceDaily,
    Recurrence.weekly => l10n.recurrenceWeekly,
    Recurrence.monthly => l10n.recurrenceMonthly,
    Recurrence.bimonthly => l10n.recurrenceBimonthly,
    Recurrence.quarterly => l10n.recurrenceQuarterly,
    Recurrence.semester => l10n.recurrenceSemester,
    Recurrence.annual => l10n.recurrenceAnnual,
  };
}

extension NotificationReminderTypeLabel on NotificationReminderType {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    NotificationReminderType.none => l10n.never,
    NotificationReminderType.daily => l10n.recurrenceDaily,
    NotificationReminderType.weekly => l10n.recurrenceWeekly,
    NotificationReminderType.monthly => l10n.recurrenceMonthly,
  };
}
