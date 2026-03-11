// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appName => 'Sossoldi';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get transactions => 'Transacties';

  @override
  String get planning => 'Planning';

  @override
  String get graphs => 'Grafieken';

  @override
  String get list => 'Lijst';

  @override
  String get categories => 'Categorieën';

  @override
  String get expenses => 'Uitgaven';

  @override
  String get incomes => 'Inkomsten';

  @override
  String get expense => 'Uitgave';

  @override
  String get income => 'Inkomst';

  @override
  String get transfer => 'Overboeking';

  @override
  String get accounts => 'Rekeningen';

  @override
  String get details => 'Details';

  @override
  String get account => 'Rekening';

  @override
  String get category => 'Categorie';

  @override
  String get date => 'Datum';

  @override
  String get investments => 'Investeringen';

  @override
  String get settings => 'Instellingen';

  @override
  String get notifications => 'Meldingen';

  @override
  String get settingsDisclaimer => 'Open source, gebouwd door de community';

  @override
  String get addTransaction => 'Transactie toevoegen';

  @override
  String get totalBalance => 'Totaal saldo';

  @override
  String get netWorth => 'Nettowaarde';

  @override
  String get save => 'Opslaan';

  @override
  String get cancel => 'Annuleren';

  @override
  String get success => 'Succes';

  @override
  String get ok => 'Ok';

  @override
  String get editingTransaction => 'Transactie bewerken';

  @override
  String get newTransaction => 'Nieuwe transactie';

  @override
  String get updateTransaction => 'Transactie bijwerken';

  @override
  String get recurringPayments => 'Terugkerende betalingen';

  @override
  String get interval => 'Interval';

  @override
  String get endRepetition => 'Einde herhaling';

  @override
  String get never => 'Nooit';

  @override
  String get onADate => 'Op een datum';

  @override
  String get switchDisabled => 'Schakelaar is uitgeschakeld';

  @override
  String get recurringTransactionWarning =>
      'Dit is een transactie gegenereerd door een terugkerende: elke wijziging heeft alleen invloed op deze unieke transactie.\nOm alle toekomstige transacties of herhalingsopties te wijzigen, TIK HIER.';

  @override
  String saveCsvFileFailed(Object e) {
    return 'Kan het bestand hier niet opslaan, kies een map in Downloads of Documenten. Fout: $e';
  }

  @override
  String errorPickingFile(Object error) {
    return 'Fout bij selecteren bestand. Controleer of je voldoende rechten hebt. Fout: $error';
  }

  @override
  String get storagePermissionRequired =>
      'Opslagtoegang is vereist om je bestanden te openen.';

  @override
  String get importingData => 'Gegevens importeren...';

  @override
  String get exportingData => 'Gegevens exporteren...';

  @override
  String fileSavedTo(Object path) {
    return 'Bestand opgeslagen in: $path';
  }

  @override
  String get dataImportedSuccessfully => 'Gegevens succesvol geïmporteerd';

  @override
  String get description => 'Beschrijving';

  @override
  String get addDescription => 'Beschrijving toevoegen';

  @override
  String get duplicateTransactionTitle => 'Transactie dupliceren';

  @override
  String get duplicateTransactionContent =>
      'Deze transactie staat al in de lijst. Wil je deze dupliceren? Je kunt de nieuwe transactie daarna bewerken.';

  @override
  String get duplicate => 'Dupliceren';

  @override
  String get moreFrequent => 'Vaker';

  @override
  String get allCategories => 'Alle categorieën';

  @override
  String get allAccounts => 'Alle rekeningen';

  @override
  String errorOccurred(Object err) {
    return 'Fout: $err';
  }

  @override
  String get selectAccount => 'Selecteer rekening';

  @override
  String get to => 'Naar:';

  @override
  String get from => 'Van:';

  @override
  String get recurringTransactionAdded => 'Terugkerende transactie toegevoegd';

  @override
  String get recurringTransactions => 'Terugkerende transacties';

  @override
  String get addTransactionReminder => 'Herinnering transactie toevoegen';

  @override
  String get privacyPolicyTitle => 'Privacybeleid';

  @override
  String get privacyCollectTitle => 'Welke informatie verzamelen we?';

  @override
  String get privacyChangesTitle => 'Wijzigingen in dit privacybeleid';

  @override
  String get contactUsTitle => 'Contact';

  @override
  String get privacyIntro =>
      'Sossoldi is gebouwd als een open source app. Deze service wordt kosteloos aangeboden en is bedoeld voor gebruik zoals het is.\nWe zijn niet geïnteresseerd in het verzamelen van persoonlijke informatie. Wij geloven dat deze informatie van jou is en van jou alleen. We slaan je persoonlijke gegevens niet op, verzenden ze niet en gebruiken geen advertentie- of analyse-software van derden.\n';

  @override
  String get privacyCollectBody =>
      'Sossoldi verzamelt geen persoonlijke informatie en maakt geen verbinding met het internet. Alle informatie die je toevoegt, blijft uitsluitend op je apparaat.\n';

  @override
  String get privacyChangesBody =>
      'We kunnen ons privacybeleid van tijd tot tijd bijwerken. We raden je aan deze pagina regelmatig te controleren op wijzigingen.\nDit beleid is effectief vanaf 2024-01-01.\n';

  @override
  String get contactUsBody =>
      'Als je vragen of suggesties hebt over ons privacybeleid, neem dan contact met ons op via \n';

  @override
  String get collaboratorsTitle => 'Medewerkers';

  @override
  String get meetTheTeam => 'Ontmoet het team';

  @override
  String get teamDescription =>
      'Sossoldi wordt gebouwd en onderhouden door een gepassioneerde open source community. Elke functie en fix komt van mensen zoals jij.';

  @override
  String get wantToContribute => 'Wil je bijdragen?';

  @override
  String get contributeDescription =>
      'Open een issue, stuur een PR of zeg hallo op GitHub';

  @override
  String get appInfo => 'App Info';

  @override
  String get appVersion => 'App Versie:';

  @override
  String get collaborators => 'Medewerkers';

  @override
  String get collaboratorsDescription => 'Zie het team achter deze app';

  @override
  String get privacyPolicy => 'Privacybeleid';

  @override
  String get privacyPolicyDescription => 'Lees meer';

  @override
  String get generalSettings => 'Algemene instellingen';

  @override
  String get appearance => 'Uiterlijk';

  @override
  String get currency => 'Valuta';

  @override
  String get requireAuthentication => 'Authenticatie vereist';

  @override
  String get searchForATransaction => 'Zoek naar een transactie';

  @override
  String get selectACurrency => 'Selecteer een valuta';

  @override
  String get search => 'Zoeken';

  @override
  String get searchIn => 'Zoeken in';

  @override
  String get lastTransactions => 'Je laatste transacties';

  @override
  String get startReconciliation => 'Start aansluiting';

  @override
  String get newBalance => 'Nieuw saldo';

  @override
  String get balanceDiscrepancy => 'Saldo afwijking?';

  @override
  String get balanceAdjustmentHint =>
      'Je geregistreerde saldo kan afwijken van je bankafschrift. Tik hieronder om je saldo handmatig aan te passen.';

  @override
  String get newAccount => 'Nieuwe rekening';

  @override
  String get editAccount => 'Rekening bewerken';

  @override
  String get createAccount => 'Rekening maken';

  @override
  String get accountName => 'Rekeningnaam';

  @override
  String get name => 'Naam';

  @override
  String get iconAndColor => 'Icoon en kleur';

  @override
  String get chooseColor => 'Kies kleur';

  @override
  String get chooseIcon => 'Kies icoon';

  @override
  String get done => 'Gereed';

  @override
  String get add => 'Toevoegen';

  @override
  String get setAsMainAccount => 'Instellen als hoofdrekening';

  @override
  String get countsForNetWorth => 'Telt mee voor nettowaarde';

  @override
  String get deleteAccount => 'Rekening verwijderen';

  @override
  String get initialBalance => 'Beginsaldo';

  @override
  String get currentBalance => 'Huidig saldo';

  @override
  String get showLess => 'Minder weergeven';

  @override
  String get showMore => 'Meer weergeven';

  @override
  String get addSubcategory => 'Subcategorie toevoegen';

  @override
  String get newCategory => 'Nieuwe categorie';

  @override
  String get editCategory => 'Categorie bewerken';

  @override
  String get createCategory => 'Categorie maken';

  @override
  String get updateCategory => 'Categorie bijwerken';

  @override
  String get categoryName => 'Categorienaam';

  @override
  String get type => 'Type';

  @override
  String get deleteCategory => 'Categorie verwijderen';

  @override
  String get newSubcategory => 'Nieuwe subcategorie';

  @override
  String get editSubcategory => 'Subcategorie bewerken';

  @override
  String get createSubcategory => 'Subcategorie maken';

  @override
  String get updateSubcategory => 'Subcategorie bijwerken';

  @override
  String get subcategoryName => 'Naam subcategorie';

  @override
  String get deleteSubcategory => 'Subcategorie verwijderen';

  @override
  String get subcategory => 'Subcategorie';

  @override
  String get categoryFirstThenBudget =>
      'Voeg eerst een categorie toe om een budget in te stellen';

  @override
  String inTheNextDays(Object next) {
    return 'Over $next dagen';
  }

  @override
  String get monthlyBudget => 'Maandelijks budget';

  @override
  String get manage => 'Beheren';

  @override
  String get swipeLeftToDelete => 'Veeg naar links om te verwijderen';

  @override
  String get yourMonthlyBudgetWillBe => 'Je maandelijkse budget wordt:';

  @override
  String get saveBudget => 'Budget opslaan';

  @override
  String get selectCategoriesToCreateBudget =>
      'Selecteer categorieën voor je budget';

  @override
  String get amount => 'Bedrag';

  @override
  String get addCategoryBudget => 'Categoriebudget toevoegen';

  @override
  String get allCategoriesAdded =>
      'Je hebt alle beschikbare categorieën al toegevoegd.';

  @override
  String get delete => 'Verwijderen';

  @override
  String get allRecurringPaymentsHere =>
      'Alle terugkerende betalingen worden hier getoond';

  @override
  String get addRecurringPayment => 'Terugkerende betaling toevoegen';

  @override
  String get seeOlderPayments => 'Bekijk oudere betalingen';

  @override
  String untilDate(Object date) {
    return 'Tot $date';
  }

  @override
  String get olderPayments => 'Oudere betalingen';

  @override
  String get categoryNotFound => 'Categorie niet gevonden';

  @override
  String get back => 'Terug';

  @override
  String onTheDay(Object day) {
    return '- Op de ${day}e dag';
  }

  @override
  String get noMonthlyPaymentHistory =>
      'Geen maandelijkse betalingsgeschiedenis';

  @override
  String get noRecurrentPaymentHistory =>
      'Geen terugkerende betalingsgeschiedenis';

  @override
  String errorLoadingPayments(Object error) {
    return 'Fout bij laden betalingen: $error';
  }

  @override
  String get editRecurringTransaction => 'Terugkerende transactie bewerken';

  @override
  String get detailsExplanation =>
      'Details (wijzigingen gelden alleen voor toekomstige transacties)';

  @override
  String get dateStart => 'Startdatum';

  @override
  String get planned => 'Gepland';

  @override
  String get composition => 'Samenstelling';

  @override
  String get progress => 'Voortgang';

  @override
  String get noBudgetSet => 'Geen budgetten ingesteld';

  @override
  String get budgetHelpText =>
      'Een budget helpt je om je uitgaven onder controle te houden';

  @override
  String get createBudget => 'Budget maken';

  @override
  String get setUpTheApp => 'App instellen';

  @override
  String get setupDescription =>
      'In een paar stappen ben je klaar om je financiën bij te houden (bijna) zoals Mr. Rip.';

  @override
  String get startTheSetup => 'Start de installatie';

  @override
  String budgetAmount(Object amount) {
    return 'Budget $amount€';
  }

  @override
  String get addBudget => 'Budget toevoegen';

  @override
  String addBudgetForCategory(Object cat) {
    return 'Budget voor categorie $cat toevoegen';
  }

  @override
  String get addCategory => 'Categorie toevoegen';

  @override
  String get confirm => 'Bevestigen';

  @override
  String get step1Of2 => 'Stap 1 van 2';

  @override
  String get setupMonthlyBudgets => 'Stel je maandelijkse budgetten in';

  @override
  String get chooseCategoriesForBudget => 'Kies categorieën voor je budget';

  @override
  String get monthlyBudgetTotal => 'Totaal maandelijks budget:';

  @override
  String get nextStep => 'Volgende stap';

  @override
  String get continueWithoutBudget => 'Doorgaan zonder budget';

  @override
  String get step2Of2 => 'Stap 2 van 2';

  @override
  String get setLiquidityInMainAccount => 'Stel saldo in op hoofdrekening';

  @override
  String get addMoreAccounts => 'Je kunt later meer rekeningen toevoegen.';

  @override
  String get liquidityDescription =>
      'Dit wordt gebruikt als basis voor inkomsten, uitgaven en vermogen.';

  @override
  String get mainAccount => 'Hoofdrekening';

  @override
  String get setAmount => 'Bedrag instellen';

  @override
  String get editIconAndColor => 'Icoon en kleur bewerken';

  @override
  String get skipStepOrStartFromZero => 'Of sla over en begin bij 0';

  @override
  String get startTrackingExpenses => 'Begin met uitgaven bijhouden';

  @override
  String get startFromZero => 'Begin bij 0';

  @override
  String get importExport => 'Import/Export';

  @override
  String get importData => 'Gegevens importeren';

  @override
  String get importDataDescription => 'Importeer CSV om database bij te werken';

  @override
  String get importMoneyManager => 'Importeer van Money Manager';

  @override
  String get importMoneyManagerDescription =>
      'Importeer CSV van Money Manager (opgeslagen als CSV vanuit XLS).';

  @override
  String get exportData => 'Gegevens exporteren';

  @override
  String get exportDataDescription => 'Sla gegevens op als CSV-bestand';

  @override
  String get warningOverwrite => 'Waarschuwing: Overschrijven gegevens';

  @override
  String get warningOverwriteContent =>
      'Importeren vervangt permanent je huidige gegevens. Maak eerst een back-up.';

  @override
  String get proceedImport => 'Doorgaan met importeren';

  @override
  String get importSuccess => 'Gegevens succesvol geïmporteerd';

  @override
  String exportFailed(Object err) {
    return 'Export mislukt: $err';
  }

  @override
  String errorExporting(Object tableName) {
    return 'Tabel exporteren mislukt: $tableName';
  }

  @override
  String get errorCsvNotFound => 'CSV-bestand niet gevonden.';

  @override
  String get errorCsvEmpty => 'CSV-bestand is leeg.';

  @override
  String errorCsvExpectedColumn(Object column) {
    return 'Verwachte kolom mist: $column';
  }

  @override
  String errorCsvUnexpectedValue(Object value) {
    return 'Onverwachte waarde gevonden: $value';
  }

  @override
  String errorCsvImportGeneral(Object error) {
    return 'Algemene fout bij CSV-import: $error';
  }

  @override
  String errorCsvTransactionImport(Object date) {
    return 'Import transactie mislukt op: $date';
  }

  @override
  String errorCleanDatabase(Object error) {
    return 'Database opschonen mislukt: $error';
  }

  @override
  String errorResetDatabase(Object error) {
    return 'Database reset mislukt: $error';
  }

  @override
  String transactionCount(Object count) {
    return '$count transacties';
  }

  @override
  String get uncategorized => 'Niet gecategoriseerd';

  @override
  String get noIncomesForSelectedMonth => 'Geen inkomsten voor deze maand';

  @override
  String get noExpensesForSelectedMonth => 'Geen uitgaven voor deze maand';

  @override
  String get total => 'Totaal';

  @override
  String get noTransactionsAdded => 'Nog geen transacties toegevoegd';

  @override
  String get addTransactionCallToAction =>
      'Voeg een transactie toe om dit overzicht te vullen';

  @override
  String get graphsEmptyState =>
      'Na het toevoegen van transacties verschijnen hier grafieken... als bij toverslag!';

  @override
  String get availableLiquidity => 'Beschikbare liquiditeit';

  @override
  String get vsLastMonth => 't.o.v. vorige maand';

  @override
  String get monthlyBalance => 'Maandelijks saldo';

  @override
  String get currentMonth => 'Huidige maand';

  @override
  String get lastMonth => 'Vorige maand';

  @override
  String get yourAccounts => 'Je rekeningen';

  @override
  String get yourBudgets => 'Je budgetten';

  @override
  String get createBudgetToTrack => 'Maak een budget om je uitgaven te volgen';

  @override
  String get close => 'Sluiten';

  @override
  String get edit => 'Bewerken';

  @override
  String get errorDuplicatingTransaction => 'Fout bij dupliceren transactie';

  @override
  String transactionCreated(Object transaction) {
    return '\"$transaction\" is aangemaakt';
  }

  @override
  String get left => 'Over';

  @override
  String get notEnoughDataForGraph => 'Niet genoeg data voor de grafiek...';

  @override
  String get generalSettingsDesc => 'Bewerk algemene instellingen';

  @override
  String get accountsDesc => 'Accounts toevoegen of bewerken';

  @override
  String get categoriesDesc => 'Categorieën en subcategorieën beheren';

  @override
  String get budget => 'Budget';

  @override
  String get budgetDesc => 'Budgetten toevoegen of bewerken';

  @override
  String get importExportDesc => 'Gegevens importeren of exporteren';

  @override
  String get notificationsDesc => 'Meldingen beheren';

  @override
  String get leaveFeedback => 'Feedback geven';

  @override
  String get leaveFeedbackDesc => 'Meld een bug of geef feedback';

  @override
  String get appInfoDesc => 'Meer over ons en de app';
}
