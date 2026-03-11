// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Sossoldi';

  @override
  String get dashboard => 'Panel';

  @override
  String get transactions => 'Transacciones';

  @override
  String get planning => 'Planificación';

  @override
  String get graphs => 'Gráficos';

  @override
  String get list => 'Lista';

  @override
  String get categories => 'Categorías';

  @override
  String get expenses => 'Gastos';

  @override
  String get incomes => 'Ingresos';

  @override
  String get expense => 'Gasto';

  @override
  String get income => 'Ingreso';

  @override
  String get transfer => 'Transferencia';

  @override
  String get accounts => 'Cuentas';

  @override
  String get details => 'Detalles';

  @override
  String get account => 'Cuenta';

  @override
  String get category => 'Categoría';

  @override
  String get date => 'Fecha';

  @override
  String get investments => 'Inversiones';

  @override
  String get settings => 'Ajustes';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get settingsDisclaimer => 'Open source, desarrollada por la comunidad';

  @override
  String get addTransaction => 'Añadir transacción';

  @override
  String get totalBalance => 'Saldo Total';

  @override
  String get netWorth => 'Patrimonio Neto';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get success => 'Éxito';

  @override
  String get ok => 'Ok';

  @override
  String get editingTransaction => 'Editar transacción';

  @override
  String get newTransaction => 'Nueva transacción';

  @override
  String get updateTransaction => 'Actualizar transacción';

  @override
  String get recurringPayments => 'Pagos recurrentes';

  @override
  String get interval => 'Intervalo';

  @override
  String get endRepetition => 'Fin de la repetición';

  @override
  String get never => 'Nunca';

  @override
  String get onADate => 'En una fecha';

  @override
  String get switchDisabled => 'Gestor desactivado';

  @override
  String get recurringTransactionWarning =>
      'Esta es una transacción generada por una recurrente: cualquier cambio afectará solo a esta transacción.\nPara cambiar todas las transacciones futuras u opciones de recurrencia, TOCA AQUÍ.';

  @override
  String saveCsvFileFailed(Object e) {
    return 'No es posible guardar archivos aquí, crea o selecciona una carpeta en Descargas o Documentos. Error: $e';
  }

  @override
  String errorPickingFile(Object error) {
    return 'Error al seleccionar el archivo. Asegúrate de tener los permisos necesarios. Error: $error';
  }

  @override
  String get storagePermissionRequired =>
      'Se requiere permiso de almacenamiento para acceder a los archivos.';

  @override
  String get importingData => 'Importando datos...';

  @override
  String get exportingData => 'Exportando datos...';

  @override
  String fileSavedTo(Object path) {
    return 'Archivo guardado en: $path';
  }

  @override
  String get dataImportedSuccessfully => 'Datos importados con éxito';

  @override
  String get description => 'Descripción';

  @override
  String get addDescription => 'Añadir descripción';

  @override
  String get duplicateTransactionTitle => 'Duplicar transacción';

  @override
  String get duplicateTransactionContent =>
      'Esta transacción ya está en la lista. ¿Deseas duplicarla? Podrás editar la nueva entrada posteriormente.';

  @override
  String get duplicate => 'Duplicar';

  @override
  String get moreFrequent => 'Más frecuente';

  @override
  String get allCategories => 'Todas las categorías';

  @override
  String get allAccounts => 'Todas las cuentas';

  @override
  String errorOccurred(Object err) {
    return 'Error: $err';
  }

  @override
  String get selectAccount => 'Seleccionar cuenta';

  @override
  String get to => 'Para:';

  @override
  String get from => 'De:';

  @override
  String get recurringTransactionAdded => 'Transacción recurrente añadida';

  @override
  String get recurringTransactions => 'Transacciones recurrentes';

  @override
  String get addTransactionReminder => 'Añadir recordatorio de transacción';

  @override
  String get privacyPolicyTitle => 'Política de Privacidad';

  @override
  String get privacyCollectTitle => '¿Qué información recopilamos?';

  @override
  String get privacyChangesTitle => 'Cambios en la Política de Privacidad';

  @override
  String get contactUsTitle => 'Contáctanos';

  @override
  String get privacyIntro =>
      'Sossoldi está desarrollado como una aplicación open source. Este servicio se proporciona de forma gratuita y está destinado a ser usado tal cual.\nNo tenemos interés en recopilar ninguna información personal. Creemos que dicha información te pertenece solo a ti. No almacenamos ni transmitimos tus datos personales, ni incluimos software de publicidad o análisis que se comunique con terceros.\n';

  @override
  String get privacyCollectBody =>
      'Sossoldi no recopila ninguna información personal ni se conecta a Internet. Cualquier información añadida a la aplicación existe exclusivamente en tu dispositivo y en ningún otro lugar.\n';

  @override
  String get privacyChangesBody =>
      'Podemos actualizar nuestra Política de Privacidad ocasionalmente. Por tanto, recomendamos que revises esta página periódicamente para verificar cambios.\nEsta política entra en vigor a partir del 01/01/2024.\n';

  @override
  String get contactUsBody =>
      'Si tienes dudas o sugerencias sobre nuestra Política de Privacidad, no dudes en contactarnos en\n';

  @override
  String get collaboratorsTitle => 'Colaboradores';

  @override
  String get meetTheTeam => 'Conoce al equipo';

  @override
  String get teamDescription =>
      'Sossoldi es desarrollada y mantenida por una apasionada comunidad open source. Cada funcionalidad, corrección e idea viene de personas como tú.';

  @override
  String get wantToContribute => '¿Quieres contribuir?';

  @override
  String get contributeDescription =>
      'Abre un issue, envía un PR o simplemente saluda en GitHub';

  @override
  String get appInfo => 'Información de la app';

  @override
  String get appVersion => 'Versión de la app:';

  @override
  String get collaborators => 'Colaboradores';

  @override
  String get collaboratorsDescription => 'Conoce al equipo detrás de esta app';

  @override
  String get privacyPolicy => 'Política de Privacidad';

  @override
  String get privacyPolicyDescription => 'Saber más';

  @override
  String get generalSettings => 'Ajustes generales';

  @override
  String get appearance => 'Apariencia';

  @override
  String get currency => 'Moneda';

  @override
  String get requireAuthentication => 'Requerir autenticación';

  @override
  String get searchForATransaction => 'Buscar una transacción';

  @override
  String get selectACurrency => 'Seleccionar una moneda';

  @override
  String get search => 'Buscar';

  @override
  String get searchIn => 'Buscar en';

  @override
  String get lastTransactions => 'Tus últimas transacciones';

  @override
  String get startReconciliation => 'Iniciar conciliación';

  @override
  String get newBalance => 'Nuevo saldo';

  @override
  String get balanceDiscrepancy => '¿Diferencia de saldo?';

  @override
  String get balanceAdjustmentHint =>
      'El saldo registrado puede diferir del extracto bancario. Toca abajo para ajustar el saldo manualmente y mantener tus registros actualizados.';

  @override
  String get newAccount => 'Nueva cuenta';

  @override
  String get editAccount => 'Editar cuenta';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get accountName => 'Nombre de la cuenta';

  @override
  String get name => 'Nombre';

  @override
  String get iconAndColor => 'Icono y color';

  @override
  String get chooseColor => 'Elegir color';

  @override
  String get chooseIcon => 'Elegir icono';

  @override
  String get done => 'Hecho';

  @override
  String get add => 'Añadir';

  @override
  String get setAsMainAccount => 'Definir como cuenta principal';

  @override
  String get countsForNetWorth => 'Incluir en el patrimonio neto';

  @override
  String get deleteAccount => 'Eliminar cuenta';

  @override
  String get initialBalance => 'Saldo inicial';

  @override
  String get currentBalance => 'Saldo actual';

  @override
  String get showLess => 'Mostrar menos';

  @override
  String get showMore => 'Mostrar más';

  @override
  String get addSubcategory => 'Añadir subcategoría';

  @override
  String get newCategory => 'Nueva categoría';

  @override
  String get editCategory => 'Editar categoría';

  @override
  String get createCategory => 'Crear categoría';

  @override
  String get updateCategory => 'Actualizar categoría';

  @override
  String get categoryName => 'Nombre de la categoría';

  @override
  String get type => 'Tipo';

  @override
  String get deleteCategory => 'Eliminar categoría';

  @override
  String get newSubcategory => 'Nueva subcategoría';

  @override
  String get editSubcategory => 'Editar subcategoría';

  @override
  String get createSubcategory => 'Crear subcategoría';

  @override
  String get updateSubcategory => 'Actualizar subcategoría';

  @override
  String get subcategoryName => 'Nombre de la subcategoría';

  @override
  String get deleteSubcategory => 'Eliminar subcategoría';

  @override
  String get subcategory => 'Subcategoría';

  @override
  String get categoryFirstThenBudget =>
      'Añade una categoría antes de crear un presupuesto';

  @override
  String inTheNextDays(Object next) {
    return 'En los próximos $next días';
  }

  @override
  String get monthlyBudget => 'Presupuesto mensual';

  @override
  String get manage => 'Gestionar';

  @override
  String get swipeLeftToDelete => 'Desliza a la izquierda para eliminar';

  @override
  String get yourMonthlyBudgetWillBe => 'Tu presupuesto mensual será:';

  @override
  String get saveBudget => 'Guardar presupuesto';

  @override
  String get selectCategoriesToCreateBudget =>
      'Selecciona las categorías para crear tu presupuesto';

  @override
  String get amount => 'Valor';

  @override
  String get addCategoryBudget => 'Añadir presupuesto a la categoría';

  @override
  String get allCategoriesAdded =>
      'Ya has añadido todas las categorías disponibles.';

  @override
  String get delete => 'Eliminar';

  @override
  String get allRecurringPaymentsHere =>
      'Todos los pagos recurrentes se mostrarán aquí';

  @override
  String get addRecurringPayment => 'Añadir pago recurrente';

  @override
  String get seeOlderPayments => 'Ver pagos antiguos';

  @override
  String untilDate(Object date) {
    return 'Hasta $date';
  }

  @override
  String get olderPayments => 'Pagos antiguos';

  @override
  String get categoryNotFound => 'Categoría no encontrada';

  @override
  String get back => 'Volver';

  @override
  String onTheDay(Object day) {
    return '- El día $day';
  }

  @override
  String get noMonthlyPaymentHistory => 'Sin historial de pagos mensuales';

  @override
  String get noRecurrentPaymentHistory => 'Sin historial de pagos recurrentes';

  @override
  String errorLoadingPayments(Object error) {
    return 'Error al cargar pagos: $error';
  }

  @override
  String get editRecurringTransaction => 'Editar transacción recurrente';

  @override
  String get detailsExplanation =>
      'Detalles (cualquier cambio afectará solo a transacciones futuras)';

  @override
  String get dateStart => 'Fecha de inicio';

  @override
  String get planned => 'Planeado';

  @override
  String get composition => 'Composición';

  @override
  String get progress => 'Progreso';

  @override
  String get noBudgetSet => 'Ningún presupuesto definido';

  @override
  String get budgetHelpText =>
      'Un presupuesto mensual puede ayudarte a realizar un seguimiento de tus gastos y mantenerte dentro de los límites';

  @override
  String get createBudget => 'Crear presupuesto';

  @override
  String get setUpTheApp => 'Configurar la app';

  @override
  String get setupDescription =>
      'En algunos pasos estarás listo para empezar a\nrealizar un seguimiento de tus finanzas personales (casi)\ncomo Mr. Rip.';

  @override
  String get startTheSetup => 'Iniciar configuración';

  @override
  String budgetAmount(Object amount) {
    return 'Presupuesto $amount€';
  }

  @override
  String get addBudget => 'Añadir presupuesto';

  @override
  String addBudgetForCategory(Object cat) {
    return 'Añadir presupuesto para la categoría $cat';
  }

  @override
  String get addCategory => 'Añadir categoría';

  @override
  String get confirm => 'Confirmar';

  @override
  String get step1Of2 => 'Paso 1 de 2';

  @override
  String get setupMonthlyBudgets => 'Define tus presupuestos\nmensuales';

  @override
  String get chooseCategoriesForBudget =>
      'Elige las categorías para las que deseas definir un presupuesto';

  @override
  String get monthlyBudgetTotal => 'Total del presupuesto mensual:';

  @override
  String get nextStep => 'Próximo paso';

  @override
  String get continueWithoutBudget => 'Continuar sin presupuesto';

  @override
  String get step2Of2 => 'Paso 2 de 2';

  @override
  String get setLiquidityInMainAccount =>
      'Define la liquidez en tu cuenta principal';

  @override
  String get addMoreAccounts => 'Podrás añadir más cuentas dentro de la app';

  @override
  String get liquidityDescription =>
      'Se usará como base para añadir ingresos, gastos y calcular tu patrimonio.\nPodrás añadir más cuentas dentro de la app.';

  @override
  String get mainAccount => 'Cuenta principal';

  @override
  String get setAmount => 'Definir valor';

  @override
  String get editIconAndColor => 'Editar icono y color';

  @override
  String get skipStepOrStartFromZero =>
      'O puedes saltar este paso y empezar desde 0';

  @override
  String get startTrackingExpenses =>
      'Empezar a realizar un seguimiento de tus gastos';

  @override
  String get startFromZero => 'Empezar desde 0';

  @override
  String get importExport => 'Importar/Exportar';

  @override
  String get importData => 'Importar datos';

  @override
  String get importDataDescription =>
      'Importa un archivo CSV para actualizar la base de datos';

  @override
  String get importMoneyManager => 'Importar de Money Manager';

  @override
  String get importMoneyManagerDescription =>
      'Importa CSV de Money Manager para actualizar la base de datos. El archivo debe guardarse en formato CSV desde XLS.';

  @override
  String get exportData => 'Exportar datos';

  @override
  String get exportDataDescription => 'Guarda tus datos como un archivo CSV';

  @override
  String get warningOverwrite => 'Atención: Sobrescritura de datos';

  @override
  String get warningOverwriteContent =>
      'La importación de este archivo reemplazará permanentemente tus datos existentes. Esta acción no se puede deshacer. Asegúrate de tener una copia de seguridad antes de proceder.';

  @override
  String get proceedImport => 'Proceder con la importación';

  @override
  String get importSuccess => 'Datos importados con éxito';

  @override
  String exportFailed(Object err) {
    return 'Fallo en la exportación: $err';
  }

  @override
  String errorExporting(Object tableName) {
    return 'No fue posible exportar la tabla: $tableName';
  }

  @override
  String get errorCsvNotFound => 'Archivo CSV no encontrado.';

  @override
  String get errorCsvEmpty => 'El archivo CSV está vacío.';

  @override
  String errorCsvExpectedColumn(Object column) {
    return 'Columna faltando en el CSV: $column';
  }

  @override
  String errorCsvUnexpectedValue(Object value) {
    return 'Valor inesperado encontrado: $value';
  }

  @override
  String errorCsvImportGeneral(Object error) {
    return 'Ocurrió un error general durante la importación del CSV. Error: $error';
  }

  @override
  String errorCsvTransactionImport(Object date) {
    return 'Error al importar la transacción en la fecha: $date';
  }

  @override
  String errorCleanDatabase(Object error) {
    return 'No fue posible limpiar la base de datos. Motivo: $error';
  }

  @override
  String errorResetDatabase(Object error) {
    return 'No fue posible restablecer la base de datos. Motivo: $error';
  }

  @override
  String transactionCount(Object count) {
    return '$count transacciones';
  }

  @override
  String get uncategorized => 'Sin categoría';

  @override
  String get noIncomesForSelectedMonth =>
      'Ningún ingreso para el mes seleccionado';

  @override
  String get noExpensesForSelectedMonth =>
      'Ningún gasto para el mes seleccionado';

  @override
  String get total => 'Total';

  @override
  String get noTransactionsAdded => 'Ninguna transacción añadida aún';

  @override
  String get addTransactionCallToAction =>
      'Añade una transacción para hacer esta sección más interesante';

  @override
  String get graphsEmptyState =>
      'Después de añadir algunas transacciones, gráficos increíbles aparecerán aquí... ¡casi como por arte de magia!';

  @override
  String get availableLiquidity => 'Liquidez disponible';

  @override
  String get vsLastMonth => 'VS mes anterior';

  @override
  String get monthlyBalance => 'Saldo mensual';

  @override
  String get currentMonth => 'Mes actual';

  @override
  String get lastMonth => 'Mes anterior';

  @override
  String get yourAccounts => 'Tus cuentas';

  @override
  String get yourBudgets => 'Tus presupuestos';

  @override
  String get createBudgetToTrack =>
      'Crea un presupuesto para realizar un seguimiento de tus gastos';

  @override
  String get close => 'Cerrar';

  @override
  String get edit => 'Editar';

  @override
  String get errorDuplicatingTransaction => 'Error al duplicar la transacción';

  @override
  String transactionCreated(Object transaction) {
    return '\"$transaction\" fue creada';
  }

  @override
  String get left => 'Restante';

  @override
  String get notEnoughDataForGraph =>
      'Lamentamos que no haya\nsuficientes datos para crear el gráfico...';

  @override
  String get generalSettingsDesc => 'Editar ajustes generales';

  @override
  String get accountsDesc => 'Añadir o editar tus cuentas';

  @override
  String get categoriesDesc => 'Añadir/editar categorías y subcategorías';

  @override
  String get budget => 'Presupuesto';

  @override
  String get budgetDesc => 'Añadir o editar tus presupuestos';

  @override
  String get importExportDesc => 'Importar o exportar datos';

  @override
  String get notificationsDesc => 'Gestionar tus ajustes de notificación';

  @override
  String get leaveFeedback => 'Dejar comentarios';

  @override
  String get leaveFeedbackDesc =>
      'Completa un pequeño formulario para reportar un error o dejar comentarios';

  @override
  String get appInfoDesc => 'Saber más sobre nosotros y la app';
}
