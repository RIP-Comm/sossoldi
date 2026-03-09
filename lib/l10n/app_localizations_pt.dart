// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Sossoldi';

  @override
  String get dashboard => 'Painel';

  @override
  String get transactions => 'Transações';

  @override
  String get planning => 'Planejamento';

  @override
  String get graphs => 'Gráficos';

  @override
  String get list => 'Lista';

  @override
  String get categories => 'Categorias';

  @override
  String get expenses => 'Despesas';

  @override
  String get incomes => 'Receitas';

  @override
  String get expense => 'Despesa';

  @override
  String get income => 'Receita';

  @override
  String get transfer => 'Transferência';

  @override
  String get accounts => 'Contas';

  @override
  String get details => 'Detalhes';

  @override
  String get account => 'Conta';

  @override
  String get category => 'Categoria';

  @override
  String get date => 'Data';

  @override
  String get investments => 'Investimentos';

  @override
  String get settings => 'Configurações';

  @override
  String get notifications => 'Notificações';

  @override
  String get settingsDisclaimer => 'Open source, desenvolvida pela comunidade';

  @override
  String get addTransaction => 'Adicionar transação';

  @override
  String get totalBalance => 'Saldo Total';

  @override
  String get netWorth => 'Patrimônio Líquido';

  @override
  String get save => 'Salvar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get success => 'Sucesso';

  @override
  String get ok => 'Ok';

  @override
  String get editingTransaction => 'Editar transação';

  @override
  String get newTransaction => 'Nova transação';

  @override
  String get updateTransaction => 'Atualizar transação';

  @override
  String get recurringPayments => 'Pagamentos recorrentes';

  @override
  String get interval => 'Intervalo';

  @override
  String get endRepetition => 'Fim da repetição';

  @override
  String get never => 'Nunca';

  @override
  String get onADate => 'Em uma data';

  @override
  String get switchDisabled => 'Gesto desativado';

  @override
  String get recurringTransactionWarning =>
      'Esta é uma transação gerada por uma recorrente: qualquer alteração afetará apenas esta transação.\nPara alterar todas as transações futuras ou opções de recorrência, TOQUE AQUI.';

  @override
  String saveCsvFileFailed(Object e) {
    return 'Não é possível salvar arquivos aqui, crie ou selecione uma pasta em Downloads ou Documentos. Erro: \$$e';
  }

  @override
  String errorPickingFile(Object error) {
    return 'Erro ao selecionar o arquivo. Certifique-se de ter as permissões necessárias. Erro: $error';
  }

  @override
  String get storagePermissionRequired =>
      'É necessária permissão de armazenamento para acessar os arquivos.';

  @override
  String get importingData => 'Importando dados...';

  @override
  String get exportingData => 'Exportando dados...';

  @override
  String fileSavedTo(Object path) {
    return 'Arquivo salvo em: $path';
  }

  @override
  String get dataImportedSuccessfully => 'Dados importados com sucesso';

  @override
  String get description => 'Descrição';

  @override
  String get addDescription => 'Adicionar descrição';

  @override
  String get duplicateTransactionTitle => 'Duplicar transação';

  @override
  String get duplicateTransactionContent =>
      'Esta transação já está na lista. Deseja duplicá-la? Você poderá editar a nova entrada posteriormente.';

  @override
  String get duplicate => 'Duplicar';

  @override
  String get moreFrequent => 'Mais frequente';

  @override
  String get allCategories => 'Todas as categorias';

  @override
  String get allAccounts => 'Todas as contas';

  @override
  String errorOccurred(Object err) {
    return 'Erro: $err';
  }

  @override
  String get selectAccount => 'Selecionar conta';

  @override
  String get to => 'Para:';

  @override
  String get from => 'De:';

  @override
  String get recurringTransactionAdded => 'Transação recorrente adicionada';

  @override
  String get recurringTransactions => 'Transações recorrentes';

  @override
  String get addTransactionReminder => 'Adicionar lembrete de transação';

  @override
  String get privacyPolicyTitle => 'Política de Privacidade';

  @override
  String get privacyCollectTitle => 'Quais informações coletamos?';

  @override
  String get privacyChangesTitle => 'Alterações na Política de Privacidade';

  @override
  String get contactUsTitle => 'Contate-nos';

  @override
  String get privacyIntro =>
      'O Sossoldi é desenvolvido como um aplicativo open source. Este serviço é fornecido gratuitamente e destina-se a ser usado como está.\nNão temos interesse em coletar nenhuma informação pessoal. Acreditamos que essas informações pertencem apenas a você. Não armazenamos nem transmitimos seus dados pessoais, nem incluímos software de publicidade ou análise que se comunique com terceiros.\n';

  @override
  String get privacyCollectBody =>
      'O Sossoldi não coleta nenhuma informação pessoal e não se conecta à Internet. Qualquer informação adicionada ao aplicativo existe exclusivamente no seu dispositivo e em nenhum outro lugar.\n';

  @override
  String get privacyChangesBody =>
      'Podemos atualizar nossa Política de Privacidade ocasionalmente. Portanto, recomendamos que você revise esta página periodicamente para verificar alterações.\nEsta política entra em vigor a partir de 01/01/2024.\n';

  @override
  String get contactUsBody =>
      'Se você tiver dúvidas ou sugestões sobre nossa Política de Privacidade, não hesite em nos contatar em\n';

  @override
  String get collaboratorsTitle => 'Colaboradores';

  @override
  String get meetTheTeam => 'Conheça a equipe';

  @override
  String get teamDescription =>
      'O Sossoldi é desenvolvido e mantido por uma apaixonada comunidade open source. Cada funcionalidade, correção e ideia vem de pessoas como você.';

  @override
  String get wantToContribute => 'Quer contribuir?';

  @override
  String get contributeDescription =>
      'Abra uma issue, envie um PR ou apenas diga olá no GitHub';

  @override
  String get appInfo => 'Informações do app';

  @override
  String get appVersion => 'Versão do app:';

  @override
  String get collaborators => 'Colaboradores';

  @override
  String get collaboratorsDescription => 'Conheça a equipe por trás deste app';

  @override
  String get privacyPolicy => 'Política de Privacidade';

  @override
  String get privacyPolicyDescription => 'Saiba mais';

  @override
  String get generalSettings => 'Configurações gerais';

  @override
  String get appearance => 'Aparência';

  @override
  String get currency => 'Moeda';

  @override
  String get requireAuthentication => 'Requerer autenticação';

  @override
  String get searchForATransaction => 'Buscar uma transação';

  @override
  String get selectACurrency => 'Selecionar uma moeda';

  @override
  String get search => 'Buscar';

  @override
  String get searchIn => 'Buscar em';

  @override
  String get lastTransactions => 'Suas últimas transações';

  @override
  String get startReconciliation => 'Iniciar reconciliação';

  @override
  String get newBalance => 'Novo saldo';

  @override
  String get balanceDiscrepancy => 'Diferença de saldo?';

  @override
  String get balanceAdjustmentHint =>
      'O saldo registrado pode diferir do extrato bancário. Toque abaixo para ajustar o saldo manualmente e manter seus registros atualizados.';

  @override
  String get newAccount => 'Nova conta';

  @override
  String get editAccount => 'Editar conta';

  @override
  String get createAccount => 'Criar conta';

  @override
  String get accountName => 'Nome da conta';

  @override
  String get name => 'Nome';

  @override
  String get iconAndColor => 'Ícone e cor';

  @override
  String get chooseColor => 'Escolher cor';

  @override
  String get chooseIcon => 'Escolher ícone';

  @override
  String get done => 'Feito';

  @override
  String get add => 'Adicionar';

  @override
  String get setAsMainAccount => 'Definir como conta principal';

  @override
  String get countsForNetWorth => 'Incluir no patrimônio líquido';

  @override
  String get deleteAccount => 'Excluir conta';

  @override
  String get initialBalance => 'Saldo inicial';

  @override
  String get currentBalance => 'Saldo atual';

  @override
  String get showLess => 'Mostrar menos';

  @override
  String get showMore => 'Mostrar mais';

  @override
  String get addSubcategory => 'Adicionar subcategoria';

  @override
  String get newCategory => 'Nova categoria';

  @override
  String get editCategory => 'Editar categoria';

  @override
  String get createCategory => 'Criar categoria';

  @override
  String get updateCategory => 'Atualizar categoria';

  @override
  String get categoryName => 'Nome da categoria';

  @override
  String get type => 'Tipo';

  @override
  String get deleteCategory => 'Excluir categoria';

  @override
  String get newSubcategory => 'Nova subcategoria';

  @override
  String get editSubcategory => 'Editar subcategoria';

  @override
  String get createSubcategory => 'Criar subcategoria';

  @override
  String get updateSubcategory => 'Atualizar subcategoria';

  @override
  String get subcategoryName => 'Nome da subcategoria';

  @override
  String get deleteSubcategory => 'Excluir subcategoria';

  @override
  String get subcategory => 'Subcategoria';

  @override
  String get categoryFirstThenBudget =>
      'Adicione uma categoria antes de criar um orçamento';

  @override
  String inTheNextDays(Object next) {
    return 'Nos próximos $next dias';
  }

  @override
  String get monthlyBudget => 'Orçamento mensal';

  @override
  String get manage => 'Gerenciar';

  @override
  String get swipeLeftToDelete => 'Deslize para a esquerda para excluir';

  @override
  String get yourMonthlyBudgetWillBe => 'Seu orçamento mensal será:';

  @override
  String get saveBudget => 'Salvar orçamento';

  @override
  String get selectCategoriesToCreateBudget =>
      'Selecione as categorias para criar seu orçamento';

  @override
  String get amount => 'Valor';

  @override
  String get addCategoryBudget => 'Adicionar orçamento à categoria';

  @override
  String get allCategoriesAdded =>
      'Você já adicionou todas as categorias disponíveis.';

  @override
  String get delete => 'Excluir';

  @override
  String get allRecurringPaymentsHere =>
      'Todos os pagamentos recorrentes serão exibidos aqui';

  @override
  String get addRecurringPayment => 'Adicionar pagamento recorrente';

  @override
  String get seeOlderPayments => 'Ver pagamentos antigos';

  @override
  String untilDate(Object date) {
    return 'Até $date';
  }

  @override
  String get olderPayments => 'Pagamentos antigos';

  @override
  String get categoryNotFound => 'Categoria não encontrada';

  @override
  String get back => 'Voltar';

  @override
  String onTheDay(Object day) {
    return '- No dia $day';
  }

  @override
  String get noMonthlyPaymentHistory => 'Sem histórico de pagamentos mensais';

  @override
  String get noRecurrentPaymentHistory =>
      'Sem histórico de pagamentos recorrentes';

  @override
  String errorLoadingPayments(Object error) {
    return 'Erro ao carregar pagamentos: $error';
  }

  @override
  String get editRecurringTransaction => 'Editar transação recorrente';

  @override
  String get detailsExplanation =>
      'Detalhes (qualquer alteração afetará apenas transações futuras)';

  @override
  String get dateStart => 'Data de início';

  @override
  String get planned => 'Planejado';

  @override
  String get composition => 'Composição';

  @override
  String get progress => 'Progresso';

  @override
  String get noBudgetSet => 'Nenhum orçamento definido';

  @override
  String get budgetHelpText =>
      'Um orçamento mensal pode ajudá-lo a acompanhar suas despesas e manter-se dentro dos limites';

  @override
  String get createBudget => 'Criar orçamento';

  @override
  String get setUpTheApp => 'Configurar o app';

  @override
  String get setupDescription =>
      'Em alguns passos você estará pronto para começar a\nacompanhar suas finanças pessoais (quase)\ncomo o Mr. Rip.';

  @override
  String get startTheSetup => 'Iniciar configuração';

  @override
  String budgetAmount(Object amount) {
    return 'Orçamento $amount€';
  }

  @override
  String get addBudget => 'Adicionar orçamento';

  @override
  String addBudgetForCategory(Object cat) {
    return 'Adicionar orçamento para a categoria $cat';
  }

  @override
  String get addCategory => 'Adicionar categoria';

  @override
  String get confirm => 'Confirmar';

  @override
  String get step1Of2 => 'Passo 1 de 2';

  @override
  String get setupMonthlyBudgets => 'Defina seus orçamentos\nmensais';

  @override
  String get chooseCategoriesForBudget =>
      'Escolha as categorias para as quais deseja definir um orçamento';

  @override
  String get monthlyBudgetTotal => 'Total do orçamento mensal:';

  @override
  String get nextStep => 'Próximo passo';

  @override
  String get continueWithoutBudget => 'Continuar sem orçamento';

  @override
  String get step2Of2 => 'Passo 2 de 2';

  @override
  String get setLiquidityInMainAccount =>
      'Defina a liquidez na sua conta principal';

  @override
  String get addMoreAccounts =>
      'Você poderá adicionar mais contas dentro do app';

  @override
  String get liquidityDescription =>
      'Ela será usada como base para adicionar receitas, despesas e calcular seu patrimônio.\nVocê poderá adicionar mais contas dentro do app.';

  @override
  String get mainAccount => 'Conta principal';

  @override
  String get setAmount => 'Definir valor';

  @override
  String get editIconAndColor => 'Editar ícone e cor';

  @override
  String get skipStepOrStartFromZero =>
      'Ou você pode pular este passo e começar do 0';

  @override
  String get startTrackingExpenses => 'Começar a acompanhar suas despesas';

  @override
  String get startFromZero => 'Começar do 0';

  @override
  String get importExport => 'Importar/Exportar';

  @override
  String get importData => 'Importar dados';

  @override
  String get importDataDescription =>
      'Importe um arquivo CSV para atualizar o banco de dados';

  @override
  String get importMoneyManager => 'Importar do Money Manager';

  @override
  String get importMoneyManagerDescription =>
      'Importe CSV do Money Manager para atualizar o banco de dados. O arquivo deve ser salvo em formato CSV a partir de XLS.';

  @override
  String get exportData => 'Exportar dados';

  @override
  String get exportDataDescription => 'Salve seus dados como um arquivo CSV';

  @override
  String get warningOverwrite => 'Atenção: Sobrescrita de dados';

  @override
  String get warningOverwriteContent =>
      'A importação deste arquivo substituirá permanentemente seus dados existentes. Esta ação não pode ser desfeita. Certifique-se de ter um backup antes de prosseguir.';

  @override
  String get proceedImport => 'Prosseguir com a importação';

  @override
  String get importSuccess => 'Dados importados com sucesso';

  @override
  String exportFailed(Object err) {
    return 'Falha na exportação: $err';
  }

  @override
  String errorExporting(Object tableName) {
    return 'Não foi possível exportar a tabela: $tableName';
  }

  @override
  String get errorCsvNotFound => 'Arquivo CSV não encontrado.';

  @override
  String get errorCsvEmpty => 'O arquivo CSV está vazio.';

  @override
  String errorCsvExpectedColumn(Object column) {
    return 'Coluna faltando no CSV: $column';
  }

  @override
  String errorCsvUnexpectedValue(Object value) {
    return 'Valor inesperado encontrado: $value';
  }

  @override
  String errorCsvImportGeneral(Object error) {
    return 'Ocorreu um erro geral durante a importação do CSV. Erro: $error';
  }

  @override
  String errorCsvTransactionImport(Object date) {
    return 'Erro ao importar a transação na data: $date';
  }

  @override
  String errorCleanDatabase(Object error) {
    return 'Não foi possível limpar o banco de dados. Motivo: $error';
  }

  @override
  String errorResetDatabase(Object error) {
    return 'Não foi possível redefinir o banco de dados. Motivo: $error';
  }

  @override
  String transactionCount(Object count) {
    return '$count transações';
  }

  @override
  String get uncategorized => 'Sem categoria';

  @override
  String get noIncomesForSelectedMonth =>
      'Nenhuma receita para o mês selecionado';

  @override
  String get noExpensesForSelectedMonth =>
      'Nenhuma despesa para o mês selecionado';

  @override
  String get total => 'Total';

  @override
  String get noTransactionsAdded => 'Nenhuma transação adicionada ainda';

  @override
  String get addTransactionCallToAction =>
      'Adicione uma transação para tornar esta seção mais interessante';

  @override
  String get graphsEmptyState =>
      'Depois de adicionar algumas transações, gráficos incríveis aparecerão aqui... quase como mágica!';

  @override
  String get availableLiquidity => 'Liquidez disponível';

  @override
  String get vsLastMonth => 'VS mês anterior';

  @override
  String get monthlyBalance => 'Saldo mensal';

  @override
  String get currentMonth => 'Mês atual';

  @override
  String get lastMonth => 'Mês anterior';

  @override
  String get yourAccounts => 'Suas contas';

  @override
  String get yourBudgets => 'Seus orçamentos';

  @override
  String get createBudgetToTrack =>
      'Crie um orçamento para acompanhar suas despesas';

  @override
  String get close => 'Fechar';

  @override
  String get edit => 'Editar';

  @override
  String get errorDuplicatingTransaction => 'Erro ao duplicar a transação';

  @override
  String transactionCreated(Object transaction) {
    return '\"$transaction\" foi criada';
  }

  @override
  String get left => 'Restante';

  @override
  String get notEnoughDataForGraph =>
      'Lamentamos, mas não há\n-dados suficientes para criar o gráfico...';

  @override
  String get generalSettingsDesc => 'Editar configurações gerais';

  @override
  String get accountsDesc => 'Adicionar ou editar suas contas';

  @override
  String get categoriesDesc => 'Adicionar/editar categorias e subcategorias';

  @override
  String get budget => 'Orçamento';

  @override
  String get budgetDesc => 'Adicionar ou editar seus orçamentos';

  @override
  String get importExportDesc => 'Importar ou exportar dados';

  @override
  String get notificationsDesc => 'Gerenciar suas configurações de notificação';

  @override
  String get leaveFeedback => 'Deixar feedback';

  @override
  String get leaveFeedbackDesc =>
      'Preencha um pequeno formulário para relatar um bug ou deixar feedback';

  @override
  String get appInfoDesc => 'Saiba mais sobre nós e o app';
}
