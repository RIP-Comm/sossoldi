import 'package:flutter/material.dart';
import "package:flutter_riverpod/flutter_riverpod.dart";
import 'package:flutter/services.dart';

import "../../../constants/style.dart";
import "../../../constants/functions.dart";
import '../../../model/transaction.dart';
import '../../../providers/transactions_provider.dart';
import '../../../utils/decimal_text_input_formatter.dart';
import 'account_selector.dart';
import 'type_tab.dart';

class AmountSection extends ConsumerWidget with Functions {
  const AmountSection({
    required this.amountController,
    Key? key,
  }) : super(key: key);

  final TextEditingController amountController;

  static const List<String> _titleList = ['Income', 'Expense', 'Transfer'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trsncTypeList = ref.watch(transactionTypeList);
    final trnscTypes = ref.watch(transactionTypesProvider);
    final selectedType = trsncTypeList[trnscTypes.indexOf(true)];

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
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
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium!
                                .copyWith(
                                  color: grey1,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Material(
                            child: InkWell(
                              onTap: () {
                                FocusManager.instance.primaryFocus?.unfocus();
                                showModalBottomSheet(
                                  context: context,
                                  builder: (_) => AccountSelector(
                                    bankAccountProvider, // from
                                  ),
                                );
                              },
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
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
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
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
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
                      onTap: () => ref
                          .read(transactionsProvider.notifier)
                          .switchAccount(),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                              child: VerticalDivider(width: 1, color: grey2)),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 2, horizontal: 20),
                            child: Icon(
                              Icons.change_circle,
                              size: 32,
                              color: grey2,
                            ),
                          ),
                          Expanded(
                            child: VerticalDivider(width: 1, color: grey2),
                          ),
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
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium!
                                .copyWith(
                                  color: grey1,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Material(
                            child: InkWell(
                              onTap: () {
                                FocusManager.instance.primaryFocus?.unfocus();
                                showModalBottomSheet(
                                  context: context,
                                  builder: (_) => AccountSelector(
                                    bankAccountTransferProvider, // to
                                  ),
                                );
                              },
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
                                      ref
                                              .watch(
                                                  bankAccountTransferProvider)
                                              ?.name ??
                                          "Select account",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
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
                suffixStyle: Theme.of(context)
                    .textTheme
                    .headlineMedium!
                    .copyWith(color: typeToColor(selectedType)),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: <TextInputFormatter>[
                DecimalTextInputFormatter(decimalDigits: 2)
              ],
              autofocus: false,
              textAlign: TextAlign.center,
              cursorColor: grey1,
              style: TextStyle(
                color: typeToColor(selectedType),
                fontSize: 58,
                fontWeight: FontWeight.bold,
              ),
              onChanged: (value) => ref.read(amountProvider.notifier).state =
                  currencyToNum(value),
            ),
          ),
        ],
      ),
    );
  }
}
