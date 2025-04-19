import 'package:flutter/material.dart';
import "package:flutter_riverpod/flutter_riverpod.dart";

import '../../../constants/constants.dart';
import "../../../constants/style.dart";
import '../../../ui/extensions.dart';
import '../../../ui/widgets/account_selector.dart';
import '../../../ui/widgets/amount_widget.dart';
import '../../../ui/widgets/rounded_icon.dart';
import '../../../models/transaction.dart';
import '../../../providers/transactions_provider.dart';
import '../../../ui/device.dart';
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

class _AmountSectionState extends ConsumerState<AmountSection> {
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

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          const SizedBox(height: Sizes.xxl),
          Container(
            height: 30,
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(Sizes.borderRadiusSmall)),
            padding: const EdgeInsets.symmetric(horizontal: Sizes.xxs * 0.5),
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
                ref.invalidate(bankAccountTransferProvider);
                setState(() => _typeToggleState = newSelection);
              },
              borderRadius: BorderRadius.circular(Sizes.borderRadiusSmall),
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
                  trsncTypeList[index].toColor(
                    brightness: Theme.of(context).brightness,
                  ),
                ),
              ),
            ),
          ),
          if (selectedType == TransactionType.transfer)
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(Sizes.lg, Sizes.sm, Sizes.lg, 0),
              child: SizedBox(
                height: Sizes.xxl * 2,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: Sizes.sm),
                          Text(
                            "FROM:",
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium!
                                .copyWith(
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? grey1
                                      : darkGrey1,
                                ),
                          ),
                          const SizedBox(height: Sizes.xxs * 0.5),
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
                                      topLeft:
                                          Radius.circular(Sizes.borderRadius),
                                      topRight:
                                          Radius.circular(Sizes.borderRadius),
                                    ),
                                  ),
                                  builder: (_) => DraggableScrollableSheet(
                                    expand: false,
                                    minChildSize: 0.5,
                                    initialChildSize: 0.7,
                                    maxChildSize: 0.9,
                                    builder: (_, controller) => AccountSelector(
                                      // from
                                      scrollController: controller,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                height: 35,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  borderRadius: BorderRadius.circular(
                                      Sizes.borderRadiusSmall),
                                  boxShadow: [defaultShadow],
                                ),
                                padding: const EdgeInsets.all(Sizes.xxs),
                                child: Row(
                                  children: [
                                    RoundedIcon(
                                      icon: ref
                                                  .watch(bankAccountProvider)
                                                  ?.symbol !=
                                              null
                                          ? accountIconList[ref
                                              .watch(bankAccountProvider)!
                                              .symbol]
                                          : null,
                                      backgroundColor: ref
                                                  .watch(bankAccountProvider)
                                                  ?.color !=
                                              null
                                          ? accountColorListTheme[ref
                                              .watch(bankAccountProvider)!
                                              .color]
                                          : null,
                                      size: 16,
                                      padding: EdgeInsets.all(Sizes.xs),
                                    ),
                                    const Spacer(),
                                    Text(
                                      ref.watch(bankAccountProvider)?.name ??
                                          "Select Account",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.light
                                                    ? grey1
                                                    : darkGrey1,
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
                                vertical: Sizes.xxs * 0.5,
                                horizontal: Sizes.xl),
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
                          const SizedBox(height: Sizes.sm),
                          Text(
                            "TO:",
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium!
                                .copyWith(
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? grey1
                                      : darkGrey1,
                                ),
                          ),
                          const SizedBox(height: Sizes.xxs * 0.5),
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
                                      topLeft:
                                          Radius.circular(Sizes.borderRadius),
                                      topRight:
                                          Radius.circular(Sizes.borderRadius),
                                    ),
                                  ),
                                  builder: (_) => DraggableScrollableSheet(
                                    expand: false,
                                    minChildSize: 0.5,
                                    initialChildSize: 0.7,
                                    maxChildSize: 0.9,
                                    builder: (_, controller) => AccountSelector(
                                      // to
                                      scrollController: controller,
                                      transfer: true,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                height: 35,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  borderRadius: BorderRadius.circular(
                                      Sizes.borderRadiusSmall),
                                  boxShadow: [defaultShadow],
                                ),
                                padding: const EdgeInsets.all(Sizes.xs),
                                child: Row(
                                  children: [
                                    RoundedIcon(
                                      icon: accountIconList[ref
                                          .watch(bankAccountTransferProvider)
                                          ?.symbol],
                                      backgroundColor: ref.watch(
                                                  bankAccountTransferProvider) !=
                                              null
                                          ? accountColorListTheme[ref
                                              .watch(
                                                  bankAccountTransferProvider)!
                                              .color]
                                          : null,
                                      size: 16,
                                      padding: EdgeInsets.all(Sizes.xs),
                                    ),
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
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.light
                                                    ? grey1
                                                    : darkGrey1,
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
          AmountWidget(widget.amountController),
        ],
      ),
    );
  }
}
