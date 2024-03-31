import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:flutter_riverpod/flutter_riverpod.dart";

import '../../../constants/functions.dart';
import "../../../constants/style.dart";
import '../../../model/transaction.dart';
import '../../../providers/currency_provider.dart';
import '../../../providers/transactions_provider.dart';
import 'account_selector.dart';
import 'type_tab.dart';

class AmountSection extends ConsumerStatefulWidget {
  const AmountSection(
    this.amountController, {
    super.key,
  });

  final TextEditingController amountController;

  @override
  ConsumerState<AmountSection> createState() => _AmountSectionState();
}

class _AmountSectionState extends ConsumerState<AmountSection> with Functions {
  static const List<String> _titleList = ['Income', 'Expense', 'Transfer'];

  List<bool> _typeToggleState = [false, true, false];

  @override
  void initState() {
    final selectedType = ref.read(transactionTypeProvider);
    setState(() {
      if (selectedType == TransactionType.income) {
        _typeToggleState = [true, false, false];
      } else if (selectedType == TransactionType.transfer) {
        _typeToggleState = [false, false, true];
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final trsncTypeList = ref.watch(transactionTypeList);
    final selectedType = ref.watch(transactionTypeProvider);
    final currencyState = ref.watch(currencyStateNotifier);

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
                List<bool> newSelection = [];
                for (TransactionType type in trsncTypeList) {
                  if (type == trsncTypeList[index]) {
                    newSelection.add(true);
                    ref.read(transactionTypeProvider.notifier).state = type;
                  } else {
                    newSelection.add(false);
                  }
                }
                setState(() => _typeToggleState = newSelection);
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
              isSelected: _typeToggleState,
              children: List.generate(
                _typeToggleState.length,
                (index) => TypeTab(
                  _typeToggleState[index],
                  _titleList[index],
                  typeToColor(trsncTypeList[index]),
                ),
              ),
            ),
          ),
          if (selectedType == TransactionType.transfer)
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
                              onTap: () {
                                FocusManager.instance.primaryFocus?.unfocus();
                                showModalBottomSheet(
                                  context: context,
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  isScrollControlled: true,
                                  useSafeArea: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10.0),
                                      topRight: Radius.circular(10.0),
                                    ),
                                  ),
                                  builder: (_) => DraggableScrollableSheet(
                                    expand: false,
                                    minChildSize: 0.5,
                                    initialChildSize: 0.7,
                                    maxChildSize: 0.9,
                                    builder: (_, controller) => AccountSelector(
                                      // from
                                      provider: bankAccountProvider,
                                      scrollController: controller,
                                    ),
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
                                      ref.watch(bankAccountProvider)?.name ?? "",
                                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
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
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(child: VerticalDivider(width: 1, color: grey2)),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 2, horizontal: 20),
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
                            style: Theme.of(context).textTheme.labelMedium!.copyWith(
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
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  isScrollControlled: true,
                                  useSafeArea: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10.0),
                                      topRight: Radius.circular(10.0),
                                    ),
                                  ),
                                  builder: (_) => DraggableScrollableSheet(
                                    expand: false,
                                    minChildSize: 0.5,
                                    initialChildSize: 0.7,
                                    maxChildSize: 0.9,
                                    builder: (_, controller) => AccountSelector(
                                      // to
                                      provider: bankAccountTransferProvider,
                                      scrollController: controller,
                                      fromAccount: ref.watch(bankAccountProvider)?.id,
                                    ),
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
                                      ref.watch(bankAccountTransferProvider)?.name ??
                                          "Select account",
                                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
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
              controller: widget.amountController,
              decoration: InputDecoration(
                hintText: "0",
                border: InputBorder.none,
                prefixText: ' ', // set to center the amount
                suffixText: currencyState.selectedCurrency.symbol,
                suffixStyle: Theme.of(context)
                    .textTheme
                    .headlineMedium!
                    .copyWith(color: typeToColor(selectedType)),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              // inputFormatters: [DecimalTextInputFormatter(decimalDigits: 2)],
              autofocus: false,
              textAlign: TextAlign.center,
              cursorColor: grey1,
              style: TextStyle(
                color: typeToColor(selectedType),
                fontSize: 58,
                fontWeight: FontWeight.bold,
              ),
              onTapOutside: (_){
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
