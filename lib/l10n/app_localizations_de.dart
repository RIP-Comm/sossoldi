// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Sossoldi';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get transactions => 'Transaktionen';

  @override
  String get planning => 'Planung';

  @override
  String get graphs => 'Grafiken';

  @override
  String get list => 'Liste';

  @override
  String get categories => 'Kategorien';

  @override
  String get expenses => 'Ausgaben';

  @override
  String get incomes => 'Einnahmen';

  @override
  String get expense => 'Ausgabe';

  @override
  String get income => 'Einnahme';

  @override
  String get transfer => 'Überweisung';

  @override
  String get accounts => 'Konten';

  @override
  String get details => 'Details';

  @override
  String get account => 'Konto';

  @override
  String get category => 'Kategorie';

  @override
  String get date => 'Datum';

  @override
  String get investments => 'Investitionen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get settingsDisclaimer => 'Open Source, von der Community entwickelt';

  @override
  String get addTransaction => 'Transaktion hinzufügen';

  @override
  String get totalBalance => 'Gesamtsaldo';

  @override
  String get netWorth => 'Nettovermögen';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get success => 'Erfolg';

  @override
  String get ok => 'Ok';

  @override
  String get editingTransaction => 'Transaktion bearbeiten';

  @override
  String get newTransaction => 'Neue Transaktion';

  @override
  String get updateTransaction => 'Transaktion aktualisieren';

  @override
  String get recurringPayments => 'Wiederkehrende Zahlungen';

  @override
  String get interval => 'Intervall';

  @override
  String get endRepetition => 'Wiederholung beenden';

  @override
  String get never => 'Nie';

  @override
  String get onADate => 'An einem Datum';

  @override
  String get switchDisabled => 'Schalter ist deaktiviert';

  @override
  String get recurringTransactionWarning =>
      'Dies ist eine von einer wiederkehrenden Transaktion generierte Buchung: Jede Änderung betrifft nur diese einzelne Transaktion.\nUm alle zukünftigen Transaktionen oder Wiederholungsoptionen zu ändern, HIER TIPPEN.';

  @override
  String saveCsvFileFailed(Object e) {
    return 'Datei kann hier nicht gespeichert werden. Bitte wählen Sie einen Ordner in Downloads oder Dokumente. Fehler: $e';
  }

  @override
  String errorPickingFile(Object error) {
    return 'Fehler beim Auswählen der Datei. Bitte stellen Sie sicher, dass Sie über ausreichende Berechtigungen verfügen. Fehler: $error';
  }

  @override
  String get storagePermissionRequired =>
      'Speicherberechtigung ist erforderlich, um auf Ihre Dateien zuzugreifen.';

  @override
  String get importingData => 'Daten werden importiert...';

  @override
  String get exportingData => 'Daten werden exportiert...';

  @override
  String fileSavedTo(Object path) {
    return 'Datei gespeichert unter: $path';
  }

  @override
  String get dataImportedSuccessfully => 'Daten erfolgreich importiert';

  @override
  String get description => 'Beschreibung';

  @override
  String get addDescription => 'Beschreibung hinzufügen';

  @override
  String get duplicateTransactionTitle => 'Transaktion duplizieren';

  @override
  String get duplicateTransactionContent =>
      'Diese Transaktion ist bereits in der Liste. Möchten Sie sie duplizieren? Sie können die neue Transaktion anschließend bearbeiten.';

  @override
  String get duplicate => 'Duplizieren';

  @override
  String get moreFrequent => 'Häufiger';

  @override
  String get allCategories => 'Alle Kategorien';

  @override
  String get allAccounts => 'Alle Konten';

  @override
  String errorOccurred(Object err) {
    return 'Fehler: $err';
  }

  @override
  String get selectAccount => 'Konto auswählen';

  @override
  String get to => 'An:';

  @override
  String get from => 'Von:';

  @override
  String get recurringTransactionAdded =>
      'Wiederkehrende Transaktion hinzugefügt';

  @override
  String get recurringTransactions => 'Wiederkehrende Transaktionen';

  @override
  String get addTransactionReminder => 'Transaktionserinnerung hinzufügen';

  @override
  String get privacyPolicyTitle => 'Datenschutzerklärung';

  @override
  String get privacyCollectTitle => 'Welche Informationen sammeln wir?';

  @override
  String get privacyChangesTitle => 'Änderungen an dieser Datenschutzerklärung';

  @override
  String get contactUsTitle => 'Kontaktieren Sie uns';

  @override
  String get privacyIntro =>
      'Sossoldi ist als Open-Source-App konzipiert. Dieser Dienst wird von uns kostenlos zur Verfügung gestellt und ist für die Nutzung im Ist-Zustand bestimmt.\nWir sind nicht daran interessiert, persönliche Informationen zu sammeln. Wir glauben, dass diese Informationen ausschließlich Ihnen gehören. Wir speichern oder übertragen Ihre persönlichen Daten nicht und binden keine Werbe- oder Analyse-Software ein, die mit Dritten kommuniziert.\n';

  @override
  String get privacyCollectBody =>
      'Sossoldi sammelt keine persönlichen Daten und verbindet sich nicht mit dem Internet. Alle Informationen, die Sie in der App hinzufügen, existieren ausschließlich auf Ihrem Gerät und nirgendwo sonst.\n';

  @override
  String get privacyChangesBody =>
      'Wir können unsere Datenschutzerklärung von Zeit zu Zeit aktualisieren. Daher wird empfohlen, diese Seite regelmäßig auf Änderungen zu überprüfen.\nDiese Richtlinie ist gültig ab 2024-01-01.\n';

  @override
  String get contactUsBody =>
      'Wenn Sie Fragen oder Anregungen zu unserer Datenschutzerklärung haben, zögern Sie nicht, uns zu kontaktieren unter \n';

  @override
  String get collaboratorsTitle => 'Mitwirkende';

  @override
  String get meetTheTeam => 'Das Team';

  @override
  String get teamDescription =>
      'Sossoldi wird von einer leidenschaftlichen Open-Source-Community entwickelt und gepflegt. Jede Funktion, jeder Fix und jede Idee kommt von Menschen wie Ihnen.';

  @override
  String get wantToContribute => 'Möchten Sie mitwirken?';

  @override
  String get contributeDescription =>
      'Öffnen Sie ein Issue, senden Sie einen PR oder sagen Sie einfach Hallo auf GitHub';

  @override
  String get appInfo => 'App-Info';

  @override
  String get appVersion => 'App-Version:';

  @override
  String get collaborators => 'Mitwirkende';

  @override
  String get collaboratorsDescription =>
      'Sehen Sie sich das Team hinter dieser App an';

  @override
  String get privacyPolicy => 'Datenschutzerklärung';

  @override
  String get privacyPolicyDescription => 'Mehr lesen';

  @override
  String get generalSettings => 'Allgemeine Einstellungen';

  @override
  String get appearance => 'Erscheinungsbild';

  @override
  String get currency => 'Währung';

  @override
  String get requireAuthentication => 'Authentifizierung anfordern';

  @override
  String get searchForATransaction => 'Nach einer Transaktion suchen';

  @override
  String get selectACurrency => 'Währung auswählen';

  @override
  String get search => 'Suche';

  @override
  String get searchIn => 'Suchen in';

  @override
  String get lastTransactions => 'Ihre letzten Transaktionen';

  @override
  String get startReconciliation => 'Abgleich starten';

  @override
  String get newBalance => 'Neuer Kontostand';

  @override
  String get balanceDiscrepancy => 'Saldo-Diskrepanz?';

  @override
  String get balanceAdjustmentHint =>
      'Ihr erfasster Saldo kann von Ihrem Bankbeleg abweichen. Tippen Sie unten, um Ihren Saldo manuell anzupassen.';

  @override
  String get newAccount => 'Neues Konto';

  @override
  String get editAccount => 'Konto bearbeiten';

  @override
  String get createAccount => 'Konto erstellen';

  @override
  String get accountName => 'Kontoname';

  @override
  String get name => 'Name';

  @override
  String get iconAndColor => 'Symbol und Farbe';

  @override
  String get chooseColor => 'Farbe wählen';

  @override
  String get chooseIcon => 'Symbol wählen';

  @override
  String get done => 'Fertig';

  @override
  String get add => 'Hinzufügen';

  @override
  String get setAsMainAccount => 'Als Hauptkonto festlegen';

  @override
  String get countsForNetWorth => 'Zählt für das Nettovermögen';

  @override
  String get deleteAccount => 'Konto löschen';

  @override
  String get initialBalance => 'Anfangssaldo';

  @override
  String get currentBalance => 'Aktueller Saldo';

  @override
  String get showLess => 'Weniger anzeigen';

  @override
  String get showMore => 'Mehr anzeigen';

  @override
  String get addSubcategory => 'Unterkategorie hinzufügen';

  @override
  String get newCategory => 'Neue Kategorie';

  @override
  String get editCategory => 'Kategorie bearbeiten';

  @override
  String get createCategory => 'Kategorie erstellen';

  @override
  String get updateCategory => 'Kategorie aktualisieren';

  @override
  String get categoryName => 'Kategoriename';

  @override
  String get type => 'Typ';

  @override
  String get deleteCategory => 'Kategorie löschen';

  @override
  String get newSubcategory => 'Neue Unterkategorie';

  @override
  String get editSubcategory => 'Unterkategorie bearbeiten';

  @override
  String get createSubcategory => 'Unterkategorie erstellen';

  @override
  String get updateSubcategory => 'Unterkategorie aktualisieren';

  @override
  String get subcategoryName => 'Name der Unterkategorie';

  @override
  String get deleteSubcategory => 'Unterkategorie löschen';

  @override
  String get subcategory => 'Unterkategorie';

  @override
  String get categoryFirstThenBudget =>
      'Fügen Sie zuerst eine Kategorie hinzu, um ein Budget festzulegen';

  @override
  String inTheNextDays(Object next) {
    return 'In $next Tagen';
  }

  @override
  String get monthlyBudget => 'Monatsbudget';

  @override
  String get manage => 'Verwalten';

  @override
  String get swipeLeftToDelete => 'Nach links wischen zum Löschen';

  @override
  String get yourMonthlyBudgetWillBe => 'Ihr monatliches Budget beträgt:';

  @override
  String get saveBudget => 'Budget speichern';

  @override
  String get selectCategoriesToCreateBudget =>
      'Wählen Sie Kategorien aus, um Ihr Budget zu erstellen';

  @override
  String get amount => 'Betrag';

  @override
  String get addCategoryBudget => 'Kategoriebudget hinzufügen';

  @override
  String get allCategoriesAdded =>
      'Sie haben bereits alle verfügbaren Kategorien hinzugefügt.';

  @override
  String get delete => 'Löschen';

  @override
  String get allRecurringPaymentsHere =>
      'Alle wiederkehrenden Zahlungen werden hier angezeigt';

  @override
  String get addRecurringPayment => 'Wiederkehrende Zahlung hinzufügen';

  @override
  String get seeOlderPayments => 'Ältere Zahlungen ansehen';

  @override
  String untilDate(Object date) {
    return 'Bis $date';
  }

  @override
  String get olderPayments => 'Ältere Zahlungen';

  @override
  String get categoryNotFound => 'Kategorie nicht gefunden';

  @override
  String get back => 'Zurück';

  @override
  String onTheDay(Object day) {
    return '- Am $day. Tag';
  }

  @override
  String get noMonthlyPaymentHistory => 'Kein monatlicher Zahlungsverlauf';

  @override
  String get noRecurrentPaymentHistory =>
      'Kein wiederkehrender Zahlungsverlauf';

  @override
  String errorLoadingPayments(Object error) {
    return 'Fehler beim Laden der Zahlungen: $error';
  }

  @override
  String get editRecurringTransaction =>
      'Wiederkehrende Transaktion bearbeiten';

  @override
  String get detailsExplanation =>
      'Details (Änderungen betreffen nur zukünftige Transaktionen)';

  @override
  String get dateStart => 'Startdatum';

  @override
  String get planned => 'Geplant';

  @override
  String get composition => 'Zusammensetzung';

  @override
  String get progress => 'Fortschritt';

  @override
  String get noBudgetSet => 'Es sind keine Budgets festgelegt';

  @override
  String get budgetHelpText =>
      'Ein monatliches Budget hilft Ihnen, Ihre Ausgaben im Blick zu behalten';

  @override
  String get createBudget => 'Budget erstellen';

  @override
  String get setUpTheApp => 'App einrichten';

  @override
  String get setupDescription =>
      'In wenigen Schritten können Sie Ihre Finanzen (fast) wie Mr. Rip verwalten.';

  @override
  String get startTheSetup => 'Setup starten';

  @override
  String budgetAmount(Object amount) {
    return 'Budget $amount€';
  }

  @override
  String get addBudget => 'Budget hinzufügen';

  @override
  String addBudgetForCategory(Object cat) {
    return 'Budget für Kategorie $cat hinzufügen';
  }

  @override
  String get addCategory => 'Kategorie hinzufügen';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get step1Of2 => 'Schritt 1 von 2';

  @override
  String get setupMonthlyBudgets => 'Richten Sie Ihre monatlichen Budgets ein';

  @override
  String get chooseCategoriesForBudget =>
      'Wählen Sie Kategorien für das Budget aus';

  @override
  String get monthlyBudgetTotal => 'Gesamtbudget pro Monat:';

  @override
  String get nextStep => 'Nächster Schritt';

  @override
  String get continueWithoutBudget => 'Ohne Budget fortfahren';

  @override
  String get step2Of2 => 'Schritt 2 von 2';

  @override
  String get setLiquidityInMainAccount => 'Liquidität im Hauptkonto festlegen';

  @override
  String get addMoreAccounts => 'Sie können später weitere Konten hinzufügen.';

  @override
  String get liquidityDescription =>
      'Dies dient als Basis für Einnahmen, Ausgaben und Vermögensberechnung.';

  @override
  String get mainAccount => 'Hauptkonto';

  @override
  String get setAmount => 'Betrag festlegen';

  @override
  String get editIconAndColor => 'Symbol und Farbe bearbeiten';

  @override
  String get skipStepOrStartFromZero => 'Oder überspringen und bei 0 beginnen';

  @override
  String get startTrackingExpenses => 'Ausgaben tracken';

  @override
  String get startFromZero => 'Bei 0 beginnen';

  @override
  String get importExport => 'Import/Export';

  @override
  String get importData => 'Daten importieren';

  @override
  String get importDataDescription =>
      'CSV-Datei importieren, um Datenbank zu aktualisieren';

  @override
  String get importMoneyManager => 'Von Money Manager importieren';

  @override
  String get importMoneyManagerDescription =>
      'CSV von Money Manager importieren (als CSV aus XLS gespeichert).';

  @override
  String get exportData => 'Daten exportieren';

  @override
  String get exportDataDescription => 'Daten als CSV-Datei speichern';

  @override
  String get warningOverwrite => 'Warnung: Daten überschreiben';

  @override
  String get warningOverwriteContent =>
      'Das Importieren ersetzt alle vorhandenen Daten dauerhaft. Erstellen Sie vorher ein Backup.';

  @override
  String get proceedImport => 'Import fortsetzen';

  @override
  String get importSuccess => 'Daten erfolgreich importiert';

  @override
  String exportFailed(Object err) {
    return 'Export fehlgeschlagen: $err';
  }

  @override
  String errorExporting(Object tableName) {
    return 'Fehler beim Exportieren der Tabelle: $tableName';
  }

  @override
  String get errorCsvNotFound => 'CSV-Datei nicht gefunden.';

  @override
  String get errorCsvEmpty => 'Die CSV-Datei ist leer.';

  @override
  String errorCsvExpectedColumn(Object column) {
    return 'Erwartete Spalte fehlt: $column';
  }

  @override
  String errorCsvUnexpectedValue(Object value) {
    return 'Unerwarteter Wert gefunden: $value';
  }

  @override
  String errorCsvImportGeneral(Object error) {
    return 'Allgemeiner Fehler beim CSV-Import: $error';
  }

  @override
  String errorCsvTransactionImport(Object date) {
    return 'Fehler beim Import der Transaktion am: $date';
  }

  @override
  String errorCleanDatabase(Object error) {
    return 'Datenbankbereinigung fehlgeschlagen: $error';
  }

  @override
  String errorResetDatabase(Object error) {
    return 'Datenbank-Reset fehlgeschlagen: $error';
  }

  @override
  String transactionCount(Object count) {
    return '$count Transaktionen';
  }

  @override
  String get uncategorized => 'Nicht kategorisiert';

  @override
  String get noIncomesForSelectedMonth => 'Keine Einnahmen für diesen Monat';

  @override
  String get noExpensesForSelectedMonth => 'Keine Ausgaben für diesen Monat';

  @override
  String get total => 'Gesamt';

  @override
  String get noTransactionsAdded => 'Noch keine Transaktionen hinzugefügt';

  @override
  String get addTransactionCallToAction =>
      'Fügen Sie eine Transaktion hinzu, um diesen Bereich zu füllen';

  @override
  String get graphsEmptyState =>
      'Nach dem Hinzufügen von Transaktionen erscheinen hier Grafiken... wie von Zauberhand!';

  @override
  String get availableLiquidity => 'Verfügbare Liquidität';

  @override
  String get vsLastMonth => 'vs. letzter Monat';

  @override
  String get monthlyBalance => 'Monatssaldo';

  @override
  String get currentMonth => 'Aktueller Monat';

  @override
  String get lastMonth => 'Letzter Monat';

  @override
  String get yourAccounts => 'Ihre Konten';

  @override
  String get yourBudgets => 'Ihre Budgets';

  @override
  String get createBudgetToTrack =>
      'Budget erstellen, um Ausgaben zu verfolgen';

  @override
  String get close => 'Schließen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get errorDuplicatingTransaction =>
      'Fehler beim Duplizieren der Transaktion';

  @override
  String transactionCreated(Object transaction) {
    return '\"$transaction\" wurde erstellt';
  }

  @override
  String get left => 'Übrig';

  @override
  String get notEnoughDataForGraph =>
      'Nicht genügend Daten für die Grafik vorhanden...';

  @override
  String get generalSettingsDesc => 'Allgemeine Einstellungen bearbeiten';

  @override
  String get accountsDesc => 'Konten hinzufügen oder bearbeiten';

  @override
  String get categoriesDesc => 'Kategorien und Unterkategorien verwalten';

  @override
  String get budget => 'Budget';

  @override
  String get budgetDesc => 'Budgets hinzufügen oder bearbeiten';

  @override
  String get importExportDesc => 'Daten importieren oder exportieren';

  @override
  String get notificationsDesc => 'Benachrichtigungen verwalten';

  @override
  String get leaveFeedback => 'Feedback geben';

  @override
  String get leaveFeedbackDesc => 'Fehler melden oder Feedback hinterlassen';

  @override
  String get appInfoDesc => 'Mehr über uns und die App erfahren';
}
