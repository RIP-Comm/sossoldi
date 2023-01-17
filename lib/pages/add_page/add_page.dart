import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  final List<Color> _colorList = [green, red, blue3];
  final List<String> _titleList = ['Income', 'Expense', 'Transfer'];

  @override
  Widget build(BuildContext context) {
    final trnscTypes = ref.watch(transactionTypesProvider);
    final selectedRecurringPay = ref.watch(selectedRecurringPayProvider);

    return SingleChildScrollView(
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
                        _colorList[index],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: TextField(
                    controller: amountController,
                    decoration: InputDecoration(
                      prefixText: ' ', // set to center the amount
                      border: InputBorder.none,
                      suffixText: '€',
                      suffixStyle: Theme.of(context).textTheme.headlineMedium!.copyWith(
                            color: trnscTypes[0] ? green : (trnscTypes[1] ? red : blue3),
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
                      color: trnscTypes[0] ? green : (trnscTypes[1] ? red : blue3),
                      fontSize: 58,
                      fontWeight: FontWeight.bold,
                    ),
                    onChanged: (value) {
                      print(ref.read(amountProvider));
                      ref.read(amountProvider.notifier).state = currencyToNum(value);
                      print(ref.read(amountProvider));
                    },
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
                DetailsTile(
                  bankAccountProvider,
                  "Account",
                  Icons.account_balance_wallet,
                  value: ref.watch(bankAccountProvider)?.name,
                ),
                const Divider(height: 1, color: grey1),
                DetailsTile(
                  categoryProvider,
                  "Category",
                  Icons.list_alt,
                  value: ref.watch(categoryProvider)?.name,
                ),
                const Divider(height: 1, color: grey1),
                DetailsTile(
                  noteProvider,
                  "Notes",
                  Icons.description,
                  value: ref.watch(noteProvider),
                ),
                const Divider(height: 1, color: grey1),
                DetailsTile(
                  dateProvider,
                  "Date",
                  Icons.calendar_month,
                  value: dateToString(ref.watch(dateProvider)),
                ),
                const Divider(height: 1, color: grey1),
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
                if (selectedRecurringPay)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                            "Interval",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(color: Theme.of(context).colorScheme.primary),
                          ),
                          const Spacer(),
                          Text(
                            "Monthly",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(color: Theme.of(context).colorScheme.secondary),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.secondary),
                        ],
                      ),
                    ),
                  ),
                if (selectedRecurringPay)
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
                          Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.secondary),
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
                  onPressed: () => ref
                        .read(transactionsProvider.notifier)
                        .addTransaction(currencyToNum(amountController.text))
                        .whenComplete(() => Navigator.of(context).pop()),
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
    );
  }
}
