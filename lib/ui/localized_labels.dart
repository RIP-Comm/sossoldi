import '../l10n/app_localizations.dart';
import '../model/category_transaction.dart';
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

extension CategoryTransactionTypeLabel on CategoryTransactionType {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    CategoryTransactionType.income => l10n.income,
    CategoryTransactionType.expense => l10n.expense,
    CategoryTransactionType.incomeAndExpense => l10n.incomeAndExpense,
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
