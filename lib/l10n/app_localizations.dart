import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_it.dart';
import 'app_localizations_nl.dart';
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
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('it'),
    Locale('nl'),
    Locale('pt'),
  ];

  /// The name of the application
  ///
  /// In it, this message translates to:
  /// **'Sossoldi'**
  String get appName;

  /// No description provided for @dashboard.
  ///
  /// In it, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @transactions.
  ///
  /// In it, this message translates to:
  /// **'Transazioni'**
  String get transactions;

  /// No description provided for @planning.
  ///
  /// In it, this message translates to:
  /// **'Pianificazione'**
  String get planning;

  /// No description provided for @graphs.
  ///
  /// In it, this message translates to:
  /// **'Grafici'**
  String get graphs;

  /// No description provided for @list.
  ///
  /// In it, this message translates to:
  /// **'Lista'**
  String get list;

  /// No description provided for @categories.
  ///
  /// In it, this message translates to:
  /// **'Categorie'**
  String get categories;

  /// No description provided for @expenses.
  ///
  /// In it, this message translates to:
  /// **'Spese'**
  String get expenses;

  /// No description provided for @incomes.
  ///
  /// In it, this message translates to:
  /// **'Entrate'**
  String get incomes;

  /// No description provided for @expense.
  ///
  /// In it, this message translates to:
  /// **'Spesa'**
  String get expense;

  /// No description provided for @income.
  ///
  /// In it, this message translates to:
  /// **'Entrata'**
  String get income;

  /// No description provided for @transfer.
  ///
  /// In it, this message translates to:
  /// **'Spostamento'**
  String get transfer;

  /// No description provided for @accounts.
  ///
  /// In it, this message translates to:
  /// **'Conti'**
  String get accounts;

  /// No description provided for @details.
  ///
  /// In it, this message translates to:
  /// **'Dettagli'**
  String get details;

  /// No description provided for @account.
  ///
  /// In it, this message translates to:
  /// **'Conto'**
  String get account;

  /// No description provided for @category.
  ///
  /// In it, this message translates to:
  /// **'Categoria'**
  String get category;

  /// No description provided for @date.
  ///
  /// In it, this message translates to:
  /// **'Data'**
  String get date;

  /// No description provided for @investments.
  ///
  /// In it, this message translates to:
  /// **'Investimenti'**
  String get investments;

  /// No description provided for @settings.
  ///
  /// In it, this message translates to:
  /// **'Impostazioni'**
  String get settings;

  /// No description provided for @notifications.
  ///
  /// In it, this message translates to:
  /// **'Notifiche'**
  String get notifications;

  /// No description provided for @settingsDisclaimer.
  ///
  /// In it, this message translates to:
  /// **'Open source, sviluppata dalla community'**
  String get settingsDisclaimer;

  /// No description provided for @addTransaction.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi transazione'**
  String get addTransaction;

  /// No description provided for @totalBalance.
  ///
  /// In it, this message translates to:
  /// **'Saldo Totale'**
  String get totalBalance;

  /// No description provided for @netWorth.
  ///
  /// In it, this message translates to:
  /// **'Patrimonio Netto'**
  String get netWorth;

  /// No description provided for @save.
  ///
  /// In it, this message translates to:
  /// **'Salva'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In it, this message translates to:
  /// **'Annulla'**
  String get cancel;

  /// No description provided for @success.
  ///
  /// In it, this message translates to:
  /// **'Successo'**
  String get success;

  /// No description provided for @ok.
  ///
  /// In it, this message translates to:
  /// **'Ok'**
  String get ok;

  /// No description provided for @editingTransaction.
  ///
  /// In it, this message translates to:
  /// **'Modifica transazione'**
  String get editingTransaction;

  /// No description provided for @newTransaction.
  ///
  /// In it, this message translates to:
  /// **'Nuova transazione'**
  String get newTransaction;

  /// No description provided for @updateTransaction.
  ///
  /// In it, this message translates to:
  /// **'Modifica transazione'**
  String get updateTransaction;

  /// No description provided for @recurringPayments.
  ///
  /// In it, this message translates to:
  /// **'Pagamenti ricorrenti'**
  String get recurringPayments;

  /// No description provided for @interval.
  ///
  /// In it, this message translates to:
  /// **'Intervallo'**
  String get interval;

  /// No description provided for @endRepetition.
  ///
  /// In it, this message translates to:
  /// **'Fine ripetizione'**
  String get endRepetition;

  /// No description provided for @never.
  ///
  /// In it, this message translates to:
  /// **'Mai'**
  String get never;

  /// No description provided for @onADate.
  ///
  /// In it, this message translates to:
  /// **'In data'**
  String get onADate;

  /// No description provided for @switchDisabled.
  ///
  /// In it, this message translates to:
  /// **'Gesto disabilitato'**
  String get switchDisabled;

  /// No description provided for @recurringTransactionWarning.
  ///
  /// In it, this message translates to:
  /// **'Questa è una transazione generata da una ricorrente: qualsiasi modifica influenzerà questa transazione unica.\nPer modificare tutte le transazioni future, o le opzioni di ricorrenza, TAP QUI.'**
  String get recurringTransactionWarning;

  /// No description provided for @saveCsvFileFailed.
  ///
  /// In it, this message translates to:
  /// **'Non puoi salvare i file qui, crea o seleziona una cartella in Downloads o Documenti. Errore: \${e}'**
  String saveCsvFileFailed(Object e);

  /// No description provided for @errorPickingFile.
  ///
  /// In it, this message translates to:
  /// **'Errore durante la selezione del file. Assicurati di avere i permessi necessari. Errore: {error}'**
  String errorPickingFile(Object error);

  /// No description provided for @storagePermissionRequired.
  ///
  /// In it, this message translates to:
  /// **'È richiesto il permesso di archiviazione per accedere ai file.'**
  String get storagePermissionRequired;

  /// No description provided for @importingData.
  ///
  /// In it, this message translates to:
  /// **'Importazione dati in corso...'**
  String get importingData;

  /// No description provided for @exportingData.
  ///
  /// In it, this message translates to:
  /// **'Esportazione dati in corso...'**
  String get exportingData;

  /// No description provided for @fileSavedTo.
  ///
  /// In it, this message translates to:
  /// **'File salvato in: {path}'**
  String fileSavedTo(Object path);

  /// No description provided for @dataImportedSuccessfully.
  ///
  /// In it, this message translates to:
  /// **'Dati importati con successo'**
  String get dataImportedSuccessfully;

  /// No description provided for @description.
  ///
  /// In it, this message translates to:
  /// **'Descrizione'**
  String get description;

  /// No description provided for @addDescription.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi descrizione'**
  String get addDescription;

  /// No description provided for @duplicateTransactionTitle.
  ///
  /// In it, this message translates to:
  /// **'Transazione duplicata'**
  String get duplicateTransactionTitle;

  /// No description provided for @duplicateTransactionContent.
  ///
  /// In it, this message translates to:
  /// **'Questa transazione è già presente nella lista. Vuoi duplicarla? Potrai poi modificare il nuovo inserimento.'**
  String get duplicateTransactionContent;

  /// No description provided for @duplicate.
  ///
  /// In it, this message translates to:
  /// **'Duplica'**
  String get duplicate;

  /// No description provided for @moreFrequent.
  ///
  /// In it, this message translates to:
  /// **'Più frequente'**
  String get moreFrequent;

  /// No description provided for @allCategories.
  ///
  /// In it, this message translates to:
  /// **'Tutte le categorie'**
  String get allCategories;

  /// No description provided for @allAccounts.
  ///
  /// In it, this message translates to:
  /// **'Tutte i conti'**
  String get allAccounts;

  /// No description provided for @errorOccurred.
  ///
  /// In it, this message translates to:
  /// **'Errore: {err}'**
  String errorOccurred(Object err);

  /// No description provided for @selectAccount.
  ///
  /// In it, this message translates to:
  /// **'Seleziona conto'**
  String get selectAccount;

  /// No description provided for @to.
  ///
  /// In it, this message translates to:
  /// **'A:'**
  String get to;

  /// No description provided for @from.
  ///
  /// In it, this message translates to:
  /// **'Da:'**
  String get from;

  /// No description provided for @recurringTransactionAdded.
  ///
  /// In it, this message translates to:
  /// **'Transazione ricorrente aggiunta'**
  String get recurringTransactionAdded;

  /// No description provided for @recurringTransactions.
  ///
  /// In it, this message translates to:
  /// **'Transazioni ricorrenti'**
  String get recurringTransactions;

  /// No description provided for @addTransactionReminder.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi promemoria transazione'**
  String get addTransactionReminder;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In it, this message translates to:
  /// **'Politica Sulla Privacy'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyCollectTitle.
  ///
  /// In it, this message translates to:
  /// **'Quali informazioni raccogliamo?'**
  String get privacyCollectTitle;

  /// No description provided for @privacyChangesTitle.
  ///
  /// In it, this message translates to:
  /// **'Modifiche alla politica sulla privacy'**
  String get privacyChangesTitle;

  /// No description provided for @contactUsTitle.
  ///
  /// In it, this message translates to:
  /// **'Contattaci'**
  String get contactUsTitle;

  /// No description provided for @privacyIntro.
  ///
  /// In it, this message translates to:
  /// **'Sossoldi è sviluppata come app open source. Questo servizio è fornito gratuitamente ed è inteso per essere utilizzato così com\'è.\nNon siamo interessati a raccogliere alcuna informazione personale. Riteniamo che tali informazioni siano solo tue. Non memorizziamo né trasmettiamo i tuoi dettagli personali, né includiamo software di pubblicità o analisi che comunichino con terze parti.\n'**
  String get privacyIntro;

  /// No description provided for @privacyCollectBody.
  ///
  /// In it, this message translates to:
  /// **'Sossoldi non raccoglie alcuna informazione personale e non si connette a Internet. Qualsiasi informazione aggiunta nell\'app esiste esclusivamente sul tuo dispositivo e da nessun\'altra parte.\n'**
  String get privacyCollectBody;

  /// No description provided for @privacyChangesBody.
  ///
  /// In it, this message translates to:
  /// **'Potremmo aggiornare la nostra politica sulla privacy di tanto in tanto. Pertanto, ti consigliamo di rivedere periodicamente questa pagina per eventuali modifiche.\nQuesta politica è efficace dal 01-01-2024.\n'**
  String get privacyChangesBody;

  /// No description provided for @contactUsBody.
  ///
  /// In it, this message translates to:
  /// **'Se hai domande o suggerimenti sulla nostra politica sulla privacy, non esitare a contattarci all\'indirizzo\n'**
  String get contactUsBody;

  /// No description provided for @collaboratorsTitle.
  ///
  /// In it, this message translates to:
  /// **'Collaboratori'**
  String get collaboratorsTitle;

  /// No description provided for @meetTheTeam.
  ///
  /// In it, this message translates to:
  /// **'Incontra il team'**
  String get meetTheTeam;

  /// No description provided for @teamDescription.
  ///
  /// In it, this message translates to:
  /// **'Sossoldi è sviluppata e mantenuta da una appassionata community open source. Ogni funzione, correzione e idea arriva da persone come te.'**
  String get teamDescription;

  /// No description provided for @wantToContribute.
  ///
  /// In it, this message translates to:
  /// **'Vuoi contribuire?'**
  String get wantToContribute;

  /// No description provided for @contributeDescription.
  ///
  /// In it, this message translates to:
  /// **'Apri una issue, invia una PR o semplicemente saluta su GitHub'**
  String get contributeDescription;

  /// No description provided for @appInfo.
  ///
  /// In it, this message translates to:
  /// **'Informazioni app'**
  String get appInfo;

  /// No description provided for @appVersion.
  ///
  /// In it, this message translates to:
  /// **'Versione app:'**
  String get appVersion;

  /// No description provided for @collaborators.
  ///
  /// In it, this message translates to:
  /// **'Collaboratori'**
  String get collaborators;

  /// No description provided for @collaboratorsDescription.
  ///
  /// In it, this message translates to:
  /// **'Scopri il team dietro questa app'**
  String get collaboratorsDescription;

  /// No description provided for @privacyPolicy.
  ///
  /// In it, this message translates to:
  /// **'Politica Sulla Privacy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicyDescription.
  ///
  /// In it, this message translates to:
  /// **'Leggi di più'**
  String get privacyPolicyDescription;

  /// No description provided for @generalSettings.
  ///
  /// In it, this message translates to:
  /// **'Impostazioni generali'**
  String get generalSettings;

  /// No description provided for @appearance.
  ///
  /// In it, this message translates to:
  /// **'Aspetto'**
  String get appearance;

  /// No description provided for @currency.
  ///
  /// In it, this message translates to:
  /// **'Valuta'**
  String get currency;

  /// No description provided for @requireAuthentication.
  ///
  /// In it, this message translates to:
  /// **'Richiedi autenticazione'**
  String get requireAuthentication;

  /// No description provided for @searchForATransaction.
  ///
  /// In it, this message translates to:
  /// **'Cerca una transazione'**
  String get searchForATransaction;

  /// No description provided for @selectACurrency.
  ///
  /// In it, this message translates to:
  /// **'Seleziona una valuta'**
  String get selectACurrency;

  /// No description provided for @search.
  ///
  /// In it, this message translates to:
  /// **'Cerca'**
  String get search;

  /// No description provided for @searchIn.
  ///
  /// In it, this message translates to:
  /// **'Cerca in'**
  String get searchIn;

  /// No description provided for @lastTransactions.
  ///
  /// In it, this message translates to:
  /// **'Le tue ultime transazioni'**
  String get lastTransactions;

  /// No description provided for @startReconciliation.
  ///
  /// In it, this message translates to:
  /// **'Avvia riconciliazione'**
  String get startReconciliation;

  /// No description provided for @newBalance.
  ///
  /// In it, this message translates to:
  /// **'Nuovo saldo'**
  String get newBalance;

  /// No description provided for @balanceDiscrepancy.
  ///
  /// In it, this message translates to:
  /// **'Differenza di saldo?'**
  String get balanceDiscrepancy;

  /// No description provided for @balanceAdjustmentHint.
  ///
  /// In it, this message translates to:
  /// **'Il saldo registrato potrebbe differire dall\'estratto conto della tua banca. Tocca qui sotto per regolare manualmente il saldo e mantenere i tuoi registri aggiornati.'**
  String get balanceAdjustmentHint;

  /// No description provided for @newAccount.
  ///
  /// In it, this message translates to:
  /// **'Nuovo conto'**
  String get newAccount;

  /// No description provided for @editAccount.
  ///
  /// In it, this message translates to:
  /// **'Modifica conto'**
  String get editAccount;

  /// No description provided for @createAccount.
  ///
  /// In it, this message translates to:
  /// **'Crea conto'**
  String get createAccount;

  /// No description provided for @accountName.
  ///
  /// In it, this message translates to:
  /// **'Nome del conto'**
  String get accountName;

  /// No description provided for @name.
  ///
  /// In it, this message translates to:
  /// **'Nome'**
  String get name;

  /// No description provided for @iconAndColor.
  ///
  /// In it, this message translates to:
  /// **'Icona e colore'**
  String get iconAndColor;

  /// No description provided for @chooseColor.
  ///
  /// In it, this message translates to:
  /// **'Scegli colore'**
  String get chooseColor;

  /// No description provided for @chooseIcon.
  ///
  /// In it, this message translates to:
  /// **'Scegli icona'**
  String get chooseIcon;

  /// No description provided for @done.
  ///
  /// In it, this message translates to:
  /// **'Fatto'**
  String get done;

  /// No description provided for @add.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi'**
  String get add;

  /// No description provided for @setAsMainAccount.
  ///
  /// In it, this message translates to:
  /// **'Imposta come conto principale'**
  String get setAsMainAccount;

  /// No description provided for @countsForNetWorth.
  ///
  /// In it, this message translates to:
  /// **'Includi nel patrimonio netto'**
  String get countsForNetWorth;

  /// No description provided for @deleteAccount.
  ///
  /// In it, this message translates to:
  /// **'Elimina conto'**
  String get deleteAccount;

  /// No description provided for @initialBalance.
  ///
  /// In it, this message translates to:
  /// **'Saldo iniziale'**
  String get initialBalance;

  /// No description provided for @currentBalance.
  ///
  /// In it, this message translates to:
  /// **'Saldo attuale'**
  String get currentBalance;

  /// No description provided for @showLess.
  ///
  /// In it, this message translates to:
  /// **'Mostra meno'**
  String get showLess;

  /// No description provided for @showMore.
  ///
  /// In it, this message translates to:
  /// **'Mostra altro'**
  String get showMore;

  /// No description provided for @addSubcategory.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi sottocategoria'**
  String get addSubcategory;

  /// No description provided for @newCategory.
  ///
  /// In it, this message translates to:
  /// **'Nuova categoria'**
  String get newCategory;

  /// No description provided for @editCategory.
  ///
  /// In it, this message translates to:
  /// **'Modifica categoria'**
  String get editCategory;

  /// No description provided for @createCategory.
  ///
  /// In it, this message translates to:
  /// **'Crea categoria'**
  String get createCategory;

  /// No description provided for @updateCategory.
  ///
  /// In it, this message translates to:
  /// **'Aggiorna categoria'**
  String get updateCategory;

  /// No description provided for @categoryName.
  ///
  /// In it, this message translates to:
  /// **'Nome della categoria'**
  String get categoryName;

  /// No description provided for @type.
  ///
  /// In it, this message translates to:
  /// **'Tipo'**
  String get type;

  /// No description provided for @deleteCategory.
  ///
  /// In it, this message translates to:
  /// **'Elimina categoria'**
  String get deleteCategory;

  /// No description provided for @newSubcategory.
  ///
  /// In it, this message translates to:
  /// **'Nuova sottocategoria'**
  String get newSubcategory;

  /// No description provided for @editSubcategory.
  ///
  /// In it, this message translates to:
  /// **'Modifica sottocategoria'**
  String get editSubcategory;

  /// No description provided for @createSubcategory.
  ///
  /// In it, this message translates to:
  /// **'Crea sottocategoria'**
  String get createSubcategory;

  /// No description provided for @updateSubcategory.
  ///
  /// In it, this message translates to:
  /// **'Aggiorna sottocategoria'**
  String get updateSubcategory;

  /// No description provided for @subcategoryName.
  ///
  /// In it, this message translates to:
  /// **'Nome della sottocategoria'**
  String get subcategoryName;

  /// No description provided for @deleteSubcategory.
  ///
  /// In it, this message translates to:
  /// **'Elimina sottocategoria'**
  String get deleteSubcategory;

  /// No description provided for @subcategory.
  ///
  /// In it, this message translates to:
  /// **'Sottocagegoria'**
  String get subcategory;

  /// No description provided for @categoryFirstThenBudget.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi una categoria prima di creare un budget'**
  String get categoryFirstThenBudget;

  /// No description provided for @inTheNextDays.
  ///
  /// In it, this message translates to:
  /// **'In  {next} giorni'**
  String inTheNextDays(Object next);

  /// No description provided for @monthlyBudget.
  ///
  /// In it, this message translates to:
  /// **'Budget mensile'**
  String get monthlyBudget;

  /// No description provided for @manage.
  ///
  /// In it, this message translates to:
  /// **'Gestisci'**
  String get manage;

  /// No description provided for @swipeLeftToDelete.
  ///
  /// In it, this message translates to:
  /// **'Scorri a sinistra per eliminare'**
  String get swipeLeftToDelete;

  /// No description provided for @yourMonthlyBudgetWillBe.
  ///
  /// In it, this message translates to:
  /// **'Il tuo budget mensile sarà:'**
  String get yourMonthlyBudgetWillBe;

  /// No description provided for @saveBudget.
  ///
  /// In it, this message translates to:
  /// **'Salva budget'**
  String get saveBudget;

  /// No description provided for @selectCategoriesToCreateBudget.
  ///
  /// In it, this message translates to:
  /// **'Seleziona le categorie per creare il tuo budget'**
  String get selectCategoriesToCreateBudget;

  /// No description provided for @amount.
  ///
  /// In it, this message translates to:
  /// **'Importo'**
  String get amount;

  /// No description provided for @addCategoryBudget.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi budget categoria'**
  String get addCategoryBudget;

  /// No description provided for @allCategoriesAdded.
  ///
  /// In it, this message translates to:
  /// **'Hai già aggiunto tutte le categorie disponibili.'**
  String get allCategoriesAdded;

  /// No description provided for @delete.
  ///
  /// In it, this message translates to:
  /// **'Elimina'**
  String get delete;

  /// No description provided for @allRecurringPaymentsHere.
  ///
  /// In it, this message translates to:
  /// **'Tutti i pagamenti ricorrenti verranno visualizzati qui'**
  String get allRecurringPaymentsHere;

  /// No description provided for @addRecurringPayment.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi pagamento ricorrente'**
  String get addRecurringPayment;

  /// No description provided for @seeOlderPayments.
  ///
  /// In it, this message translates to:
  /// **'Vedi pagamenti passati'**
  String get seeOlderPayments;

  /// No description provided for @untilDate.
  ///
  /// In it, this message translates to:
  /// **'Fino al {date}'**
  String untilDate(Object date);

  /// No description provided for @olderPayments.
  ///
  /// In it, this message translates to:
  /// **'Pagamenti passati'**
  String get olderPayments;

  /// No description provided for @categoryNotFound.
  ///
  /// In it, this message translates to:
  /// **'Categoria non trovata'**
  String get categoryNotFound;

  /// No description provided for @back.
  ///
  /// In it, this message translates to:
  /// **'Indietro'**
  String get back;

  /// No description provided for @onTheDay.
  ///
  /// In it, this message translates to:
  /// **'- Il giorno {day}'**
  String onTheDay(Object day);

  /// No description provided for @noMonthlyPaymentHistory.
  ///
  /// In it, this message translates to:
  /// **'Nessuna cronologia pagamenti mensili'**
  String get noMonthlyPaymentHistory;

  /// No description provided for @noRecurrentPaymentHistory.
  ///
  /// In it, this message translates to:
  /// **'Nessuna cronologia pagamenti ricorrenti'**
  String get noRecurrentPaymentHistory;

  /// No description provided for @errorLoadingPayments.
  ///
  /// In it, this message translates to:
  /// **'Errore nel caricamento pagamenti: {error}'**
  String errorLoadingPayments(Object error);

  /// No description provided for @editRecurringTransaction.
  ///
  /// In it, this message translates to:
  /// **'Modifica transazione ricorrente'**
  String get editRecurringTransaction;

  /// No description provided for @detailsExplanation.
  ///
  /// In it, this message translates to:
  /// **'Dettagli (ogni modifica influenzerà solo le transazioni future)'**
  String get detailsExplanation;

  /// No description provided for @dateStart.
  ///
  /// In it, this message translates to:
  /// **'Data inizio'**
  String get dateStart;

  /// No description provided for @planned.
  ///
  /// In it, this message translates to:
  /// **'Pianificato'**
  String get planned;

  /// No description provided for @composition.
  ///
  /// In it, this message translates to:
  /// **'Composizione'**
  String get composition;

  /// No description provided for @progress.
  ///
  /// In it, this message translates to:
  /// **'Avanzamento'**
  String get progress;

  /// No description provided for @noBudgetSet.
  ///
  /// In it, this message translates to:
  /// **'Non ci sono budget impostati'**
  String get noBudgetSet;

  /// No description provided for @budgetHelpText.
  ///
  /// In it, this message translates to:
  /// **'Un budget mensile può aiutarti a tenere traccia delle tue spese e a rimanere entro i limiti'**
  String get budgetHelpText;

  /// No description provided for @createBudget.
  ///
  /// In it, this message translates to:
  /// **'Crea budget'**
  String get createBudget;

  /// No description provided for @setUpTheApp.
  ///
  /// In it, this message translates to:
  /// **'Configura l\'app'**
  String get setUpTheApp;

  /// No description provided for @setupDescription.
  ///
  /// In it, this message translates to:
  /// **'In pochi passaggi sarai pronto a iniziare a tenere\ntraccia delle tue finanze personali (quasi) come\nMr. Rip.'**
  String get setupDescription;

  /// No description provided for @startTheSetup.
  ///
  /// In it, this message translates to:
  /// **'Inizia la configurazione'**
  String get startTheSetup;

  /// No description provided for @budgetAmount.
  ///
  /// In it, this message translates to:
  /// **'Bilancio {amount}€'**
  String budgetAmount(Object amount);

  /// No description provided for @addBudget.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi budget'**
  String get addBudget;

  /// No description provided for @addBudgetForCategory.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi un budget per la categoria {cat}'**
  String addBudgetForCategory(Object cat);

  /// No description provided for @addCategory.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi categoria'**
  String get addCategory;

  /// No description provided for @confirm.
  ///
  /// In it, this message translates to:
  /// **'Conferma'**
  String get confirm;

  /// No description provided for @step1Of2.
  ///
  /// In it, this message translates to:
  /// **'Passaggio 1 di 2'**
  String get step1Of2;

  /// No description provided for @setupMonthlyBudgets.
  ///
  /// In it, this message translates to:
  /// **'Imposta i tuoi budget\nmensili'**
  String get setupMonthlyBudgets;

  /// No description provided for @chooseCategoriesForBudget.
  ///
  /// In it, this message translates to:
  /// **'Scegli le categorie per le quali vuoi impostare un budget'**
  String get chooseCategoriesForBudget;

  /// No description provided for @monthlyBudgetTotal.
  ///
  /// In it, this message translates to:
  /// **'Totale budget mensile:'**
  String get monthlyBudgetTotal;

  /// No description provided for @nextStep.
  ///
  /// In it, this message translates to:
  /// **'Passaggio successivo'**
  String get nextStep;

  /// No description provided for @continueWithoutBudget.
  ///
  /// In it, this message translates to:
  /// **'Continua senza budget'**
  String get continueWithoutBudget;

  /// No description provided for @step2Of2.
  ///
  /// In it, this message translates to:
  /// **'Passaggio 2 DI 2'**
  String get step2Of2;

  /// No description provided for @setLiquidityInMainAccount.
  ///
  /// In it, this message translates to:
  /// **'Imposta la liquidità nel tuo conto principale'**
  String get setLiquidityInMainAccount;

  /// No description provided for @addMoreAccounts.
  ///
  /// In it, this message translates to:
  /// **'Sarai in grado di aggiungere altri account dall\'app.'**
  String get addMoreAccounts;

  /// No description provided for @liquidityDescription.
  ///
  /// In it, this message translates to:
  /// **'Verrà utilizzata come base a cui aggiungere entrate, spese e calcolare il tuo patrimonio.\nPotrai aggiungere altri conti all\'interno dell\'app.'**
  String get liquidityDescription;

  /// No description provided for @mainAccount.
  ///
  /// In it, this message translates to:
  /// **'Conto principale'**
  String get mainAccount;

  /// No description provided for @setAmount.
  ///
  /// In it, this message translates to:
  /// **'Imposta importo'**
  String get setAmount;

  /// No description provided for @editIconAndColor.
  ///
  /// In it, this message translates to:
  /// **'Modifica icona e colore'**
  String get editIconAndColor;

  /// No description provided for @skipStepOrStartFromZero.
  ///
  /// In it, this message translates to:
  /// **'Oppure puoi saltare questo passaggio e iniziare da 0'**
  String get skipStepOrStartFromZero;

  /// No description provided for @startTrackingExpenses.
  ///
  /// In it, this message translates to:
  /// **'Inizia a tracciare le tue spese'**
  String get startTrackingExpenses;

  /// No description provided for @startFromZero.
  ///
  /// In it, this message translates to:
  /// **'Inizia da 0'**
  String get startFromZero;

  /// No description provided for @importExport.
  ///
  /// In it, this message translates to:
  /// **'Importa/Esporta'**
  String get importExport;

  /// No description provided for @importData.
  ///
  /// In it, this message translates to:
  /// **'Importa dati'**
  String get importData;

  /// No description provided for @importDataDescription.
  ///
  /// In it, this message translates to:
  /// **'Importa un file CSV per aggiornare il database'**
  String get importDataDescription;

  /// No description provided for @importMoneyManager.
  ///
  /// In it, this message translates to:
  /// **'Importa da Money Manager'**
  String get importMoneyManager;

  /// No description provided for @importMoneyManagerDescription.
  ///
  /// In it, this message translates to:
  /// **'Importa CSV da Money Manager per aggiornare il database. Il file deve essere salvato in formato CSV da XLS.'**
  String get importMoneyManagerDescription;

  /// No description provided for @exportData.
  ///
  /// In it, this message translates to:
  /// **'Esporta dati'**
  String get exportData;

  /// No description provided for @exportDataDescription.
  ///
  /// In it, this message translates to:
  /// **'Salva i tuoi dati come file CSV'**
  String get exportDataDescription;

  /// No description provided for @warningOverwrite.
  ///
  /// In it, this message translates to:
  /// **'Attenzione: Sovrascrittura dati'**
  String get warningOverwrite;

  /// No description provided for @warningOverwriteContent.
  ///
  /// In it, this message translates to:
  /// **'L\'importazione di questo file sostituirà definitivamente i tuoi dati esistenti. Questa azione non può essere annullata. Assicurati di avere un backup prima di procedere.'**
  String get warningOverwriteContent;

  /// No description provided for @proceedImport.
  ///
  /// In it, this message translates to:
  /// **'Procedi con l\'importazione'**
  String get proceedImport;

  /// No description provided for @importSuccess.
  ///
  /// In it, this message translates to:
  /// **'Dati importati con successo'**
  String get importSuccess;

  /// No description provided for @exportFailed.
  ///
  /// In it, this message translates to:
  /// **'Esportazione fallita: {err}'**
  String exportFailed(Object err);

  /// No description provided for @errorExporting.
  ///
  /// In it, this message translates to:
  /// **'Impossibile esportare la tabella: {tableName}'**
  String errorExporting(Object tableName);

  /// No description provided for @errorCsvNotFound.
  ///
  /// In it, this message translates to:
  /// **'File CSV non trovato.'**
  String get errorCsvNotFound;

  /// No description provided for @errorCsvEmpty.
  ///
  /// In it, this message translates to:
  /// **'Il file CSV è vuoto.'**
  String get errorCsvEmpty;

  /// No description provided for @errorCsvExpectedColumn.
  ///
  /// In it, this message translates to:
  /// **'Colonna mancante nel CSV: {column}'**
  String errorCsvExpectedColumn(Object column);

  /// No description provided for @errorCsvUnexpectedValue.
  ///
  /// In it, this message translates to:
  /// **'Valore non previsto trovato: {value}'**
  String errorCsvUnexpectedValue(Object value);

  /// No description provided for @errorCsvImportGeneral.
  ///
  /// In it, this message translates to:
  /// **'Si è verificato un errore generale durante l\'importazione del CSV. Errore: {error}'**
  String errorCsvImportGeneral(Object error);

  /// No description provided for @errorCsvTransactionImport.
  ///
  /// In it, this message translates to:
  /// **'Errore durante l\'importazione della transazione in data: {date}'**
  String errorCsvTransactionImport(Object date);

  /// No description provided for @errorCleanDatabase.
  ///
  /// In it, this message translates to:
  /// **'Impossibile pulire il database. Motivo: {error}'**
  String errorCleanDatabase(Object error);

  /// No description provided for @errorResetDatabase.
  ///
  /// In it, this message translates to:
  /// **'Impossibile ripristinare il database. Motivo: {error}'**
  String errorResetDatabase(Object error);

  /// No description provided for @transactionCount.
  ///
  /// In it, this message translates to:
  /// **'{count} transazioni'**
  String transactionCount(Object count);

  /// No description provided for @uncategorized.
  ///
  /// In it, this message translates to:
  /// **'Senza categoria'**
  String get uncategorized;

  /// No description provided for @noIncomesForSelectedMonth.
  ///
  /// In it, this message translates to:
  /// **'Nessuna entrata per il mese selezionato'**
  String get noIncomesForSelectedMonth;

  /// No description provided for @noExpensesForSelectedMonth.
  ///
  /// In it, this message translates to:
  /// **'Nessuna spesa per il mese selezionato'**
  String get noExpensesForSelectedMonth;

  /// No description provided for @total.
  ///
  /// In it, this message translates to:
  /// **'Totale'**
  String get total;

  /// No description provided for @noTransactionsAdded.
  ///
  /// In it, this message translates to:
  /// **'Non ci sono ancora transazioni aggiunte'**
  String get noTransactionsAdded;

  /// No description provided for @addTransactionCallToAction.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi una transazione per rendere questa sezione più interessante'**
  String get addTransactionCallToAction;

  /// No description provided for @graphsEmptyState.
  ///
  /// In it, this message translates to:
  /// **'Dopo aver aggiunto alcune transazioni, dei grafici eccezionali appariranno qui... quasi per magia!'**
  String get graphsEmptyState;

  /// No description provided for @availableLiquidity.
  ///
  /// In it, this message translates to:
  /// **'Liquidità disponibile'**
  String get availableLiquidity;

  /// No description provided for @vsLastMonth.
  ///
  /// In it, this message translates to:
  /// **'VS mese scorso'**
  String get vsLastMonth;

  /// No description provided for @monthlyBalance.
  ///
  /// In it, this message translates to:
  /// **'Bilancio mensile'**
  String get monthlyBalance;

  /// No description provided for @currentMonth.
  ///
  /// In it, this message translates to:
  /// **'Mese corrente'**
  String get currentMonth;

  /// No description provided for @lastMonth.
  ///
  /// In it, this message translates to:
  /// **'Mese scorso'**
  String get lastMonth;

  /// No description provided for @yourAccounts.
  ///
  /// In it, this message translates to:
  /// **'I tuoi conti'**
  String get yourAccounts;

  /// No description provided for @yourBudgets.
  ///
  /// In it, this message translates to:
  /// **'I tuoi budget'**
  String get yourBudgets;

  /// No description provided for @createBudgetToTrack.
  ///
  /// In it, this message translates to:
  /// **'Crea un budget per monitorare le tue spese'**
  String get createBudgetToTrack;

  /// No description provided for @close.
  ///
  /// In it, this message translates to:
  /// **'Chiudi'**
  String get close;

  /// No description provided for @edit.
  ///
  /// In it, this message translates to:
  /// **'Modifica'**
  String get edit;

  /// No description provided for @errorDuplicatingTransaction.
  ///
  /// In it, this message translates to:
  /// **'Errore durante la duplicazione della transazione'**
  String get errorDuplicatingTransaction;

  /// No description provided for @transactionCreated.
  ///
  /// In it, this message translates to:
  /// **'\"{transaction}\" è stata creata'**
  String transactionCreated(Object transaction);

  /// No description provided for @left.
  ///
  /// In it, this message translates to:
  /// **'Rimanenti'**
  String get left;

  /// No description provided for @notEnoughDataForGraph.
  ///
  /// In it, this message translates to:
  /// **'Siamo spiacenti, ma non ci sono\nabbastanza dati per creare il grafico...'**
  String get notEnoughDataForGraph;

  /// No description provided for @generalSettingsDesc.
  ///
  /// In it, this message translates to:
  /// **'Modifica impostazioni generali'**
  String get generalSettingsDesc;

  /// No description provided for @accountsDesc.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi o modifica i tuoi conti'**
  String get accountsDesc;

  /// No description provided for @categoriesDesc.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi/modifica categorie e sottocategorie'**
  String get categoriesDesc;

  /// No description provided for @budget.
  ///
  /// In it, this message translates to:
  /// **'Bilancio'**
  String get budget;

  /// No description provided for @budgetDesc.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi o modifica i tuoi budget'**
  String get budgetDesc;

  /// No description provided for @importExportDesc.
  ///
  /// In it, this message translates to:
  /// **'Importa o esporta dati'**
  String get importExportDesc;

  /// No description provided for @notificationsDesc.
  ///
  /// In it, this message translates to:
  /// **'Gestisci le impostazioni delle notifiche'**
  String get notificationsDesc;

  /// No description provided for @leaveFeedback.
  ///
  /// In it, this message translates to:
  /// **'Lascia un feedback'**
  String get leaveFeedback;

  /// No description provided for @leaveFeedbackDesc.
  ///
  /// In it, this message translates to:
  /// **'Compila un modulo per segnalare un bug o lasciare un feedback'**
  String get leaveFeedbackDesc;

  /// No description provided for @appInfoDesc.
  ///
  /// In it, this message translates to:
  /// **'Scopri di più su di noi e sull\'app'**
  String get appInfoDesc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'it',
    'nl',
    'pt',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'it':
      return AppLocalizationsIt();
    case 'nl':
      return AppLocalizationsNl();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
