import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/transaction.dart';
import 'widgets/details_tile.dart';
import 'widgets/type_tab.dart';
import '../../providers/transactions_provider.dart';
import '../../constants/style.dart';
import '../../constants/functions.dart';

class AddPage extends ConsumerStatefulWidget {
  const AddPage({super.key});

  @override
  ConsumerState<AddPage> createState() => _AddPageState();
}

class _AddPageState extends ConsumerState<AddPage> with Functions {
  final TextEditingController amountController = TextEditingController();

  final List<String> _titleList = ['Income', 'Expense', 'Transfer'];

  @override
  Widget build(BuildContext context) {
    final trsncTypeList = ref.watch(transactionTypeList);
    final trnscTypes = ref.watch(transactionTypesProvider);
    final selectedType = trsncTypeList[trnscTypes.indexOf(true)];
    final selectedRecurringPay = ref.watch(selectedRecurringPayProvider);
    // I listen servono a evitare che il provider faccia il dispose subito dopo essere stato aggiornato
    ref.listen(amountProvider, (_, __) {});
    ref.listen(noteProvider, (_, __) {});

    return GestureDetector(
      // Serve a togliere il focus se si preme su altro
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancel',
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(color: blue5),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Text(
                            "New Transaction",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ),
                      const Expanded(flex: 1, child: SizedBox()),
                    ],
                  ),
                  const SizedBox(height: 34),
                  Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.background,
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: ToggleButtons(
                      direction: Axis.horizontal,
                      onPressed: (int index) {
                        List<bool> list = trnscTypes;
                        for (int i = 0; i < 3; i++) {
                          list[i] = i == index;
                        }
                        ref.read(transactionTypesProvider.notifier).state = [...list];
                      },
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      renderBorder: false,
                      selectedColor: Colors.transparent,
                      fillColor: Colors.transparent,
                      constraints: BoxConstraints(
                        minHeight: 26,
                        maxHeight: 26,
                        minWidth: (MediaQuery.of(context).size.width - 36) / 3,
                        maxWidth: (MediaQuery.of(context).size.width - 36) / 3,
                      ),
                      isSelected: trnscTypes,
                      children: List.generate(
                        trnscTypes.length,
                        (index) => TypeTab(
                          trnscTypes[index],
                          _titleList[index],
                          typeToColor(trsncTypeList[index]),
                        ),
                      ),
                    ),
                  ),
                  if (selectedType == Type.transfer)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: SizedBox(
                        height: 64,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Text(
                                    "FROM:",
                                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                                          color: grey1,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Material(
                                    child: InkWell(
                                      onTap: () => Navigator.of(context).pushNamed('/accountselect',
                                          arguments: bankAccountProvider),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: white,
                                          borderRadius: BorderRadius.circular(4),
                                          boxShadow: [defaultShadow],
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        child: Row(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Theme.of(context).colorScheme.secondary,
                                              ),
                                              padding: const EdgeInsets.all(4.0),
                                              child: const Icon(
                                                Icons.account_balance,
                                                color: white,
                                                size: 16,
                                              ),
                                            ),
                                            const Spacer(),
                                            Text(
                                              ref.watch(bankAccountProvider)!.name,
                                              style:
                                                  Theme.of(context).textTheme.bodySmall!.copyWith(
                                                        color: grey1,
                                                      ),
                                            ),
                                            const Spacer(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => ref.read(transactionsProvider.notifier).switchAccount(),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Expanded(child: VerticalDivider(width: 1, color: grey2)),
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 2, horizontal: 20),
                                    child: Icon(
                                      Icons.change_circle,
                                      size: 32,
                                      color: grey2,
                                    ),
                                  ),
                                  Expanded(child: VerticalDivider(width: 1, color: grey2)),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Text(
                                    "TO:",
                                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                                          color: grey1,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Material(
                                    child: InkWell(
                                      onTap: () => Navigator.of(context).pushNamed('/accountselect',
                                          arguments: toAccountProvider),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: white,
                                          borderRadius: BorderRadius.circular(4),
                                          boxShadow: [defaultShadow],
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.sort, color: grey2),
                                            const Spacer(),
                                            Text(
                                              ref.watch(toAccountProvider)?.name ??
                                                  "Select account",
                                              style:
                                                  Theme.of(context).textTheme.bodySmall!.copyWith(
                                                        color: grey1,
                                                      ),
                                            ),
                                            const Spacer(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: TextField(
                      controller: amountController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixText: ' ', // set to center the amount
                        suffixText: '€',
                        suffixStyle: Theme.of(context).textTheme.headlineMedium!.copyWith(
                              color: typeToColor(trsncTypeList[trnscTypes.indexOf(true)]),
                            ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[0,0-9,9]')),
                      ],
                      autofocus: true,
                      textAlign: TextAlign.center,
                      cursorColor: grey1,
                      style: TextStyle(
                        color: typeToColor(trsncTypeList[trnscTypes.indexOf(true)]),
                        fontSize: 58,
                        fontWeight: FontWeight.bold,
                      ),
                      onChanged: (value) =>
                          ref.read(amountProvider.notifier).state = currencyToNum(value),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                const SizedBox(height: 32),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    "DETAILS",
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
            Container(
              color: Theme.of(context).colorScheme.surface,
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  if (trsncTypeList[trnscTypes.indexOf(true)] != Type.transfer)
                    DetailsTile(
                      "Account",
                      Icons.account_balance_wallet,
                      () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        Navigator.of(context)
                            .pushNamed('/accountselect', arguments: bankAccountProvider);
                      },
                      value: ref.watch(bankAccountProvider)?.name,
                    ),
                  if (trsncTypeList[trnscTypes.indexOf(true)] != Type.transfer)
                    const Divider(height: 1, color: grey1),
                  if (trsncTypeList[trnscTypes.indexOf(true)] != Type.transfer)
                    DetailsTile(
                      "Category",
                      Icons.list_alt,
                      () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        Navigator.of(context).pushNamed('/categoryselect');
                      },
                      value: ref.watch(categoryProvider)?.name,
                    ),
                  if (trsncTypeList[trnscTypes.indexOf(true)] != Type.transfer)
                    const Divider(height: 1, color: grey1),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 32, 16),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Icon(
                              Icons.description,
                              size: 24.0,
                              color: Theme.of(context).colorScheme.background,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          "Notes",
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(color: Theme.of(context).colorScheme.primary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(border: InputBorder.none),
                            textAlign: TextAlign.end,
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(color: grey1),
                            onChanged: (value) => ref.read(noteProvider.notifier).state = value,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: grey1),
                  DetailsTile(
                    "Date",
                    Icons.calendar_month,
                    () => showCupertinoModalPopup(
                      context: context,
                      builder: (_) => Container(
                        height: 300,
                        color: white,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 300,
                              child: CupertinoDatePicker(
                                initialDateTime: ref.watch(dateProvider),
                                use24hFormat: true,
                                onDateTimeChanged: (date) =>
                                    ref.read(dateProvider.notifier).state = date,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    value: dateToString(ref.watch(dateProvider)),
                  ),
                  if (trsncTypeList[trnscTypes.indexOf(true)] == Type.expense)
                    const Divider(height: 1, color: grey1),
                  if (trsncTypeList[trnscTypes.indexOf(true)] == Type.expense)
                    ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Icon(
                            Icons.autorenew,
                            size: 24.0,
                            color: Theme.of(context).colorScheme.background,
                          ),
                        ),
                      ),
                      title: Text(
                        "Recurring payment",
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(color: Theme.of(context).colorScheme.primary),
                      ),
                      trailing: CupertinoSwitch(
                          value: selectedRecurringPay,
                          onChanged: (select) =>
                              ref.read(selectedRecurringPayProvider.notifier).state = select),
                    ),
                  if (selectedRecurringPay && selectedType == Type.expense)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.background,
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        onPressed: () => Navigator.of(context).pushNamed('/recurrenceselect'),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Interval",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(color: Theme.of(context).colorScheme.primary),
                            ),
                            const Spacer(),
                            Text(
                              recurrenceMap[ref.watch(intervalProvider)]!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(color: Theme.of(context).colorScheme.secondary),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.chevron_right,
                                color: Theme.of(context).colorScheme.secondary),
                          ],
                        ),
                      ),
                    ),
                  if (selectedRecurringPay && selectedType == Type.expense)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.background,
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        onPressed: () => null,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "End repetition",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(color: Theme.of(context).colorScheme.primary),
                            ),
                            const Spacer(),
                            Text(
                              "Never",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(color: Theme.of(context).colorScheme.secondary),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.chevron_right,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: blue1.withOpacity(0.15),
                      blurRadius: 5.0,
                      offset: const Offset(0, -1.0),
                    )
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    boxShadow: [defaultShadow],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextButton(
                    onPressed: () {
                      if (ref.read(amountProvider) != 0) {
                        ref
                            .read(transactionsProvider.notifier)
                            .addTransaction()
                            .whenComplete(() => Navigator.of(context).pop());
                      }
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      "ADD TRANSACTION",
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(color: Theme.of(context).colorScheme.background),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
