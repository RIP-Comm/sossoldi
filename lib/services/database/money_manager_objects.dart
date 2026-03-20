import '../../model/transaction.dart';


class MMAccount {

  final String uuid;

  final DateTime useTime;

  final String accountGroupName;

  final bool countInNet;


  MMAccount({

    required this.uuid,

    required this.useTime,

    required this.accountGroupName,

    required this.countInNet,

  });

  static final String tableName = "ASSETS";
  static final String uidColumn = "uid";

  static final String timeColumn = "A_UTIME";

  static final String countNethWorthColumn = "ZDATA2";

  static final String groupNameColumn = "NIC_NAME";



  factory MMAccount.fromMap(Map<String, dynamic> map) {

    int timestamp = (map[timeColumn] as num?)?.toInt() ?? 0;

    bool countIn = false;

    if(map[countNethWorthColumn] != null)

    {

      countIn = map[countNethWorthColumn] == '0';

    }

    return MMAccount(

      uuid: map[uidColumn],

      useTime: DateTime.fromMillisecondsSinceEpoch(timestamp),

      accountGroupName: map[groupNameColumn] ?? '',

      countInNet: countIn,

    );

  }

}



class MMCurrency {

  final String name;

  final String iso;

  final String symbol;

  final bool mainCurrency;


  MMCurrency({

    required this.name,

    required this.iso,

    required this.symbol,

    required this.mainCurrency,

  });

  static final String tableName = "CURRENCY";
  static final String mainCurrencyColumn = "MAIN_ISO";

  static final String treeLetterCodeColumn = "ISO";

  static final String nameColumn = "NAME";
  static final String uidColumn = "uid";
  static final String symbolColumn = "SYMBOL";



  factory MMCurrency.fromMap(Map<String, dynamic> map) {

    String mainIso = map[mainCurrencyColumn] ?? '';

    String iso = map[treeLetterCodeColumn] ?? '';


    return MMCurrency(

      name: map[nameColumn] ?? '',

      iso: iso,

      symbol: map[symbolColumn] ?? '',

      mainCurrency: mainIso == iso && iso.isNotEmpty,

    );

  }

}


class MMCategory {

  final int id;

  final DateTime cUTime;

  final String textUid;

  final String name;

  final String? parent;


  MMCategory({

    required this.id,

    required this.cUTime,

    required this.textUid,

    required this.name,

    required this.parent,

  });

  static final String tableName = "ZCATEGORY";
  static final String uidColumn = "ID";
  static final String creationTimeColumn = "C_UTIME";
  static final String nameColumn = "NAME";
  static final String parentUidColumn = "pUid";
  static final String textUidColumn = "uid";
  static final String typeColumn = "TYPE";

  factory MMCategory.fromMap(Map<String, dynamic> map) {

    return MMCategory(

      id: map[uidColumn] ?? 0,

      cUTime: DateTime.fromMillisecondsSinceEpoch((map[creationTimeColumn] as num).toInt()),

      textUid: map[textUidColumn] ?? '', // Ensure this matches your column name

      name: map[nameColumn] ?? 'Unnamed',

      parent: map[parentUidColumn],

    );

  }

}

TransactionType getCSVTransactionTypeFromName(String code)
{
  switch(code)
  {
    case 'Income':
      return TransactionType.income;
    case 'Expense':
      return TransactionType.expense;
    case 'Transfer-Out':
      return TransactionType.transfer;
  }

  return TransactionType.expense;
}



class MMTransaction {
  final DateTime date;
  final int account;
  // In case of transfer
  final int? destinationAccount;
  // Could be also an account fi the type is transaction
  final int category;
  String? description;
  // Still Don't know the difference between description and note
  String currency;
  final double amount;

  final TransactionType type; // Income o Expense or transaction
  static final String tableName = "INOUTCOME";
  static final String groupIdColumn = "assetUid";
  static final String destinationGroupIdColumn = "toAssetUid";
  static final String dateColumn = "ZDATE";
  static final String amountColumn = "AMOUNT_ACCOUNT";
  static final String descriptionColumn = "ZCONTENT";
  static final String categoryIdColumn = "ctgUid";
  static final String currencyIdColumn = "currencyUid";
  static final String typeColumn = "DO_TYPE";

  MMTransaction({required this.date, required this.account, required this.category, required this.amount, required this.type,required this.currency, this.destinationAccount, this.description });
  factory MMTransaction.transfer({required DateTime date, required int account, required int dAccount, required amount,required currency, description,note})
  {
    return MMTransaction(date: date, account: account,  category: -1, amount: amount, type: TransactionType.transfer,currency: currency, destinationAccount : dAccount, description: description );
  }

  factory MMTransaction.income({required DateTime date, required int account, required category, required amount,required currency,sub,description,note})
  {
    return MMTransaction(date: date, account: account,  category: category, amount: amount, type: TransactionType.income,currency: currency , description: description);
  }

  factory MMTransaction.expense({required DateTime date, required int account, required category, required amount,required currency,sub,description,note})
  {
    return MMTransaction(date: date, account: account,  category: category, amount: amount, type: TransactionType.expense,currency: currency , description: description);
  }

  factory MMTransaction.invalid()
  {
    return MMTransaction(date: DateTime.now(),
        account: -1,
        category: -1,
        amount: 0.0,
        type: TransactionType.expense,
        currency: 'ZWD');
  }

  factory MMTransaction.fromMap(Map<String, dynamic> map,Map<String,int> accountHelperMap,Map<String,int> incomeCategoryHelperMap,Map<String,int>expensesCategoryHelperMap, Map<String,String> currencyHelper, int inMod, int outMod) {
    String uTime = map[dateColumn];
    DateTime date = DateTime.fromMillisecondsSinceEpoch(int.parse(uTime));
    String asset = map[groupIdColumn];
    if(!accountHelperMap.containsKey(asset))
    {
      return MMTransaction.invalid();
    }
    int accountId = accountHelperMap[asset]!;
    double amount = map[amountColumn] ;
    String desc = map[descriptionColumn] ?? '';

    // I know that it isn't use by us
    String curr = map[currencyIdColumn];
    if(currencyHelper.containsKey(curr)) {
      curr = currencyHelper[curr]!;
    }

    String cat = map[categoryIdColumn];
    int categoryId = -1;
    if(expensesCategoryHelperMap.containsKey(cat))
    {
      categoryId = expensesCategoryHelperMap[cat]!;
    }
    if(incomeCategoryHelperMap.containsKey(cat))
    {
      categoryId = incomeCategoryHelperMap[cat]!;
    }

    int doType = int.parse(map[typeColumn] ?? -1) ;

    if (doType == 0 || doType == 7) {
      if(categoryId == -1)
      {
        categoryId =inMod;
      }

      return MMTransaction.income(date: date, account: accountId, category: categoryId, amount: amount, currency: curr, description: desc);
    } else if (doType == 1) {
      if(categoryId == -1)
      {
        categoryId =outMod;
      }

      return MMTransaction.expense(date: date, account: accountId, category: categoryId, amount: amount, currency: curr,description: desc);
    } else if (doType == 3) {
      String destAsset = map[destinationGroupIdColumn];
      if(!accountHelperMap.containsKey(destAsset))
      {
        return MMTransaction.invalid();
      }
      int destAccountId = accountHelperMap[destAsset]!;
      return MMTransaction.transfer(date: date, account: accountId, dAccount: destAccountId, amount: amount, currency:curr, description: desc);

    } else {
      return MMTransaction.invalid();
    }
  }



}

