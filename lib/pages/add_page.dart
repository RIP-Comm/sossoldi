import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/style.dart';

class AddPage extends ConsumerStatefulWidget {
  const AddPage({super.key, required this.controller});

  final ScrollController controller;

  @override
  ConsumerState<AddPage> createState() => _AddPageState();
}

class _AddPageState extends ConsumerState<AddPage> {
  // final List<bool> _selectedTransactionType = [false, true, false];
  final StateProvider _selectedTransactionType =
      StateProvider<List<bool>>((ref) => [false, true, false]);
  final StateProvider _selectedRecurringPay = StateProvider<bool>((ref) => false);
  final TextEditingController importController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final selectedTrnscType = ref.watch(_selectedTransactionType);
    final selectedRecurringPay = ref.watch(_selectedRecurringPay);

    return Stack(
      children: [
        SingleChildScrollView(
          controller: widget.controller,
          child: Column(
            children: [
              Container(
                color: Theme.of(context).colorScheme.surface,
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
                              style:
                                  Theme.of(context).textTheme.titleMedium!.copyWith(color: blue5),
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
                          List<bool> list = selectedTrnscType;
                          for (int i = 0; i < 3; i++) {
                            list[i] = i == index;
                          }
                          ref.read(_selectedTransactionType.notifier).state = [...list];
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
                        isSelected: selectedTrnscType,
                        children: [
                          typeWidget(context, selectedTrnscType[0], 'Income', green),
                          typeWidget(context, selectedTrnscType[1], 'Expense', red),
                          typeWidget(context, selectedTrnscType[2], 'Transfer', blue3),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                      child: TextField(
                        controller: importController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          suffixText: '€',
                          suffixStyle: Theme.of(context).textTheme.headlineMedium!.copyWith(
                              color: selectedTrnscType[0]
                                  ? green
                                  : (selectedTrnscType[1] ? red : blue3)),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[0,0-9,9]')),
                        ],
                        autofocus: true,
                        textAlign: TextAlign.center,
                        cursorColor: grey1,
                        style: TextStyle(
                          color:
                              selectedTrnscType[0] ? green : (selectedTrnscType[1] ? red : blue3),
                          fontSize: 58,
                          fontWeight: FontWeight.bold,
                        ),
                        onChanged: (value) {
                          print(value);
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
                            Icons.account_balance_wallet,
                            size: 24.0,
                            color: Theme.of(context).colorScheme.background,
                          ),
                        ),
                      ),
                      title: Text(
                        "Account",
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(color: Theme.of(context).colorScheme.primary),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "HYPE",
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(color: grey1),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.chevron_right, color: grey1),
                        ],
                      ),
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
                            Icons.list_alt,
                            size: 24.0,
                            color: Theme.of(context).colorScheme.background,
                          ),
                        ),
                      ),
                      title: Text(
                        "Category",
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(color: Theme.of(context).colorScheme.primary),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Casa, Luce",
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(color: grey1),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.chevron_right, color: grey1),
                        ],
                      ),
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
                            Icons.description,
                            size: 24.0,
                            color: Theme.of(context).colorScheme.background,
                          ),
                        ),
                      ),
                      title: Text(
                        "Notes",
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(color: Theme.of(context).colorScheme.primary),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Bolletta luce",
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(color: grey1),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.chevron_right, color: grey1),
                        ],
                      ),
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
                            Icons.calendar_month,
                            size: 24.0,
                            color: Theme.of(context).colorScheme.background,
                          ),
                        ),
                      ),
                      title: Text(
                        "Date",
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(color: Theme.of(context).colorScheme.primary),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Oggi, mer 11 gennaio",
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(color: grey1),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.chevron_right, color: grey1),
                        ],
                      ),
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
                      trailing: CupertinoSwitch(value: selectedRecurringPay, onChanged: (select) => ref.read(_selectedRecurringPay.notifier).state = select),
                    ),
                  ],
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
                onPressed: () => print("click"),
                style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
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
    );
  }
}

Widget typeWidget(context, selectedType, title, color) {
  return Container(
    height: 26,
    width: (MediaQuery.of(context).size.width - 36) / 3,
    decoration: BoxDecoration(
      color: selectedType ? color : white,
      borderRadius: const BorderRadius.all(Radius.circular(4)),
      boxShadow: selectedType ? [defaultShadow] : [],
    ),
    alignment: Alignment.center,
    child: Text(
      title,
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: selectedType ? white : color),
    ),
  );
}
